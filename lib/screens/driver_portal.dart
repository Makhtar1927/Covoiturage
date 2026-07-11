import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/state_providers.dart';
import '../widgets/glass_container.dart';
import '../widgets/network_banner.dart';

class DriverPortal extends ConsumerStatefulWidget {
  const DriverPortal({super.key});

  @override
  ConsumerState<DriverPortal> createState() => _DriverPortalState();
}

class _DriverPortalState extends ConsumerState<DriverPortal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Vehicle form keys/controllers
  final _vehicleFormKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateController = TextEditingController();
  String _selectedCategory = 'Particulier';
  int _vehicleSeats = 4;

  // Ride form keys/controllers
  final _rideFormKey = GlobalKey<FormState>();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final List<TextEditingController> _stopControllers = [];
  final _priceController = TextEditingController(text: '500');
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);
  int _rideSeats = 3;
  
  final List<String> _selectedCircles = [];
  final List<String> _availableCircles = [
    'UKAC Touba',
    'Quartier Dianatou',
    'Résidence Darou Khoudoss',
    'Complexe Keur Nabi'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initVehicleFields();
    // Default circle to the user's circle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user?.circle != null && !_selectedCircles.contains(user!.circle!)) {
        setState(() {
          _selectedCircles.add(user.circle!);
        });
      }
    });
  }

  void _initVehicleFields() {
    final vehicle = ref.read(currentUserProvider.notifier).getVehicle();
    if (vehicle != null) {
      _modelController.text = vehicle.model;
      _colorController.text = vehicle.color;
      _plateController.text = vehicle.licensePlate;
      _selectedCategory = vehicle.category;
      _vehicleSeats = vehicle.availableSeats;
    } else {
      _modelController.text = 'Renault Zoe';
      _colorController.text = 'Bleu Électrique';
      _plateController.text = 'AA-123-BB';
      _selectedCategory = 'Particulier';
      _vehicleSeats = 4;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    _startController.dispose();
    _endController.dispose();
    _priceController.dispose();
    for (var c in _stopControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveVehicle() {
    if (_vehicleFormKey.currentState!.validate()) {
      final vehicle = Vehicle(
        model: _modelController.text.trim(),
        color: _colorController.text.trim(),
        category: _selectedCategory,
        licensePlate: _plateController.text.trim().toUpperCase(),
        availableSeats: _vehicleSeats,
      );
      ref.read(currentUserProvider.notifier).updateVehicle(vehicle);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Véhicule enregistré avec succès !"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _publishRide() {
    final hasVehicle = ref.read(currentUserProvider.notifier).getVehicle() != null;
    if (!hasVehicle) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez d'abord configurer votre véhicule dans l'onglet 'Véhicule'"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _tabController.animateTo(0);
      return;
    }

    if (_rideFormKey.currentState!.validate()) {
      if (_selectedCircles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Veuillez sélectionner au moins un cercle autorisé"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final startPoint = _startController.text.trim();
      final endPoint = _endController.text.trim();
      final intermediateStops = _stopControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
      final price = double.tryParse(_priceController.text) ?? 500.0;

      final fullDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      ref.read(rideListProvider.notifier).publishRide(
        startPoint: startPoint,
        endPoint: endPoint,
        intermediateStops: intermediateStops,
        dateTime: fullDateTime,
        price: price,
        availableSeats: _rideSeats,
        allowedCircles: _selectedCircles,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Trajet publié avec succès !"),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Clear fields
      _startController.clear();
      _endController.clear();
      setState(() {
        _stopControllers.clear();
      });
      
      // Redirect to requests tab
      _tabController.animateTo(2);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  int _getMaxSeatsForCategory(String category) {
    switch (category) {
      case 'Particulier':
        return 4;
      case 'Mini-bus':
        return 15;
      case 'Bus':
        return 50;
      default:
        return 4;
    }
  }

  int _getMinSeatsForCategory(String category) {
    switch (category) {
      case 'Particulier':
        return 1;
      case 'Mini-bus':
        return 5;
      case 'Bus':
        return 16;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final bookings = ref.watch(bookingProvider);
    final isOnline = ref.watch(networkStatusProvider);
    
    // Filter bookings where this user is the driver of the ride
    final driverBookings = bookings.where((b) => b.ride.driver.id == user?.id).toList();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final textColor = cs.onSurface;
    final subtitleColor = cs.onSurface.withValues(alpha: 0.6);
    final dividerColor = cs.onSurface.withValues(alpha: 0.12);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          "Espace Conducteur",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: cs.primary,
          labelColor: cs.primary,
          unselectedLabelColor: subtitleColor,
          tabs: const [
            Tab(icon: Icon(Icons.directions_car_rounded), text: "Véhicule"),
            Tab(icon: Icon(Icons.add_location_alt_rounded), text: "Publier"),
            Tab(icon: Icon(Icons.people_alt_rounded), text: "Demandes"),
          ],
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: NetworkBanner(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: VEHICLE MANAGEMENT
                _buildVehicleTab(cs, textColor, subtitleColor, dividerColor, isDark),
                
                // TAB 2: PUBLISH RIDE
                _buildPublishTab(user, cs, textColor, subtitleColor, dividerColor, isDark),
                
                // TAB 3: BOOKING REQUESTS
                _buildRequestsTab(driverBookings, isOnline, cs, textColor, subtitleColor, dividerColor, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTab(ColorScheme cs, Color textColor, Color subtitleColor, Color dividerColor, bool isDark) {
    final vehicleSaved = ref.watch(currentUserProvider.notifier).getVehicle() != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (vehicleSaved) ...[
            GlassContainer(
              opacity: 0.1,
              borderColor: cs.primary,
              useWhiteBlend: !isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Véhicule Enregistré",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _selectedCategory,
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: dividerColor, height: 20),
                  Text(
                    _modelController.text,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.color_lens_rounded, size: 16, color: subtitleColor),
                      const SizedBox(width: 6),
                      Text("Couleur : ${_colorController.text}", style: TextStyle(color: subtitleColor)),
                      const SizedBox(width: 20),
                      Icon(Icons.airline_seat_recline_normal_rounded, size: 16, color: subtitleColor),
                      const SizedBox(width: 6),
                      Text("Places : $_vehicleSeats", style: TextStyle(color: subtitleColor)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: dividerColor),
                    ),
                    child: Text(
                      _plateController.text,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          Form(
            key: _vehicleFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Configurer votre véhicule",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: cs.surface,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: "Catégorie de véhicule",
                    labelStyle: TextStyle(color: subtitleColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                  ),
                  items: ['Particulier', 'Mini-bus', 'Bus'].map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat, style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                        // Reset capacity bounds
                        final min = _getMinSeatsForCategory(value);
                        final max = _getMaxSeatsForCategory(value);
                        if (_vehicleSeats < min || _vehicleSeats > max) {
                          _vehicleSeats = min;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _modelController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: "Marque & Modèle",
                    labelStyle: TextStyle(color: subtitleColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? "Champs obligatoire" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _colorController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: "Couleur",
                    labelStyle: TextStyle(color: subtitleColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? "Champs obligatoire" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _plateController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: "Plaque d'immatriculation",
                    labelStyle: TextStyle(color: subtitleColor),
                    hintText: "AA-123-BB",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? "Champs obligatoire" : null,
                ),
                const SizedBox(height: 20),
                Text(
                  "Capacité du véhicule : $_vehicleSeats places",
                  style: TextStyle(color: subtitleColor, fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: _vehicleSeats.toDouble(),
                  min: _getMinSeatsForCategory(_selectedCategory).toDouble(),
                  max: _getMaxSeatsForCategory(_selectedCategory).toDouble(),
                  divisions: _getMaxSeatsForCategory(_selectedCategory) - _getMinSeatsForCategory(_selectedCategory),
                  activeColor: cs.primary,
                  inactiveColor: cs.onSurface.withValues(alpha: 0.15),
                  onChanged: (val) {
                    setState(() {
                      _vehicleSeats = val.round();
                      _rideSeats = _vehicleSeats - 1; // Subtract 1 for driver
                      if (_rideSeats < 1) _rideSeats = 1;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _saveVehicle,
                  child: const Text("Enregistrer le véhicule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishTab(User? user, ColorScheme cs, Color textColor, Color subtitleColor, Color dividerColor, bool isDark) {
    final vehicle = ref.watch(currentUserProvider.notifier).getVehicle();
    if (vehicle == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_car_rounded, size: 72, color: subtitleColor.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              Text(
                "Aucun véhicule configuré",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "Vous devez d'abord ajouter votre véhicule pour pouvoir publier des trajets.",
                textAlign: TextAlign.center,
                style: TextStyle(color: subtitleColor),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _tabController.animateTo(0),
                child: const Text("Configurer mon véhicule"),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _rideFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Détails du trajet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _startController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: "Point de départ (Adresse exacte)",
                labelStyle: TextStyle(color: subtitleColor),
                prefixIcon: Icon(Icons.circle_outlined, color: cs.primary, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? "Indiquez le départ" : null,
            ),
            const SizedBox(height: 16),
            // Dynamic Stops
            ..._stopControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: "Étape intermédiaire ${index + 1}",
                          labelStyle: TextStyle(color: subtitleColor),
                          prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          _stopControllers.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              style: TextButton.styleFrom(alignment: Alignment.centerLeft),
              onPressed: () {
                setState(() {
                  _stopControllers.add(TextEditingController());
                });
              },
              icon: Icon(Icons.add_circle_outline_rounded, color: cs.primary),
              label: Text("Ajouter une étape intermédiaire", style: TextStyle(color: cs.primary)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _endController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: "Point d'arrivée (Destination)",
                labelStyle: TextStyle(color: subtitleColor),
                prefixIcon: const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? "Indiquez la destination" : null,
            ),
            const SizedBox(height: 20),
            // Date & Time Picker
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Date",
                        labelStyle: TextStyle(color: subtitleColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: TextStyle(color: textColor),
                          ),
                          Icon(Icons.calendar_month_rounded, color: subtitleColor),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Heure",
                        labelStyle: TextStyle(color: subtitleColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedTime.format(context),
                            style: TextStyle(color: textColor),
                          ),
                          Icon(Icons.access_time_rounded, color: subtitleColor),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: "Prix par place (FCFA)",
                      labelStyle: TextStyle(color: subtitleColor),
                      suffixText: "CFA",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Indiquez le prix";
                      if (double.tryParse(value) == null) return "Prix incorrect";
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Places proposées : $_rideSeats",
                        style: TextStyle(color: subtitleColor, fontSize: 13),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline, color: subtitleColor),
                            onPressed: _rideSeats > 1
                                ? () => setState(() => _rideSeats--)
                                : null,
                          ),
                          Text("$_rideSeats", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline, color: subtitleColor),
                            onPressed: _rideSeats < (vehicle.availableSeats - 1)
                                ? () => setState(() => _rideSeats++)
                                : null,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Circle checklist
            Text(
              "Cercles communautaires autorisés",
              style: TextStyle(fontWeight: FontWeight.bold, color: subtitleColor),
            ),
            const SizedBox(height: 8),
            ..._availableCircles.map((circle) {
              final isAllowed = _selectedCircles.contains(circle);
              return CheckboxListTile(
                value: isAllowed,
                title: Text(circle, style: TextStyle(color: textColor, fontSize: 14)),
                activeColor: cs.primary,
                checkColor: cs.onPrimary,
                dense: true,
                onChanged: (bool? val) {
                  setState(() {
                    if (val == true) {
                      _selectedCircles.add(circle);
                    } else {
                      _selectedCircles.remove(circle);
                    }
                  });
                },
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _publishRide,
              child: const Text("Publier le trajet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsTab(List<Booking> driverBookings, bool isOnline, ColorScheme cs, Color textColor, Color subtitleColor, Color dividerColor, bool isDark) {
    if (driverBookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline_rounded, size: 72, color: subtitleColor.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              Text(
                "Aucune demande de réservation",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "Les demandes des passagers s'afficheront ici.",
                style: TextStyle(color: subtitleColor),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: driverBookings.length,
      itemBuilder: (context, index) {
        final booking = driverBookings[index];
        final ride = booking.ride;
        final passenger = booking.passenger;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: cs.onSurface.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: dividerColor),
          ),

          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(passenger.avatar),
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(passenger.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                              const SizedBox(width: 4),
                              Icon(Icons.verified_rounded, color: cs.primary, size: 16),
                            ],
                          ),
                          Text(
                            "${passenger.circle} • ★ ${passenger.rating}",
                            style: TextStyle(color: subtitleColor, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(booking.status),
                  ],
                ),
                Divider(color: dividerColor, height: 24),
                // Ride points
                Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ride.startPoint, style: TextStyle(color: textColor, fontSize: 13))),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: SizedBox(height: 6, child: VerticalDivider(color: dividerColor, width: 2)),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ride.endPoint, style: TextStyle(color: textColor, fontSize: 13))),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Date : ${DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(ride.dateTime)}",
                  style: TextStyle(color: subtitleColor.withValues(alpha: 0.9), fontSize: 12),
                ),
                if (booking.status == 'pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: isDark ? Colors.redAccent : Colors.red.shade700,
                        ),
                        onPressed: () {
                          ref.read(bookingProvider.notifier).updateBookingStatus(booking.id, 'rejected');
                        },
                        child: const Text("Refuser"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          ref.read(bookingProvider.notifier).updateBookingStatus(booking.id, 'accepted');
                        },
                        child: const Text("Accepter", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.transparent;
    Color fg = Colors.grey;
    String text = status;

    if (status == 'pending') {
      bg = Colors.amber.withValues(alpha: 0.08);
      fg = Colors.amber.shade700;
      text = "En attente";
    } else if (status == 'accepted') {
      bg = Colors.green.withValues(alpha: 0.08);
      fg = Colors.green.shade700;
      text = "Validé";
    } else if (status == 'rejected') {
      bg = Colors.red.withValues(alpha: 0.08);
      fg = Colors.red.shade700;
      text = "Refusé";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
