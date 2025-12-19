# Content Repository

This directory contains the CMS content for your app's Library feature.

## Structure

```
content/
├── index.json          # Content index (required)
├── articles/           # Markdown content files
│   ├── about.md
│   ├── support.md
│   └── credits.md
└── images/             # Article images
    └── (add your images here)
```

## Setting Up as a Separate Repository

This content directory should be managed as a separate git repository so you can:
1. Keep content public while iOS code is private
2. Allow non-developers to update content
3. Deploy content changes without app updates

### Steps:

1. Create a new GitHub repository (e.g., `yourapp-content`)
2. Copy the contents of this directory to the new repo
3. Update `indexURL` in the iOS app's `LibraryViewModel.swift`

## index.json Format

```json
{
  "version": "1.0",
  "lastUpdated": "2025-01-01T00:00:00Z",
  "articles": [
    {
      "id": "unique-id",
      "title": "Article Title",
      "summary": "Brief description",
      "category": "category_slug",
      "publishDate": "2025-01-01T00:00:00Z",
      "expiryDate": null,
      "contentURL": "https://raw.githubusercontent.com/ORG/REPO/main/articles/file.md",
      "imageURL": "https://raw.githubusercontent.com/ORG/REPO/main/images/file.jpg",
      "featured": false,
      "version": "1.0"
    }
  ]
}
```

### Field Reference

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique identifier |
| `title` | Yes | Display title |
| `summary` | Yes | Brief description for list view |
| `category` | Yes | Category slug (use snake_case) |
| `publishDate` | Yes | ISO 8601 date when article becomes visible |
| `expiryDate` | No | ISO 8601 date when article is hidden (null = never) |
| `contentURL` | Yes | Raw GitHub URL to markdown file |
| `imageURL` | No | Raw GitHub URL to header image |
| `featured` | No | Show in featured carousel (default: false) |
| `version` | Yes | Version string for cache invalidation |

## Categories

Categories are automatically derived from the `category` field. Use snake_case for consistency:

- `getting_started`
- `features`
- `tips`
- `support`
- `about`

The iOS app will convert these to display names (e.g., "Getting Started").

## Publishing Content

1. Create or edit a markdown file in `articles/`
2. Add/update the entry in `index.json`
3. Commit and push to GitHub
4. The app will fetch the new content on next refresh

## Markdown Support

The app uses [swift-markdown-ui](https://github.com/gonzalezreal/swift-markdown-ui) for rendering. Supported elements:

- Headings (#, ##, ###)
- Bold and italic text
- Links
- Images (use full URLs)
- Lists (ordered and unordered)
- Code blocks
- Blockquotes
- Horizontal rules

## Tips

- Use `featured: true` sparingly (2-3 articles max)
- Articles published in the last 30 days get a "NEW" badge
- Use `expiryDate` for time-sensitive content
- Increment `version` when updating content to bust cache
