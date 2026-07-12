import 'dart:ui';
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
import 'widgets/user_avatar.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(color: Color(0xFFDDE3EA)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(color: Color(0xFFDDE3EA)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E1A35),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(color: Color(0xFF2E2855)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(color: Color(0xFF2E2855)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
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
    final selectedColor = cs.primary;
    final unselectedColor = isDark ? Colors.white38 : Colors.black38;

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

          // Screen content — padded below topbar and nav
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 72, bottom: 88),
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ),

          // ── Premium Top Bar ──────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.white.withValues(alpha: 0.80),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.10)
                              : Colors.white.withValues(alpha: 0.90),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: selectedColor.withValues(alpha: isDark ? 0.15 : 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // ── Logo + App Name ──
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [selectedColor, cs.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: selectedColor.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.directions_car_filled_rounded,
                              color: isDark ? Colors.black87 : Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // ── Brand Name + Greeting ──
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'CommuniRide',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                    color: isDark ? Colors.white : const Color(0xFF1C1C2E),
                                    height: 1.1,
                                  ),
                                ),
                                if (user != null)
                                  Text(
                                    'Bonjour, ${user.name.split(' ').first} 👋',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.55)
                                          : const Color(0xFF1C1C2E).withValues(alpha: 0.50),
                                      fontWeight: FontWeight.w500,
                                      height: 1.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          // ── Theme Toggle ──
                          GestureDetector(
                            onTap: () => ref.read(themeModeProvider.notifier).toggle(),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : selectedColor.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedColor.withValues(alpha: 0.20),
                                  width: 1,
                                ),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                  key: ValueKey(isDark),
                                  color: selectedColor,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // ── Profile Avatar ──
                          GestureDetector(
                            onTap: () => _showProfileDialog(context, user, isDark, cs),
                            child: Hero(
                              tag: 'profile_avatar',
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      selectedColor,
                                      cs.secondary,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: selectedColor.withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: UserAvatar(
                                    name: user?.name ?? '',
                                    avatarUrl: user?.avatar ?? '',
                                    radius: 17,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Custom Navigation Bar — Premium Glass
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : Colors.white.withValues(alpha: 0.9),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: selectedColor.withValues(alpha: isDark ? 0.18 : 0.10),
                        blurRadius: 28,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.search_rounded, "Rechercher", selectedColor, unselectedColor, isDark),
                      _buildNavItem(1, Icons.directions_car_filled_rounded, "Conduire", selectedColor, unselectedColor, isDark),
                      _buildNavItem(2, Icons.book_rounded, "Carnet", selectedColor, unselectedColor, isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color selectedColor, Color unselectedColor, bool isDark) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 18, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    selectedColor.withValues(alpha: isDark ? 0.28 : 0.18),
                    selectedColor.withValues(alpha: isDark ? 0.12 : 0.07),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(50),
          border: isSelected
              ? Border.all(color: selectedColor.withValues(alpha: 0.30), width: 1.2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon with subtle glow when selected
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey('$index-$isSelected'),
                color: isSelected ? selectedColor : unselectedColor,
                size: isSelected ? 22 : 22,
              ),
            ),
            // Label slides in when selected
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: selectedColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
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
                UserAvatar(
                  name: user?.name ?? '',
                  avatarUrl: user?.avatar ?? '',
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
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
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
