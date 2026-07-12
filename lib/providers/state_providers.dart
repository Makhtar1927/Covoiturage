import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:uuid/uuid.dart';
import '../models/models.dart';

// --- Hive Boxes names ---
const String kUsersBoxName = 'users_box';
const String kRidesBoxName = 'rides_box';
const String kBookingsBoxName = 'bookings_box';
const String kSyncQueueBoxName = 'sync_queue_box';

// --- State Providers ---

// Theme mode toggle (default: light)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light);

  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

final networkStatusProvider = StateNotifierProvider<NetworkStatusNotifier, bool>((ref) {
  return NetworkStatusNotifier(ref);
});

class NetworkStatusNotifier extends StateNotifier<bool> {
  final Ref _ref;
  NetworkStatusNotifier(this._ref) : super(true);

  void toggle() {
    state = !state;
    if (state) {
      // If we go back online, trigger synchronization of pending actions
      _ref.read(syncQueueProvider.notifier).syncQueue();
    }
  }

  void setOnline() {
    if (!state) {
      state = true;
      _ref.read(syncQueueProvider.notifier).syncQueue();
    }
  }

  void setOffline() {
    state = false;
  }
}

// Current User State Provider
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>((ref) {
  return CurrentUserNotifier();
});

class CurrentUserNotifier extends StateNotifier<User?> {
  CurrentUserNotifier() : super(null) {
    _loadUser();
  }

  late Box _box;

  Future<void> _loadUser() async {
    _box = await Hive.openBox(kUsersBoxName);
    final userJson = _box.get('current_user');
    if (userJson != null) {
      state = User.fromJson(userJson);
    }
  }

  Future<void> loginAndVerify(String name, String email, String circle) async {
    final user = User(
      id: const Uuid().v4(),
      name: name,
      email: email,
      avatar: 'https://api.dicebear.com/7.x/bottts/png?seed=${Uri.encodeComponent(name)}',
      rating: 4.8,
      isVerified: true,
      circle: circle,
    );
    state = user;
    await _box.put('current_user', user.toJson());
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    if (state == null) return;
    await _box.put('driver_vehicle', vehicle.toJson());
    state = state!.copyWith(); // trigger notify
  }

  Vehicle? getVehicle() {
    final vehicleJson = _box.get('driver_vehicle');
    if (vehicleJson != null) {
      return Vehicle.fromJson(vehicleJson);
    }
    return null;
  }

  Future<void> logout() async {
    state = null;
    await _box.delete('current_user');
    await _box.delete('driver_vehicle');
  }
}

// ─── Shared mock drivers & passengers ───────────────────────────────────────

User _mkDriver1() => User(
      id: 'd1',
      name: 'Ibrahima Mbaye',
      email: 'ibrahima@gmail.com',
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Ibrahima',
      rating: 4.9,
      isVerified: true,
      circle: 'UKAC Touba',
    );

User _mkDriver2() => User(
      id: 'd2',
      name: 'Mariama Sall',
      email: 'mariama@gmail.com',
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Mariama',
      rating: 4.7,
      isVerified: true,
      circle: 'Quartier Dianatou',
    );

User _mkDriver3() => User(
      id: 'd3',
      name: 'Moustapha Diop',
      email: 'moustapha@gmail.com',
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Moustapha',
      rating: 4.5,
      isVerified: true,
      circle: 'Résidence Darou Khoudoss',
    );

User _mkDriver4() => User(
      id: 'd4',
      name: 'Fatoumata Diallo',
      email: 'fatou@gmail.com',
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Fatou',
      rating: 4.8,
      isVerified: true,
      circle: 'Complexe Keur Nabi',
    );

User _mkDriver5() => User(
      id: 'd5',
      name: 'Abdoulaye Thiam',
      email: 'abdoulaye@gmail.com',
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Abdoulaye',
      rating: 4.6,
      isVerified: true,
      circle: 'UKAC Touba',
    );

User _mkDriver6() => User(
      id: 'd6',
      name: 'Ndèye Fatou Cissé',
      email: 'ndeye.fatou@gmail.com',
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Ndeye',
      rating: 5.0,
      isVerified: true,
      circle: 'Quartier Dianatou',
    );

// ─── Shared mock passengers ──────────────────────────────────────────────────

