# Front-end Test Vista

Flutter app for managing companies and their services. It connects to the
`back-end-test-vista` REST API.

**Tech stack:** Flutter, Provider (state management), http

## Features

- Company list showing name, registration number and the services under each company
- Create company form with validation (non-empty fields)
- Create service form with validation (non-empty fields, numeric price) and a company dropdown
- Loading indicators and error messages for all API calls
- Simple responsive layout (content is centred and width-limited on wide screens)

## Prerequisites

- Flutter SDK
- The backend running (see the `back-end-test-vista` repository)

## Setup

1. Install dependencies:

   ```bash
   flutter pub get
   ```

2. Check the API address in `lib/api_service.dart`:

   ```dart
   const baseUrl = 'http://localhost:3000';
   ```

   - Chrome / iOS simulator: `http://localhost:3000`
   - Android emulator: `http://10.0.2.2:3000`
   - Real device: your computer's local IP, for example `http://192.168.1.10:3000`

## Run

Start the backend first, then:

```bash
flutter run -d chrome
```

## Project structure

```
lib/main.dart                              App entry point and theme
lib/models.dart                            Company and Service models
lib/api_service.dart                       HTTP calls to the backend
lib/app_provider.dart                      State management (Provider)
lib/screens/company_list_screen.dart       List of companies and services
lib/screens/create_company_screen.dart     Create company form
lib/screens/create_service_screen.dart     Create service form
```