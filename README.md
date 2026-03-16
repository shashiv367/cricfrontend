# SportBet Flutter Application

A modern sports betting application built with Flutter, featuring a beautiful purple-themed UI.

## Features

- **Home Screen**: Browse sports categories and featured betting options
- **Soccer Screen**: View live matches, trending bets, and place wagers
- **My Bets Screen**: Track placed bets and view past betting history
- **Bottom Navigation**: Easy navigation between Games, My Bets, Messages, and Profile
- **Modern UI**: Purple color scheme with clean, intuitive design

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Navigate to the frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/                  # Screen widgets
│   ├── home_screen.dart
│   ├── soccer_screen.dart
│   ├── my_bets_screen.dart
│   ├── games_screen.dart
│   ├── messages_screen.dart
│   └── profile_screen.dart
├── widgets/                  # Reusable widgets
│   ├── bottom_nav_bar.dart
│   ├── featured_card.dart
│   ├── sport_category_item.dart
│   ├── match_card.dart
│   └── past_bet_item.dart
└── utils/                    # Utilities
    └── app_colors.dart
```

## Design

The app follows a purple color scheme with:
- Primary Purple: #6B46C1
- Accent Yellow: #FCD34D
- Success Green: #10B981
- Error Red: #EF4444

## Screens

1. **Home Screen**: Displays featured betting cards and sports categories
2. **Soccer Screen**: Shows live matches with betting options and tabs (All, Trending, Upcoming, World Cup)
3. **My Bets Screen**: Displays placed bets and past betting history with results

## Development

This is a Flutter application. For more information about Flutter, visit [flutter.dev](https://flutter.dev).










