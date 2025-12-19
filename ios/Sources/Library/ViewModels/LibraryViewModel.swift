//
//  LibraryViewModel.swift
//  MyApp
//
//  ViewModel for fetching and filtering library content.
//

import Foundation
import SwiftUI
import Combine

class LibraryViewModel: ObservableObject {

    @Published var entries: [LibraryEntry] = []
    @Published var filteredEntries: [LibraryEntry] = []
    @Published var selectedCategory: String?
    @Published var availableCategories: [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    @Published var searchText: String = ""

    /// Check if there are featured entries in current filter
    var hasFeaturedEntries: Bool {
        filteredEntries.contains { $0.featured == true }
    }

    private var cancellables = Set<AnyCancellable>()
    private let cacheManager = LibraryCacheManager.shared

    private let indexURL = AppConfiguration.libraryIndexURL

    init() {
        // Update filtered entries when search text changes
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.filterEntries()
            }
            .store(in: &cancellables)

        // Update filtered entries when category changes
        $selectedCategory
            .sink { [weak self] _ in
                self?.filterEntries()
            }
            .store(in: &cancellables)
    }

    // MARK: - Fetching

    func fetchEntries(forceRefresh: Bool = false) {
        isLoading = true
        errorMessage = nil

        // Check cache first if not forcing refresh
        if !forceRefresh,
           let cachedIndex = cacheManager.getCachedIndex(),
           let cachedDate = cacheManager.getIndexLastUpdated(),
           Calendar.current.isDateInToday(cachedDate) {

            processEntries(from: cachedIndex)
            lastUpdated = cachedDate
            isLoading = false
            return
        }

        // Fetch from GitHub
        guard let url = URL(string: indexURL) else {
            errorMessage = "Invalid index URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: LibraryIndex.self, decoder: JSONDecoder.libraryDecoder)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Failed to fetch library: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] libraryIndex in
                    self?.cacheManager.cacheIndex(libraryIndex)
                    self?.processEntries(from: libraryIndex)
                    self?.lastUpdated = libraryIndex.lastUpdated
                }
            )
            .store(in: &cancellables)
    }

    private func processEntries(from index: LibraryIndex) {
        let now = Date()
        let sortedEntries = index.articles
            .filter { article in
                let isPublished = article.publishDate <= now
                let isNotExpired = article.expiryDate == nil || article.expiryDate! >= now
                return isPublished && isNotExpired
            }
            .sorted(by: { $0.publishDate > $1.publishDate })

        entries = sortedEntries
        updateAvailableCategories()
        filterEntries()
    }

    // MARK: - Filtering

    func filterEntries() {
        var filtered = entries

        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }

        // Filter by search text
        if !searchText.isEmpty {
            let searchTerms = searchText.lowercased().split(separator: " ").map(String.init)
            filtered = filtered.filter { entry in
                let title = entry.title.lowercased()
                let summary = entry.summary.lowercased()
                return searchTerms.allSatisfy { term in
                    title.contains(term) || summary.contains(term)
                }
            }
        }

        filteredEntries = filtered
    }

    func updateAvailableCategories() {
        let categorySet = Set(entries.map { $0.category })
        let sortedCategories = categorySet.sorted {
            formatCategoryName($0) < formatCategoryName($1)
        }
        availableCategories = sortedCategories
    }

    func resetCategory() {
        selectedCategory = nil
    }

    func displayNameForCategory(_ category: String) -> String {
        formatCategoryName(category)
    }

    // MARK: - Content Fetching

    func fetchEntryContent(for entry: LibraryEntry) -> AnyPublisher<String, Error> {
        let versionHash = entry.version.hashValue

        // Check cache first
        if let cachedContent = cacheManager.getCachedContent(for: entry.id, version: versionHash) {
            return Just(cachedContent)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        // Fetch from GitHub
        guard let url = URL(string: entry.contentURL) else {
            return Fail(error: NSError(
                domain: "",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid content URL"]
            ))
            .eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data -> String in
                guard let content = String(data: data, encoding: .utf8) else {
                    throw NSError(
                        domain: "",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid content encoding"]
                    )
                }
                self.cacheManager.cacheContent(content, for: entry.id, version: versionHash)
                return content
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Helpers

    /// Check if an entry is new (published within last 30 days)
    func isEntryNew(_ publishDate: Date) -> Bool {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return publishDate > thirtyDaysAgo
    }
}
