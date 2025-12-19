//
//  LibraryModel.swift
//  MyApp
//
//  Data models for the GitHub-based CMS library system.
//

import SwiftUI

// MARK: - Library Index

/// Root index model containing all articles
struct LibraryIndex: Codable {
    let lastUpdated: Date
    let articles: [LibraryEntry]
    let version: String

    enum CodingKeys: String, CodingKey {
        case lastUpdated, articles, version
    }
}

// MARK: - Library Entry

/// Individual library article entry
struct LibraryEntry: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let summary: String
    let contentURL: String
    let publishDate: Date
    let expiryDate: Date?
    let category: String
    let imageURL: String?
    let featured: Bool?
    let version: String

    /// Display-friendly category name
    var categoryDisplayName: String {
        formatCategoryName(category)
    }

    enum CodingKeys: String, CodingKey {
        case id, title, summary, contentURL, publishDate, expiryDate
        case category, imageURL, featured, version
    }

    static func == (lhs: LibraryEntry, rhs: LibraryEntry) -> Bool {
        lhs.id == rhs.id && lhs.version == rhs.version
    }
}

// MARK: - Category Helpers

/// Convert snake_case category to display name
func formatCategoryName(_ rawName: String) -> String {
    let words = rawName.split(separator: "_")
    let properWords = words.map { word -> String in
        let firstChar = word.prefix(1).uppercased()
        let remainingChars = word.dropFirst().lowercased()
        return firstChar + remainingChars
    }
    return properWords.joined(separator: " ")
}

// MARK: - Category Color/Icon Extensions

extension String {

    /// Get a consistent color for a category
    var categoryColor: Color {
        switch self.lowercased() {
        case "getting_started":
            return .blue
        case "features":
            return .purple
        case "tips":
            return .green
        case "support":
            return .orange
        case "about":
            return .cyan
        default:
            // Generate consistent color from hash
            let hash = abs(self.hashValue)
            let colors: [Color] = [.blue, .purple, .green, .orange, .red, .pink, .teal, .cyan]
            return colors[hash % colors.count]
        }
    }

    /// Get a consistent icon for a category
    var categoryIcon: String {
        switch self.lowercased() {
        case "getting_started":
            return "book.pages"
        case "features":
            return "gear"
        case "tips":
            return "lightbulb"
        case "support":
            return "questionmark.circle"
        case "about":
            return "info.circle"
        default:
            return "doc.text"
        }
    }
}

// MARK: - JSON Decoder Extension

extension JSONDecoder {
    /// Decoder configured for library index JSON
    static var libraryDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }
}
