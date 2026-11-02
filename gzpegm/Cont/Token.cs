using gzpegm.Models;
using System;
using System.Linq;
using System.Web;

namespace gzpegm.Cont
{
    public class Token
    {
        public void RemoveToken(int fldUserId)
        {
            try
            {
                using (GZPEGM1 context = new GZPEGM1())
                {
                    var token = context.E_Token.Where(sc => sc.fldUserId == fldUserId).ToList();
                    if (token != null)
                    {
                        foreach (var t in token)
                        {
                            if (!string.IsNullOrEmpty(t.fldToken) && HttpRuntime.Cache != null)
                            {
                                var trimmed = t.fldToken.Trim();
                                HttpRuntime.Cache.Remove("CurrentToken:" + trimmed);
                                if (trimmed.Contains("+"))
                                    HttpRuntime.Cache.Remove("CurrentToken:" + trimmed.Replace("+", " "));
                                if (trimmed.Contains(" "))
                                    HttpRuntime.Cache.Remove("CurrentToken:" + trimmed.Replace(" ", "+"));
                            }
                        }
                        context.E_Token.RemoveRange(token);
                        context.SaveChanges();
                    }
                }
            }
            catch (Exception exp)
            {
                throw new Exception("Hata Silinemedi - " + exp.Message.ToString(), exp);
            }
        }
        public void AddToken(int UserId, string Token, DateTime dt, string Ip)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    var check = GetToken(Token);
                    if (check == null)
                    {
                        var token = new E_Token();
                        token.fldUserId = UserId;
                        token.fldToken = Token;
                        token.fldDateTime = dt;
                        token.fldIp = Ip;

                        _db.E_Token.Add(token);
                        _db.SaveChanges();

                        // Oturum tokenini hemen bellek onbellegine sliding expiration (4 saat) ile al
                        if (HttpRuntime.Cache != null)
                        {
                            var sKey = "CurrentToken:" + Token.Trim();
                            HttpRuntime.Cache.Insert(sKey, token, null, System.Web.Caching.Cache.NoAbsoluteExpiration, TimeSpan.FromHours(4));
                        }
                    }
                    else
                    {
                        RemoveToken(Convert.ToInt32(check.fldUserId));
                        var token = new E_Token();
                        token.fldUserId = UserId;
                        token.fldToken = Token;
                        token.fldDateTime = dt;
                        token.fldIp = Ip;
                        _db.E_Token.Add(token);
                        _db.SaveChanges();

                        if (HttpRuntime.Cache != null)
                        {
                            var sKey = "CurrentToken:" + Token.Trim();
                            HttpRuntime.Cache.Insert(sKey, token, null, System.Web.Caching.Cache.NoAbsoluteExpiration, TimeSpan.FromHours(4));
                        }
                    }

                }
            }
            catch (Exception exp)
            {
                throw new Exception("Hata Eklenemedi - " + exp.Message.ToString(), exp);
            }
        }
        public E_Token GetToken(string Token)
        {
            if (string.IsNullOrWhiteSpace(Token))
                return null;

            var tokenValue = Token.Trim();
            var cacheKey = "CurrentToken:" + tokenValue;

            // 1. Aynı istek içi önbellek
            var items = HttpContext.Current?.Items;
            if (items != null && items.Contains(cacheKey))
                return items[cacheKey] as E_Token;

            // 2. Sayfalar arası bellek önbelleği (5 dakika - SQL sorgusu yapmaz)
            var cached = HttpRuntime.Cache?[cacheKey] as E_Token;
            if (cached != null)
            {
                if (items != null) items[cacheKey] = cached;
                return cached;
            }

            using (GZPEGM1 _db = new GZPEGM1())
            {
                var token = _db.E_Token.FirstOrDefault(c => c.fldToken == tokenValue);
                if (token == null && tokenValue.Contains(" "))
                {
                    var plusVal = tokenValue.Replace(" ", "+");
                    token = _db.E_Token.FirstOrDefault(c => c.fldToken == plusVal);
                }
                if (token == null && (tokenValue.Contains("%") || tokenValue.Contains("+")))
                {
                    try
                    {
                        var decoded = HttpUtility.UrlDecode(tokenValue);
                        if (decoded != tokenValue)
                        {
                            token = _db.E_Token.FirstOrDefault(c => c.fldToken == decoded);
                        }
                    }
                    catch { }
                }

                if (token != null && HttpRuntime.Cache != null)
                {
                    // Sliding expiration: Kullanici sitede islem yaptikca onbellek suresi 4 saat kaydirilir.
                    HttpRuntime.Cache.Insert(
                        cacheKey,
                        token,
                        null,
                        System.Web.Caching.Cache.NoAbsoluteExpiration,
                        TimeSpan.FromHours(4));

                    if (!string.IsNullOrEmpty(token.fldToken))
                    {
                        var dbKey = "CurrentToken:" + token.fldToken.Trim();
                        if (dbKey != cacheKey)
                        {
                            HttpRuntime.Cache.Insert(
                                dbKey,
                                token,
                                null,
                                System.Web.Caching.Cache.NoAbsoluteExpiration,
                                TimeSpan.FromHours(4));
                        }
                    }
                }

                if (items != null)
                    items[cacheKey] = token;

                return token;
            }
        }

    }
}
