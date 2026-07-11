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
  final _priceController = TextEditingController(text: '3.00');
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);
  int _rideSeats = 3;
  
  final List<String> _selectedCircles = [];
  final List<String> _availableCircles = [
    'Google Paris',
    'Sorbonne Université',
    'Station F',
    'Université Paris-Saclay'
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
      final price = double.tryParse(_priceController.text) ?? 2.0;

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
      
      // Redirect to list or view requests
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Espace Conducteur",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyanAccent,
          labelColor: Colors.cyanAccent,
          unselectedLabelColor: Colors.white70,
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
                _buildVehicleTab(),
                
                // TAB 2: PUBLISH RIDE
                _buildPublishTab(user),
                
                // TAB 3: BOOKING REQUESTS
                _buildRequestsTab(driverBookings, isOnline),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTab() {
    final vehicleSaved = ref.watch(currentUserProvider.notifier).getVehicle() != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (vehicleSaved) ...[
            GlassContainer(
              opacity: 0.1,
              borderColor: Colors.cyanAccent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Véhicule Enregistré",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.cyan.shade900.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                        ),
                        child: Text(
                          _selectedCategory,
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  Text(
                    _modelController.text,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.color_lens_rounded, size: 16, color: Colors.white.withOpacity(0.6)),
                      const SizedBox(width: 6),
                      Text("Couleur : ${_colorController.text}", style: TextStyle(color: Colors.white.withOpacity(0.7))),
                      const SizedBox(width: 20),
                      Icon(Icons.airline_seat_recline_normal_rounded, size: 16, color: Colors.white.withOpacity(0.6)),
                      const SizedBox(width: 6),
                      Text("Places : $_vehicleSeats", style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      _plateController.text,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                const Text(
                  "Configurer votre véhicule",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: Colors.deepPurple.shade900,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Catégorie de véhicule",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                  ),
                  items: ['Particulier', 'Mini-bus', 'Bus'].map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
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
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Marque & Modèle",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? "Champs obligatoire" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _colorController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Couleur",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? "Champs obligatoire" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _plateController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Plaque d'immatriculation",
                    hintText: "AA-123-BB",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? "Champs obligatoire" : null,
                ),
                const SizedBox(height: 20),
                Text(
                  "Capacité du véhicule : $_vehicleSeats places",
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: _vehicleSeats.toDouble(),
                  min: _getMinSeatsForCategory(_selectedCategory).toDouble(),
                  max: _getMaxSeatsForCategory(_selectedCategory).toDouble(),
                  divisions: _getMaxSeatsForCategory(_selectedCategory) - _getMinSeatsForCategory(_selectedCategory),
                  activeColor: Colors.cyanAccent,
                  inactiveColor: Colors.white24,
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
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black87,
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

  Widget _buildPublishTab(User? user) {
    final vehicle = ref.watch(currentUserProvider.notifier).getVehicle();
    if (vehicle == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car_rounded, size: 72, color: Colors.white30),
              const SizedBox(height: 16),
              const Text(
                "Aucun véhicule configuré",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                "Vous devez d'abord ajouter votre véhicule pour pouvoir publier des trajets.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black87,
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
            const Text(
              "Détails du trajet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _startController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Point de départ (Adresse exacte)",
                prefixIcon: const Icon(Icons.circle_outlined, color: Colors.cyanAccent, size: 18),
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
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Étape intermédiaire ${index + 1}",
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
              icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.cyanAccent),
              label: const Text("Ajouter une étape intermédiaire", style: TextStyle(color: Colors.cyanAccent)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _endController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Point d'arrivée (Destination)",
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Icon(Icons.calendar_month_rounded, color: Colors.white60),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedTime.format(context),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Icon(Icons.access_time_rounded, color: Colors.white60),
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
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Prix par place (€)",
                      suffixText: "EUR",
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
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.white60),
                            onPressed: _rideSeats > 1
                                ? () => setState(() => _rideSeats--)
                                : null,
                          ),
                          Text("$_rideSeats", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.white60),
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
            const Text(
              "Cercles communautaires autorisés",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            ..._availableCircles.map((circle) {
              final isAllowed = _selectedCircles.contains(circle);
              return CheckboxListTile(
                value: isAllowed,
                title: Text(circle, style: const TextStyle(color: Colors.white, fontSize: 14)),
                activeColor: Colors.cyanAccent,
                checkColor: Colors.black,
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
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black87,
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

  Widget _buildRequestsTab(List<Booking> driverBookings, bool isOnline) {
    if (driverBookings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline_rounded, size: 72, color: Colors.white30),
              const SizedBox(height: 16),
              const Text(
                "Aucune demande de réservation",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                "Les demandes des passagers s'afficheront ici.",
                style: TextStyle(color: Colors.white60),
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
          color: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
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
                              Text(passenger.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified_rounded, color: Colors.cyanAccent, size: 16),
                            ],
                          ),
                          Text(
                            "${passenger.circle} • ★ ${passenger.rating}",
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(booking.status),
                  ],
                ),
                const Divider(color: Colors.white12, height: 24),
                // Ride points
                Row(
                  children: [
                    const Icon(Icons.circle, size: 10, color: Colors.cyanAccent),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ride.startPoint, style: const TextStyle(color: Colors.white, fontSize: 13))),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: SizedBox(height: 6, child: VerticalDivider(color: Colors.white24, width: 2)),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ride.endPoint, style: const TextStyle(color: Colors.white, fontSize: 13))),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Date : ${DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(ride.dateTime)}",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
                if (booking.status == 'pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                        onPressed: () {
                          ref.read(bookingProvider.notifier).updateBookingStatus(booking.id, 'rejected');
                        },
                        child: const Text("Refuser"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black87,
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
    Color bg = Colors.white10;
    Color fg = Colors.white;
    String text = status;

    if (status == 'pending') {
      bg = Colors.amber.shade900.withOpacity(0.3);
      fg = Colors.amberAccent;
      text = "En attente";
    } else if (status == 'accepted') {
      bg = Colors.green.shade900.withOpacity(0.3);
      fg = Colors.greenAccent;
      text = "Validé";
    } else if (status == 'rejected') {
      bg = Colors.red.shade900.withOpacity(0.3);
      fg = Colors.redAccent;
      text = "Refusé";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
