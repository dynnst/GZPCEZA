using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace gzpegm.Models
{
    public class DocumentTermsViewModel
    {
        [Required(ErrorMessage = "Terim adý zorunludur")]
        [MaxLength(255)]
        [Display(Name = "Terim Adý")]
        public string Term { get; set; }

        [MaxLength(255)]
        [Display(Name = "Slug")]
        public string Slug { get; set; }

        [Required(ErrorMessage = "Kategori seçiniz")]
        [MaxLength(100)]
        [Display(Name = "Kategori")]
        public string Category { get; set; }

        [Required(ErrorMessage = "Taným zorunludur")]
        [Display(Name = "Taným")]
        public string Definition { get; set; }

        [Display(Name = "Ayrýntýlý Açýklama")]
        public string DetailedDescription { get; set; }

        [MaxLength(500)]
        [Display(Name = "Resim URL")]
        public string ImageUrl { get; set; }

        [MaxLength(500)]
        [Display(Name = "Ýliþkili Terimler")]
        public string RelatedTerms { get; set; }

        [Display(Name = "Doðrulama Ýpuçlarý")]
        public string VerificationTips { get; set; }

        [Display(Name = "Aktif")]
        public bool IsActive { get; set; } = true;

        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }

        // Kategori yönetimi için
        public List<string> Categories { get; set; } = new List<string>();
        public string NewCategoryName { get; set; }
        public bool IsNewCategory { get; set; }
    }
}