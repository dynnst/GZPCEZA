using System.Collections.Generic;

namespace gzpegm.Models.ViewModels
{
    public class TahditStatisticsViewModel
    {
        public int TodayTotal { get; set; }
        public int AllTotal { get; set; }
        public List<TahditCodeStatItem> TodayByCode { get; set; }
        public List<TahditCodeStatItem> AllByCode { get; set; }
        public List<TahditBorderStatItem> TodayByBorder { get; set; }
        public List<TahditBorderStatItem> AllByBorder { get; set; }
        public List<TahditUserStatItem> TodayByUser { get; set; }
        public List<TahditUserStatItem> AllByUser { get; set; }

        public TahditStatisticsViewModel()
        {
            TodayByCode = new List<TahditCodeStatItem>();
            AllByCode = new List<TahditCodeStatItem>();
            TodayByBorder = new List<TahditBorderStatItem>();
            AllByBorder = new List<TahditBorderStatItem>();
            TodayByUser = new List<TahditUserStatItem>();
            AllByUser = new List<TahditUserStatItem>();
        }
    }

    public class TahditCodeStatItem
    {
        public string TahditCode { get; set; }
        public string IdariTahditCode { get; set; }
        public int Count { get; set; }
    }

    public class TahditBorderStatItem
    {
        public string Border { get; set; }
        public string TahditCode { get; set; }
        public string IdariTahditCode { get; set; }
        public int Count { get; set; }
    }

    public class TahditUserStatItem
    {
        public int? UserId { get; set; }
        public string UserSicil { get; set; }
        public string UserDisplayName { get; set; }
        public string Border { get; set; }
        public string TahditCode { get; set; }
        public string IdariTahditCode { get; set; }
        public int Count { get; set; }
    }
}
