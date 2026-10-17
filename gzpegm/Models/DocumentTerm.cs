using System;
using System.ComponentModel.DataAnnotations;

namespace gzpegm.Models
{
    public class DocumentTerm
    {
        [Key]
        public int Id { get; set; }

        [Required, StringLength(200)]
        public string Term { get; set; }

        [Required, StringLength(250)]
        public string Slug { get; set; }

        [Required, StringLength(100)]
        public string Category { get; set; }

        [Required]
        public string Definition { get; set; }

        public string DetailedDescription { get; set; }

        [StringLength(500)]
        public string ImageUrl { get; set; }

        [StringLength(500)]
        public string RelatedTerms { get; set; }

        public bool IsActive { get; set; }

        public DateTime? CreatedAt { get; set; }

        public DateTime? UpdatedAt { get; set; }

        [StringLength(50)]
        public string Sicil { get; set; }

        [StringLength(200)]
        public string AdSoyad { get; set; }
    }
}