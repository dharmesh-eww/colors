enum BottleInteractionMode {
  drag,
  tap,
}

extension BottleInteractionModeExtension on BottleInteractionMode {
  String get displayName {
    switch (this) {
      case BottleInteractionMode.drag:
        return 'Drag to Mix';
      case BottleInteractionMode.tap:
        return 'Tap & Hold to Mix';
    }
  }

  String get description {
    switch (this) {
      case BottleInteractionMode.drag:
        return 'Drag bottle from shelf into mixing tile to pour';
      case BottleInteractionMode.tap:
        return 'Tap or hold bottle in shelf to pour into mixing tile';
    }
  }
}
