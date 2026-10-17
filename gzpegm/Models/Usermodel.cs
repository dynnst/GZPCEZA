using System.Collections.Generic;

namespace gzpegm.Models
{
    public class Usermodel
    {
        public List<tbl_TempUser> tempuser { get; set; }
        public List<E_User> user { get; set; }
        public List<E_Border> borders { get; set; }

        // Online kullanıcılar sadece UserViewModel üzerinden gösterilecek
        public List<UserViewModel> onlineUsers { get; set; }
        public List<E_User> teacherRequests { get; set; }

        // ✅ YENİ: Pasif/Aktif kullanıcılar
        public List<UserViewModel> inactiveUsers { get; set; }

        public Usermodel()
        {
            teacherRequests = teacherRequests ?? new List<E_User>();
            onlineUsers = onlineUsers ?? new List<UserViewModel>();
            inactiveUsers = inactiveUsers ?? new List<UserViewModel>();
            tempuser = tempuser ?? new List<tbl_TempUser>();
            user = user ?? new List<E_User>();
            borders = borders ?? new List<E_Border>();
        }
    }
}