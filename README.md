# Claude Desktop Allow Clicker (AHK v2)

AutoHotkey v2 script to automatically click the "Allow" button in Claude Desktop when enabling MCP tools.

## How it works

- Searches for an image (`allow_dark.png` or `allow_light.png`) in the Claude window.
- Clicks the matched location with a small random offset to simulate human input.
- Cools down for 5 seconds if the button is found, else waits for 1 second.
- The button must be fully visible.

## Files

- `allow.ahk` — main script
- `allow_dark.png` — button image for dark theme
- `allow_light.png` — button image for light theme

## Usage

1. Install [AutoHotkey v2](https://www.autohotkey.com/).
2. Download files in repository.
3. Edit `allow.ahk` if needed:
   - Set `theme := "dark"` or `"light"`
   - Set `winTitle := "Claude"` if different
4. Run `allow.ahk`.