User _mkPassenger1() => User(
      id: 'p1',
      name: 'Serigne Modou Ndiaye',
      email: 'smodou@gmail.com',
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Serigne',
      rating: 4.6,
      isVerified: true,
      circle: 'UKAC Touba',
    );

User _mkPassenger2() => User(
      id: 'p2',
      name: 'Aminata Touré',
      email: 'aminata@gmail.com',
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Aminata',
      rating: 4.9,
      isVerified: true,
      circle: 'Quartier Dianatou',
    );

User _mkPassenger3() => User(
      id: 'p3',
      name: 'Omar Sy Ba',
      email: 'omar.ba@gmail.com',
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Omar',
      rating: 4.4,
      isVerified: true,
      circle: 'Résidence Darou Khoudoss',
    );

User _mkPassenger4() => User(
      id: 'p4',
      name: 'Rokhaya Diagne',
      email: 'rokhaya@gmail.com',
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Rokhaya',
      rating: 4.7,
      isVerified: false,
      circle: 'Complexe Keur Nabi',
    );

User _mkPassenger5() => User(
      id: 'p5',
      name: 'Cheikh Tidiane Fall',
      email: 'ctfall@gmail.com',
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Cheikh',
      rating: 4.3,
      isVerified: true,
      circle: 'UKAC Touba',
    );

User _mkPassenger6() => User(
      id: 'p6',
      name: 'Khadija Gueye',
      email: 'khadija@gmail.com',
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Khadija',
      rating: 5.0,
      isVerified: true,
      circle: 'Quartier Dianatou',
    );

// ─── Rides State Provider ────────────────────────────────────────────────────

final rideListProvider = StateNotifierProvider<RideListNotifier, List<Ride>>((ref) {
  return RideListNotifier(ref);
});

class RideListNotifier extends StateNotifier<List<Ride>> {
  final Ref _ref;
  late Box _box;

  RideListNotifier(this._ref) : super([]) {
    _initRides();
  }

  Future<void> _initRides() async {
    _box = await Hive.openBox(kRidesBoxName);
    final isMigrated = _box.get('mock_version_v2') == true;
    if (!isMigrated) {
      await _box.clear();
      await _box.put('mock_version_v2', true);
    }
    final ridesList = _box.values.whereType<String>().toList();
    if (ridesList.isEmpty) {
      _loadDummyRides();
    } else {
      state = ridesList.map((e) => Ride.fromJson(e)).toList();
    }
  }

