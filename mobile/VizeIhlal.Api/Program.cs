using System.Security.Cryptography;
using System.Text.Json;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
    options.SerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
});

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.Services.AddSingleton<AuthStore>();
builder.Services.AddSingleton<SystemSettingsStore>();

var app = builder.Build();

app.UseCors();

app.MapGet("/", () => Results.Ok(new
{
    name = "Vize İhlal Test API",
    status = "ok",
    plans = PlanCatalog.All.Values
}));

app.MapPost("/auth/login", (LoginRequest request, AuthStore store) =>
{
    var user = store.FindUser(request.Email);
    if (user is null || !PasswordHasher.Verify(request.Password, user.PasswordHash))
    {
        return Results.Unauthorized();
    }

    var token = store.CreateSession(user.Id);
    return Results.Ok(AuthResponse.From(user, token));
});

app.MapPost("/auth/register", (RegisterRequest request, AuthStore store) =>
{
    if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
    {
        return Results.BadRequest(new { message = "E-posta ve şifre zorunludur." });
    }

    if (request.Password.Length < 6)
    {
        return Results.BadRequest(new { message = "Şifre en az 6 karakter olmalıdır." });
    }

    var normalizedPlan = PlanCatalog.Normalize(request.PlanCode ?? "standard");
    if (normalizedPlan is null)
    {
        return Results.BadRequest(new { message = "Geçersiz abonelik planı." });
    }

    var created = store.CreateUser(request.Email, request.Password, normalizedPlan);
    return created is null
        ? Results.Conflict(new { message = "Bu e-posta zaten kayıtlı." })
        : Results.Ok(AuthResponse.From(created, store.CreateSession(created.Id)));
});

app.MapGet("/me", (HttpRequest request, AuthStore store) =>
{
    var user = store.GetUserByBearer(request);
    return user is null
        ? Results.Unauthorized()
        : Results.Ok(UserResponse.From(user));
});

app.MapPost("/usage/consume", (HttpRequest request, AuthStore store) =>
{
    var user = store.GetUserByBearer(request);
    if (user is null)
    {
        return Results.Unauthorized();
    }

    var result = store.ConsumeDailyUsage(user);
    return result.Allowed
        ? Results.Ok(result)
        : Results.Json(result, statusCode: StatusCodes.Status402PaymentRequired);
});

app.MapGet("/admin/users", (HttpRequest httpRequest, AuthStore store) =>
{
    var admin = store.GetUserByBearer(httpRequest);
    if (admin is null)
    {
        return Results.Unauthorized();
    }

    if (admin.Role != "admin")
    {
        return Results.Forbid();
    }

    return Results.Ok(store.ListUsers().Select(UserResponse.From));
});

app.MapPost("/admin/assign-plan", (HttpRequest httpRequest, AssignPlanRequest request, AuthStore store) =>
{
    var admin = store.GetUserByBearer(httpRequest);
    if (admin is null)
    {
        return Results.Unauthorized();
    }

    if (admin.Role != "admin")
    {
        return Results.Forbid();
    }

    var normalizedPlan = PlanCatalog.Normalize(request.PlanCode);
    if (normalizedPlan is null)
    {
        return Results.BadRequest(new { message = "Geçersiz abonelik planı." });
    }

    var user = store.AssignPlan(request.Email, normalizedPlan, request.Days ?? 30);
    return user is null
        ? Results.NotFound(new { message = "Kullanıcı bulunamadı." })
        : Results.Ok(UserResponse.From(user));
});

app.MapGet("/system-settings", (SystemSettingsStore settingsStore) =>
{
    return Results.Ok(settingsStore.GetSettings());
});

app.MapPost("/system-settings", (HttpRequest httpRequest, SystemSettingsUpdateRequest request, AuthStore store, SystemSettingsStore settingsStore) =>
{
    var admin = store.GetUserByBearer(httpRequest);
    if (admin is null)
    {
        return Results.Unauthorized();
    }

    if (admin.Role != "admin")
    {
        return Results.Forbid();
    }

    var updated = settingsStore.UpdateSettings(request, admin.Email);
    return Results.Ok(updated);
});

