//
//  LibraryCacheManager.swift
//  MyApp
//
//  Manages caching of library content for offline access.
//

import Foundation

class LibraryCacheManager {

    static let shared = LibraryCacheManager()

    private let indexCacheKey = "com.myapp.library.index"
    private let indexLastUpdatedKey = "com.myapp.library.indexLastUpdated"
    private let contentCachePrefix = "com.myapp.library.content."
    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - Index Caching

    func cacheIndex(_ index: LibraryIndex) {
        guard let data = try? JSONEncoder().encode(index) else { return }
        defaults.set(data, forKey: indexCacheKey)
        defaults.set(Date(), forKey: indexLastUpdatedKey)
    }

    func getCachedIndex() -> LibraryIndex? {
        guard let data = defaults.data(forKey: indexCacheKey),
              let index = try? JSONDecoder.libraryDecoder.decode(LibraryIndex.self, from: data) else {
            return nil
        }
        return index
    }

    func getIndexLastUpdated() -> Date? {
        defaults.object(forKey: indexLastUpdatedKey) as? Date
    }

    // MARK: - Content Caching

    func cacheContent(_ content: String, for entryId: String, version: Int) {
        let key = "\(contentCachePrefix)\(entryId).\(version)"
        defaults.set(content, forKey: key)
    }

    func getCachedContent(for entryId: String, version: Int) -> String? {
        let key = "\(contentCachePrefix)\(entryId).\(version)"
        return defaults.string(forKey: key)
    }

    // MARK: - Cache Management

    func clearCache() {
        defaults.removeObject(forKey: indexCacheKey)
        defaults.removeObject(forKey: indexLastUpdatedKey)

        // Remove all content cache
        let allKeys = defaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix(contentCachePrefix) {
            defaults.removeObject(forKey: key)
        }
    }

    /// Get approximate cache size in bytes
    var approximateCacheSize: Int {
        var size = 0

        if let indexData = defaults.data(forKey: indexCacheKey) {
            size += indexData.count
        }

        let allKeys = defaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix(contentCachePrefix) {
            if let content = defaults.string(forKey: key) {
                size += content.utf8.count
            }
        }

        return size
    }
}
