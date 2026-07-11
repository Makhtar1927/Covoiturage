import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/state_providers.dart';
import '../widgets/glass_container.dart';
import '../widgets/network_banner.dart';
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

  double _maxPrice = 10.0;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Recherche de Trajets",
          style: TextStyle(fontWeight: FontWeight.bold),
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
                // Glassmorphic Search Filters Card
                GlassContainer(
                  opacity: 0.08,
                  borderColor: Colors.deepPurpleAccent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Filtres de recherche",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Start search field
                      TextFormField(
                        controller: _startController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Départ",
                          prefixIcon: const Icon(Icons.circle_outlined, color: Colors.cyanAccent, size: 16),
                          suffixIcon: _startController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    _startController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // End search field
                      TextFormField(
                        controller: _endController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Destination",
                          prefixIcon: const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 16),
                          suffixIcon: _endController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    _endController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Horizontal filter chips (Time)
                      Row(
                        children: [
                          const Text("Date :", style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterChip('Tout', null),
                                  const SizedBox(width: 8),
                                  _buildFilterChip('Aujourd\'hui', 'today'),
                                  const SizedBox(width: 8),
                                  _buildFilterChip('Demain', 'tomorrow'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Max price slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Prix max par place :", style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Text(
                            "${_maxPrice.toStringAsFixed(2)} €",
                            style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Slider(
                        value: _maxPrice,
                        min: 1.0,
                        max: 20.0,
                        divisions: 19,
                        activeColor: Colors.cyanAccent,
                        inactiveColor: Colors.white24,
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
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        activeColor: Colors.cyanAccent,
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
                    const Text(
                      "Trajets Disponibles",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      "${filteredRides.length} résultat(s)",
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Results List
                if (filteredRides.isEmpty)
                  _buildNoResults()
                else
                  ...filteredRides.map((ride) => _buildRideCard(context, ride)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _selectedTimeFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTimeFilter = value;
        });
      },
      selectedColor: Colors.cyanAccent.withOpacity(0.2),
      backgroundColor: Colors.white.withOpacity(0.05),
      labelStyle: TextStyle(
        color: isSelected ? Colors.cyanAccent : Colors.white70,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Colors.cyanAccent.withOpacity(0.5) : Colors.white12,
      ),
    );
  }

  Widget _buildNoResults() {
    return GlassContainer(
      opacity: 0.05,
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 64, color: Colors.white30),
          const SizedBox(height: 12),
          const Text(
            "Aucun trajet trouvé",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "Essayez d'élargir vos critères de recherche.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(BuildContext context, Ride ride) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        opacity: 0.07,
        padding: const EdgeInsets.all(16),
        borderColor: Colors.white10,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RideDetailsScreen(ride: ride)),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver header
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(ride.driver.avatar),
                    radius: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(ride.driver.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: Colors.cyanAccent, size: 14),
                          ],
                        ),
                        Text(
                          "Cercle : ${ride.driver.circle} • ★ ${ride.driver.rating}",
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${ride.price.toStringAsFixed(2)} €",
                    style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 24),
              // Route
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.circle, color: Colors.cyanAccent, size: 10),
                      Container(width: 2, height: 24, color: Colors.white24),
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 12),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.startPoint,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ride.endPoint,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (ride.intermediateStops.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  "Étape(s) : ${ride.intermediateStops.join(' ➔ ')}",
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontStyle: FontStyle.italic),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Divider(color: Colors.white12, height: 20),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.white.withOpacity(0.6), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(ride.dateTime),
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.airline_seat_recline_normal_rounded, color: Colors.white.withOpacity(0.6), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "${ride.availableSeats} place(s) restante(s)",
                        style: TextStyle(
                          color: ride.availableSeats > 0 ? Colors.greenAccent : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
