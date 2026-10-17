SET XACT_ABORT ON;
BEGIN TRANSACTION;

IF EXISTS
(
    SELECT 1
    FROM dbo.Exam AS e
    LEFT JOIN dbo.Courses AS c ON c.CourseId = e.CourseId
    WHERE c.CourseId IS NULL
)
BEGIN
    ROLLBACK TRANSACTION;
    THROW 51000, 'FK_Exam_Courses eklenemedi: dbo.Exam tablosunda dbo.Courses ile eslesmeyen CourseId kayitlari var. Once bu kayitlari duzeltin.', 1;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Exam_CourseId'
      AND object_id = OBJECT_ID(N'dbo.Exam')
)
BEGIN
    CREATE INDEX IX_Exam_CourseId ON dbo.Exam(CourseId);
END;

IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Exam_Courses'
      AND parent_object_id = OBJECT_ID(N'dbo.Exam')
)
BEGIN
    ALTER TABLE dbo.Exam WITH CHECK
    ADD CONSTRAINT FK_Exam_Courses
        FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId);

    ALTER TABLE dbo.Exam CHECK CONSTRAINT FK_Exam_Courses;
END;

COMMIT TRANSACTION;
