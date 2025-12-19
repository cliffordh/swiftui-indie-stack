//
//  LibraryEntryRow.swift
//  MyApp
//
//  Card view for library entries in the list.
//

import SwiftUI

struct LibraryEntryRow: View {
    let entry: LibraryEntry
    @ObservedObject var viewModel: LibraryViewModel

    @State private var imageLoadError = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section
            ZStack(alignment: .topTrailing) {
                entryImage
                    .frame(height: 140)
                    .clipped()

                // Badges
                HStack(spacing: 8) {
                    if entry.featured == true {
                        BadgeView(text: "FEATURED", color: .yellow)
                    }
                    if viewModel.isEntryNew(entry.publishDate) {
                        BadgeView(text: "NEW", color: .green)
                    }
                }
                .padding(8)
            }

            // Content section
            VStack(alignment: .leading, spacing: 8) {
                // Category pill
                CategoryPill(category: entry.category)

                // Title
                Text(entry.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                // Summary
                Text(entry.summary)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(12)
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    @ViewBuilder
    private var entryImage: some View {
        if let imageURL = entry.imageURL, !imageLoadError, let url = URL(string: imageURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    placeholderImage
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderImage
                        .onAppear { imageLoadError = true }
                @unknown default:
                    placeholderImage
                }
            }
        } else {
            placeholderImage
        }
    }

    private var placeholderImage: some View {
        ZStack {
            Rectangle()
                .fill(entry.category.categoryColor.opacity(0.2))

            Image(systemName: entry.category.categoryIcon)
                .font(.system(size: 40))
                .foregroundColor(entry.category.categoryColor)
        }
    }
}

// MARK: - Supporting Views

struct BadgeView: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(4)
    }
}

struct CategoryPill: View {
    let category: String

    var body: some View {
        Text(formatCategoryName(category))
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(category.categoryColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(category.categoryColor.opacity(0.15))
            .cornerRadius(12)
    }
}

#Preview {
    LibraryEntryRow(
        entry: LibraryEntry(
            id: "test",
            title: "Getting Started with Your App",
            summary: "Learn how to make the most of all the features available to you.",
            contentURL: "https://example.com/content.md",
            publishDate: Date(),
            expiryDate: nil,
            category: "getting_started",
            imageURL: nil,
            featured: true,
            version: "1.0"
        ),
        viewModel: LibraryViewModel()
    )
    .frame(width: 300, height: 260)
    .padding()
}
