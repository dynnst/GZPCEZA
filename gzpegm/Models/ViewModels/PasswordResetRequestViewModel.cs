using System;

namespace gzpegm.Models.ViewModels
{
    public class PasswordResetRequestViewModel
    {
        public int RequestId { get; set; }
        public int UserId { get; set; }
        public string Sicil { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public DateTime RequestedAt { get; set; }
        public string Status { get; set; }
    }
}
