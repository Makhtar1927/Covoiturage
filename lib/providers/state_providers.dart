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

// Network status simulator (true = Online, false = Offline)
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
    // We mock saving vehicle into the user's data or store it in another key
    await _box.put('driver_vehicle', vehicle.toJson());
    // Trigger notification
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

// Rides State Provider (managing all rides)
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
    final ridesList = _box.values.toList();
    if (ridesList.isEmpty) {
      _loadDummyRides();
    } else {
      state = ridesList.map((e) => Ride.fromJson(e as String)).toList();
    }
  }

  void _loadDummyRides() {
    final now = DateTime.now();
    final driver1 = User(
      id: 'd1',
      name: 'Ibrahima Mbaye',
      email: 'ibrahima@gmail.com',
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Ibrahima',
      rating: 4.9,
      isVerified: true,
      circle: 'UKAC Touba',
    );
    final driver2 = User(
      id: 'd2',
      name: 'Mariama Sall',
      email: 'mariama@gmail.com',
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Mariama',
      rating: 4.7,
      isVerified: true,
      circle: 'Quartier Dianatou',
    );
    final driver3 = User(
      id: 'd3',
      name: 'Moustapha Diop',
      email: 'moustapha@gmail.com',
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Moustapha',
      rating: 4.5,
      isVerified: true,
      circle: 'Résidence Darou Khoudoss',
    );
    final driver4 = User(
      id: 'd4',
      name: 'Fatoumata Diallo',
      email: 'fatou@gmail.com',
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Fatou',
      rating: 4.8,
      isVerified: true,
      circle: 'Complexe Keur Nabi',
    );

    final dummyRides = [
      Ride(
        id: 'r1',
        driver: driver1,
        startPoint: 'Marché Ocass (Touba)',
        endPoint: 'UKAC - Campus Universitaire',
        intermediateStops: ['Grande Mosquée de Touba'],
        dateTime: now.add(const Duration(hours: 2)),
        price: 500,
        availableSeats: 3,
        totalSeats: 4,
        allowedCircles: ['UKAC Touba'],
        status: 'planned',
      ),
      Ride(
        id: 'r2',
        driver: driver2,
        startPoint: 'Keur Nabi (Entrée)',
        endPoint: 'Quartier Dianatou (Place Centrale)',
        intermediateStops: ['Baye Lamine', 'Darou Rahmane II'],
        dateTime: now.add(const Duration(hours: 4)),
        price: 300,
        availableSeats: 2,
        totalSeats: 3,
        allowedCircles: ['Quartier Dianatou'],
        status: 'planned',
      ),
      Ride(
        id: 'r3',
        driver: driver3,
        startPoint: 'Gare Routière de Touba',
        endPoint: 'Résidence Darou Khoudoss',
        intermediateStops: [],
        dateTime: now.add(const Duration(hours: 1)),
        price: 200,
        availableSeats: 8,
        totalSeats: 12,
        allowedCircles: ['Résidence Darou Khoudoss', 'UKAC Touba'],
        status: 'planned',
      ),
      Ride(
        id: 'r4',
        driver: driver4,
        startPoint: 'Darou Mousty (Carréfour principal)',
        endPoint: 'Complexe Keur Nabi (Bloc A)',
        intermediateStops: ['Dianatou Mahwa'],
        dateTime: now.add(const Duration(hours: 3)),
        price: 150,
        availableSeats: 28,
        totalSeats: 45,
        allowedCircles: ['Complexe Keur Nabi'],
        status: 'planned',
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

// Bookings State Provider (managing all bookings/reservations)
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
    final bookingsList = _box.values.toList();
    if (bookingsList.isNotEmpty) {
      state = bookingsList.map((e) => Booking.fromJson(e as String)).toList();
    } else {
      // Pre-load a dummy pending booking to show "Incoming Requests" to the driver
      _loadDummyBookings();
    }
  }

  void _loadDummyBookings() {
    final passenger = User(

      id: 'p1',
      name: 'Serigne Modou Ndiaye',
      email: 'smodou@gmail.com',
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Serigne',
      rating: 4.6,
      isVerified: true,
      circle: 'UKAC Touba',
    );

    // Let's find r1 (driver1 = Alexandre) to request a booking from Lucas
    final rides = _ref.read(rideListProvider);
    final r1 = rides.firstWhere((r) => r.id == 'r1', orElse: () => rides.first);

    final dummyBooking = Booking(
      id: 'b1',
      ride: r1,
      passenger: passenger,
      status: 'pending',
      departureValidated: false,
      arrivalValidated: false,
    );

    _box.put(dummyBooking.id, dummyBooking.toJson());
    state = [dummyBooking];
  }

  // Create booking reservation
  Future<void> createBooking(Ride ride) async {
    final passenger = _ref.read(currentUserProvider);
    if (passenger == null) return;

    final newBooking = Booking(
      id: const Uuid().v4(),
      ride: ride,
      passenger: passenger,
      status: 'pending', // Pending validation by driver
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
      // Immediate server sync
      final updated = booking.copyWith(departureValidated: true);
      updateBookingLocally(updated);
    } else {
      // Offline mode: mark departure validated and queue the sync action
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
      // Immediate server sync
      final updated = booking.copyWith(
        arrivalValidated: true,
        ride: booking.ride.copyWith(status: 'completed'),
      );
      updateBookingLocally(updated);
      _ref.read(rideListProvider.notifier).updateRide(updated.ride);
    } else {
      // Offline mode: mark arrival validated and queue the sync action
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

// Offline Synchronisation Queue State Provider
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
            offlineActionTimestamp: null, // cleared
          );
          bookingsNotifier.updateBookingLocally(updated);
        } else if (action.actionType == 'VALIDATE_ARRIVAL') {
          final updated = booking.copyWith(
            arrivalValidated: true,
            offlineActionTimestamp: null, // cleared
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
