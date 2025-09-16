import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

part 'material_color_generator.dart';
part 'my_typography.dart';

class MyTheme {
  MaterialColor primarySwatch = _generateMaterialColor(
    const Color.fromARGB(255, 178, 0, 191),
  );
  MaterialColor secondarySwatch = _generateMaterialColor(
    const Color.fromARGB(255, 201, 43, 222),
  );

  List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      spreadRadius: 2,
      blurRadius: 7,
      offset: const Offset(0, 3),
    ),
  ];

  MyTypography typographyRegular = MyTypography(
    headingLarge: GoogleFonts.poppins(
      fontWeight: FontWeight.w400,
      fontSize: 48,
    ),
    headingMedium: GoogleFonts.poppins(
      fontWeight: FontWeight.w400,
      fontSize: 32,
    ),
    headingSmall: GoogleFonts.poppins(
      fontWeight: FontWeight.w400,
      fontSize: 24,
    ),
    bodyLarge: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 18),
    bodyMedium: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 16),
    bodySmall: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 14),
    bodyExtraSmall: GoogleFonts.poppins(
      fontWeight: FontWeight.w400,
      fontSize: 12,
    ),
    titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 18),
  );

  MyTypography typographyLight = MyTypography(
    headingLarge: GoogleFonts.poppins(
      fontWeight: FontWeight.w300,
      fontSize: 48,
    ),
    headingMedium: GoogleFonts.poppins(
      fontWeight: FontWeight.w300,
      fontSize: 32,
    ),
    headingSmall: GoogleFonts.poppins(
      fontWeight: FontWeight.w300,
      fontSize: 24,
    ),
    bodyLarge: GoogleFonts.poppins(fontWeight: FontWeight.w300, fontSize: 18),
    bodyMedium: GoogleFonts.poppins(fontWeight: FontWeight.w300, fontSize: 16),
    bodySmall: GoogleFonts.poppins(fontWeight: FontWeight.w300, fontSize: 14),
    bodyExtraSmall: GoogleFonts.poppins(
      fontWeight: FontWeight.w300,
      fontSize: 12,
    ),
    titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w300, fontSize: 18),
  );

  MyTypography typographyBold = MyTypography(
    headingLarge: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 48,
    ),
    headingMedium: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 32,
    ),
    headingSmall: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 24,
    ),
    bodyLarge: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 18),
    bodyMedium: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16),
    bodySmall: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
    bodyExtraSmall: GoogleFonts.poppins(
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ),
    titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 18),
  );

  ThemeData buildLightTheme(BuildContext context) {
    return ThemeData(
      primarySwatch: primarySwatch,
      scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBarTheme: AppBarTheme(
        backgroundColor: primarySwatch,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey,
        elevation: 0,
        titleTextStyle: typographyBold.bodyLarge.copyWith(color: Colors.black),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
    );
  }

  ThemeData buildDarkTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      primaryColor: primarySwatch,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySwatch,
        foregroundColor: Colors.white,
        shadowColor: Colors.grey[800],
        elevation: 0.5,
        titleTextStyle: typographyBold.bodyLarge.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }

  Widget loadingIndicator({Color? color, double? size}) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color ?? primarySwatch),
        strokeWidth: size ?? 4.0,
      ),
    );
  }
}
