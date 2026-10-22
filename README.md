# Smart Fridge Food & Expiry Management System

A distributed IoT and cross-platform Flutter application engineered to eliminate domestic food waste, automate grocery intake/extraction logging, track shelf-life expiry, and dynamically suggest zero-waste recipes using Google Gemini 1.5 Flash Vision.

---

## Architecture & Implementation Roadmap

For the full end-to-end engineering breakdown, architecture diagrams, and phase-by-phase deliverables, see:
* **[IMPLEMENTATION_PHASES.md](file:///Users/hello/food_management/IMPLEMENTATION_PHASES.md)**
* **[UI_DESIGN_SYSTEM.md](file:///Users/hello/food_management/ui/UI_DESIGN_SYSTEM.md)** — Comprehensive UI/UX design tokens, typography, component inventory, and screen specifications.

---

## Current Status

* **Phase 1: Project Scaffolding & Foundation** — `COMPLETED` (Material 3 dual-theme, GoRouter navigation shell, Riverpod setup)
* **Phase 2: Core Data Models & Local Mock Repository** — `COMPLETED` (Domain models, ExpiryCalculator, Mock repository, 17/17 tests passing)
* **Phase 3: Core UI Screens & User Flows** — `NEXT IN QUEUE` (Dashboard, My Fridge, Expiry Calendar, Add/Edit Item Form)
* **Phase 4: Firebase Integration (Auth & Realtime Firestore)** — `PLANNED`
* **Phase 5: Cloud Functions & AI Vision Ingestion Pipeline** — `PLANNED`
* **Phase 6: Zero-Waste Recipe Recommendation Engine** — `PLANNED`
* **Phase 7: ESP32-S3 CAM Edge Hardware Integration** — `PLANNED`
* **Phase 8: System Hardening & End-to-End Acceptance** — `PLANNED`

---

## Development & Testing Commands

```bash
# Verify static analysis
flutter analyze

# Run unit and widget test suite
flutter test

# Run app on Chrome Web
flutter run -d chrome

# Run app on macOS Desktop
flutter run -d macos
```

---

## Design System & Standards

* **UI Aesthetics:** Material 3 with dedicated Light Mode and Dark Mode palettes. Zero hardcoded colors.
* **Vector Iconography:** Strictly zero emojis throughout code and UI.
* **Security:** Zero API keys on edge hardware or client devices. All AI calls route through Google Cloud Secret Manager and Firebase Cloud Functions v2.
