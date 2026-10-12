# conversation_list/widgets/footer/ — Skin Footers

## Files
| File | Purpose |
|------|---------|
| `cupertino_glass_footer.dart` | iOS 26 Liquid Glass bottom bar (search capsule + compose button) for the iOS skin; replaces the FAB and header search button. Metrics from the iOS 26.2 simulator |
| `samsung_footer.dart` | Bottom navigation bar for the Samsung One UI skin; shows Home / Search / Settings tabs in a bottom nav style |

## Platform
`samsung_footer.dart`: Samsung One UI only. `cupertino_glass_footer.dart`: iOS skin, mobile only. Controlled via `ThemeSwitcher` in the parent conversation list pages.

## Related
- Samsung headers: `../header/CLAUDE.md`
- Parent list: `../../CLAUDE.md` (conversation_list)
