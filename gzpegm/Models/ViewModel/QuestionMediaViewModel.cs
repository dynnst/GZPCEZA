namespace gzpegm.Models.ViewModels
{
    public class QuestionMediaViewModel
    {
        public int MediaId { get; set; }     // ✅ EKLENDİ
        public byte MediaType { get; set; }  // 1 = Resim, 2 = Video
        public string MediaPath { get; set; }
        public int SortOrder { get; set; }
    }
}
