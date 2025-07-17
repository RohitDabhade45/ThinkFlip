import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/scan_view_model.dart';
import 'models/card_view_model.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/history_view_model.dart';
import 'pages/login_screen.dart';
import 'pages/home_screen.dart';
import 'theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CardViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<AuthViewModel, ScanViewModel>(
          create: (context) => ScanViewModel(context.read<AuthViewModel>()),
          update: (context, auth, previous) =>
              previous ?? ScanViewModel(auth),
        ),
        ChangeNotifierProxyProvider<AuthViewModel, HistoryViewModel>(
          create: (context) => HistoryViewModel(context.read<AuthViewModel>()),
          update: (context, auth, previous) =>
              previous ?? HistoryViewModel(auth),
        ),
      ],
      child: Consumer2<ThemeProvider, AuthViewModel>(
        builder: (context, themeProvider, authViewModel, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ThinkFlip',
            themeMode: themeProvider.themeMode,
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            home: authViewModel.isLoading
                ? const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : authViewModel.isAuthenticated
                    ? const HomeScreen()
                    : const LoginScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: brightness,
      ),
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor: isDark ? Colors.black : null,
      canvasColor: isDark ? Colors.black : null,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? Colors.black : null,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.black : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
