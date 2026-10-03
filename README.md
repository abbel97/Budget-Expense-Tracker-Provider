# Expense Tracker

Expense Tracker is a Flutter application for recording income and expenses,
monitoring a budget, and viewing spending activity over time. It supports
account registration and sign-in, transaction CRUD operations, budget
calculation, category summaries, and weekly, monthly, and yearly charts.

> Current status: functional prototype. The app is suitable for development
> and demonstration, but the authentication and API architecture must be
> replaced before a production release.

## Features

- Welcome, registration, and sign-in screens.
- Duplicate-email protection with the message `Account already registered. Please sign in.`
- Email normalization for registration and sign-in.
- Monthly budget configuration.
- Add income or expense transactions.
- Edit and delete transactions.
- Expense categories and category icons.
- Current balance, total income, total expenses, and savings calculations.
- Weekly, monthly, and yearly spending charts.
- Pull-to-refresh for transaction data.
- Per-account expense filtering using the normalized account email.
- Loading, network, server, and validation error states.

## Technology Stack

- Flutter and Dart
- Provider for application state management
- `http` for REST API requests
- MockAPI for the current expense data endpoint
- SharedPreferences for local prototype account/session state
- `fl_chart` for charts
- `intl` for currency and date formatting
- `flutter_lints` and `flutter_test` for code quality and testing

## Requirements

Install the following before running the project:

- Flutter SDK compatible with Dart `^3.11.1`
- Android Studio and an Android SDK for Android development, or
- Xcode and CocoaPods for iOS development on macOS
- A configured emulator, simulator, or physical device

Verify the Flutter installation with:

```bash
flutter doctor
```

## Installation

From the project root:

```bash
flutter pub get
```

List available devices:

```bash
flutter devices
```

Run the application:

```bash
flutter run
```

Run on a specific device:

```bash
flutter run -d <device-id>
```

## Data Model

Each expense record contains:

| Field | Description |
| --- | --- |
| `id` | API-generated transaction identifier |
| `ownerEmail` | Normalized account email that owns the record |
| `title` | Transaction title |
| `amount` | Positive numeric amount |
| `type` | `income` or `expense` |
| `category` | Category such as Food & Drinks, Salary, or Transport |
| `date` | ISO-8601 timestamp |

## Authentication and Storage

The current prototype stores the following values in SharedPreferences:

- `userName`
- `userEmail`
- `userPassword`
- `userBudget`
- `isLoggedIn`

This is intentionally simple for local development. SharedPreferences is not
a secure authentication system, and the current implementation stores the
password locally. Do not use this authentication design for real users or
sensitive financial data.

## Screenshots

<p align="center">
  <img src="screenshots/welcome page.jpg" width="250"/>
  <img src="screenshots/home page.jpg" width="250"/>
  <img src="screenshots/add image.jpg" width="250"/>
  <img src="screenshots/edit image.jpg" width="250"/>
  <img src="screenshots/delete image.jpg" width="250"/>
</p>