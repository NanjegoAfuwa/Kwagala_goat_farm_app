# Flutter Kwagala Farm - Hard-Coded Colors Analysis Report

**Analysis Date:** 2026-06-17  
**Focus:** Identify all hard-coded color values in `lib/Screens/` that should use `AppTheme` helper for dark mode support  
**Excluded:** `settings_screen.dart` (already implements dark mode properly)  

---

## Summary
Found **12 screen files** with hard-coded colors that violate theme-aware principles. Most colors can be mapped to existing `AppTheme` helper methods.

---

## Detailed Findings by File

### 1. **add_goat.dart**

#### Background Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 84 | `backgroundColor: const Color(0xFFF8F9FA)` | `AppTheme.bg(context)` | Scaffold background |
| 86 | `backgroundColor: Colors.white` | `AppTheme.card(context)` | AppBar background |

#### Text Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 99 | `foregroundColor: const Color(0xFF0F172A)` | `AppTheme.textDark(context)` | AppBar text |

#### Border Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 88 | `color: const Color(0xFFE2E8F0)` | `AppTheme.border(context)` | Divider |

---

### 2. **financial_reports_screen.dart**

#### Background Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 156 | `backgroundColor: const Color(0xFFF8F9FA)` | `AppTheme.bg(context)` | Scaffold background |

#### Text Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 104 | `color: Color(0xFF64748B)` | `AppTheme.textMid(context)` | Subheading |
| 328 | `color: Color(0xFF0F172A)` | `AppTheme.textDark(context)` | Title |
| 330 | `color: Color(0xFF94A3B8)` | `AppTheme.textLight(context)` | Hint |
| 349 | `color: Color(0xFF0F172A)` | `AppTheme.textDark(context)` | Card title |
| 359 | `color: Color(0xFF334155)` | `AppTheme.textMid(context)` | Label |
| 361 | `color: Color(0xFF0F172A)` | `AppTheme.textDark(context)` | Value |
| 380 | `color: Color(0xFF64748B)` | `AppTheme.textMid(context)` | Label |
| 385 | `color: Colors.black` | `AppTheme.inputText(context)` | TextFormField text |

#### Input Field Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 388 | `hintStyle: const TextStyle(color: Color(0xFF94A3B8), ...)` | Use `AppTheme.textLight(context)` for hint | Hint text |
| 389 | `fillColor: const Color(0xFFF8FAFC)` | `AppTheme.inputFill(context)` | Fill color |
| 394 | `borderSide: const BorderSide(color: Color(0xFFE2E8F0))` | `AppTheme.inputBorder(context)` | Border |
| 397 | `borderSide: const BorderSide(color: Color(0xFFE2E8F0))` | `AppTheme.inputBorder(context)` | Border |
| 406 | `fillColor: const Color(0xFFF8FAFC)` | `AppTheme.inputFill(context)` | Dropdown fill |
| 409 | `borderSide: const BorderSide(color: Color(0xFFE2E8F0))` | `AppTheme.inputBorder(context)` | Dropdown border |
| 411 | `borderSide: const BorderSide(color: Color(0xFFE2E8F0))` | `AppTheme.inputBorder(context)` | Dropdown border |

#### Border/Container Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 344 | `color: Colors.white` | `AppTheme.card(context)` | Container background |
| 346 | `border: Border.all(color: const Color(0xFFE2E8F0))` | `AppTheme.border(context)` | Card border |
| 366 | `color: const Color(0xFFF1F5F9)` | `AppTheme.divider(context)` | Bar background |

---

### 3. **health_vaccination_screen.dart**

#### Background Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 65 | `backgroundColor: Colors.white` | `AppTheme.card(context)` | AppBar |
| 125 | `backgroundColor: const Color(0xFFF8F9FA)` | `AppTheme.bg(context)` | Scaffold |