  void _loadDummyRides() {
    final now = DateTime.now();

    final dummyRides = [
      // ── Planned rides (available for search) ──────────────────────────────
      Ride(
        id: 'r1',
        driver: _mkDriver1(),
        startPoint: 'Marché Ocass (Touba)',
        endPoint: 'UKAC - Campus Universitaire',
        intermediateStops: ['Grande Mosquée de Touba', 'Pharmacie Centrale'],
        dateTime: now.add(const Duration(hours: 2)),
        price: 500,
        availableSeats: 2,
        totalSeats: 4,
        allowedCircles: ['UKAC Touba'],
        status: 'planned',
      ),
      Ride(
        id: 'r2',
        driver: _mkDriver2(),
        startPoint: 'Keur Nabi (Entrée principale)',
        endPoint: 'Quartier Dianatou (Place Centrale)',
        intermediateStops: ['Baye Lamine', 'Darou Rahmane II'],
        dateTime: now.add(const Duration(hours: 4)),
        price: 300,
        availableSeats: 1,
        totalSeats: 3,
        allowedCircles: ['Quartier Dianatou'],
        status: 'planned',
      ),
      Ride(
        id: 'r3',
        driver: _mkDriver3(),
        startPoint: 'Gare Routière de Touba',
        endPoint: 'Résidence Darou Khoudoss',
        intermediateStops: ['Boulangerie Al-Khaïr'],
        dateTime: now.add(const Duration(hours: 1)),
        price: 200,
        availableSeats: 6,
        totalSeats: 12,
        allowedCircles: ['Résidence Darou Khoudoss', 'UKAC Touba'],
        status: 'planned',
      ),
      Ride(
        id: 'r4',
        driver: _mkDriver4(),
        startPoint: 'Darou Mousty (Carrefour Principal)',
        endPoint: 'Complexe Keur Nabi (Bloc A)',
        intermediateStops: ['Dianatou Mahwa', 'Marché Ndamatou'],
        dateTime: now.add(const Duration(hours: 3)),
        price: 150,
        availableSeats: 22,
        totalSeats: 45,
        allowedCircles: ['Complexe Keur Nabi'],
        status: 'planned',
      ),
      Ride(
        id: 'r8',
        driver: _mkDriver2(),
        startPoint: 'Complexe Keur Nabi',
        endPoint: 'Université Cheikh Anta Diop (Antenne Touba)',
        intermediateStops: ['Rond-Point Darou Marnane', 'École Technique'],
        dateTime: now.add(const Duration(hours: 6)),
        price: 350,
        availableSeats: 3,
        totalSeats: 5,
        allowedCircles: ['Quartier Dianatou', 'Complexe Keur Nabi'],
        status: 'planned',
      ),
      // ── Ongoing ride ──────────────────────────────────────────────────────
      Ride(
        id: 'r5',
        driver: _mkDriver5(),
        startPoint: 'UKAC - Bibliothèque Centrale',
        endPoint: 'Gare Routière de Touba',
        intermediateStops: ['Rond-Point Baye Lahat'],
        dateTime: now.subtract(const Duration(hours: 1)),
        price: 400,
        availableSeats: 0,
        totalSeats: 4,
        allowedCircles: ['UKAC Touba', 'Quartier Dianatou'],
        status: 'ongoing',
      ),
      // ── Completed rides ───────────────────────────────────────────────────
      Ride(
        id: 'r6',
        driver: _mkDriver6(),
        startPoint: 'Résidence Darou Khoudoss (Bloc C)',
        endPoint: 'Hôpital Matlaboul Fawzeyni',
        intermediateStops: ['Pharmacie El-Hadji Malick'],
        dateTime: now.subtract(const Duration(hours: 3)),
        price: 250,
        availableSeats: 0,
        totalSeats: 4,
        allowedCircles: ['Quartier Dianatou', 'Résidence Darou Khoudoss'],
        status: 'completed',
      ),
      Ride(
        id: 'r7',
        driver: _mkDriver1(),
        startPoint: 'UKAC - Résidence Étudiante',
        endPoint: 'Marché Ocass (Touba)',
        intermediateStops: ['Grande Mosquée de Touba'],
        dateTime: now.subtract(const Duration(days: 1, hours: 2)),
        price: 500,
        availableSeats: 0,
        totalSeats: 3,
        allowedCircles: ['UKAC Touba'],
        status: 'completed',
      ),
    ];

    for (var ride in dummyRides) {
      _box.put(ride.id, ride.toJson());
    }
    state = dummyRides;
  }

  Future<void> publishRide({
    required String startPoint,
    required String endPoint,
    required List<String> intermediateStops,
    required DateTime dateTime,
    required double price,
    required int availableSeats,
    required List<String> allowedCircles,
  }) async {
    final driver = _ref.read(currentUserProvider);
    if (driver == null) return;

    final newRide = Ride(
      id: const Uuid().v4(),
      driver: driver,
      startPoint: startPoint,
      endPoint: endPoint,
      intermediateStops: intermediateStops,
      dateTime: dateTime,
      price: price,
      availableSeats: availableSeats,
      totalSeats: availableSeats,
      allowedCircles: allowedCircles,
      status: 'planned',
    );

    state = [...state, newRide];
    await _box.put(newRide.id, newRide.toJson());
  }

  // Update ride seats or status locally
  void updateRide(Ride updatedRide) {
    state = [
      for (final r in state)
        if (r.id == updatedRide.id) updatedRide else r
    ];
    _box.put(updatedRide.id, updatedRide.toJson());
  }
}

// ─── Bookings State Provider ─────────────────────────────────────────────────

final bookingProvider = StateNotifierProvider<BookingNotifier, List<Booking>>((ref) {
  return BookingNotifier(ref);
});

class BookingNotifier extends StateNotifier<List<Booking>> {
  final Ref _ref;
  late Box _box;

  BookingNotifier(this._ref) : super([]) {
    _initBookings();
  }

