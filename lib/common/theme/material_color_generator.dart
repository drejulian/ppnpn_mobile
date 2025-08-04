part of 'my_theme.dart';

MaterialColor _generateMaterialColor(Color color) {
  final int a = (color.a * 255).round();
  final int r = (color.r * 255).round();
  final int g = (color.g * 255).round();
  final int b = (color.b * 255).round();

  final int colorValue = (a << 24) | (r << 16) | (g << 8) | b;

  return MaterialColor(colorValue, {
    50: _tintColor(color, 0.9),
    100: _tintColor(color, 0.8),
    200: _tintColor(color, 0.6),
    300: _tintColor(color, 0.4),
    400: _tintColor(color, 0.2),
    500: color,
    600: _shadeColor(color, 0.1),
    700: _shadeColor(color, 0.2),
    800: _shadeColor(color, 0.3),
    900: _shadeColor(color, 0.4),
  });
}

int _tintValue(int value, double factor) =>
    max(0, min((value + ((255 - value) * factor)).round(), 255));

Color _tintColor(Color color, double factor) => Color.fromRGBO(
  _tintValue((color.r * 255).round(), factor),
  _tintValue((color.g * 255).round(), factor),
  _tintValue((color.b * 255).round(), factor),
  1,
);

int _shadeValue(int value, double factor) =>
    max(0, min(value - (value * factor).round(), 255));

Color _shadeColor(Color color, double factor) => Color.fromRGBO(
  _shadeValue((color.r * 255).round(), factor),
  _shadeValue((color.g * 255).round(), factor),
  _shadeValue((color.b * 255).round(), factor),
  1,
);