#### Text Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 210 | `color: Color(0xFF0F172A)` | `AppTheme.textDark(context)` | Title |
| 214 | `color: Color(0xFF64748B)` | `AppTheme.textMid(context)` | Subtitle |
| 217 | `color: Color(0xFF94A3B8)` | `AppTheme.textLight(context)` | Note |
| 222 | `color: Color(0xFF94A3B8)` | `AppTheme.textLight(context)` | Secondary |
| 241 | `color: Color(0xFF2E7D32)` | Keep (Brand color) | Icon tint |
| 245 | `color: Color(0xFF2E7D32)` | Keep (Brand color) | Text tint |
| 281 | `color: Color(0xFF0F172A)` | `AppTheme.textDark(context)` | Content |
| 293 | `color: Color(0xFF64748B)` | `AppTheme.textMid(context)` | Metadata |
| 296 | `color: Color(0xFF94A3B8)` | `AppTheme.textLight(context)` | Icon |
| 299 | `color: Color(0xFF64748B)` | `AppTheme.textMid(context)` | Date |
| 304 | `color: Color(0xFF64748B)` | `AppTheme.textMid(context)` | Metadata |
| 306 | `color: Color(0xFF94A3B8)` | `AppTheme.textLight(context)` | Icon |
| 309 | `color: Color(0xFF64748B)` | `AppTheme.textMid(context)` | Data |
| 321 | `color: Color(0xFF64748B)` | `AppTheme.textMid(context)` | Label |
| 325 | `color: Colors.black` | `AppTheme.inputText(context)` | TextFormField |
| 328 | `hintStyle: const TextStyle(color: Color(0xFF94A3B8), ...)` | Use `AppTheme.textLight(context)` | Hint |

#### Input Field Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 329 | `fillColor: const Color(0xFFF8FAFC)` | `AppTheme.inputFill(context)` | Fill |
| 332 | `borderSide: const BorderSide(color: Color(0xFFE2E8F0))` | `AppTheme.inputBorder(context)` | Border |
| 334 | `borderSide: const BorderSide(color: Color(0xFFE2E8F0))` | `AppTheme.inputBorder(context)` | Border |
| 336 | `borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)` | Keep (Brand color focused border) | Focus border |

#### Status Badge Colors (Soft-colored backgrounds)
| Line | Current Code | Note |
|------|-------------|------|
| 256 | `statusBg = const Color(0xFFFEF2F2); statusFg = const Color(0xFFDC2626)` | Status: Overdue - Keep (Status color) |
| 259 | `statusBg = const Color(0xFFFFF7ED); statusFg = const Color(0xFFF57C00)` | Status: Due Soon - Keep (Status color) |
| 262 | `statusBg = const Color(0xFFF0FDF4); statusFg = const Color(0xFF15803D)` | Status: Upcoming - Keep (Status color) |

#### Border/Container Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 193 | `color: Colors.white` | `AppTheme.card(context)` | Container |
| 195 | `border: Border.all(color: const Color(0xFFE2E8F0))` | `AppTheme.border(context)` | Border |
| 269 | `color: Colors.white` | `AppTheme.card(context)` | Container |
| 274 | `color: const Color(0xFFFECACA)` | *Consider* theme-aware error tint | Error border |

---

### 4. **home_screen.dart**

#### Background & Container Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 203 | `color: Colors.black.withOpacity(0.18)` | Keep (Shadow/overlay) | Box shadow |
| 222 | `color: Colors.white` | `AppTheme.card(context)` | Container |
| 227 | `color: Colors.white` | `AppTheme.card(context)` | Text container |
| 250 | `height: 1, color: Color(0xFFF1F5F9)` | `AppTheme.divider(context)` | Divider |
| 397 | `color: Colors.black.withOpacity(0.08)` | Keep (Subtle overlay) | Background tint |
| 412 | `Colors.black.withOpacity(0.80)` | Keep (Overlay) | Text overlay |
| 413 | `Colors.black.withOpacity(0.15)` | Keep (Overlay) | Text overlay |
| 708 | `color: Colors.white` | `AppTheme.card(context)` | Container |
| 746 | `color: Colors.white` | `AppTheme.card(context)` | Container |

#### Text & Icon Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 244 | `color: Color(0xFF94A3B8)` | `AppTheme.textLight(context)` | Hint |
| 263 | `color: Color(0xFF0F172A)` | `AppTheme.textDark(context)` | Title |
| 424 | `color: Colors.white` | Keep (On colored background) | Text on green |
| 435 | `color: Color(0xFFE2E8F0)` | `AppTheme.divider(context)` | Divider |
| 452 | `color: Color(0xFF0F172A)` | `AppTheme.textDark(context)` | Title |
| 466 | `color: Colors.white` | Keep (On colored background) | Icon on colored |
| 470 | `color: Colors.white` | Keep (On colored background) | Text on colored |
| 494 | `color: Colors.white` | Keep (On colored background) | Text on colored |
| 607 | `color: Colors.white` | Keep (On colored background) | Text on colored |
| 610 | `color: const Color(0xFFE2E8F0)` | `AppTheme.divider(context)` | Divider |
| 619 | `color: Color(0xFF94A3B8)` | `AppTheme.textLight(context)` | Hint |
| 628 | `color: Color(0xFFE2E8F0)` | `AppTheme.divider(context)` | Divider |
| 666 | `color: const Color(0xFF94A3B8)` | `AppTheme.textLight(context)` | Inactive |
| 667 | `color: const Color(0xFF0F172A)` | `AppTheme.textDark(context)` | Active |
| 696 | `color: Colors.white` | Keep (On colored background) | Text on orange |

