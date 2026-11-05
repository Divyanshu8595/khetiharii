# Khetiharii 🌾

A farmer-first crop marketplace built with Flutter and Firebase.

Khetiharii is designed to help farmers publish crop availability and connect directly with buyers. The current implementation includes email/password authentication, farmer/buyer account roles, crop listing creation and discovery, buyer order requests, and a farmer order inbox.

## Current marketplace scope

| Capability | Implementation |
|---|---|
| Email/password registration and sign-in | Firebase Authentication |
| Farmer and buyer roles | Firestore user profiles |
| Publish crop listings | Firestore `crop_listings` |
| Search active crops | Firestore prefix search |
| Request to buy available quantity | Firestore transaction |
| Buyer order history | Firestore query |
| Farmer request inbox | Firestore query |
| Accept, decline and complete orders | Role-checked Firestore updates |
| Data access control | `firestore.rules` |

## Stack

- Flutter / Dart
- Firebase Authentication
- Cloud Firestore
- Provider (legacy cart demo remains during migration)

## Firebase setup

The Android Firebase configuration is already present in `android/google-services.json`. Its Android package identifier must match `com.example.khetiharii` (the Gradle namespace/application ID in this repository).

1. Install Flutter and Firebase CLI.
2. Install dependencies: `flutter pub get`.
3. Enable **Email/Password** in Firebase Authentication.
4. Create a Cloud Firestore database.
5. Deploy rules and indexes:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes
   ```
6. Run on Android: `flutter run`.

The checked-in Firebase configuration only covers Android. Before running on iOS, web, macOS, Windows or Linux, configure each platform using FlutterFire CLI and provide its generated platform options. Do not assume Android configuration automatically configures other targets.

## Data model

### `users/{uid}`
- `uid`, `name`, `email`, `role` (`farmer` or `buyer`), `createdAt`

### `crop_listings/{listingId}`
- `farmerId`, `farmerName`, `cropName`, `cropNameLower`, `variety`, `description`
- `quantity`, `unit`, `pricePerUnit`
- `village`, `district`, `state`, `createdAt`, `status`

### `marketplace_orders/{orderId}`
- `listingId`, `buyerId`, `farmerId`, `cropName`
- `quantity`, `unit`, `unitPrice`, `totalPrice`, `status`, `createdAt`

## Important production work still required

- Inventory reservation and order creation should be moved to a trusted callable Cloud Function. The current client transaction validates listing availability and creates a request, but intentionally does not decrement stock; client-side stock writes are not trusted.
- Add server-side validation, rate limiting, audit logging and abuse protection.
- Add phone verification and verified farmer/business profiles.
- Add crop images using Firebase Storage with strict upload rules.
- Add payment integration only after settlement, refunds, dispute handling and legal requirements are designed.
- Add pagination, offline behavior, localization and accessibility checks.
- Add emulator-based Firestore rules tests and CI.

## Quality checks

Before release, run:

```bash
dart format .
flutter pub get
flutter analyze
flutter test
```

## Security

Review `firestore.rules` against your actual business requirements before production deployment. Never ship service-account credentials in the mobile app.
