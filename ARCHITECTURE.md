# Architecture Guide

This document explains the patterns and structure of SwiftUI Indie Stack. Follow these patterns when adding new features to maintain consistency.

---

## Core Principles

1. **Offline-First**: Local storage is the source of truth. Cloud sync is optional.
2. **Feature Flags**: Everything can be toggled via `AppConfiguration.swift`.
3. **Conditional Compilation**: Optional dependencies use `#if canImport()`.
4. **Consistent Patterns**: Every feature follows the same structure.

---

## Architecture Pattern: MVVM

This project uses **MVVM (Model-View-ViewModel)**, the most common architecture pattern for SwiftUI applications.

### Why MVVM?

MVVM is a natural fit for SwiftUI because Apple's property wrappers map directly to the pattern:

| Component | Role | SwiftUI Implementation |
|-----------|------|------------------------|
| **Model** | Data structures | `Codable` structs |
| **ViewModel** | State + business logic | `ObservableObject` with `@Published` properties |
| **View** | UI rendering | SwiftUI views observing ViewModels |

**Benefits for this starter kit:**

- **Testable**: Business logic lives in ViewModels, separate from UI
- **Scalable**: Add features without rewiring existing code
- **SwiftUI-native**: Uses `@StateObject`, `@ObservedObject`, `@Published` as intended
- **Approachable**: Most iOS tutorials and documentation use MVVM

### Why Not Other Patterns?

Patterns like **VIPER**, **TCA (The Composable Architecture)**, and **Clean Architecture** are powerful but add complexity that isn't appropriate for a starter template. MVVM provides the right balance of structure and simplicity—you can always evolve toward more sophisticated patterns as your app grows.

### The Rule

**Views don't talk to storage directly.** Always go through a ViewModel:

```
View → ViewModel → Storage (UserDefaults / Firestore)
```

---

## Folder Structure

Each feature follows this pattern:

```
Sources/
├── YourFeature/
│   ├── Models/           # Data structures (Codable structs)
│   ├── ViewModels/       # State + business logic (ObservableObject)
│   └── Views/            # SwiftUI views
```

### Canonical Example: Library/

The `Library/` folder is the most complete example. Reference it when creating new features:

```
Library/
├── Models/
│   └── LibraryModel.swift      # LibraryEntry, LibraryIndex structs
├── ViewModels/
│   └── LibraryViewModel.swift  # Fetching, filtering, caching logic
├── Views/
│   ├── LibraryView.swift       # Main list view
│   ├── LibraryDetailView.swift # Article detail view
│   └── LibraryEntryRow.swift   # List row component
└── Cache/
    └── LibraryCacheManager.swift  # Local caching
```

---

## Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         SwiftUI View                            │
│                    @StateObject viewModel                       │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                      ViewModel                                  │
│              @Published properties                              │
│         Business logic, data transformation                     │
└─────────────────────────┬───────────────────────────────────────┘
                          │
          ┌───────────────┴───────────────┐
          ▼                               ▼
┌─────────────────────┐       ┌─────────────────────────────────┐
│   Local Storage     │       │      FirestoreManager           │
│   (UserDefaults)    │       │   (when useFirebase = true)     │
└─────────────────────┘       └─────────────────────────────────┘
```

### Read Flow
1. View observes ViewModel's `@Published` properties
2. ViewModel fetches from local storage first (cache)
3. If Firebase enabled, ViewModel also fetches from Firestore
4. ViewModel updates `@Published` properties
5. View automatically re-renders

### Write Flow
1. View calls ViewModel method (e.g., `save()`)
2. ViewModel writes to local storage immediately
3. If Firebase enabled, ViewModel also writes to Firestore
4. ViewModel updates `@Published` properties

---

## Adding a New Feature

### Step 1: Create Folder Structure

```bash
mkdir -p Sources/YourFeature/{Models,ViewModels,Views}
```

### Step 2: Define Your Model

```swift
// Sources/YourFeature/Models/YourModel.swift

import Foundation

struct YourItem: Codable, Identifiable {
    let id: String
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date

    init(id: String = UUID().uuidString, title: String, content: String) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
```

### Step 3: Create the ViewModel

```swift
// Sources/YourFeature/ViewModels/YourViewModel.swift

import Foundation
import SwiftUI

class YourViewModel: ObservableObject {

    // MARK: - Published State (UI binds to these)
    @Published var items: [YourItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let storageKey = "your_items"

    // MARK: - Singleton (if needed app-wide)
    static let shared = YourViewModel()

    // MARK: - Initialization
    init() {
        loadFromLocal()
    }

    // MARK: - Public Methods (called by Views)

    func create(title: String, content: String) {
        let item = YourItem(title: title, content: content)
        items.append(item)
        saveToLocal()
        syncToFirestoreIfEnabled()
    }

    func update(_ item: YourItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        var updated = item
        updated.updatedAt = Date()
        items[index] = updated
        saveToLocal()
        syncToFirestoreIfEnabled()
    }

    func delete(_ item: YourItem) {
        items.removeAll { $0.id == item.id }
        saveToLocal()
        deleteFromFirestoreIfEnabled(item.id)
    }

    // MARK: - Private Methods (internal logic)

    private func loadFromLocal() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([YourItem].self, from: data) else {
            return
        }
        items = decoded
    }