#### Border Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 747 | `border: Border.all(color: const Color(0xFFE2E8F0))` | `AppTheme.border(context)` | Card border |
| 764 | `backgroundColor: const Color(0xFFF1F5F9)` | `AppTheme.divider(context)` | Chip background |

---

### 5. **goat_records.dart**

#### Background & Container Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 86 | `backgroundColor: AppTheme.card(context)` | ✓ Already using theme | (Already correct) |
| 204 | `backgroundColor: AppTheme.card(context)` | ✓ Already using theme | (Already correct) |
| 253 | `backgroundColor: AppTheme.bg(context)` | ✓ Already using theme | (Already correct) |
| 304 | `color: Colors.white` | `AppTheme.card(context)` | Container |
| 384 | `color: Colors.white` | `AppTheme.card(context)` | Container |
| 389 | `color: Colors.black.withOpacity(0.045)` | Keep (Shadow) | Box shadow |
| 408 | `color: const Color(0xFFF0F0EE)` | *Consider theme* | Container |
| 534 | `color: Colors.white` | `AppTheme.card(context)` | Container |

#### Text & Icon Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 106 | `color: Color(0xFF475569)` | `AppTheme.textMid(context)` | Subtitle |
| 127 | `color: Color(0xFF64748B)` | `AppTheme.textMid(context)` | Label |
| 210 | `color: Color(0xFF0F172A)` | `AppTheme.textDark(context)` | Title |
| 214 | `color: Color(0xFF64748B)` | `AppTheme.textMid(context)` | Subtitle |
| 217 | `color: Color(0xFF94A3B8)` | `AppTheme.textLight(context)` | Hint |
| 222 | `color: Color(0xFF94A3B8)` | `AppTheme.textLight(context)` | Hint |
| 241-422 | Color palette colors (green/orange) | Keep (Brand colors) | Goat type indicators |
| 453 | `color: Color(0xFF111111)` | `AppTheme.textDark(context)` or Keep | Dark text |
| 462 | `color: Color(0xFF555555)` | `AppTheme.textMid(context)` | Medium text |
| 478 | `color: Color(0xFF999999)` | `AppTheme.textLight(context)` | Light text |
| 487 | `color: Color(0xFF777777)` | `AppTheme.textMid(context)` | Medium text |
| 517 | `color: Color(0xFFCCCCCC)` | Keep or use lighter theme color | Placeholder |
| 521 | `color: Color(0xFFAAAAAA)` | `AppTheme.textLight(context)` | Light text |
| 548 | `color: Color(0xFF1A1A1A)` | `AppTheme.textDark(context)` | Dark text |
| 561 | `color: Color(0xFF64748B)` | `AppTheme.textMid(context)` | Label |
| 569 | `color: Color(0xFF94A3B8)` | `AppTheme.textLight(context)` | Hint |
| 596 | `color: Color(0xFF1A1A1A)` | `AppTheme.textDark(context)` | Dark text |

#### Input Field Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 570 | `fillColor: const Color(0xFFF8FAFC)` | `AppTheme.inputFill(context)` | Fill |
| 575 | `borderSide: const BorderSide(color: Color(0xFFE2E8F0))` | `AppTheme.inputBorder(context)` | Border |
| 578 | `borderSide: const BorderSide(color: Color(0xFFE2E8F0))` | `AppTheme.inputBorder(context)` | Border |
| 582 | `color: Color(0xFF2E7D32), width: 1.5` | Keep (Brand color focus) | Focused border |
| 598 | `fillColor: const Color(0xFFF8FAFC)` | `AppTheme.inputFill(context)` | Fill |
| 603 | `borderSide: const BorderSide(color: Color(0xFFE2E8F0))` | `AppTheme.inputBorder(context)` | Border |
| 606 | `borderSide: const BorderSide(color: Color(0xFFE2E8F0))` | `AppTheme.inputBorder(context)` | Border |
| 610 | `color: Color(0xFF2E7D32), width: 1.5` | Keep (Brand color focus) | Focused border |

