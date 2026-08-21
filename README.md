<div align="center">
  <img src="assets/images/app_icon.png" alt="All-in-One Lifestyle App icon" width="120" />

  # All-in-One Lifestyle App

  **One Flutter app for the everyday things that matter.**

  Explore products and recipes, discover posts and quotes, organize todos,
  manage your cart, and interact with users through a clean, unified experience.

  [![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
  [![DummyJSON](https://img.shields.io/badge/API-DummyJSON-6C63FF)](https://dummyjson.com/)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
</div>

## About

All-in-One Lifestyle App is a cross-platform Flutter application that brings
shopping, inspiration, content, and daily planning into one place. It is built
as a practical showcase of REST API integration, reusable UI components,
responsive layouts, asynchronous state handling, and CRUD workflows in Flutter.

The application uses [DummyJSON](https://dummyjson.com/) as its backend service.

## Features

- **Authentication** — Sign in with a valid DummyJSON account.
- **Products** — Browse, search, filter by category, and view product details.
- **Shopping cart** — Add products and update item quantities.
- **Recipes** — Explore recipes and view ingredients and instructions.
- **Posts and comments** — Browse, search, create, edit, and delete content.
- **Todos** — Add, update, filter, complete, and remove daily tasks.
- **Quotes** — Discover a collection of memorable quotes.
- **Users** — Browse profiles and perform user management actions.
- **Polished UI states** — Loading skeletons, feedback messages, empty states,
  and error states.
- **Cross-platform foundation** — Android, iOS, web, macOS, Windows, and Linux.

## Built With

- [Flutter](https://flutter.dev/) and [Dart](https://dart.dev/)
- [Material Design](https://m3.material.io/)
- [`http`](https://pub.dev/packages/http) for REST API communication
- [DummyJSON REST API](https://dummyjson.com/docs)
- Flutter Test for widget and interaction tests

## Project Structure

```text
lib/
├── core/          # Theme, colors, spacing, typography, and navigation
├── models/        # Application data models
├── screens/       # Feature screens and user flows
├── services/      # DummyJSON API clients
├── widgets/       # Shared and reusable UI components
└── main.dart      # Application entry point
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Dart SDK (included with Flutter)
- An emulator, simulator, browser, or connected device

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/emiresers/all-in-one-lifestyle-app.git
   cd all-in-one-lifestyle-app
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Check the available devices:

   ```bash
   flutter devices
   ```

4. Run the application:

   ```bash
   flutter run
   ```

Use any valid test account listed in the
[DummyJSON authentication documentation](https://dummyjson.com/docs/auth) to
sign in.

## Testing

Run the test suite with:

```bash
flutter test
```

The project includes tests for the splash experience and product-card
interactions, along with the default widget test foundation.

## API Behavior

DummyJSON is a mock REST API. Create, update, and delete requests return
realistic responses, but the changes are simulated and are not permanently
stored on the server.

## Roadmap

- Add local favorites and persistent session support
- Introduce state management and offline caching
- Expand automated test coverage
- Add localization and dark mode
- Publish production builds for mobile and web

## Contributing

Contributions are welcome. Fork the repository, create a feature branch, and
open a pull request with a clear description of your changes.

## License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">
  Built with Flutter and powered by DummyJSON.
</div>
