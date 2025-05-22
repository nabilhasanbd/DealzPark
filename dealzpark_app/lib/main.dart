import 'package:flutter/material.dart';
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
    return ChangeNotifierProvider(
      create: (ctx) => OfferProvider(),
      child: MaterialApp(
        title: 'DealzPark',
        theme: ThemeData(
          primaryColor: const Color(0xFF6A1B9A), // Deep Purple
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF6A1B9A), // Deep Purple
            secondary: const Color(0xFF00ACC1), // Cyan Accent
            // error for red accents like discount tags
            error: Colors.redAccent,
          ),
          scaffoldBackgroundColor: Colors.grey[100], // Light grey background
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF6A1B9A), // Deep Purple
            elevation: 0, // Flat app bar
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
           elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}