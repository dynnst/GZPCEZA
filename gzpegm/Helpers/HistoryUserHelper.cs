using System;

namespace gzpegm.Helpers
{
    public static class HistoryUserHelper
    {
        // fldUser storage format (new): "{fldSicil}|{DisplayName}". Old records may be just "DisplayName".
        // fldSicil is stable and never changes, prefer it as grouping key.
        public static string ExtractSicil(string fldUser)
        {
            if (string.IsNullOrWhiteSpace(fldUser)) return null;
            var idx = fldUser.IndexOf('|');
            if (idx <= 0) return null;
            var prefix = fldUser.Substring(0, idx).Trim();
            return string.IsNullOrEmpty(prefix) ? null : prefix;
        }

        public static string GetDisplayName(string fldUser)
        {
            if (string.IsNullOrWhiteSpace(fldUser)) return string.Empty;
            var idx = fldUser.IndexOf('|');
            if (idx >= 0 && idx + 1 < fldUser.Length)
                return fldUser.Substring(idx + 1).Trim();
            return fldUser.Trim();
        }

        // Grouping key: prefer stable fldSicil when present, otherwise use normalized display name
        public static string GetGroupingKey(string fldUser)
        {
            var sicil = ExtractSicil(fldUser);
            if (!string.IsNullOrEmpty(sicil)) return "sicil:" + sicil;
            return GetDisplayName(fldUser).ToLowerInvariant();
        }
    }
}
