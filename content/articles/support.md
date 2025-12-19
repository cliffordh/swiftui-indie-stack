# Getting Help

Resources and support for SwiftUI Indie Stack users.

## Documentation

### In-App Documentation
You're reading it! The Library tab contains guides for all major features.

### GitHub Repository
The main repository contains:
- `README.md` - Overview and quick start
- `CUSTOMIZATION.md` - Detailed customization guide
- `ARCHITECTURE.md` - Code patterns and structure

## Common Issues

### RevenueCat Errors
**"Invalid credentials" or similar errors**
- Ensure API key is correct in `AppConfiguration.swift`
- Check RevenueCat dashboard for app configuration
- Use Sandbox accounts for testing

### Firebase Issues
**"No Firebase App configured"**
- Add `GoogleService-Info.plist` to your project
- Ensure Firebase is properly initialized
- Check `useFirebase = true` is set

### Library Not Loading
**"Failed to fetch library" error**
- Check your content repository URL
- Verify `index.json` is valid JSON
- Ensure URLs use raw.githubusercontent.com format

### Widgets Not Updating
**Widget shows stale data**
- Verify App Groups are configured
- Check group identifier matches in code
- Call `WidgetCenter.shared.reloadAllTimelines()`

### Build Errors
**"No such module" errors**
- Resolve SPM packages: File > Packages > Resolve
- Clean build folder: Cmd + Shift + K
- Restart Xcode

## Getting Updates

### Starter Kit Updates
Watch the GitHub repository for:
- New features
- Bug fixes
- iOS version support

### Dependency Updates
Periodically update SPM packages:
1. File > Packages > Update to Latest
2. Test thoroughly after updates

## External Resources

### RevenueCat
- [Documentation](https://docs.revenuecat.com)
- [SDK Reference](https://sdk.revenuecat.com)

### TelemetryDeck
- [Documentation](https://telemetrydeck.com/docs)
- [Dashboard](https://dashboard.telemetrydeck.com)

### Firebase
- [iOS Setup Guide](https://firebase.google.com/docs/ios/setup)
- [Authentication](https://firebase.google.com/docs/auth/ios/start)
- [Firestore](https://firebase.google.com/docs/firestore/quickstart)

### SwiftUI
- [Apple Documentation](https://developer.apple.com/documentation/swiftui)
- [Hacking with Swift](https://www.hackingwithswift.com/quick-start/swiftui)

## Contact

### Reporting Issues
Found a bug or have a feature request?
- Open an issue on GitHub
- Include steps to reproduce
- Attach relevant logs or screenshots

### Community
- GitHub Discussions for questions
- Star the repo to show support

## FAQ

**Can I use this for commercial apps?**
Yes! The starter kit is designed for production apps.

**Do I need all the dependencies?**
No. Disable features you don't need via `AppConfiguration.swift` and remove unused packages.

**Can I remove the attribution?**
Yes, you can customize all branding.

**How do I request features?**
Open a GitHub issue with the "enhancement" label.