  Future<void> _initBookings() async {
    _box = await Hive.openBox(kBookingsBoxName);
    final isMigrated = _box.get('mock_version_v2') == true;
    if (!isMigrated) {
      await _box.clear();
      await _box.put('mock_version_v2', true);
    }
    final bookingsList = _box.values.whereType<String>().toList();
    if (bookingsList.isNotEmpty) {
      state = bookingsList.map((e) => Booking.fromJson(e)).toList();
    } else {
      _loadDummyBookings();
    }
  }

  void _loadDummyBookings() {
    final rides = _ref.read(rideListProvider);
    Ride rideById(String id) => rides.firstWhere((r) => r.id == id, orElse: () => rides.first);

    final now = DateTime.now();

    final dummyBookings = [
      // ── Pending (conducteur voit les demandes entrantes) ──────────────────
      Booking(
        id: 'b1',
        ride: rideById('r1'),
        passenger: _mkPassenger1(),
        status: 'pending',
        departureValidated: false,
        arrivalValidated: false,
      ),
      Booking(
        id: 'b2',
        ride: rideById('r2'),
        passenger: _mkPassenger6(),
        status: 'pending',
        departureValidated: false,
        arrivalValidated: false,
      ),

      // ── Accepted – départ non validé (Carnet: bouton "Valider Départ") ────
      Booking(
        id: 'b3',
        ride: rideById('r3'),
        passenger: _mkPassenger2(),
        status: 'accepted',
        departureValidated: false,
        arrivalValidated: false,
      ),
      Booking(
        id: 'b4',
        ride: rideById('r4'),
        passenger: _mkPassenger3(),
        status: 'accepted',
        departureValidated: false,
        arrivalValidated: false,
      ),

      // ── Accepted – départ validé, arrivée non validée (trajet en cours) ──
      Booking(
        id: 'b5',
        ride: rideById('r5'),
        passenger: _mkPassenger4(),
        status: 'accepted',
        departureValidated: true,
        arrivalValidated: false,
      ),
      Booking(
        id: 'b6',
        ride: rideById('r5'),
        passenger: _mkPassenger5(),
        status: 'accepted',
        departureValidated: true,
        arrivalValidated: false,
      ),

      // ── Accepted – validé hors-ligne (en attente de sync) ─────────────────
      Booking(
        id: 'b7',
        ride: rideById('r8'),
        passenger: _mkPassenger1(),
        status: 'accepted',
        departureValidated: true,
        arrivalValidated: false,
        offlineActionTimestamp: now.subtract(const Duration(minutes: 12)).toIso8601String(),
      ),

      // ── Fully completed (départ + arrivée validés) ────────────────────────
      Booking(
        id: 'b8',
        ride: rideById('r6'),
        passenger: _mkPassenger2(),
        status: 'accepted',
        departureValidated: true,
        arrivalValidated: true,
      ),
      Booking(
        id: 'b9',
        ride: rideById('r7'),
        passenger: _mkPassenger3(),
        status: 'accepted',
        departureValidated: true,
        arrivalValidated: true,
      ),
    ];

    for (var booking in dummyBookings) {
      _box.put(booking.id, booking.toJson());
    }
    state = dummyBookings;
  }

  // Create booking reservation
  Future<void> createBooking(Ride ride) async {
    final passenger = _ref.read(currentUserProvider);
    if (passenger == null) return;

    final newBooking = Booking(
      id: const Uuid().v4(),
      ride: ride,
      passenger: passenger,
      status: 'pending',
      departureValidated: false,
      arrivalValidated: false,
    );

    state = [...state, newBooking];
    await _box.put(newBooking.id, newBooking.toJson());
  }

