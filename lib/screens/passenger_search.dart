import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/state_providers.dart';
import '../widgets/glass_container.dart';
import '../widgets/network_banner.dart';
import '../widgets/user_avatar.dart';
import 'ride_details_screen.dart';

class PassengerSearch extends ConsumerStatefulWidget {
  const PassengerSearch({super.key});

  @override
  ConsumerState<PassengerSearch> createState() => _PassengerSearchState();
}

class _PassengerSearchState extends ConsumerState<PassengerSearch> {
  final _searchController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  double _maxPrice = 1000.0;
  bool _filterByMyCircleOnly = true;
  String? _selectedTimeFilter; // 'today', 'tomorrow', 'all'

  @override
  void dispose() {
    _searchController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  List<Ride> _filterRides(List<Ride> rides, User? user) {
    if (user == null) return [];

    return rides.where((ride) {
      // 1. Circle Filter
      if (_filterByMyCircleOnly && user.circle != null) {
        if (!ride.allowedCircles.contains(user.circle)) {
          return false;
        }
      }

      // 2. Start/End Point search
      final queryStart = _startController.text.trim().toLowerCase();
      final queryEnd = _endController.text.trim().toLowerCase();
      if (queryStart.isNotEmpty && !ride.startPoint.toLowerCase().contains(queryStart)) {
        return false;
      }
      if (queryEnd.isNotEmpty && !ride.endPoint.toLowerCase().contains(queryEnd)) {
        return false;
      }

      // 3. Price Filter
      if (ride.price > _maxPrice) {
        return false;
      }

      // 4. Time Filter
      final now = DateTime.now();
      if (_selectedTimeFilter == 'today') {
        final startOfToday = DateTime(now.year, now.month, now.day);
        final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
        if (ride.dateTime.isBefore(startOfToday) || ride.dateTime.isAfter(endOfToday)) {
          return false;
        }
      } else if (_selectedTimeFilter == 'tomorrow') {
        final tomorrow = now.add(const Duration(days: 1));
        final startOfTomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
        final endOfTomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59, 59);
        if (ride.dateTime.isBefore(startOfTomorrow) || ride.dateTime.isAfter(endOfTomorrow)) {
          return false;
        }
      }

      // 5. Hide driver's own rides
      if (ride.driver.id == user.id) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final allRides = ref.watch(rideListProvider);
    final filteredRides = _filterRides(allRides, user);

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final textColor = cs.onSurface;
    final subtitleColor = cs.onSurface.withValues(alpha: 0.6);
    final cardBorder = cs.onSurface.withValues(alpha: 0.12);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          "Recherche de Trajets",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: NetworkBanner(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                GlassContainer(
                  opacity: 0.08,
                  borderColor: cs.primary.withValues(alpha: 0.4),
                  useWhiteBlend: !isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune_rounded, color: cs.primary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "Filtres de recherche",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Connected Route search fields
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Journey line indicator on the left
                          Padding(
                            padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                            child: Column(
                              children: [
                                Icon(Icons.radio_button_checked_rounded, color: cs.primary, size: 16),
                                Container(
                                  width: 2,
                                  height: 38,
                                  color: cs.onSurface.withValues(alpha: 0.15),
                                ),
                                const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 18),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Fields on the right
                          Expanded(
                            child: Column(
                              children: [
                                // Start search field
                                TextFormField(
                                  controller: _startController,
                                  onChanged: (_) => setState(() {}),
                                  style: TextStyle(color: textColor),
                                  decoration: InputDecoration(
                                    labelText: "Départ",
                                    labelStyle: TextStyle(color: subtitleColor),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    suffixIcon: _startController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear, size: 16),
                                            onPressed: () {
                                              _startController.clear();
                                              setState(() {});
                                            },
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // End search field
                                TextFormField(
                                  controller: _endController,
                                  onChanged: (_) => setState(() {}),
                                  style: TextStyle(color: textColor),
                                  decoration: InputDecoration(
                                    labelText: "Destination",
                                    labelStyle: TextStyle(color: subtitleColor),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    suffixIcon: _endController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear, size: 16),
                                            onPressed: () {
                                              _endController.clear();
                                              setState(() {});
                                            },
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Horizontal filter chips (Time)
                      Row(
                        children: [
                          Text("Date :", style: TextStyle(color: subtitleColor, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterChip('Tout', null, cs, isDark),
                                  const SizedBox(width: 8),
                                  _buildFilterChip('Aujourd\'hui', 'today', cs, isDark),
                                  const SizedBox(width: 8),
                                  _buildFilterChip('Demain', 'tomorrow', cs, isDark),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Max price slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Prix max par place :", style: TextStyle(color: subtitleColor, fontSize: 13, fontWeight: FontWeight.w600)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              "${_maxPrice.toInt()} FCFA",
                              style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Slider(
                        value: _maxPrice,
                        min: 100.0,
                        max: 2000.0,
                        divisions: 19,
                        activeColor: cs.primary,
                        inactiveColor: cs.onSurface.withValues(alpha: 0.15),
                        onChanged: (val) {
                          setState(() {
                            _maxPrice = val;
                          });
                        },
                      ),
                      // My Circle Switch
                      SwitchListTile(
                        value: _filterByMyCircleOnly,
                        title: Text(
                          "Mon cercle uniquement (${user?.circle ?? 'Aucun'})",
                          style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        activeThumbColor: cs.primary,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onChanged: (val) {
                          setState(() {
                            _filterByMyCircleOnly = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Heading results
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Trajets Disponibles",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    Text(
                      "${filteredRides.length} résultat(s)",
                      style: TextStyle(color: subtitleColor, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Results List
                if (filteredRides.isEmpty)
                  _buildNoResults(textColor, subtitleColor, isDark)
                else
                  ...filteredRides.map((ride) => _buildRideCard(context, ride, cs, textColor, subtitleColor, cardBorder, isDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, ColorScheme cs, bool isDark) {
    final isSelected = _selectedTimeFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTimeFilter = value;
        });
      },
      shape: const StadiumBorder(),
      selectedColor: cs.primary.withValues(alpha: 0.18),
      backgroundColor: cs.onSurface.withValues(alpha: 0.05),
      labelStyle: TextStyle(
        color: isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.7),
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? cs.primary.withValues(alpha: 0.6) : cs.onSurface.withValues(alpha: 0.1),
        width: isSelected ? 1.5 : 1.0,
      ),
    );
  }

  Widget _buildNoResults(Color textColor, Color subtitleColor, bool isDark) {
    return GlassContainer(
      opacity: 0.05,
      useWhiteBlend: !isDark,
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: subtitleColor.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            "Aucun trajet trouvé",
            style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "Essayez d'élargir vos critères de recherche.",
            textAlign: TextAlign.center,
            style: TextStyle(color: subtitleColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(BuildContext context, Ride ride, ColorScheme cs, Color textColor, Color subtitleColor, Color cardBorder, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: GlassContainer(
          opacity: isDark ? 0.09 : 0.06,
          useWhiteBlend: !isDark,
          padding: const EdgeInsets.all(18),
          borderColor: cardBorder,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RideDetailsScreen(ride: ride)),
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Driver header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.primary.withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: UserAvatar(
                        name: ride.driver.name,
                        avatarUrl: ride.driver.avatar,
                        radius: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                ride.driver.name,
                                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.verified_rounded, color: cs.primary, size: 15),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              // Community circle badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  ride.driver.circle ?? "Sans cercle",
                                  style: TextStyle(color: cs.primary, fontSize: 10, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Rating badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                                    const SizedBox(width: 2),
                                    Text(
                                      ride.driver.rating.toString(),
                                      style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Price pill badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            cs.primary.withValues(alpha: isDark ? 0.22 : 0.12),
                            cs.primary.withValues(alpha: isDark ? 0.08 : 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: cs.primary.withValues(alpha: 0.25), width: 1.2),
                      ),
                      child: Text(
                        "${ride.price.toInt()} FCFA",
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(color: cs.onSurface.withValues(alpha: 0.08), height: 28),
                // Route visuals
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        children: [
                          Icon(Icons.circle, color: cs.primary, size: 8),
                          Container(
                            width: 1.5,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [cs.primary, Colors.redAccent],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 12),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.startPoint,
                            style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            ride.endPoint,
                            style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (ride.intermediateStops.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  // Intermediate stops styled as clean tag line
                  Row(
                    children: [
                      Icon(Icons.alt_route_rounded, color: subtitleColor.withValues(alpha: 0.5), size: 13),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ride.intermediateStops.map((stop) {
                              return Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cs.onSurface.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: cs.onSurface.withValues(alpha: 0.06)),
                                ),
                                child: Text(
                                  stop,
                                  style: TextStyle(color: subtitleColor, fontSize: 10, fontWeight: FontWeight.w500),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                Divider(color: cs.onSurface.withValues(alpha: 0.08), height: 28),
                // Footer details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date pill chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: cs.onSurface.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, color: subtitleColor, size: 12),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('dd/MM à HH:mm').format(ride.dateTime),
                            style: TextStyle(color: subtitleColor, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    // Available seats pill chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: ride.availableSeats > 0 
                            ? Colors.green.withValues(alpha: 0.12)
                            : Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.airline_seat_recline_normal_rounded, 
                            color: ride.availableSeats > 0 ? Colors.green : Colors.red,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${ride.availableSeats} place(s) libre(s)",
                            style: TextStyle(
                              color: ride.availableSeats > 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