app.MapGet("/system-settings/data", (IWebHostEnvironment environment) =>
{
    var dataDirectory = Path.Combine(environment.ContentRootPath, "Data");
    var filePath = Path.Combine(dataDirectory, "cezam_data.json");
    if (!File.Exists(filePath))
    {
        var fallbackPath = Path.Combine(environment.ContentRootPath, "..", "cezam_calculator", "assets", "cezam_data.json");
        if (File.Exists(fallbackPath))
        {
            return Results.File(fallbackPath, "application/json");
        }
        return Results.NotFound(new { message = "Sistem verisi henüz yüklenmemiş." });
    }
    return Results.File(filePath, "application/json");
});

app.MapPost("/system-settings/data", async (HttpRequest httpRequest, AuthStore store, IWebHostEnvironment environment) =>
{
    var admin = store.GetUserByBearer(httpRequest);
    if (admin is null)
    {
        return Results.Unauthorized();
    }

    if (admin.Role != "admin")
    {
        return Results.Forbid();
    }

    var dataDirectory = Path.Combine(environment.ContentRootPath, "Data");
    Directory.CreateDirectory(dataDirectory);
    var filePath = Path.Combine(dataDirectory, "cezam_data.json");

    using var reader = new StreamReader(httpRequest.Body);
    var content = await reader.ReadToEndAsync();
    if (string.IsNullOrWhiteSpace(content))
    {
        return Results.BadRequest(new { message = "Veri içeriği boş olamaz." });
    }

    await File.WriteAllTextAsync(filePath, content);
    return Results.Ok(new { success = true, message = "Sistem verileri (UVR, AUH, Tahdit) başarıyla kaydedildi.", updatedAt = DateTimeOffset.UtcNow });
});

app.Run();

