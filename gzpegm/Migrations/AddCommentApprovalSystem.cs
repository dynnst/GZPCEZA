namespace gzpegm.Migrations
{
    using System.Data.Entity.Migrations;

    /// <summary>
    /// Migration: Kullanýcý Yorumlarý Admin Onay Sistemi
    /// Açýklama: E_Messages tablosuna onay alanlarý eklenir
    /// </summary>
    public partial class AddCommentApprovalSystem : DbMigration
    {
        public override void Up()
        {
            // fldIsApproved alaný ekle
            AddColumn("dbo.E_Messages", "fldIsApproved", c => c.Boolean(nullable: false, defaultValue: false));

            // fldApprovedBy alaný ekle
            AddColumn("dbo.E_Messages", "fldApprovedBy", c => c.Int());

            // fldApprovedDateTime alaný ekle
            AddColumn("dbo.E_Messages", "fldApprovedDateTime", c => c.DateTime());

            // Ýndeks oluþtur: Hýzlý sorgulama için
            CreateIndex("dbo.E_Messages", new[] { "fldIsApproved", "fldDateTime" }, name: "IX_E_Messages_IsApproved");
        }

        public override void Down()
        {
            // Ýndeks sil
            DropIndex("dbo.E_Messages", "IX_E_Messages_IsApproved");

            // Alanlarý sil
            DropColumn("dbo.E_Messages", "fldApprovedDateTime");
            DropColumn("dbo.E_Messages", "fldApprovedBy");
            DropColumn("dbo.E_Messages", "fldIsApproved");
        }
    }
}
