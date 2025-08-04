part of 'my_theme.dart';

class MyTypography {
  const MyTypography({
    required this.headingLarge,
    required this.headingMedium,
    required this.headingSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.bodyExtraSmall,
    required this.titleMedium, // Add this to the constructor
  });

  final TextStyle headingLarge;

  final TextStyle headingMedium;

  final TextStyle headingSmall;

  final TextStyle bodyLarge;

  final TextStyle bodyMedium;

  final TextStyle bodySmall;

  final TextStyle bodyExtraSmall;

  final TextStyle titleMedium; // Define it as a final TextStyle
}
