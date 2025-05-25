import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure this is in your pubspec.yaml
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
    // Define core colors
    // Groupon often uses a green or teal. Let's go with a modern, clean teal.
    const Color primaryColor = Color(0xFF00838F); // A deeper teal
    const Color accentColor = Color(0xFF00BFA5);  // A brighter teal/mint for accents (FAB, buttons)
    const Color errorColor = Colors.redAccent;    // For discount badges, error messages
    const Color lightBackgroundColor = Color(0xFFF5F5F5); // Very light grey for backgrounds
    const Color darkTextColor = Color(0xFF333333);
    const Color lightTextColor = Color(0xFF555555);

    // Create a base text theme with Lato
    final TextTheme baseTextTheme = GoogleFonts.latoTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    );

    return ChangeNotifierProvider(
      create: (ctx) => OfferProvider(),
      child: MaterialApp(
        title: 'DealzPark',
        theme: ThemeData(
          // --- Color Scheme ---
          primaryColor: primaryColor,
          colorScheme: ColorScheme.fromSwatch(
            // Using fromSwatch can be a bit restrictive if you want full control.
            // Consider ColorScheme.light for more direct assignments.
            primarySwatch: _createMaterialColor(primaryColor), // Create a MaterialColor from primaryColor
          ).copyWith(
            primary: primaryColor,
            secondary: accentColor, // Used for FAB, buttons
            error: errorColor,
            background: lightBackgroundColor, // Main background for scaffold
            onPrimary: Colors.white, // Text/icon color on primaryColor
            onSecondary: Colors.white, // Text/icon color on accentColor
            onError: Colors.white,
            onBackground: darkTextColor, // Default text color on background
            surface: Colors.white, // Card backgrounds, dialogs etc.
            onSurface: darkTextColor, // Text color on surface
          ),

          // --- General UI Elements ---
          scaffoldBackgroundColor: lightBackgroundColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          dividerTheme: DividerThemeData(
            color: Colors.grey[300],
            thickness: 1,
            space: 1,
          ),

          // --- AppBar Theme ---
          appBarTheme: AppBarTheme(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white, // Color for icons and title if not overridden by titleTextStyle
            elevation: 1, // Subtle shadow
            titleTextStyle: baseTextTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600, // Slightly less bold than 'bold'
              fontSize: 20,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),

          // --- BottomNavigationBar Theme ---
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: baseTextTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            unselectedLabelStyle: baseTextTheme.bodySmall,
            type: BottomNavigationBarType.fixed,
            elevation: 8.0, // Standard elevation
          ),

          // --- Card Theme ---
          cardTheme: CardTheme(
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            color: Colors.white, // Explicitly set card color
            clipBehavior: Clip.antiAlias,
          ),

          // --- Button Themes ---
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor, // Use accent for primary action buttons
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: baseTextTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              elevation: 2,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              textStyle: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
             backgroundColor: accentColor,
             foregroundColor: Colors.white,
             elevation: 4.0,
          ),

          // --- Text Theme ---
          textTheme: baseTextTheme.copyWith(
            displayLarge: baseTextTheme.displayLarge?.copyWith(color: darkTextColor, fontWeight: FontWeight.bold),
            displayMedium: baseTextTheme.displayMedium?.copyWith(color: darkTextColor, fontWeight: FontWeight.bold),
            displaySmall: baseTextTheme.displaySmall?.copyWith(color: darkTextColor, fontWeight: FontWeight.bold),
            headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: darkTextColor, fontWeight: FontWeight.bold),
            headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: darkTextColor, fontWeight: FontWeight.bold), // Good for card titles
            headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: darkTextColor, fontWeight: FontWeight.w600),
            titleLarge: baseTextTheme.titleLarge?.copyWith(color: darkTextColor, fontWeight: FontWeight.w600), // AppBar title style is in appBarTheme
            titleMedium: baseTextTheme.titleMedium?.copyWith(color: darkTextColor, fontWeight: FontWeight.w500),
            titleSmall: baseTextTheme.titleSmall?.copyWith(color: lightTextColor, fontWeight: FontWeight.w500),
            bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: darkTextColor, fontSize: 16, height: 1.4),
            bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: lightTextColor, fontSize: 14, height: 1.4), // Standard body text
            bodySmall: baseTextTheme.bodySmall?.copyWith(color: Colors.grey[600], fontSize: 12), // For captions, secondary info
            labelLarge: baseTextTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold), // For button text
          ),

          // --- InputDecoration Theme (for TextFields) ---
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            hintStyle: baseTextTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            prefixIconColor: Colors.grey[600],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0), // Rounded search bar
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: errorColor, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: errorColor, width: 1.5),
            ),
          ),

          // --- ListTile Theme ---
          listTileTheme: ListTileThemeData(
            iconColor: primaryColor,
            titleTextStyle: baseTextTheme.bodyLarge?.copyWith(color: darkTextColor),
            subtitleTextStyle: baseTextTheme.bodyMedium?.copyWith(color: lightTextColor),
          ),

          // --- TabBar Theme ---
          // tabBarTheme: TabBarTheme( (if you use tabs later)
          //   labelColor: primaryColor,
          //   unselectedLabelColor: Colors.grey[600],
          //   indicator: UnderlineTabIndicator(
          //     borderSide: BorderSide(color: primaryColor, width: 2.0),
          //   ),
          // ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  // Helper function to create a MaterialColor from a single Color
  // This is needed for `primarySwatch`.
  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}