    private func saveToLocal() {
        guard let encoded = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }

    private func syncToFirestoreIfEnabled() {
        #if canImport(Firebase)
        guard AppConfiguration.useFirebase else { return }
        // FirestoreManager.shared.saveItems(items)
        #endif
    }

    private func deleteFromFirestoreIfEnabled(_ id: String) {
        #if canImport(Firebase)
        guard AppConfiguration.useFirebase else { return }
        // FirestoreManager.shared.deleteItem(id)
        #endif
    }
}
```

### Step 4: Create the Views

```swift
// Sources/YourFeature/Views/YourListView.swift

import SwiftUI

struct YourListView: View {
    @StateObject private var viewModel = YourViewModel.shared

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items) { item in
                    NavigationLink(destination: YourDetailView(item: item)) {
                        YourRowView(item: item)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Your Feature")
            .toolbar {
                Button(action: addItem) {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            Analytics.trackScreenView("YourListView")
        }
    }

    private func addItem() {
        viewModel.create(title: "New Item", content: "")
    }

    private func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            viewModel.delete(viewModel.items[index])
        }
    }
}
```

### Step 5: Add to Navigation

In `MainTabView.swift`, add your new tab:

```swift
case 3:
    YourListView()

// And the tab icon:
TabBarIcon(
    selectedTab: $selectedTab,
    assignedTab: 3,
    systemIconName: "star.fill",
    tabName: "Your Tab",
    color: AppColors.accent
)
```

---

## Key Singletons

| Singleton | Purpose | File |
|-----------|---------|------|
| `AuthManager.shared` | Authentication state | `Auth/AuthManager.swift` |
| `PaywallManager.shared` | Subscription state | `Paywall/PaywallManager.swift` |
| `SettingsViewModel.shared` | User settings | `User/SettingsViewModel.swift` |
| `StreakDataProvider.shared` | Streak display | `Streak/StreakDataProvider.swift` |
| `FirestoreManager.shared` | Firestore operations | `User/FirestoreManager.swift` |

---

## Conditional Firebase Pattern

Always guard Firebase code with both compile-time and runtime checks:

```swift
#if canImport(Firebase)
import Firebase
#endif

class SomeManager {
    func doSomething() {
        // Local logic always runs
        saveLocally()

        // Firebase logic only when enabled
        #if canImport(Firebase)
        if AppConfiguration.useFirebase {
            saveToFirestore()
        }
        #endif
    }
}
```

---

## Analytics Pattern

Track screen views and events consistently:

```swift
// Screen views - in .task modifier
.task {
    Analytics.trackScreenView("ScreenName")
}

// Events - on user actions
Button("Subscribe") {
    Analytics.track(event: "subscribe_tapped", parameters: ["source": "settings"])
    PaywallManager.shared.triggerPaywall()
}
```

---

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Models | Singular noun | `LibraryEntry`, `StreakData` |
| ViewModels | Feature + ViewModel | `LibraryViewModel`, `SettingsViewModel` |
| Views | Descriptive + View | `LibraryView`, `StreakBadgeView` |
| Managers | Feature + Manager | `PaywallManager`, `CacheManager` |
| Providers | Feature + Provider/DataProvider | `StreakDataProvider` |

---

## For AI Assistants

When generating code for this project:

1. **Follow the Library/ pattern** - It's the canonical example
2. **Use ObservableObject + @Published** - Not @Observable (iOS 17 only)
3. **Always add Analytics** - `Analytics.trackScreenView()` in Views
4. **Check AppConfiguration** - Respect feature flags
5. **Use #if canImport()** - For optional dependencies
6. **Prefer UserDefaults** - For simple local storage
7. **Follow existing naming** - Match the conventions above

When modifying existing features:
1. Read the existing code first
2. Match the existing style exactly
3. Don't refactor unrelated code
4. Keep changes minimal and focused

---

## Common Patterns

### Loading State

```swift
@Published var isLoading = false
@Published var errorMessage: String?

func fetch() {
    isLoading = true
    errorMessage = nil

    // ... async work ...

    isLoading = false
}
```

### List with Search

```swift
@Published var items: [Item] = []
@Published var searchText = ""

var filteredItems: [Item] {
    if searchText.isEmpty {
        return items
    }
    return items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
}
```

### Offline-First Save

```swift
func save(_ item: Item) {
    // 1. Save locally first (instant)
    saveToLocal(item)

    // 2. Sync to cloud (eventual)
    #if canImport(Firebase)
    if AppConfiguration.useFirebase {
        Task {
            try? await saveToFirestore(item)
        }
    }
    #endif
}
```
