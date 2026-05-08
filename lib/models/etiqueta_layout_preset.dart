enum EtiquetaLayoutPreset {
  mm60x40,
  mm100x80;

  String get label {
    switch (this) {
      case EtiquetaLayoutPreset.mm60x40:
        return '60 x 40 mm';
      case EtiquetaLayoutPreset.mm100x80:
        return '100 x 80 mm';
    }
  }

  double get larguraMm {
    switch (this) {
      case EtiquetaLayoutPreset.mm60x40:
        return 60;
      case EtiquetaLayoutPreset.mm100x80:
        return 100;
    }
  }

  double get alturaMm {
    switch (this) {
      case EtiquetaLayoutPreset.mm60x40:
        return 40;
      case EtiquetaLayoutPreset.mm100x80:
        return 80;
    }
  }

  String get storageKey {
    switch (this) {
      case EtiquetaLayoutPreset.mm60x40:
        return '60x40';
      case EtiquetaLayoutPreset.mm100x80:
        return '100x80';
    }
  }
}

extension EtiquetaLayoutPresetX on EtiquetaLayoutPreset {
  static EtiquetaLayoutPreset fromStorageKey(String? value) {
    switch (value) {
      case '100x80':
        return EtiquetaLayoutPreset.mm100x80;
      case '60x40':
      default:
        return EtiquetaLayoutPreset.mm60x40;
    }
  }
}