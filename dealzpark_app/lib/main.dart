import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // You might need to add google_fonts to pubspec.yaml
import 'package:provider/provider.dart';
import 'providers/offer_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define primary and accent colors (similar to Groupon's green/teal, but you can choose)
    const Color primaryColor = Color(0xFF00838F); // A teal/cyan like color
    const Color accentColor = Color(0xFF00BFA5);  // A brighter accent

    return ChangeNotifierProvider(
      create: (ctx) => OfferProvider(),
      child: MaterialApp(
        title: 'DealzPark',
        theme: ThemeData(
          primaryColor: primaryColor,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: primaryColor,
            secondary: accentColor, // Used for FAB, buttons
            error: Colors.redAccent, // For discount badges
            background: Colors.grey[100], // Light background
          ),
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: AppBarTheme(
            backgroundColor: primaryColor,
            elevation: 1,
            titleTextStyle: GoogleFonts.lato( // Using Google Fonts for a cleaner look
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Slightly less rounded buttons
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold),
            ),
          ),
          textTheme: GoogleFonts.latoTextTheme( // Apply Lato to all text
            Theme.of(context).textTheme,
          ).copyWith(
            titleLarge: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
            titleMedium: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
            bodyMedium: GoogleFonts.lato(fontSize: 14),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}