#### Border/Divider Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 322 | `color: Color(0xFFE0E0E0)` | `AppTheme.border(context)` | Divider |
| 386 | `border: Border.all(color: const Color(0xFFE8E8E8), width: 1)` | `AppTheme.border(context)` | Border |
| 410 | `border: Border.all(color: const Color(0xFFE0E0E0), width: 0.8)` | `AppTheme.border(context)` | Border |

---

### 6. **weather_screen.dart**

#### Background Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 63 | `backgroundColor: const Color(0xFFF8F9FA)` | `AppTheme.bg(context)` | Scaffold |
| 67 | `backgroundColor: const Color(0xFF2E7D32)` | Keep (Brand color) | AppBar |

#### Text & Icon Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 201 | `color: Color(0xFF0F172A)` | `AppTheme.textDark(context)` | Title |
| 203 | `color: Color(0xFF64748B)` | `AppTheme.textMid(context)` | Subtitle |
| 224 | `color: Color(0xFF0F172A)` | `AppTheme.textDark(context)` | Title |
| 267 | `color: Color(0xFF0F172A)` | `AppTheme.textDark(context)` | Title |
| 275 | `color: Color(0xFF64748B)` | `AppTheme.textMid(context)` | Subtitle |
| 281 | `color: Color(0xFF0F172A)` | `AppTheme.textDark(context)` | Title |
| 284 | `color: Color(0xFF94A3B8)` | `AppTheme.textLight(context)` | Hint |
| 289 | `color: Color(0xFF1D4ED8)` | Keep (Status color) | Blue status |

#### Border/Container Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 193 | `color: Colors.white` | `AppTheme.card(context)` | Container |
| 195 | `border: Border.all(color: const Color(0xFFE2E8F0))` | `AppTheme.border(context)` | Border |
| 213 | `color: Colors.white` | `AppTheme.card(context)` | Container |
| 215 | `border: Border.all(color: const Color(0xFFE2E8F0))` | `AppTheme.border(context)` | Border |
| 259 | `color: Colors.white` | `AppTheme.card(context)` | Container |
| 261 | `border: Border.all(color: const Color(0xFFE2E8F0))` | `AppTheme.border(context)` | Border |

#### Status Badge Colors
| Line | Current Code | Note |
|------|-------------|------|
| 229 | `Color(0xFFFEF2F2)` and `Color(0xFFDC2626)` | Red status - Keep (Status) |
| 230 | `Color(0xFFFFF7ED)` and `Color(0xFFF57C00)` | Orange status - Keep (Status) |
| 231 | `Color(0xFFEFF6FF)` and `Color(0xFF1D4ED8)` | Blue status - Keep (Status) |
| 232 | `Color(0xFFDCFCE7)` and `Color(0xFF15803D)` | Green status - Keep (Status) |

---

### 7. **market_sales_screen.dart**

#### Background Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 67 | `backgroundColor: Colors.white` | `AppTheme.card(context)` | Modal |

#### Input Field Colors
- Check `_dropDeco()` method for hard-coded `Color(0xFFF8FAFC)` and `Color(0xFFE2E8F0)` → Use `AppTheme.inputFill(context)` and `AppTheme.inputBorder(context)`

---

### 8. **edit_farm_screen.dart**

#### Background Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 96 | `backgroundColor: const Color(0xFFF8F9FA)` | `AppTheme.bg(context)` | Scaffold |
| 98 | `backgroundColor: Colors.white` | `AppTheme.card(context)` | AppBar |
| 139 | `backgroundColor: const Color(0xFFF1F5F9)` | `AppTheme.divider(context)` | Container |

#### Text Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 99 | `foregroundColor: const Color(0xFF0F172A)` | `AppTheme.textDark(context)` | AppBar text |

#### Border Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 108 | `BorderSide(color: Color(0xFFE2E8F0), width: 1)` | `AppTheme.border(context)` | Bottom border |
| 135 | `border: Border.all(color: Colors.white, width: 3)` | Keep (Circle border) | Image border |
| 152 | `backgroundColor: Colors.white` | `AppTheme.card(context)` | Camera button |

---

### 9. **on_boarding_screen.dart**

#### Background Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 129 | `backgroundColor: Color(0xFF1B3A1F)` | Consider theme dark color or keep (brand) | Scaffold |
| 133 | `backgroundColor: const Color(0xFF1B3A1F)` | Consider theme dark color or keep (brand) | Scaffold |

#### Text Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 220 | `color: Color(0xFFE2E8F0)` | `AppTheme.divider(context)` or theme light text | Indicator |

