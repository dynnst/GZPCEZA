using System;
using System.Collections.Generic;
using System.Web;

namespace gzpegm.Models.ViewModels
{
    public class CourseContentViewModel
    {
        public int ContentId { get; set; }
        public int CourseId { get; set; }
        public string ContentType { get; set; }    // Video, PDF, Doc, vb.
        public string ContentTitle { get; set; }
        public string ContentDescription { get; set; } // Yeni alan eklendi
        public string ContentHtml { get; set; } // HTML içerik düzenleme
        public HttpPostedFileBase FileUpload { get; set; } // Dosya yüklemek için

        // Bu liste eklendi:
        public List<CourseContentItemViewModel> Contents { get; set; }
    }

    public class CourseContentItemViewModel
    {
        public int ContentId { get; set; }
        public string ContentTitle { get; set; }
        public string ContentDescription { get; set; } // Yeni alan eklendi
        public string ContentType { get; set; }
        public string FilePath { get; set; }
        public DateTime? CreatedDate { get; set; }
    }
}
