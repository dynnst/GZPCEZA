using System.Collections.Generic;

namespace gzpegm.Models.ViewModels
{
    public class OldOperationsIndexViewModel
    {
        public bool CanSeeAdminOperations { get; set; }
        public List<OldOperationLinkViewModel> GeneralOperations { get; set; } = new List<OldOperationLinkViewModel>();
        public List<OldOperationLinkViewModel> AdminOperations { get; set; } = new List<OldOperationLinkViewModel>();
    }

    public class OldOperationLinkViewModel
    {
        public string Group { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Url { get; set; }
        public string Icon { get; set; }
    }
}
