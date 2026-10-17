using System;
using System.Web;
using System.Web.Caching;

namespace gzpegm.Services
{
    public class CacheService
    {
        private static Cache cache = HttpRuntime.Cache;

        /// <summary>
        /// Cache'e veri ekle
        /// </summary>
        public static void Set<T>(string key, T value, int durationMinutes = 30)
        {
            if (cache != null)
            {
                cache.Insert(
                    key,
                    value,
                    null,
                    DateTime.Now.AddMinutes(durationMinutes),
                    Cache.NoSlidingExpiration,
                    CacheItemPriority.Normal,
                    null
                );
            }
        }

        /// <summary>
        /// Cache'den veri al
        /// </summary>
        public static T Get<T>(string key)
        {
            if (cache != null)
            {
                var item = cache.Get(key);
                return item != null ? (T)item : default(T);
            }
            return default(T);
        }

        /// <summary>
        /// Cache'de var mı kontrol et
        /// </summary>
        public static bool Exists(string key)
        {
            return cache != null && cache.Get(key) != null;
        }

        /// <summary>
        /// Cache'den sil
        /// </summary>
        public static void Remove(string key)
        {
            if (cache != null)
            {
                cache.Remove(key);
            }
        }

        /// <summary>
        /// Tüm cache'i temizle
        /// </summary>
        public static void Clear()
        {
            if (cache != null)
            {
                var enumerator = cache.GetEnumerator();
                while (enumerator.MoveNext())
                {
                    cache.Remove(enumerator.Key.ToString());
                }
            }
        }

        /// <summary>
        /// Cache'den al, yoksa oluştur
        /// </summary>
        public static T GetOrCreate<T>(string key, Func<T> createItem, int durationMinutes = 30)
        {
            if (Exists(key))
            {
                return Get<T>(key);
            }

            var item = createItem();
            Set(key, item, durationMinutes);
            return item;
        }
    }
}
