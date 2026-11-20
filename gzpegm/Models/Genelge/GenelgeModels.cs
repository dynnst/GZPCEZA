using System;
using System.Collections.Generic;

namespace gzpegm.Models.Genelge
{
    public class GenelgeItem
    {
        public string Id { get; set; }
        public string Title { get; set; }
        public string FileName { get; set; }
        public string RelativePath { get; set; }
        public string FolderPath { get; set; }
        public string FolderTitle { get; set; }
        public string Extension { get; set; }
        public long FileSize { get; set; }
        public string FormattedSize { get; set; }
        public DateTime Date { get; set; }
        public string FormattedDate { get; set; }
        public string CategoryTag { get; set; }
        public bool IsPdf { get; set; }
        public bool IsImage { get; set; }
        public bool IsOffice { get; set; }
        public bool IsTiff { get; set; }
        public int TiffPageCount { get; set; }
        public string IconClass { get; set; }

        // Gizli Belge & Yetkilendirme
        public bool IsConfidential { get; set; }
        public string ConfidentialReason { get; set; }
        public bool LockedByAdmin { get; set; }
        public string LockedByUserName { get; set; }
        public bool CanCurrentUserUnlock { get; set; }
        public bool UserHasAccess { get; set; }
        public bool HasPendingRequest { get; set; }
    }

    public class GenelgeFolderItem
    {
        public string FolderPath { get; set; }
        public string FolderName { get; set; }
        public string CleanTitle { get; set; }
        public DateTime? ParsedDate { get; set; }
        public DateTime? LatestFileDate { get; set; }
        public int FileCount { get; set; }
        public string CategoryTag { get; set; }
        public bool IsConfidential { get; set; }
        public bool LockedByAdmin { get; set; }
        public bool CanCurrentUserUnlock { get; set; }
        public bool UserHasAccess { get; set; }
        public List<GenelgeItem> Files { get; set; } = new List<GenelgeItem>();
    }

    public class GenelgeAccessRequestItem
    {
        public int Id { get; set; }
        public string ItemIdentifier { get; set; }
        public string ItemTitle { get; set; }
        public int UserId { get; set; }
        public string UserSicil { get; set; }
        public string UserName { get; set; }
        public DateTime RequestDate { get; set; }
        public string FormattedRequestDate { get; set; }
        public string Reason { get; set; }
        public string Status { get; set; } // 'Bekliyor', 'Onaylandi', 'Reddedildi'
        public DateTime? ExpiryDate { get; set; }
        public string FormattedExpiryDate { get; set; }
        public string ReviewNote { get; set; }
    }

    public class GenelgePortalViewModel
    {
        public int TotalFolderCount { get; set; }
        public int TotalDocumentCount { get; set; }
        public string TotalSizeFormatted { get; set; }
        public List<GenelgeFolderItem> TopCategories { get; set; } = new List<GenelgeFolderItem>();
        public List<GenelgeItem> RecentDocuments { get; set; } = new List<GenelgeItem>();
        public string RootPath { get; set; }
        public bool RootExists { get; set; }
        public bool IsAdmin { get; set; }
        public bool CanManage { get; set; } // Admin veya Eğitimci
        public string UserDisplayName { get; set; }
        public string UserSicil { get; set; }
        public string UserIp { get; set; }
        public Dictionary<string, int> TagCounts { get; set; } = new Dictionary<string, int>();

        // Talepler ve Onaylananlar
        public int PendingRequestCount { get; set; }
        public List<GenelgeAccessRequestItem> AccessRequests { get; set; } = new List<GenelgeAccessRequestItem>();
        public List<GenelgeAccessRequestItem> ApprovedRequests { get; set; } = new List<GenelgeAccessRequestItem>();
    }

    public class GenelgeSearchResult
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public int TotalMatches { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public int TotalPages { get; set; }
        public List<GenelgeItem> Items { get; set; } = new List<GenelgeItem>();
    }

    public class CountryDocumentResult
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public string Country { get; set; }
        public int TotalCount { get; set; }
        public List<GenelgeItem> Documents { get; set; } = new List<GenelgeItem>();
        public object VisaRegime { get; set; }
        public decimal DailyPrice { get; set; }
    }

    public class CountryDocCountItem
    {
        public string Country { get; set; }
        public int Count { get; set; }
    }
}