#### Note on Overlays
Lines 166-169: Black opacity overlays on gradients (keep as-is - these are intentional overlay effects)

---

### 10. **splash_screen.dart**

#### Background Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 89 | `backgroundColor: const Color(0xFF1B3A1F)` | Consider theme dark color or keep (brand) | Scaffold |

#### Text Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 99 | `color: Colors.white` | Keep (On dark background) | Logo text |
| 121 | `color: Colors.white` | Keep (On dark background) | App name |

---

### 11. **change_password_screen.dart**

#### Background Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 66 | `backgroundColor: const Color(0xFFF8F9FA)` | `AppTheme.bg(context)` | Scaffold |
| 68 | `backgroundColor: Colors.white` | `AppTheme.card(context)` | AppBar |

#### Text Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| 69 | `foregroundColor: const Color(0xFF0F172A)` | `AppTheme.textDark(context)` | AppBar text |

---

### 12. **farm_chat_screen.dart**

#### Background Colors
| Line | Current Code | Replacement | Type |
|------|-------------|-------------|------|
| ~44 | `backgroundColor: Colors.white` | `AppTheme.card(context)` | Modal background |

#### Border/Divider Colors
- Check modal styling for `Colors.grey.shade300` → Consider theme divider
- Check message container borders

---

### 13. **analytics_screen.dart**

#### Note
This file primarily uses brand colors for chart visualization. Most colors should be kept as-is (they're categorical/status colors). Check for any generic background or text colors that need theme support.

---

## Color Replacement Reference

### Utility Function Conversions

```dart
// Instead of hard-coded colors, use:

// Background colors
scaffold bg:          AppTheme.bg(context)           // Light: #F8F9FA, Dark: #0F0F0F
scaffold bg2:         AppTheme.bg2(context)          // Light: #F0F4F0, Dark: #1A1A1A
card bg:              AppTheme.card(context)         // Light: white, Dark: #1A1A1A

// Text colors
text (dark/primary):  AppTheme.textDark(context)     // Light: #0F172A, Dark: white
text (medium/sec):    AppTheme.textMid(context)      // Light: #475569, Dark: white60
text (light/hint):    AppTheme.textLight(context)    // Light: #94A3B8, Dark: white54

// Input field colors
input fill:           AppTheme.inputFill(context)    // Light: white, Dark: #1A1A1A
input border:         AppTheme.inputBorder(context)  // Light: #E2E8F0, Dark: white12
input text:           AppTheme.inputText(context)    // Light: black, Dark: white

// Dividers & borders
border:               AppTheme.border(context)       // Light: #E2E8F0, Dark: white12
divider:              AppTheme.divider(context)      // Light: #F1F5F9, Dark: white8

// Brand colors (keep as constants)
green (brand):        AppTheme.green                 // #2E7D32
orange (brand):       AppTheme.orange                // #F57C00
red (brand):          AppTheme.red                   // #DC2626
blue (brand):         AppTheme.blue                  // #1D4ED8

// Brand tints (semi-transparent, theme-aware)
green tint:           AppTheme.accentTint(context)
orange tint:          AppTheme.orangeTint(context)
purple tint:          AppTheme.purpleTint(context)
red tint:             AppTheme.redTint(context)
```

---

## Priority Migration Order

1. **High Priority** - Affects user experience in light/dark mode:
   - Scaffold background colors (bg, bg2)
   - Text colors (dark, mid, light)
   - Input field fills and borders
   - Card/Container backgrounds

2. **Medium Priority** - Visual consistency:
   - Border colors
   - Divider colors
   - Subtitle and hint text colors

3. **Low Priority** - Keep as constants:
   - Brand colors (green, orange, red, blue)
   - Status colors (overdue, due_soon, etc.)
   - Black/white overlays on colored backgrounds

---

## Files Already Using AppTheme ✓

- `home_screen.dart` - Already uses `AppTheme.bg(context)` and `AppTheme.card(context)` in key places
- `goat_records.dart` - Already uses `AppTheme.bg(context)`, `AppTheme.card(context)`, and `AppTheme.inputFill(context)`
- `settings_screen.dart` - **EXCLUDED** (already implements full dark mode support)

---

## Next Steps

1. Create a migration script or manual updates for each file
2. Test theme switching (light/dark mode) after each update
3. Verify all text is readable in both light and dark modes
4. Check input field visibility and contrast
5. Validate brand colors remain consistent

---

**Report Generated:** 2026-06-17
