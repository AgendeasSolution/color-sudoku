# Color Sudoku - Project Structure

This document outlines the organized structure of the Color Sudoku Flutter project.

## 📁 Project Structure

```
lib/
├── constants/
│   └── app_constants.dart          # All app constants, colors, configurations
├── models/
│   ├── cell_position.dart          # Cell position model
│   ├── game_state.dart             # Game state model
│   ├── modal_types.dart            # Modal types and content
│   └── models.dart                 # Barrel file for models
├── screens/
│   └── game_screen.dart            # Main game screen
├── services/
│   ├── game_logic_service.dart     # Core game logic
│   ├── solver_service.dart         # Game solver algorithm
│   └── services.dart               # Barrel file for services
├── utils/
│   ├── color_utils.dart            # Color-related utilities
│   ├── validation_utils.dart       # Game validation utilities
│   └── utils.dart                  # Barrel file for utils
├── widgets/
│   ├── components/
│   │   ├── ball.dart               # Ball widget
│   │   ├── color_ball.dart         # Color ball with count
│   │   ├── game_button.dart        # Game action buttons
│   │   ├── grid_cell.dart          # Grid cell widget
│   │   └── level_badge.dart        # Level indicator
│   ├── modals/
│   │   ├── modal_button.dart       # Modal action button
│   │   ├── modal_container.dart    # Modal container
│   │   └── startup_modal.dart      # Game startup modal
│   └── widgets.dart                # Barrel file for widgets
└── main.dart                       # App entry point
```

## 🏗️ Architecture Overview

### Constants (`/constants`)

- **app_constants.dart**: Centralized configuration including colors, animations, spacing, fonts, and game settings

### Models (`/models`)

- **cell_position.dart**: Represents a position in the game grid
- **game_state.dart**: Immutable game state with copyWith functionality
- **modal_types.dart**: Modal types, actions, and content provider

### Services (`/services`)

- **game_logic_service.dart**: Core game logic including path generation, validation, and state management
- **solver_service.dart**: AI solver algorithm for the game

### Utils (`/utils`)

- **color_utils.dart**: Color-related helper functions
- **validation_utils.dart**: Game validation and rule checking

### Widgets (`/widgets`)

- **components/**: Reusable UI components
- **modals/**: Modal dialogs and overlays

### Screens (`/screens`)

- **game_screen.dart**: Main game interface with state management

## 🎯 Key Features

### Separation of Concerns

- **Models**: Pure data classes with no business logic
- **Services**: Business logic and algorithms
- **Utils**: Pure functions for common operations
- **Widgets**: UI components with minimal logic
- **Screens**: UI orchestration and state management

### Immutable State Management

- Game state is immutable with `copyWith` methods
- Predictable state updates
- Easy to test and debug

### Reusable Components

- Modular widget design
- Consistent styling through constants
- Easy to maintain and extend

### Clean Architecture

- Clear separation between UI and business logic
- Testable services and utilities
- Scalable structure for future features

## 🚀 Usage

### Importing

Use barrel files for clean imports:

```dart
// Instead of multiple imports
import 'package:color_sudoku/models/cell_position.dart';
import 'package:color_sudoku/models/game_state.dart';

// Use barrel file
import 'package:color_sudoku/models/models.dart';
```

### Adding New Features

1. **New Models**: Add to `/models` and export in `models.dart`
2. **New Services**: Add to `/services` and export in `services.dart`
3. **New Widgets**: Add to appropriate subfolder in `/widgets`
4. **New Screens**: Add to `/screens`
5. **New Constants**: Add to `app_constants.dart`

## 📝 Best Practices

1. **Constants**: All magic numbers and strings should be in `app_constants.dart`
2. **Models**: Keep models simple and immutable
3. **Services**: Keep services pure and testable
4. **Widgets**: Keep widgets focused and reusable
5. **Imports**: Use barrel files for cleaner imports
6. **Naming**: Use descriptive names following Dart conventions

This structure follows Flutter best practices and makes the codebase maintainable, testable, and scalable.
