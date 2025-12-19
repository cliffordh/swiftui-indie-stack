//
//  LibraryView.swift
//  MyApp
//
//  Main library view with category filtering and search.
//

import SwiftUI

struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    @State private var searchText = ""
    @State private var showingSearchBar = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if showingSearchBar {
                    SearchBar(text: $searchText, onCommit: {
                        viewModel.searchText = searchText
                    })
                    .padding(.horizontal)
                }

                if viewModel.isLoading && viewModel.entries.isEmpty {
                    LoadingView()
                } else if viewModel.errorMessage != nil && viewModel.entries.isEmpty {
                    ErrorView(
                        errorMessage: viewModel.errorMessage ?? "Unknown error",
                        onRetry: { viewModel.fetchEntries(forceRefresh: true) }
                    )
                } else {
                    contentView
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            showingSearchBar.toggle()
                            if !showingSearchBar {
                                searchText = ""
                                viewModel.searchText = ""
                            }
                        }
                    }) {
                        Image(systemName: showingSearchBar ? "xmark.circle.fill" : "magnifyingglass")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.fetchEntries(forceRefresh: true) }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchEntries()
            Analytics.trackScreenView("LibraryView")
        }
        .onChange(of: searchText) { _, newValue in
            viewModel.searchText = newValue
        }
    }

    private var contentView: some View {
        ScrollView {
            // Category filters
            categoryFilters
                .padding(.horizontal)

            if viewModel.filteredEntries.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 0) {
                    // Featured entries
                    if viewModel.hasFeaturedEntries {
                        featuredEntriesSection
                    }

                    // Regular entries
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredEntries.filter { $0.featured != true }) { entry in
                            NavigationLink(destination: LibraryDetailView(entry: entry, viewModel: viewModel)) {
                                LibraryEntryRow(entry: entry, viewModel: viewModel)
                                    .frame(height: 260)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, viewModel.hasFeaturedEntries ? 0 : 16)
                    .padding(.bottom, 16)
                }
            }
        }
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryFilterButton(
                    title: "All",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    withAnimation {
                        viewModel.resetCategory()
                    }
                }

                ForEach(viewModel.availableCategories, id: \.self) { category in
                    CategoryFilterButton(
                        title: viewModel.displayNameForCategory(category),
                        isSelected: viewModel.selectedCategory == category,
                        color: category.categoryColor
                    ) {
                        withAnimation {
                            if viewModel.selectedCategory == category {
                                viewModel.selectedCategory = nil
                            } else {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var featuredEntriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(viewModel.filteredEntries.filter { $0.featured == true }) { entry in
                        NavigationLink(destination: LibraryDetailView(entry: entry, viewModel: viewModel)) {
                            LibraryEntryRow(entry: entry, viewModel: viewModel)
                                .frame(width: 260, height: 320)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }

    @ViewBuilder
    private var emptyStateView: some View {
        if viewModel.selectedCategory != nil {
            EmptyStateView(
                icon: "folder.badge.questionmark",
                title: "No Articles in this Category",
                message: "Try selecting a different category or check back later."
            )
        } else if !viewModel.searchText.isEmpty {
            EmptyStateView(
                icon: "magnifyingglass",
                title: "No Results",
                message: "No matches found for \"\(viewModel.searchText)\""
            )
        } else {
            EmptyStateView(
                icon: "book.closed",
                title: "No Library Entries",
                message: "Check back later for educational content."
            )
        }
    }
}

// MARK: - Supporting Views

struct SearchBar: View {
    @Binding var text: String
    var onCommit: () -> Void = {}

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search library...", text: $text, onCommit: onCommit)
                .disableAutocorrection(true)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onCommit()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    var color: Color = .blue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color.opacity(0.2) : Color(.secondarySystemBackground))
                .foregroundColor(isSelected ? color : .primary)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? color : Color.clear, lineWidth: 1)
                )
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            Text("Loading library content...")
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct ErrorView: View {
    let errorMessage: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text("Error Loading Content")
                .font(.title2)
                .fontWeight(.bold)

            Text(errorMessage)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Button("Try Again", action: onRetry)
                .primaryStyle()
                .frame(width: 200)

            Spacer()
        }
        .padding()
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 40)

            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text(title)
                .font(.title2)
                .fontWeight(.bold)

            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding()
    }
}

#Preview {
    LibraryView()
}
