# Library CMS System

The Library feature you're reading right now is powered by a GitHub-based CMS. Update content without app updates!

## How It Works

```
GitHub Repository          iOS App
      │                       │
      ├── index.json ────────►│ Fetch index
      │                       │
      ├── articles/*.md ─────►│ Fetch content
      │                       │
      └── images/* ──────────►│ Load images
```

1. Content lives in a GitHub repository
2. App fetches `index.json` to get article list
3. Individual articles are fetched on demand
4. Content is cached locally for offline access

## Repository Structure

```
your-content-repo/
├── index.json           # Article index (required)
├── articles/            # Markdown files
│   ├── welcome.md
│   ├── getting-started.md
│   └── ...
├── images/              # Article images
│   └── header.jpg
└── README.md            # Repo documentation
```

## index.json Format

```json
{
  "version": "1.0",
  "lastUpdated": "2025-01-01T00:00:00Z",
  "articles": [
    {
      "id": "unique-id",
      "title": "Article Title",
      "summary": "Brief description shown in list",
      "category": "getting_started",
      "publishDate": "2025-01-01T00:00:00Z",
      "expiryDate": null,
      "contentURL": "https://raw.githubusercontent.com/ORG/REPO/main/articles/file.md",
      "imageURL": null,
      "featured": true,
      "version": "1.0"
    }
  ]
}
```

## Field Reference

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique identifier |
| `title` | Yes | Display title |
| `summary` | Yes | Description for list view |
| `category` | Yes | Category slug (snake_case) |
| `publishDate` | Yes | When article becomes visible |
| `expiryDate` | No | When article is hidden |
| `contentURL` | Yes | Raw GitHub URL to markdown |
| `imageURL` | No | Header image URL |
| `featured` | No | Show in carousel |
| `version` | Yes | For cache invalidation |

## Categories

Use snake_case for category slugs:
- `getting_started` → "Getting Started"
- `features` → "Features"
- `tips` → "Tips"
- `support` → "Support"

The app automatically formats these for display.

## Publishing Workflow

### Adding a New Article

1. Create markdown file in `articles/`
2. Add entry to `index.json`
3. Update `lastUpdated` timestamp
4. Commit and push

### Updating an Article

1. Edit the markdown file
2. Increment `version` in `index.json`
3. Update `lastUpdated`
4. Commit and push

### Scheduling Content

Use `publishDate` for future articles:
```json
"publishDate": "2025-06-01T00:00:00Z"
```

Use `expiryDate` for time-limited content:
```json
"expiryDate": "2025-12-31T23:59:59Z"
```

## Setup Your Repository

1. Create a new GitHub repository
2. Copy the `content/` folder contents
3. Update URLs in `index.json` to point to your repo
4. Update `AppConfiguration.swift`:

```swift
static let libraryIndexURL =
    "https://raw.githubusercontent.com/YOUR_ORG/YOUR_REPO/main/index.json"
```

## Markdown Support

The app renders markdown using swift-markdown-ui:

- **Headings**: #, ##, ###
- **Emphasis**: *italic*, **bold**
- **Links**: [text](url)
- **Images**: ![alt](url)
- **Lists**: Ordered and unordered
- **Code**: Inline `code` and blocks
- **Blockquotes**: > quote
- **Horizontal rules**: ---

## Caching

Articles are cached locally:
- Index refreshes once per day
- Content cached by version hash
- Force refresh available via pull-to-refresh
