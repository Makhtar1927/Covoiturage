import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/state_providers.dart';
import '../widgets/glass_container.dart';
import 'carnet_voyage_screen.dart';

class RideDetailsScreen extends ConsumerWidget {
  final Ride ride;

  const RideDetailsScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final bookings = ref.watch(bookingProvider);
    
    // Check if this user has already booked this ride
    final userBooking = bookings.firstWhere(
      (b) => b.ride.id == ride.id && b.passenger.id == user?.id,
      orElse: () => Booking(
        id: '',
        ride: ride,
        passenger: user ?? User(id: '', name: '', email: '', avatar: '', rating: 0, isVerified: false),
        status: 'none',
        departureValidated: false,
        arrivalValidated: false,
      ),
    );

    final isBooked = userBooking.status != 'none';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails du Trajet"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Route Header
            GlassContainer(
              opacity: 0.1,
              borderColor: Colors.cyanAccent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "COMMUNAUTAIRE",
                        style: TextStyle(
                          color: Colors.cyanAccent.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        "${ride.price.toStringAsFixed(2)} €",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 24.0,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  const SizedBox(height: 8),
                  // Route endpoints
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.circle, color: Colors.cyanAccent, size: 12),
                          Container(width: 2, height: 32, color: Colors.white24),
                          const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride.startPoint,
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              ride.endPoint,
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (ride.intermediateStops.isNotEmpty) ...[
                    const Divider(color: Colors.white12, height: 24),
                    const Text("Étapes intermédiaires :", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: ride.intermediateStops.map((stop) {
                        return Chip(
                          label: Text(stop, style: const TextStyle(fontSize: 11)),
                          backgroundColor: Colors.white.withOpacity(0.05),
                          labelStyle: const TextStyle(color: Colors.white70),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Driver & Circle Card
            GlassContainer(
              opacity: 0.05,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(ride.driver.avatar),
                    radius: 26,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              ride.driver.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: Colors.cyanAccent, size: 18),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "★ ${ride.driver.rating} • Conducteur vérifié",
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.groups_rounded, size: 14, color: Colors.white.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Text(
                              "Cercles autorisés : ${ride.allowedCircles.join(', ')}",
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ride Date/Time & Seats Detail
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    opacity: 0.05,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.calendar_month, color: Colors.cyanAccent.withOpacity(0.8), size: 20),
                        const SizedBox(height: 8),
                        const Text("Date & Heure", style: TextStyle(color: Colors.white54, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd/MM à HH:mm').format(ride.dateTime),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassContainer(
                    opacity: 0.05,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.airline_seat_recline_normal, color: Colors.cyanAccent.withOpacity(0.8), size: 20),
                        const SizedBox(height: 8),
                        const Text("Places disponibles", style: TextStyle(color: Colors.white54, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          "${ride.availableSeats} / ${ride.totalSeats}",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // MODULE 3: FEUILLE DE ROUTE (Only visible if booking is accepted/validated)
            if (userBooking.status == 'accepted') ...[
              _buildFeuilleDeRoute(context, userBooking),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            if (ride.driver.id == user?.id)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    "Vous êtes le conducteur de ce trajet",
                    style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else if (isBooked)
              _buildBookingStatusArea(context, userBooking)
            else if (ride.availableSeats <= 0)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: null,
                child: const Text("Trajet Complet", style: TextStyle(color: Colors.white30, fontSize: 16)),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black87,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                ),
                onPressed: () {
                  ref.read(bookingProvider.notifier).createBooking(ride);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Demande de réservation envoyée au conducteur !"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text("Réserver une place", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeuilleDeRoute(BuildContext context, Booking booking) {
    return GlassContainer(
      opacity: 0.08,
      borderColor: Colors.tealAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_rounded, color: Colors.tealAccent),
              const SizedBox(width: 8),
              Text(
                "Feuille de Route (Embarquée)",
                style: TextStyle(color: Colors.tealAccent.shade100, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 20),
          const SizedBox(height: 4),
          const Text(
            "Téléchargée localement pour accès en zone blanche.",
            style: TextStyle(color: Colors.white54, fontSize: 11, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          // Phone contact
          Row(
            children: [
              const Icon(Icons.phone_rounded, color: Colors.white70, size: 18),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Contact Conducteur", style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Text(
                    "+33 6 78 54 32 10",
                    style: TextStyle(color: Colors.cyanAccent.shade100, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Rendez-vous point
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.meeting_room_rounded, color: Colors.white70, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Point de rendez-vous exact", style: TextStyle(color: Colors.white54, fontSize: 10)),
                    Text(
                      booking.ride.startPoint,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Route instructions
          const Text(
            "Instructions d'itinéraire :",
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 6),
          _buildInstructionStep("1", "Rendez-vous à l'adresse de départ 5 minutes avant l'heure."),
          _buildInstructionStep("2", "Le conducteur s'arrêtera sur la zone de dépose minute."),
          _buildInstructionStep("3", "Trajet direct par la voie rapide vers ${booking.ride.endPoint}."),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Text(
              step,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingStatusArea(BuildContext context, Booking booking) {
    Color color = Colors.white60;
    String statusText = "";
    Widget? subWidget;

    if (booking.status == 'pending') {
      color = Colors.amberAccent;
      statusText = "Demande en attente de validation";
    } else if (booking.status == 'accepted') {
      color = Colors.greenAccent;
      statusText = "Réservation acceptée !";
      subWidget = Padding(
        padding: const EdgeInsets.only(top: 14.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(46),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CarnetVoyageScreen()),
            );
          },
          icon: const Icon(Icons.assignment_turned_in_rounded),
          label: const Text("Ouvrir le Carnet de Voyage", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    } else if (booking.status == 'rejected') {
      color = Colors.redAccent;
      statusText = "Réservation refusée par le conducteur";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                booking.status == 'accepted' 
                    ? Icons.check_circle_outline_rounded 
                    : (booking.status == 'rejected' ? Icons.cancel_outlined : Icons.hourglass_empty_rounded),
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                statusText,
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          if (subWidget != null) subWidget,
        ],
      ),
    );
  }
}
