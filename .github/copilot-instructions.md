# Copilot Instructions for NTI E-Commerce Flutter Project

## Project Overview

- **Type:** Flutter mobile app (NTI Graduation Project)
- **Purpose:** Modern e-commerce app with Firebase backend, responsive UI, and Cubit/BLoC state management.
- **Key Features:** Authentication, product catalog, user profile, search with history, responsive design, and Firestore integration.

## Architecture & Patterns

- **Directory Structure:**
  - `lib/core/`: Shared constants, utilities, widgets, and themes.
  - `lib/features/`: Feature-based modules (auth, products, cart, etc.), each with its own `cubits`, `models`, `screens`, and `widgets`.
  - `lib/services/`: App-wide services (Firebase, Hive, seeding, etc.).
- **State Management:**
  - Uses Cubit/BLoC (`flutter_bloc`) for all business logic and UI state.
  - Each feature has its own Cubit and State classes (see `lib/features/products/cubits/products_cubit.dart`).
- **Data Models:**
  - `ProductModel` and `UserModel` use `Equatable` for value equality and JSON serialization.
- **Persistence:**
  - Product and user data stored in Firestore.
  - Search history stored locally using Hive (see `HiveService`).
- **Seeding:**
  - Use `SeedService.seedProducts()` to populate Firestore with sample products (trigger via UI or debug action).

## Developer Workflows

- **Build:**
  - Standard Flutter build: `flutter run`, `flutter build apk`, etc.
- **Test:**
  - Tests (if present) are in `test/` or alongside features. Run with `flutter test`.
- **Firebase:**
  - Requires valid `google-services.json` (Android) and Firebase setup.
- **Local Storage:**
  - Hive is initialized at app startup. Search history is managed via `HiveService`.
- **Responsive Design:**
  - Use `ResponsiveHelper` for adaptive layouts and font sizes.

## Project Conventions

- **Feature-first organization:**
  - All code for a feature (UI, logic, models) is grouped under `lib/features/<feature>/`.
- **State changes:**
  - UI listens to Cubit state via `BlocBuilder`.
- **Error handling:**
  - Errors are surfaced via state classes (e.g., `ProductsError`, `AuthError`) and shown in the UI with `EmptyStateWidget`.
- **Search:**
  - Search queries update both UI and Hive search history.
- **Seeding:**
  - Seeding is idempotent and should only be run in development/debug.

## Integration Points

- **Firebase:**
  - Auth, Firestore, and Storage are used. See `pubspec.yaml` for dependencies.
- **Hive:**
  - Used for local persistence (search history, etc.).
- **Navigation:**
  - Uses named routes defined in `AppRoutes`.

## Examples

- **Product Search:**
  - `ProductsCubit.searchProducts(query)` filters products in-memory; search history is managed by `HiveService`.
- **Error UI:**
  - `EmptyStateWidget` is used for all empty/error states in product and other screens.

## Key Files

- `lib/features/products/cubits/products_cubit.dart` (product logic)
- `lib/features/auth/cubits/auth_cubit.dart` (auth logic)
- `lib/services/hive_service.dart` (local storage)
- `lib/services/seed_service.dart` (data seeding)
- `lib/core/utils/responsive_helper.dart` (responsive design)

---

For questions about unclear patterns or missing documentation, ask for clarification or check the README for updates.