sealed class AuthStore
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented = true
    };

    private readonly string _filePath;
    private readonly object _sync = new();
    private AuthDatabase _db;

    public AuthStore(IWebHostEnvironment environment)
    {
        var dataDirectory = Path.Combine(environment.ContentRootPath, "Data");
        Directory.CreateDirectory(dataDirectory);
        _filePath = Path.Combine(dataDirectory, "auth-store.json");
        _db = LoadOrSeed();
        EnsureRequiredUsers();
    }

    public UserAccount? FindUser(string email)
    {
        var normalized = NormalizeEmail(email);
        lock (_sync)
        {
            return _db.Users.FirstOrDefault(user => user.Email.Equals(normalized, StringComparison.OrdinalIgnoreCase));
        }
    }

    public UserAccount? CreateUser(string email, string password, string planCode)
    {
        var normalized = NormalizeEmail(email);
        lock (_sync)
        {
            if (_db.Users.Any(user => user.Email.Equals(normalized, StringComparison.OrdinalIgnoreCase)))
            {
                return null;
            }

            var user = NewUser(normalized, password, planCode, "user");
            _db.Users.Add(user);
            Save();
            return user;
        }
    }

    public string CreateSession(string userId)
    {
        lock (_sync)
        {
            var token = Base64Url(RandomNumberGenerator.GetBytes(32));
            _db.Sessions[token] = new SessionRecord(userId, DateTimeOffset.UtcNow.AddDays(30));
            Save();
            return token;
        }
    }

    public UserAccount? GetUserByBearer(HttpRequest request)
    {
        var authorization = request.Headers.Authorization.ToString();
        if (!authorization.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        var token = authorization["Bearer ".Length..].Trim();
        lock (_sync)
        {
            if (!_db.Sessions.TryGetValue(token, out var session) || session.ExpiresAtUtc <= DateTimeOffset.UtcNow)
            {
                return null;
            }

            return _db.Users.FirstOrDefault(user => user.Id == session.UserId);
        }
    }

    public UsageResponse ConsumeDailyUsage(UserAccount user)
    {
        lock (_sync)
        {
            var latest = _db.Users.First(current => current.Id == user.Id);
            var plan = PlanCatalog.All[latest.PlanCode];
            var today = TodayInTurkey();
            var usage = latest.UsageByDate.GetValueOrDefault(today, 0);
            var subscriptionActive = latest.SubscriptionExpiresAtUtc > DateTimeOffset.UtcNow;

            if (latest.Role == "admin")
            {
                return UsageResponse.AdminAllowedResult(latest, plan, usage, today);
            }

            if (!subscriptionActive)
            {
                return UsageResponse.Denied(latest, plan, usage, today, "Abonelik süresi dolmuş.");
            }

            if (usage >= plan.DailyLimit)
            {
                return UsageResponse.Denied(latest, plan, usage, today, "Günlük sorgu hakkı dolmuş.");
            }

            usage += 1;
            latest.UsageByDate[today] = usage;
            Save();
            return UsageResponse.AllowedResult(latest, plan, usage, today);
        }
    }

    public UserAccount? AssignPlan(string email, string planCode, int days)
    {
        var normalized = NormalizeEmail(email);
        lock (_sync)
        {
            var user = _db.Users.FirstOrDefault(current => current.Email.Equals(normalized, StringComparison.OrdinalIgnoreCase));
            if (user is null)
            {
                return null;
            }

            user.PlanCode = planCode;
            user.SubscriptionExpiresAtUtc = DateTimeOffset.UtcNow.AddDays(Math.Clamp(days, 1, 365));
            Save();
            return user;
        }
    }

    public IReadOnlyList<UserAccount> ListUsers()
    {
        lock (_sync)
        {
            return _db.Users
                .OrderByDescending(user => user.Role == "admin")
                .ThenBy(user => user.Email)
                .Select(user => new UserAccount
                {
                    Id = user.Id,
                    Email = user.Email,
                    PasswordHash = "",
                    PlanCode = user.PlanCode,
                    Role = user.Role,
                    SubscriptionExpiresAtUtc = user.SubscriptionExpiresAtUtc,
                    UsageByDate = new Dictionary<string, int>(user.UsageByDate)
                })
                .ToList();
        }
    }

    private AuthDatabase LoadOrSeed()
    {
        if (File.Exists(_filePath))
        {
            var existing = File.ReadAllText(_filePath);
            return JsonSerializer.Deserialize<AuthDatabase>(existing, JsonOptions) ?? SeedDatabase();
        }

        var seeded = SeedDatabase();
        File.WriteAllText(_filePath, JsonSerializer.Serialize(seeded, JsonOptions));
        return seeded;
    }

    private static AuthDatabase SeedDatabase()
    {
        return new AuthDatabase
        {
            Users =
            [
                NewUser("admin@test.local", "123456", "gold", "admin"),
                NewUser("standard@test.local", "123456", "standard", "user"),
                NewUser("gumus@test.local", "123456", "silver", "user"),
                NewUser("altin@test.local", "123456", "gold", "user")
            ]
        };
    }

    private void EnsureRequiredUsers()
    {
        var changed = false;
        foreach (var user in _db.Users.Where(user => string.IsNullOrWhiteSpace(user.Role)))
        {
            user.Role = "user";
            changed = true;
        }

        if (!_db.Users.Any(user => user.Email.Equals("admin@test.local", StringComparison.OrdinalIgnoreCase)))
        {
            _db.Users.Add(NewUser("admin@test.local", "123456", "gold", "admin"));
            changed = true;
        }

        if (changed)
        {
            Save();
        }
    }

    private static UserAccount NewUser(string email, string password, string planCode, string role)
    {
        return new UserAccount
        {
            Id = Guid.NewGuid().ToString("N"),
            Email = NormalizeEmail(email),
            PasswordHash = PasswordHasher.Hash(password),
            PlanCode = planCode,
            Role = role,
            SubscriptionExpiresAtUtc = DateTimeOffset.UtcNow.AddDays(30)
        };
    }

    private void Save()
    {
        File.WriteAllText(_filePath, JsonSerializer.Serialize(_db, JsonOptions));
    }

    private static string NormalizeEmail(string email)
    {
        return email.Trim().ToLowerInvariant();
    }

    private static string TodayInTurkey()
    {
        TimeZoneInfo timeZone;
        try
        {
            timeZone = TimeZoneInfo.FindSystemTimeZoneById("Turkey Standard Time");
        }
        catch (TimeZoneNotFoundException)
        {
            timeZone = TimeZoneInfo.FindSystemTimeZoneById("Europe/Istanbul");
        }

        return TimeZoneInfo.ConvertTime(DateTimeOffset.UtcNow, timeZone).ToString("yyyy-MM-dd");
    }

    private static string Base64Url(byte[] bytes)
    {
        return Convert.ToBase64String(bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_');
    }
}

static class PlanCatalog
{
    public static readonly IReadOnlyDictionary<string, SubscriptionPlan> All = new Dictionary<string, SubscriptionPlan>
    {
        ["standard"] = new("standard", "Standart", 1),
        ["silver"] = new("silver", "Gümüş", 3),
        ["gold"] = new("gold", "Altın", 5)
    };

    public static string? Normalize(string? planCode)
    {
        if (string.IsNullOrWhiteSpace(planCode))
        {
            return null;
        }

        var normalized = planCode.Trim().ToLowerInvariant();
        return All.ContainsKey(normalized) ? normalized : null;
    }
}

static class PasswordHasher
{
    private const int SaltSize = 16;
    private const int HashSize = 32;
    private const int Iterations = 100_000;

    public static string Hash(string password)
    {
        var salt = RandomNumberGenerator.GetBytes(SaltSize);
        var hash = Rfc2898DeriveBytes.Pbkdf2(password, salt, Iterations, HashAlgorithmName.SHA256, HashSize);
        return $"{Iterations}.{Convert.ToBase64String(salt)}.{Convert.ToBase64String(hash)}";
    }

    public static bool Verify(string password, string stored)
    {
        var parts = stored.Split('.');
        if (parts.Length != 3 || !int.TryParse(parts[0], out var iterations))
        {
            return false;
        }

        var salt = Convert.FromBase64String(parts[1]);
        var expected = Convert.FromBase64String(parts[2]);
        var actual = Rfc2898DeriveBytes.Pbkdf2(password, salt, iterations, HashAlgorithmName.SHA256, expected.Length);
        return CryptographicOperations.FixedTimeEquals(actual, expected);
    }
}

sealed record LoginRequest(string Email, string Password);
sealed record RegisterRequest(string Email, string Password, string? PlanCode);
sealed record AssignPlanRequest(string Email, string PlanCode, int? Days);
sealed record SubscriptionPlan(string Code, string Name, int DailyLimit);
sealed record SessionRecord(string UserId, DateTimeOffset ExpiresAtUtc);

sealed class AuthDatabase
{
    public List<UserAccount> Users { get; set; } = [];
    public Dictionary<string, SessionRecord> Sessions { get; set; } = [];
}

sealed class UserAccount
{
    public string Id { get; set; } = "";
    public string Email { get; set; } = "";
    public string PasswordHash { get; set; } = "";
    public string PlanCode { get; set; } = "standard";
    public string Role { get; set; } = "user";
    public DateTimeOffset SubscriptionExpiresAtUtc { get; set; }
    public Dictionary<string, int> UsageByDate { get; set; } = [];
}

sealed record UserResponse(
    string Email,
    string Role,
    bool IsAdmin,
    string PlanCode,
    string PlanName,
    int DailyLimit,
    DateTimeOffset SubscriptionExpiresAtUtc)
{
    public static UserResponse From(UserAccount user)
    {
        var plan = PlanCatalog.All[user.PlanCode];
        var isAdmin = user.Role == "admin";
        return new UserResponse(user.Email, user.Role, isAdmin, plan.Code, isAdmin ? "Admin" : plan.Name, isAdmin ? 0 : plan.DailyLimit, user.SubscriptionExpiresAtUtc);
    }
}

sealed record AuthResponse(
    string Token,
    string Email,
    string Role,
    bool IsAdmin,
    string PlanCode,
    string PlanName,
    int DailyLimit,
    DateTimeOffset SubscriptionExpiresAtUtc)
{
    public static AuthResponse From(UserAccount user, string token)
    {
        var plan = PlanCatalog.All[user.PlanCode];
        var isAdmin = user.Role == "admin";
        return new AuthResponse(token, user.Email, user.Role, isAdmin, plan.Code, isAdmin ? "Admin" : plan.Name, isAdmin ? 0 : plan.DailyLimit, user.SubscriptionExpiresAtUtc);
    }
}

sealed record UsageResponse(
    bool Allowed,
    string Message,
    string Email,
    string Role,
    bool IsAdmin,
    string PlanCode,
    string PlanName,
    int DailyLimit,
    int UsedToday,
    int RemainingToday,
    string UsageDate,
    DateTimeOffset SubscriptionExpiresAtUtc)
{
    public static UsageResponse AllowedResult(UserAccount user, SubscriptionPlan plan, int usedToday, string usageDate)
    {
        return new UsageResponse(
            true,
            "Sorgu hakkı kullanıldı.",
            user.Email,
            user.Role,
            user.Role == "admin",
            plan.Code,
            plan.Name,
            plan.DailyLimit,
            usedToday,
            Math.Max(0, plan.DailyLimit - usedToday),
            usageDate,
            user.SubscriptionExpiresAtUtc);
    }

    public static UsageResponse AdminAllowedResult(UserAccount user, SubscriptionPlan plan, int usedToday, string usageDate)
    {
        return new UsageResponse(
            true,
            "Admin sinirsiz sorgu hakki.",
            user.Email,
            user.Role,
            true,
            plan.Code,
            "Admin",
            0,
            usedToday,
            0,
            usageDate,
            user.SubscriptionExpiresAtUtc);
    }

    public static UsageResponse Denied(UserAccount user, SubscriptionPlan plan, int usedToday, string usageDate, string message)
    {
        return new UsageResponse(
            false,
            message,
            user.Email,
            user.Role,
            user.Role == "admin",
            plan.Code,
            plan.Name,
            plan.DailyLimit,
            usedToday,
            Math.Max(0, plan.DailyLimit - usedToday),
            usageDate,
            user.SubscriptionExpiresAtUtc);
    }
}

sealed record SystemSettingsUpdateRequest(
    double? Usd,
    double? Eur,
    double? Gbp,
    double? SingleEntryVisaFee,
    double? DefterPrice
);

sealed class SystemSettingsModel
{
    public double Usd { get; set; } = 33.50;
    public double Eur { get; set; } = 36.20;
    public double Gbp { get; set; } = 43.10;
    public double SingleEntryVisaFee { get; set; } = 3100.0;
    public double DefterPrice { get; set; } = 565.0;
    public string UpdatedAt { get; set; } = "";
    public string UpdatedBy { get; set; } = "system";
}

sealed class SystemSettingsStore
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented = true
    };

    private readonly string _filePath;
    private readonly object _sync = new();
    private SystemSettingsModel _settings;

    public SystemSettingsStore(IWebHostEnvironment environment)
    {
        var dataDirectory = Path.Combine(environment.ContentRootPath, "Data");
        Directory.CreateDirectory(dataDirectory);
        _filePath = Path.Combine(dataDirectory, "system-settings.json");
        _settings = LoadOrSeed();
    }

    public SystemSettingsModel GetSettings()
    {
        lock (_sync)
        {
            return _settings;
        }
    }

    public SystemSettingsModel UpdateSettings(SystemSettingsUpdateRequest request, string adminEmail)
    {
        lock (_sync)
        {
            if (request.Usd.HasValue && request.Usd.Value > 0)
                _settings.Usd = request.Usd.Value;

            if (request.Eur.HasValue && request.Eur.Value > 0)
                _settings.Eur = request.Eur.Value;

            if (request.Gbp.HasValue && request.Gbp.Value > 0)
                _settings.Gbp = request.Gbp.Value;

            if (request.SingleEntryVisaFee.HasValue && request.SingleEntryVisaFee.Value >= 0)
                _settings.SingleEntryVisaFee = request.SingleEntryVisaFee.Value;

            if (request.DefterPrice.HasValue && request.DefterPrice.Value >= 0)
                _settings.DefterPrice = request.DefterPrice.Value;

            _settings.UpdatedAt = DateTimeOffset.UtcNow.ToString("o");
            _settings.UpdatedBy = adminEmail;

            File.WriteAllText(_filePath, JsonSerializer.Serialize(_settings, JsonOptions));
            return _settings;
        }
    }

    private SystemSettingsModel LoadOrSeed()
    {
        if (File.Exists(_filePath))
        {
            try
            {
                var json = File.ReadAllText(_filePath);
                return JsonSerializer.Deserialize<SystemSettingsModel>(json, JsonOptions) ?? CreateDefaultSettings();
            }
            catch
            {
                return CreateDefaultSettings();
            }
        }

        var defaults = CreateDefaultSettings();
        File.WriteAllText(_filePath, JsonSerializer.Serialize(defaults, JsonOptions));
        return defaults;
    }

    private static SystemSettingsModel CreateDefaultSettings() => new()
    {
        Usd = 33.50,
        Eur = 36.20,
        Gbp = 43.10,
        SingleEntryVisaFee = 3100.0,
        DefterPrice = 565.0,
        UpdatedAt = DateTimeOffset.UtcNow.ToString("o"),
        UpdatedBy = "system"
    };
}

