# RepliQ

RepliQ is a macOS menu bar application that monitors your clipboard and automatically replaces text based on predefined rules.

## Features

- **Menu Bar Application**: Runs discretely in the menu bar - no dock icon clutter
- **Auto-Start Monitoring**: Automatically starts monitoring clipboard changes on app launch
- **Clipboard Monitoring**: Real-time clipboard change detection and text replacement
- **Text Replacement**: Replace specific keywords with custom text instantly
- **Rule Management**: Add, delete, and toggle replacement rules through settings window
- **Persistent Settings**: Rules are saved and restored between app launches
- **System Integration**: Works with all macOS applications that use the system clipboard

## How to Use

### First Launch
1. **Launch RepliQ** - You'll see an "R" icon appear in your menu bar
2. **Access Settings** - Click the menu bar icon and select "Open Settings"
3. **Add replacement rules**:
   - Enter a keyword in the "Keyword" field (e.g., "David")
   - Enter the replacement text in the "Replacement" field (e.g., "Tim")
   - Click "Add Rule"
4. **Monitor Status** - The app automatically starts monitoring your clipboard

### Menu Bar Controls
Click the RepliQ icon in your menu bar to access:
- **Stop/Start Monitoring** - Toggle clipboard monitoring on/off
- **Open Settings** - Access the main settings window to manage rules
- **About RepliQ** - View app information
- **Quit RepliQ** - Exit the application

### Example Usage
1. Set up a rule: Keyword "David" → Replacement "Tim"
2. Copy text containing "Hello David"
3. When you paste, it will automatically be "Hello Tim"

## Technical Details

- **Platform**: macOS only
- **Architecture**: Native Objective-C with Storyboard UI
- **System Requirements**: macOS 10.15 or later
- **Background Operation**: LSUIElement application (no dock icon)
- **Clipboard API**: Uses NSPasteboard for system integration

## Building from Source

1. Open `RepliQ.xcodeproj` in Xcode
2. Select "RepliQ" scheme
3. Build and run (⌘+R)

## Files Structure

- `AppDelegate` - Menu bar management and app lifecycle
- `ClipboardManager` - Clipboard monitoring and text replacement logic
- `ReplacementRule` - Data model for replacement rules
- `ViewController` - Settings window UI
- `StatusBarIcon` - Menu bar icon generation
- `Info.plist` - Configured for menu bar application (LSUIElement)

---

**Created by Vincent Yang** 