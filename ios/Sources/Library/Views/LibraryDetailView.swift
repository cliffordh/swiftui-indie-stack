//
//  LibraryDetailView.swift
//  MyApp
//
//  Detail view for reading library articles with markdown rendering.
//

import SwiftUI
import Combine
import MarkdownUI

struct LibraryDetailView: View {
    let entry: LibraryEntry
    @ObservedObject var viewModel: LibraryViewModel

    @State private var content: String = ""
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var imageLoadError = false

    private class CancelBag {
        var cancellables = Set<AnyCancellable>()
    }
    private let cancelBag = CancelBag()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header section
                ZStack(alignment: .bottomLeading) {
                    headerImage
                        .frame(height: 250)
                        .clipped()

                    // Gradient overlay
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    // Title overlay
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x: 0, y: 1)

                        HStack {
                            CategoryPill(category: entry.category)

                            Spacer()

                            HStack(spacing: 8) {
                                if entry.featured == true {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                }

                                if viewModel.isEntryNew(entry.publishDate) {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                }
                            }
                        }

                        Text("Published \(formatDate(entry.publishDate))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .black, radius: 1, x: 0, y: 1)
                    }
                    .padding(20)
                }

                // Content section
                VStack(alignment: .leading, spacing: 20) {
                    if isLoading {
                        VStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                    } else if let error = errorMessage {
                        VStack {
                            Spacer()
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()

                            Button("Try Again") {
                                loadContent()
                            }
                            .primaryStyle()
                            .frame(width: 150)

                            Spacer()
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                    } else {
                        Markdown(content)
                            .markdownTheme(.gitHub)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadContent()
            Analytics.track(
                event: "library.view.entry",
                parameters: [
                    "id": entry.id,
                    "title": entry.title,
                    "category": entry.category
                ]
            )
        }
    }

    @ViewBuilder
    private var headerImage: some View {
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
                .font(.system(size: 70))
                .foregroundColor(entry.category.categoryColor)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func loadContent() {
        isLoading = true
        errorMessage = nil

        viewModel.fetchEntryContent(for: entry)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                    self.isLoading = false
                },
                receiveValue: { content in
                    self.content = content
                }
            )
            .store(in: &cancelBag.cancellables)
    }
}

#Preview {
    NavigationView {
        LibraryDetailView(
            entry: LibraryEntry(
                id: "test",
                title: "Getting Started",
                summary: "Learn how to use the app",
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
    }
}
