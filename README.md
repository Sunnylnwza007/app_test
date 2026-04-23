# QuickNote

A fast, lightweight, fully responsive note-taking app for Flutter — inspired by Obsidian. Works seamlessly on **mobile**, **tablet**, **desktop**, and **web**.

---

## ✨ Features

- 📝 **Fast note creation** — Create, edit and delete notes instantly
- 🔍 **Full-text search** — Find notes by title, content or tags
- 📌 **Pin notes** — Keep important notes at the top
- ✍️ **Markdown editor** — Write in Markdown with a formatting toolbar
- 👁️ **Live preview** — Toggle between edit and rendered Markdown view
- 📊 **Word/char count** — Real-time writing stats in the status bar
- 🏷️ **Tags** — Organise notes with tags
- 💾 **Local storage** — All notes saved locally via `shared_preferences`
- 🌑 **Dark / Light theme** — Toggle between Obsidian-style dark and light modes
- 📱 **Fully responsive** — Adaptive sidebar layout on desktop/tablet; card list + navigation on mobile

---

## 📐 Responsive Layout

| Screen width | Layout |
|---|---|
| ≥ 900 px (desktop) | Sidebar (280 px) + note editor side-by-side |
| 600–900 px (tablet) | Same as desktop |
| < 600 px (mobile) | Note list with FAB; editor opens as a full-screen route |

---

## 🛠️ Tech Stack

| Package | Purpose |
|---|---|
| `provider` | State management |
| `shared_preferences` | Local persistence |
| `flutter_markdown` | Markdown rendering |
| `google_fonts` | Typography (Inter) |
| `uuid` | Unique note IDs |
| `intl` | Date formatting |

---

## 🚀 Getting Started

### Prerequisites
- Flutter ≥ 3.0.0
- Dart ≥ 3.0.0

### Run

```bash
flutter pub get
flutter run
```

### Test

```bash
flutter test
```

### Build

```bash
# Android
flutter build apk

# Web
flutter build web

# iOS (macOS only)
flutter build ios

# Desktop
flutter build linux   # Linux
flutter build windows # Windows
flutter build macos   # macOS
```
