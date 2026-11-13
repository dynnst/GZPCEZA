using System;
using System.Collections.Generic;

namespace gzpegm.Models.ViewModels
{
    public class ProfileSample
    {
        public int Id { get; set; }
        public DateTime? Date { get; set; }
        public string Name { get; set; }
        public string Nationality { get; set; }
        public string Visa { get; set; }
        public string Penalty { get; set; }
    }

    public class ProfileBorderStat
    {
        public string Border { get; set; }
        public int Count { get; set; }
        public decimal Sum { get; set; }
        public string MostActiveDay { get; set; }
        public List<ProfileSample> Samples { get; set; }
    }
}