  // Approve or reject booking (for driver)
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    state = [
      for (final b in state)
        if (b.id == bookingId) ...[
          (() {
            final updated = b.copyWith(status: newStatus);
            _box.put(bookingId, updated.toJson());

            // If accepted, update the ride's available seats
            if (newStatus == 'accepted') {
              final ride = b.ride;
              if (ride.availableSeats > 0) {
                final updatedRide = ride.copyWith(availableSeats: ride.availableSeats - 1);
                _ref.read(rideListProvider.notifier).updateRide(updatedRide);
              }
            }
            return updated;
          })()
        ] else
          b
    ];
  }

  // Local updates helper (for offline validation)
  void updateBookingLocally(Booking updatedBooking) {
    state = [
      for (final b in state)
        if (b.id == updatedBooking.id) updatedBooking else b
    ];
    _box.put(updatedBooking.id, updatedBooking.toJson());
  }

  // Validate Departure (works offline!)
  Future<void> validateDeparture(String bookingId) async {
    final isOnline = _ref.read(networkStatusProvider);
    final booking = state.firstWhere((b) => b.id == bookingId);

    if (isOnline) {
      final updated = booking.copyWith(departureValidated: true);
      updateBookingLocally(updated);
    } else {
      final updated = booking.copyWith(
        departureValidated: true,
        offlineActionTimestamp: DateTime.now().toIso8601String(),
      );
      updateBookingLocally(updated);

      final syncAction = SyncAction(
        id: const Uuid().v4(),
        actionType: 'VALIDATE_DEPARTURE',
        bookingId: bookingId,
        timestamp: DateTime.now().toIso8601String(),
      );
      _ref.read(syncQueueProvider.notifier).addAction(syncAction);
    }
  }

  // Validate Arrival (works offline!)
  Future<void> validateArrival(String bookingId) async {
    final isOnline = _ref.read(networkStatusProvider);
    final booking = state.firstWhere((b) => b.id == bookingId);

    if (isOnline) {
      final updated = booking.copyWith(
        arrivalValidated: true,
        ride: booking.ride.copyWith(status: 'completed'),
      );
      updateBookingLocally(updated);
      _ref.read(rideListProvider.notifier).updateRide(updated.ride);
    } else {
      final updated = booking.copyWith(
        arrivalValidated: true,
        offlineActionTimestamp: DateTime.now().toIso8601String(),
      );
      updateBookingLocally(updated);

      final syncAction = SyncAction(
        id: const Uuid().v4(),
        actionType: 'VALIDATE_ARRIVAL',
        bookingId: bookingId,
        timestamp: DateTime.now().toIso8601String(),
      );
      _ref.read(syncQueueProvider.notifier).addAction(syncAction);
    }
  }
}

// ─── Offline Synchronisation Queue State Provider ────────────────────────────

final syncQueueProvider = StateNotifierProvider<SyncQueueNotifier, List<SyncAction>>((ref) {
  return SyncQueueNotifier(ref);
});

class SyncQueueNotifier extends StateNotifier<List<SyncAction>> {
  final Ref _ref;
  late Box _box;

  SyncQueueNotifier(this._ref) : super([]) {
    _initSyncQueue();
  }

  Future<void> _initSyncQueue() async {
    _box = await Hive.openBox(kSyncQueueBoxName);
    final list = _box.values.toList();
    if (list.isNotEmpty) {
      state = list.map((e) => SyncAction.fromJson(e as String)).toList();
    }
  }

  Future<void> addAction(SyncAction action) async {
    state = [...state, action];
    await _box.put(action.id, action.toJson());
  }

  // Synchronise offline actions queue with mock "server"
  Future<void> syncQueue() async {
    if (state.isEmpty) return;

    // Simulate server connection delay
    await Future.delayed(const Duration(seconds: 1));

    final list = List<SyncAction>.from(state);
    final bookingsNotifier = _ref.read(bookingProvider.notifier);
    final ridesNotifier = _ref.read(rideListProvider.notifier);

    for (var action in list) {
      try {
        final booking = _ref.read(bookingProvider).firstWhere((b) => b.id == action.bookingId);

        if (action.actionType == 'VALIDATE_DEPARTURE') {
          final updated = booking.copyWith(
            departureValidated: true,
            offlineActionTimestamp: null,
          );
          bookingsNotifier.updateBookingLocally(updated);
        } else if (action.actionType == 'VALIDATE_ARRIVAL') {
          final updated = booking.copyWith(
            arrivalValidated: true,
            offlineActionTimestamp: null,
            ride: booking.ride.copyWith(status: 'completed'),
          );
          bookingsNotifier.updateBookingLocally(updated);
          ridesNotifier.updateRide(updated.ride);
        }
      } catch (e) {
        // Handle case where booking might not exist
      }

      await _box.delete(action.id);
    }

    state = [];
  }
}
