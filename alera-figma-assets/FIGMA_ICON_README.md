# Alera Figma Assets

These are the original SVG exports from the Alera Figma components page, reorganized for Flutter use.

## Flutter-ready icons

```text
assets/icons/status/
assets/icons/vitals/
assets/icons/mini_status/
```

- `status/` contains the 40×40 status-container variants.
- `vitals/` contains the 40×40 heart-rate, SpO2, sleep, activity, and stress variants.
- `mini_status/` contains the compact 20×20 variants for list rows and alert cards.

## Vital-card references

`design-references/vital-cards/` contains full 139×170 Figma vital-card components. They are reference artwork, not icon files to render as 20×20 assets.

## Integration later

Use `flutter_svg` when the UI icon replacement pass begins. Keep icon rendering behind a small shared wrapper so paths and display sizes remain consistent across the app.

Existing Material chevrons and current bottom navigation intentionally remain unchanged.
