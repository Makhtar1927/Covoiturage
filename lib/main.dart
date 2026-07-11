import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/models.dart';
import 'providers/state_providers.dart';
import 'screens/onboarding_screen.dart';
import 'screens/passenger_search.dart';
import 'screens/driver_portal.dart';
import 'screens/carnet_voyage_screen.dart';
import 'widgets/glass_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// ─── Theme Definitions ──────────────────────────────────────────────────────

final _lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'Roboto',
  scaffoldBackgroundColor: const Color(0xFFF5F7FA),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1E7FBF),
    brightness: Brightness.light,
    primary: const Color(0xFF1E7FBF),
    secondary: const Color(0xFF00B4D8),
    surface: Colors.white,
    onSurface: const Color(0xFF1C1C2E),
    onPrimary: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFF5F7FA),
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Color(0xFF1C1C2E)),
    titleTextStyle: TextStyle(
      color: Color(0xFF1C1C2E),
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: const CardThemeData(
    color: Colors.white,
    elevation: 2,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1E7FBF),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDDE3EA)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDDE3EA)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF1E7FBF), width: 1.5),
    ),
  ),
  dividerColor: const Color(0xFFDDE3EA),
  iconTheme: const IconThemeData(color: Color(0xFF1E7FBF)),
);

final _darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'Roboto',
  scaffoldBackgroundColor: const Color(0xFF0F0B1E),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF00D4FF),
    secondary: Color(0xFF7C5CBF),
    surface: Color(0xFF161129),
    onSurface: Colors.white,
    onPrimary: Color(0xFF0F0B1E),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0F0B1E),
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF1E1A35),
    elevation: 4,
    shadowColor: Colors.black45,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF00D4FF),
      foregroundColor: const Color(0xFF0F0B1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E1A35),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF2E2855)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF2E2855)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF00D4FF), width: 1.5),
    ),
  ),
  dividerColor: const Color(0xFF2E2855),
  iconTheme: const IconThemeData(color: Color(0xFF00D4FF)),
);

// ─── App Root ─────────────────────────────────────────────────────────────────

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'CommuniRide',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('fr', 'FR'),
      home: const RootNavigation(),
    );
  }
}

// ─── Root Navigation ──────────────────────────────────────────────────────────

class RootNavigation extends ConsumerWidget {
  const RootNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const OnboardingScreen();
    return const MainLayout();
  }
}

// ─── Main Layout ──────────────────────────────────────────────────────────────

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PassengerSearch(),
    const DriverPortal(),
    const CarnetVoyageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final cs = Theme.of(context).colorScheme;

    // Adaptive colors
    final glowColor1 = isDark ? const Color(0xFF00D4FF) : const Color(0xFF1E7FBF);
    final glowColor2 = isDark ? const Color(0xFF7C5CBF) : const Color(0xFF00B4D8);
    final navBarBg = isDark ? const Color(0xFF161129) : Colors.white;
    final selectedColor = cs.primary;
    final unselectedColor = isDark ? Colors.white38 : Colors.black38;
    final navBorder = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.06);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // Background soft glowing orbs
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: glowColor1.withValues(alpha: isDark ? 0.08 : 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: glowColor2.withValues(alpha: isDark ? 0.08 : 0.05),
              ),
            ),
          ),

          // Screen content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ),

          // Theme toggle button (top-left)
          Positioned(
            top: 14,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => ref.read(themeModeProvider.notifier).toggle(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: navBarBg,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: selectedColor.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: navBorder),
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: selectedColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          // Profile avatar (top-right)
          Positioned(
            top: 14,
            right: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => _showProfileDialog(context, user, isDark, cs),
                child: Hero(
                  tag: 'profile_avatar',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: selectedColor.withValues(alpha: 0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: selectedColor.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(user?.avatar ?? ''),
                      radius: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Custom Navigation Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              decoration: BoxDecoration(
                color: navBarBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: navBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.search_rounded, "Rechercher", selectedColor, unselectedColor),
                  _buildNavItem(1, Icons.directions_car_filled_rounded, "Conducteur", selectedColor, unselectedColor),
                  _buildNavItem(2, Icons.assignment_rounded, "Carnet", selectedColor, unselectedColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color selectedColor, Color unselectedColor) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? selectedColor : unselectedColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? selectedColor : unselectedColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, User? user, bool isDark, ColorScheme cs) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: GlassContainer(
            opacity: isDark ? 0.12 : 0.85,
            borderColor: cs.primary,
            useWhiteBlend: !isDark,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(user?.avatar ?? ''),
                  radius: 36,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user?.name ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.verified_rounded, color: cs.primary, size: 18),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 12),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    "Cercle : ${user?.circle ?? 'Aucun'}",
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: cs.onSurface.withValues(alpha: 0.12)),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    ref.read(currentUserProvider.notifier).logout();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  label: const Text("Se déconnecter", style: TextStyle(color: Colors.redAccent)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Fermer"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
