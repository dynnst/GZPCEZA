namespace gzpegm.Migrations
{
    using System.Data.Entity.Migrations;

    public partial class UpdateDatabaseSchema : DbMigration
    {
        public override void Up()
        {
            // Varolan tablolarý kontrol et ve eksik olanlarý oluþtur

            // 1. __MigrationHistory - EF Migration yönetimi için (otomatik)
            CreateTable(
                "dbo.__MigrationHistory",
                c => new
                {
                    MigrationId = c.String(nullable: false, maxLength: 255),
                    Model = c.Binary(nullable: false),
                    ProductVersion = c.String(nullable: false, maxLength: 32),
                })
                .PrimaryKey(t => t.MigrationId);

            // 2. Airline Tablosu
            CreateTable(
                "dbo.Airline",
                c => new
                {
                    Id = c.Int(nullable: false, identity: true),
                    IATACode = c.String(nullable: false, maxLength: 7),
                    Name = c.String(nullable: false, maxLength: 150),
                    Country = c.String(maxLength: 100),
                    IsActive = c.Boolean(nullable: false),
                    IsUserDefined = c.Boolean(),
                    CreatedDate = c.DateTime(),
                })
                .PrimaryKey(t => t.Id);

            // 3. Categories Tablosu
            CreateTable(
                "dbo.Categories",
                c => new
                {
                    CategoryId = c.Int(nullable: false, identity: true),
                    CategoryName = c.String(nullable: false, maxLength: 200),
                    Description = c.String(),
                    IsActive = c.Boolean(nullable: false),
                })
                .PrimaryKey(t => t.CategoryId);

            // 4. E_User Tablosu (diðer tablolarýn ana referansý)
            CreateTable(
                "dbo.E_User",
                c => new
                {
                    fldId = c.Int(nullable: false, identity: true),
                    fldSicil = c.String(),
                    fldName = c.String(),
                    fldLastName = c.String(),
                    fldPhone = c.String(),
                    fldEmail = c.String(),
                    fldTitle = c.String(),
                    fldDeputy = c.String(),
                    fldPicture = c.String(),
                    fldAuth = c.String(),
                    fldSubAuth = c.String(),
                    fldPassword = c.String(),
                    fldDateTime = c.DateTime(),
                    fldBorder = c.String(),
                    fldActive = c.String(maxLength: 1, fixedLength: true),
                    Role = c.String(nullable: false, maxLength: 20),
                    LastLogin = c.DateTime(),
                    XP = c.Int(nullable: false),
                    Level = c.Int(nullable: false),
                    IsActive = c.Boolean(),
                    TeacherRequestStatus = c.Byte(),
                    TeacherRequestDate = c.DateTime(),
                })
                .PrimaryKey(t => t.fldId);

            // 5. Courses Tablosu
            CreateTable(
                "dbo.Courses",
                c => new
                {
                    CourseId = c.Int(nullable: false, identity: true),
                    CourseTitle = c.String(nullable: false, maxLength: 200),
                    CourseDescription = c.String(),
                    CoverImage = c.String(),
                    CreatedBy = c.Int(nullable: false),
                    CreatedDate = c.DateTime(),
                    CategoryId = c.Int(nullable: false),
                    ResourceFile = c.String(),
                    IsActive = c.Boolean(nullable: false),
                    IsDeleted = c.Boolean(),
                })
                .PrimaryKey(t => t.CourseId)
                .ForeignKey("dbo.Categories", t => t.CategoryId, cascadeDelete: false)
                .ForeignKey("dbo.E_User", t => t.CreatedBy, cascadeDelete: false)
                .Index(t => t.CreatedBy)
                .Index(t => t.CategoryId);

            // 6. Exam Tablosu
            CreateTable(
                "dbo.Exam",
                c => new
                {
                    ExamId = c.Int(nullable: false, identity: true),
                    CourseId = c.Int(nullable: false),
                    Title = c.String(nullable: false, maxLength: 200),
                    Description = c.String(),
                    DurationMinutes = c.Int(),
                    PassingScore = c.Int(),
                    IsActive = c.Boolean(nullable: false),
                    CreatedAt = c.DateTime(nullable: false),
                    IsArchived = c.Boolean(),
                })
                .PrimaryKey(t => t.ExamId)
                .ForeignKey("dbo.Courses", t => t.CourseId, cascadeDelete: true)
                .Index(t => t.CourseId);

            // 7. ExamResult Tablosu
            CreateTable(
                "dbo.ExamResult",
                c => new
                {
                    ExamResultId = c.Int(nullable: false, identity: true),
                    ExamId = c.Int(nullable: false),
                    UserId = c.Int(),
                    Score = c.Decimal(nullable: true, precision: 5, scale: 2),
                    StartedAt = c.DateTime(),
                    FinishedAt = c.DateTime(),
                    Status = c.Byte(nullable: false),
                })
                .PrimaryKey(t => t.ExamResultId)
                .ForeignKey("dbo.Exam", t => t.ExamId, cascadeDelete: true)
                .Index(t => t.ExamId);

            // 8. Question Tablosu
            CreateTable(
                "dbo.Question",
                c => new
                {
                    QuestionId = c.Int(nullable: false, identity: true),
                    ExamId = c.Int(nullable: false),
                    Text = c.String(nullable: false),
                    QuestionType = c.Byte(nullable: false),
                    Points = c.Int(nullable: false),
                    SortOrder = c.Int(nullable: false),
                    IsActive = c.Boolean(nullable: false),
                })
                .PrimaryKey(t => t.QuestionId)
                .ForeignKey("dbo.Exam", t => t.ExamId, cascadeDelete: true)
                .Index(t => t.ExamId);

            // 9. QuestionOption Tablosu
            CreateTable(
                "dbo.QuestionOption",
                c => new
                {
                    OptionId = c.Int(nullable: false, identity: true),
                    QuestionId = c.Int(nullable: false),
                    Text = c.String(nullable: false),
                    IsCorrect = c.Boolean(nullable: false),
                    SortOrder = c.Int(nullable: false),
                })
                .PrimaryKey(t => t.OptionId)
                .ForeignKey("dbo.Question", t => t.QuestionId, cascadeDelete: true)
                .Index(t => t.QuestionId);

            // 10. QuestionMedia Tablosu
            CreateTable(
                "dbo.QuestionMedia",
                c => new
                {
                    MediaId = c.Int(nullable: false, identity: true),
                    QuestionId = c.Int(nullable: false),
                    MediaType = c.Byte(nullable: false),
                    MediaPath = c.String(nullable: false),
                    SortOrder = c.Int(nullable: false),
                    CreatedAt = c.DateTime(nullable: false),
                })
                .PrimaryKey(t => t.MediaId)
                .ForeignKey("dbo.Question", t => t.QuestionId, cascadeDelete: true)
                .Index(t => t.QuestionId);

            // 11. Answer Tablosu
            CreateTable(
                "dbo.Answer",
                c => new
                {
                    AnswerId = c.Int(nullable: false, identity: true),
                    ExamResultId = c.Int(nullable: false),
                    QuestionId = c.Int(nullable: false),
                    OptionId = c.Int(),
                    TextAnswer = c.String(),
                })
                .PrimaryKey(t => t.AnswerId)
                .ForeignKey("dbo.ExamResult", t => t.ExamResultId, cascadeDelete: true)
                .ForeignKey("dbo.Question", t => t.QuestionId, cascadeDelete: true)
                .ForeignKey("dbo.QuestionOption", t => t.OptionId, cascadeDelete: false)
                .Index(t => t.ExamResultId)
                .Index(t => t.QuestionId)
                .Index(t => t.OptionId);

            // 12. CourseContents Tablosu
            CreateTable(
                "dbo.CourseContents",
                c => new
                {
                    ContentId = c.Int(nullable: false, identity: true),
                    CourseId = c.Int(nullable: false),
                    ContentType = c.String(nullable: false, maxLength: 20),
                    ContentTitle = c.String(maxLength: 200),
                    FilePath = c.String(nullable: false, maxLength: 500),
                    CreatedDate = c.DateTime(),
                    ContentDescription = c.String(),
                })
                .PrimaryKey(t => t.ContentId)
                .ForeignKey("dbo.Courses", t => t.CourseId, cascadeDelete: true)
                .Index(t => t.CourseId);

            // 13. CourseEnrollments Tablosu
            CreateTable(
                "dbo.CourseEnrollments",
                c => new
                {
                    EnrollmentId = c.Int(nullable: false, identity: true),
                    CourseId = c.Int(nullable: false),
                    UserId = c.Int(nullable: false),
                    EnrollmentDate = c.DateTime(),
                    IsDrawEntry = c.Boolean(nullable: false),
                    DrawEntryDate = c.DateTime(),
                })
                .PrimaryKey(t => t.EnrollmentId)
                .ForeignKey("dbo.Courses", t => t.CourseId, cascadeDelete: false)
                .ForeignKey("dbo.E_User", t => t.UserId, cascadeDelete: true)
                .Index(t => t.CourseId)
                .Index(t => t.UserId);

            // 14. CourseReviews Tablosu
            CreateTable(
                "dbo.CourseReviews",
                c => new
                {
                    ReviewId = c.Int(nullable: false, identity: true),
                    CourseId = c.Int(nullable: false),
                    UserId = c.Int(nullable: false),
                    Rating = c.Byte(nullable: false),
                    Comment = c.String(),
                    CreatedDate = c.DateTime(nullable: false),
                    IsApproved = c.Boolean(nullable: false),
                    ApprovedBy = c.Int(),
                    ApprovedDate = c.DateTime(),
                })
                .PrimaryKey(t => t.ReviewId)
                .ForeignKey("dbo.Courses", t => t.CourseId, cascadeDelete: true)
                .ForeignKey("dbo.E_User", t => t.UserId, cascadeDelete: false)
                .ForeignKey("dbo.E_User", t => t.ApprovedBy, cascadeDelete: false)
                .Index(t => t.CourseId)
                .Index(t => t.UserId)
                .Index(t => t.ApprovedBy);

            // 15. Certificate Tablosu
            CreateTable(
                "dbo.Certificate",
                c => new
                {
                    CertificateId = c.Int(nullable: false, identity: true),
                    UserId = c.Int(nullable: false),
                    CourseId = c.Int(nullable: false),
                    ExamResultId = c.Int(),
                    CertificateNumber = c.String(nullable: false, maxLength: 50),
                    FilePath = c.String(maxLength: 500),
                    IssuedDate = c.DateTime(nullable: false),
                    Score = c.Int(nullable: false),
                    IsActive = c.Boolean(nullable: false),
                    CreatedAt = c.DateTime(nullable: false),
                })
                .PrimaryKey(t => t.CertificateId)
                .ForeignKey("dbo.E_User", t => t.UserId, cascadeDelete: false)
                .ForeignKey("dbo.Courses", t => t.CourseId, cascadeDelete: false)
                .ForeignKey("dbo.ExamResult", t => t.ExamResultId, cascadeDelete: false)
                .Index(t => t.UserId)
                .Index(t => t.CourseId)
                .Index(t => t.ExamResultId);

            // 16. CertificateRequest Tablosu
            CreateTable(
                "dbo.CertificateRequest",
                c => new
                {
                    RequestId = c.Int(nullable: false, identity: true),
                    UserId = c.Int(nullable: false),
                    CourseId = c.Int(nullable: false),
                    RequestDate = c.DateTime(nullable: false),
                    Status = c.Byte(nullable: false),
                    AdminNote = c.String(maxLength: 500),
                    ProcessedDate = c.DateTime(),
                    ProcessedBy = c.Int(),
                })
                .PrimaryKey(t => t.RequestId);

            // 17. DocumentTerms Tablosu
            CreateTable(
                "dbo.DocumentTerms",
                c => new
                {
                    Id = c.Int(nullable: false, identity: true),
                    Term = c.String(nullable: false, maxLength: 200),
                    Slug = c.String(nullable: false, maxLength: 250),
                    Category = c.String(nullable: false, maxLength: 100),
                    Definition = c.String(nullable: false),
                    DetailedDescription = c.String(),
                    ImageUrl = c.String(maxLength: 500),
                    RelatedTerms = c.String(maxLength: 500),
                    IsActive = c.Boolean(nullable: false),
                    CreatedAt = c.DateTime(),
                    UpdatedAt = c.DateTime(),
                    Sicil = c.String(maxLength: 50),
                    AdSoyad = c.String(maxLength: 200),
                })
                .PrimaryKey(t => t.Id);

            // 18. E_Messages Tablosu
            CreateTable(
                "dbo.E_Messages",
                c => new
                {
                    fldId = c.Int(nullable: false, identity: true),
                    fldSendByName = c.String(),
                    fldSendBySicil = c.String(),
                    fldSendByPhone = c.String(),
                    fldSendByMail = c.String(),
                    fldDateTime = c.DateTime(),
                    fldMessage = c.String(),
                    fldSenderId = c.Int(),
                    fldSenderRole = c.String(maxLength: 20),
                    fldRecipientId = c.Int(),
                    fldRecipientRole = c.String(maxLength: 20),
                    fldSubject = c.String(maxLength: 200),
                    fldIsRead = c.Boolean(nullable: false),
                    fldReadDateTime = c.DateTime(),
                    fldIsDeletedBySender = c.Boolean(nullable: false),
                    fldIsDeletedByRecipient = c.Boolean(nullable: false),
                    fldParentMessageId = c.Int(),
                    fldIsReply = c.Boolean(nullable: false),
                    fldIsApproved = c.Boolean(nullable: false),
                    fldApprovedBy = c.Int(),
                    fldApprovedDateTime = c.DateTime(),
                })
                .PrimaryKey(t => t.fldId)
                .ForeignKey("dbo.E_User", t => t.fldSenderId, cascadeDelete: false)
                .ForeignKey("dbo.E_User", t => t.fldRecipientId, cascadeDelete: false)
                .ForeignKey("dbo.E_Messages", t => t.fldParentMessageId, cascadeDelete: false)
                .Index(t => t.fldSenderId)
                .Index(t => t.fldRecipientId)
                .Index(t => t.fldParentMessageId);

            // 19. E_AUH Tablosu (Yabancý Uyruklu Hazýrlýk)
            CreateTable(
                "dbo.E_AUH",
                c => new
                {
                    fldId = c.Int(nullable: false, identity: true),
                    fldCountry = c.String(),
                    fldFirstMounth = c.String(),
                    fldKat = c.String(),
                    fldDayStart = c.String(),
                    fldDayKat = c.String(),
                    fldToM = c.String(),
                })
                .PrimaryKey(t => t.fldId);

            // 20. E_Border Tablosu
            CreateTable(
                "dbo.E_Border",
                c => new
                {
                    fldId = c.Int(nullable: false, identity: true),
                    fldName = c.String(),
                })
                .PrimaryKey(t => t.fldId);

            // 21. E_Defter Tablosu
            CreateTable(
                "dbo.E_Defter",
                c => new
                {
                    fldId = c.Int(nullable: false, identity: true),
                    fldPrice = c.String(maxLength: 25),
                    fldTypeofMoney = c.String(maxLength: 50),
                })
                .PrimaryKey(t => t.fldId);

            // 22. E_Exchange Tablosu
            CreateTable(
                "dbo.E_Exchange",
                c => new
                {
                    fldId = c.Int(nullable: false, identity: true),
                    fldEuro = c.String(maxLength: 50),
                    fldDollar = c.String(maxLength: 50),
                    fldPaund = c.String(maxLength: 50),
                })
                .PrimaryKey(t => t.fldId);

            // 23. E_Forms Tablosu
            CreateTable(
                "dbo.E_Forms",
                c => new
                {
                    fldId = c.Int(nullable: false, identity: true),
                    fldGB = c.String(),
                    fldDE = c.String(),
                    fldRU = c.String(),
                    fldIR = c.String(),
                    fldGBC = c.String(),
                    fldDEC = c.String(),
                    fldRUC = c.String(),
                    fldIRC = c.String(),
                    fldIRKC = c.String(),
                    fldIRK = c.String(),
                    fldFransizca = c.String(),
                    fldFransizcaC = c.String(),
                })
                .PrimaryKey(t => t.fldId);

            // 24. E_History Tablosu
            CreateTable(
                "dbo.E_History",
                c => new
                {
                    fldId = c.Int(nullable: false, identity: true),
                    fldStart = c.DateTime(),
                    fldShouldExit = c.DateTime(),
                    fldBirthDate = c.DateTime(),
                    fldCountry = c.String(),
                    fldPenalty = c.String(),
                    fldPMoney = c.String(),
                    fldUser = c.String(),
                    fldBorder = c.String(),
                    fldDatetime = c.DateTime(),
                })
                .PrimaryKey(t => t.fldId);

            // 25. E_Inad Tablosu (Ýnadý Geçiþler)
            CreateTable(
                "dbo.E_Inad",
                c => new
                {
                    InadId = c.Int(nullable: false, identity: true),
                    TarihSaat = c.DateTime(),
                    AdSoyad = c.String(maxLength: 50, fixedLength: true),
                    DogumT = c.DateTime(),
                    DogumY = c.String(maxLength: 50),
                    Cinsiyet = c.String(maxLength: 10),
                    Uyruk = c.String(maxLength: 250, fixedLength: true),
                    PasaportNo = c.String(maxLength: 20, fixedLength: true),
                    BelgeNo = c.String(maxLength: 20),
                    PasaportTuru = c.String(maxLength: 50, fixedLength: true),
                    Beyan = c.String(maxLength: 100),
                    GelenUcusNo = c.String(maxLength: 10),
                    GelenHavayolu = c.String(maxLength: 150),
                    GeldigiYer = c.String(maxLength: 250, fixedLength: true),
                    GeldigiTarihSaat = c.DateTime(),
                    InadSebepAciklama = c.String(),
                    InadSebep = c.String(),
                    GidenHavayolu = c.String(maxLength: 150),
                    GidisUcusNo = c.String(maxLength: 10),
                    GidisYer = c.String(maxLength: 250, fixedLength: true),
                    GidisTarihSaat = c.DateTime(),
                    Personel = c.String(),
                    UstAramaEsya = c.String(),
                    UcagaNakil = c.String(),
                    OzelGuvenlik = c.String(maxLength: 50),
                    YerHizmetleriPersonel = c.String(maxLength: 50),
                    YerHizmetleri = c.String(maxLength: 250, fixedLength: true),
                    Refakat = c.String(maxLength: 250),
                    Kapi = c.String(),
                    Valilik = c.String(),
                    Durum = c.String(),
                    Sicil = c.String(),
                })
                .PrimaryKey(t => t.InadId);

            // 26. E_IsK Tablosu (Ýþ Aranacak)
            CreateTable(
                "dbo.E_IsK",
                c => new
                {
                    fldId = c.Int(nullable: false, identity: true),
                    fldDatetime = c.DateTime(),
                    fldName = c.String(),
                    fldPassport = c.String(),
                    fldIdn = c.String(),
                    fldOrgin = c.String(),
                    fldBirthdate = c.DateTime(),
                    fldForm = c.String(),
                    fldPassControl = c.String(),
                    fldApproval = c.String(),
                    fldBorder = c.String(),
                    fldVisa = c.String(),
                    fldPMoney = c.String(),
                    fldPicture = c.String(),
                })
                .PrimaryKey(t => t.fldId);

            // 27. E_Sartli Tablosu (Þartlý Geçiþler)
            CreateTable(
                "dbo.E_Sartli",
                c => new
                {
                    fldId = c.Int(nullable: false, identity: true),
                    fldBy = c.String(maxLength: 150, unicode: false),
                    fldOrgin = c.String(maxLength: 50),
                    fldBdate = c.DateTime(),
                    fldDate = c.DateTime(),
                    fldName = c.String(maxLength: 250),
                    fldBorder = c.String(maxLength: 500),
                })
                .PrimaryKey(t => t.fldId);

            // 28. E_TGVH Tablosu (Turist Gümrük Vergisi)
            CreateTable(
                "dbo.E_TGVH",
                c => new
                {
                    fldId = c.Int(nullable: false, identity: true),
                    fldPrice = c.String(maxLength: 25),
                    fldTypeofMoney = c.String(maxLength: 25),
                    fldYear = c.String(maxLength: 25),
                })
                .PrimaryKey(t => t.fldId);

            // 29. E_TKOD Tablosu (Tahdit Kodu)
            CreateTable(
                "dbo.E_TKOD",
                c => new
                {
                    fldId = c.Int(nullable: false, identity: true),
                    fldCode = c.String(maxLength: 50),
                    fldPTime = c.String(maxLength: 50),
                    fldStart = c.Int(),
                    fldFinish = c.Int(),
                    fldIdariCode = c.String(maxLength: 50),
                    fldPaid = c.Byte(),
                })
                .PrimaryKey(t => t.fldId);

            // 30. E_Token Tablosu
            CreateTable(
                "dbo.E_Token",
                c => new
                {
                    fldId = c.Int(nullable: false, identity: true),
                    fldUserId = c.Int(),
                    fldToken = c.String(),
                    fldDateTime = c.DateTime(),
                    fldIp = c.String(maxLength: 50),
                })
                .PrimaryKey(t => t.fldId);

            // 31. E_UVR Tablosu (Ülke Vize Kurallarý)
            CreateTable(
                "dbo.E_UVR",
                c => new
                {
                    fldId = c.Int(nullable: false, identity: true),
                    fldCountry = c.String(),
                    fldCalculateType = c.Int(),
                    fldPassportType = c.Int(),
                    fldVisaStatus = c.Int(),
                    fldDay = c.Int(),
                    fldLong = c.Int(),
                    fldOneTime = c.Int(),
                    fldHB = c.Byte(),
                })
                .PrimaryKey(t => t.fldId);

            // 32. TahditKod Tablosu
            CreateTable(
                "dbo.TahditKod",
                c => new
                {
                    Id = c.Int(nullable: false, identity: true),
                    Kod = c.String(nullable: false, maxLength: 20),
                    Aciklama = c.String(nullable: false, maxLength: 500),
                    SureAy = c.Int(),
                    Aktif = c.Boolean(nullable: false),
                    GirisGelirse = c.String(),
                    CikisGelirse = c.String(),
                    TahditMedia = c.String(),
                })
                .PrimaryKey(t => t.Id);

            // 33. tbl_TempUser Tablosu
            CreateTable(
                "dbo.tbl_TempUser",
                c => new
                {
                    fldId = c.Int(nullable: false, identity: true),
                    fldSicil = c.String(),
                    fldName = c.String(),
                    fldLastName = c.String(),
                    fldPhone = c.String(),
                    fldEmail = c.String(),
                    fldTitle = c.String(),
                    fldDeputy = c.String(),
                })
                .PrimaryKey(t => t.fldId);

            // Ek indeksler
            CreateIndex("dbo.E_User", "fldEmail");
            CreateIndex("dbo.E_User", "fldSicil");
            CreateIndex("dbo.Courses", "CourseTitle");
            CreateIndex("dbo.Exam", "CourseId");
            CreateIndex("dbo.ExamResult", "ExamId");
            CreateIndex("dbo.Question", "ExamId");
        }

        public override void Down()
        {
            // Drop Foreign Keys
            DropForeignKey("dbo.E_Messages", "fldParentMessageId", "dbo.E_Messages");
            DropForeignKey("dbo.E_Messages", "fldRecipientId", "dbo.E_User");
            DropForeignKey("dbo.E_Messages", "fldSenderId", "dbo.E_User");
            DropForeignKey("dbo.CourseReviews", "ApprovedBy", "dbo.E_User");
            DropForeignKey("dbo.CourseReviews", "UserId", "dbo.E_User");
            DropForeignKey("dbo.CourseReviews", "CourseId", "dbo.Courses");
            DropForeignKey("dbo.CourseEnrollments", "UserId", "dbo.E_User");
            DropForeignKey("dbo.CourseEnrollments", "CourseId", "dbo.Courses");
            DropForeignKey("dbo.Certificate", "ExamResultId", "dbo.ExamResult");
            DropForeignKey("dbo.Certificate", "CourseId", "dbo.Courses");
            DropForeignKey("dbo.Certificate", "UserId", "dbo.E_User");
            DropForeignKey("dbo.CourseContents", "CourseId", "dbo.Courses");
            DropForeignKey("dbo.Answer", "OptionId", "dbo.QuestionOption");
            DropForeignKey("dbo.Answer", "QuestionId", "dbo.Question");
            DropForeignKey("dbo.Answer", "ExamResultId", "dbo.ExamResult");
            DropForeignKey("dbo.QuestionMedia", "QuestionId", "dbo.Question");
            DropForeignKey("dbo.QuestionOption", "QuestionId", "dbo.Question");
            DropForeignKey("dbo.ExamResult", "ExamId", "dbo.Exam");
            DropForeignKey("dbo.Question", "ExamId", "dbo.Exam");
            DropForeignKey("dbo.Exam", "CourseId", "dbo.Courses");
            DropForeignKey("dbo.Courses", "CreatedBy", "dbo.E_User");
            DropForeignKey("dbo.Courses", "CategoryId", "dbo.Categories");

            // Drop Indexes
            DropIndex("dbo.E_Messages", new[] { "fldParentMessageId" });
            DropIndex("dbo.E_Messages", new[] { "fldRecipientId" });
            DropIndex("dbo.E_Messages", new[] { "fldSenderId" });
            DropIndex("dbo.CourseReviews", new[] { "ApprovedBy" });
            DropIndex("dbo.CourseReviews", new[] { "UserId" });
            DropIndex("dbo.CourseReviews", new[] { "CourseId" });
            DropIndex("dbo.CourseEnrollments", new[] { "UserId" });
            DropIndex("dbo.CourseEnrollments", new[] { "CourseId" });
            DropIndex("dbo.Certificate", new[] { "ExamResultId" });
            DropIndex("dbo.Certificate", new[] { "CourseId" });
            DropIndex("dbo.Certificate", new[] { "UserId" });
            DropIndex("dbo.CourseContents", new[] { "CourseId" });
            DropIndex("dbo.Answer", new[] { "OptionId" });
            DropIndex("dbo.Answer", new[] { "QuestionId" });
            DropIndex("dbo.Answer", new[] { "ExamResultId" });
            DropIndex("dbo.QuestionMedia", new[] { "QuestionId" });
            DropIndex("dbo.QuestionOption", new[] { "QuestionId" });
            DropIndex("dbo.ExamResult", new[] { "ExamId" });
            DropIndex("dbo.Question", new[] { "ExamId" });
            DropIndex("dbo.Exam", new[] { "CourseId" });
            DropIndex("dbo.Courses", new[] { "CategoryId" });
            DropIndex("dbo.Courses", new[] { "CreatedBy" });

            // Drop Tables
            DropTable("dbo.tbl_TempUser");
            DropTable("dbo.TahditKod");
            DropTable("dbo.E_UVR");
            DropTable("dbo.E_Token");
            DropTable("dbo.E_TKOD");
            DropTable("dbo.E_TGVH");
            DropTable("dbo.E_Sartli");
            DropTable("dbo.E_IsK");
            DropTable("dbo.E_Inad");
            DropTable("dbo.E_History");
            DropTable("dbo.E_Forms");
            DropTable("dbo.E_Exchange");
            DropTable("dbo.E_Defter");
            DropTable("dbo.E_Border");
            DropTable("dbo.E_AUH");
            DropTable("dbo.E_Messages");
            DropTable("dbo.DocumentTerms");
            DropTable("dbo.CertificateRequest");
            DropTable("dbo.Certificate");
            DropTable("dbo.CourseReviews");
            DropTable("dbo.CourseEnrollments");
            DropTable("dbo.CourseContents");
            DropTable("dbo.Answer");
            DropTable("dbo.QuestionMedia");
            DropTable("dbo.QuestionOption");
            DropTable("dbo.Question");
            DropTable("dbo.ExamResult");
            DropTable("dbo.Exam");
            DropTable("dbo.Courses");
            DropTable("dbo.E_User");
            DropTable("dbo.Categories");
            DropTable("dbo.Airline");
            DropTable("dbo.__MigrationHistory");
        }
    }
}

