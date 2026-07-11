import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final double rating;
  final bool isVerified;
  final String? circle;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.rating,
    required this.isVerified,
    this.circle,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'rating': rating,
      'isVerified': isVerified,
      'circle': circle,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatar: map['avatar'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      isVerified: map['isVerified'] ?? false,
      circle: map['circle'],
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    double? rating,
    bool? isVerified,
    String? circle,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      rating: rating ?? this.rating,
      isVerified: isVerified ?? this.isVerified,
      circle: circle ?? this.circle,
    );
  }
}

class Vehicle {
  final String model;
  final String color;
  final String category; // 'Particulier', 'Mini-bus', 'Bus'
  final String licensePlate;
  final int availableSeats;

  Vehicle({
    required this.model,
    required this.color,
    required this.category,
    required this.licensePlate,
    required this.availableSeats,
  });

  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'color': color,
      'category': category,
      'licensePlate': licensePlate,
      'availableSeats': availableSeats,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      model: map['model'] ?? '',
      color: map['color'] ?? '',
      category: map['category'] ?? 'Particulier',
      licensePlate: map['licensePlate'] ?? '',
      availableSeats: map['availableSeats'] ?? 4,
    );
  }

  String toJson() => json.encode(toMap());

  factory Vehicle.fromJson(String source) => Vehicle.fromMap(json.decode(source));
}

class Ride {
  final String id;
  final User driver;
  final String startPoint;
  final String endPoint;
  final List<String> intermediateStops;
  final DateTime dateTime;
  final double price;
  final int availableSeats;
  final int totalSeats;
  final List<String> allowedCircles;
  final String status; // 'planned', 'ongoing', 'completed', 'cancelled'

  Ride({
    required this.id,
    required this.driver,
    required this.startPoint,
    required this.endPoint,
    required this.intermediateStops,
    required this.dateTime,
    required this.price,
    required this.availableSeats,
    required this.totalSeats,
    required this.allowedCircles,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driver': driver.toMap(),
      'startPoint': startPoint,
      'endPoint': endPoint,
      'intermediateStops': intermediateStops,
      'dateTime': dateTime.toIso8601String(),
      'price': price,
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'allowedCircles': allowedCircles,
      'status': status,
    };
  }

  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
      id: map['id'] ?? '',
      driver: User.fromMap(map['driver'] ?? {}),
      startPoint: map['startPoint'] ?? '',
      endPoint: map['endPoint'] ?? '',
      intermediateStops: List<String>.from(map['intermediateStops'] ?? []),
      dateTime: DateTime.parse(map['dateTime'] ?? DateTime.now().toIso8601String()),
      price: (map['price'] ?? 0.0).toDouble(),
      availableSeats: map['availableSeats'] ?? 0,
      totalSeats: map['totalSeats'] ?? 0,
      allowedCircles: List<String>.from(map['allowedCircles'] ?? []),
      status: map['status'] ?? 'planned',
    );
  }

  String toJson() => json.encode(toMap());

  factory Ride.fromJson(String source) => Ride.fromMap(json.decode(source));

  Ride copyWith({
    String? id,
    User? driver,
    String? startPoint,
    String? endPoint,
    List<String>? intermediateStops,
    DateTime? dateTime,
    double? price,
    int? availableSeats,
    int? totalSeats,
    List<String>? allowedCircles,
    String? status,
  }) {
    return Ride(
      id: id ?? this.id,
      driver: driver ?? this.driver,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      intermediateStops: intermediateStops ?? this.intermediateStops,
      dateTime: dateTime ?? this.dateTime,
      price: price ?? this.price,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      allowedCircles: allowedCircles ?? this.allowedCircles,
      status: status ?? this.status,
    );
  }
}

class Booking {
  final String id;
  final Ride ride;
  final User passenger;
  final String status; // 'pending', 'accepted', 'rejected'
  final bool departureValidated;
  final bool arrivalValidated;
  final String? offlineActionTimestamp;

  Booking({
    required this.id,
    required this.ride,
    required this.passenger,
    required this.status,
    required this.departureValidated,
    required this.arrivalValidated,
    this.offlineActionTimestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ride': ride.toMap(),
      'passenger': passenger.toMap(),
      'status': status,
      'departureValidated': departureValidated,
      'arrivalValidated': arrivalValidated,
      'offlineActionTimestamp': offlineActionTimestamp,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? '',
      ride: Ride.fromMap(map['ride'] ?? {}),
      passenger: User.fromMap(map['passenger'] ?? {}),
      status: map['status'] ?? 'pending',
      departureValidated: map['departureValidated'] ?? false,
      arrivalValidated: map['arrivalValidated'] ?? false,
      offlineActionTimestamp: map['offlineActionTimestamp'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Booking.fromJson(String source) => Booking.fromMap(json.decode(source));

  Booking copyWith({
    String? id,
    Ride? ride,
    User? passenger,
    String? status,
    bool? departureValidated,
    bool? arrivalValidated,
    String? offlineActionTimestamp,
  }) {
    return Booking(
      id: id ?? this.id,
      ride: ride ?? this.ride,
      passenger: passenger ?? this.passenger,
      status: status ?? this.status,
      departureValidated: departureValidated ?? this.departureValidated,
      arrivalValidated: arrivalValidated ?? this.arrivalValidated,
      offlineActionTimestamp: offlineActionTimestamp ?? this.offlineActionTimestamp,
    );
  }
}

class SyncAction {
  final String id;
  final String actionType; // 'VALIDATE_DEPARTURE', 'VALIDATE_ARRIVAL'
  final String bookingId;
  final String timestamp;

  SyncAction({
    required this.id,
    required this.actionType,
    required this.bookingId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'actionType': actionType,
      'bookingId': bookingId,
      'timestamp': timestamp,
    };
  }

  factory SyncAction.fromMap(Map<String, dynamic> map) {
    return SyncAction(
      id: map['id'] ?? '',
      actionType: map['actionType'] ?? '',
      bookingId: map['bookingId'] ?? '',
      timestamp: map['timestamp'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SyncAction.fromJson(String source) => SyncAction.fromMap(json.decode(source));
}
