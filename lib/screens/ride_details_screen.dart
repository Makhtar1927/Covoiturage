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
          "Détails du Trajet",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Route Header
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
                        "COMMUNAUTAIRE",
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        "${ride.price.toInt()} FCFA",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 24.0,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: dividerColor, height: 20),
                  const SizedBox(height: 8),
                  // Route endpoints
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.circle, color: cs.primary, size: 12),
                          Container(width: 2, height: 32, color: dividerColor),
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
                              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              ride.endPoint,
                              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (ride.intermediateStops.isNotEmpty) ...[
                    Divider(color: dividerColor, height: 24),
                    Text(
                      "Étapes intermédiaires :",
                      style: TextStyle(color: subtitleColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: ride.intermediateStops.map((stop) {
                        return Chip(
                          label: Text(stop, style: TextStyle(fontSize: 11, color: textColor)),
                          backgroundColor: cs.onSurface.withValues(alpha: 0.05),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          side: BorderSide(color: dividerColor),
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
              useWhiteBlend: !isDark,
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
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.verified, color: cs.primary, size: 18),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "★ ${ride.driver.rating} • Conducteur vérifié",
                          style: TextStyle(color: subtitleColor, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.groups_rounded, size: 14, color: subtitleColor.withValues(alpha: 0.8)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Cercles : ${ride.allowedCircles.join(', ')}",
                                style: TextStyle(color: subtitleColor, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
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
                    useWhiteBlend: !isDark,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.calendar_month, color: cs.primary, size: 20),
                        const SizedBox(height: 8),
                        Text("Date & Heure", style: TextStyle(color: subtitleColor, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd/MM à HH:mm').format(ride.dateTime),
                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassContainer(
                    opacity: 0.05,
                    useWhiteBlend: !isDark,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.airline_seat_recline_normal, color: cs.primary, size: 20),
                        const SizedBox(height: 8),
                        Text("Places libres", style: TextStyle(color: subtitleColor, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          "${ride.availableSeats} / ${ride.totalSeats}",
                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // MODULE 3: FEUILLE DE ROUTE (Only visible if booking is accepted)
            if (userBooking.status == 'accepted') ...[
              _buildFeuilleDeRoute(context, userBooking, cs, textColor, subtitleColor, dividerColor, isDark),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            if (ride.driver.id == user?.id)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: dividerColor),
                ),
                child: Center(
                  child: Text(
                    "Vous êtes le conducteur de ce trajet",
                    style: TextStyle(color: subtitleColor, fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else if (isBooked)
              _buildBookingStatusArea(context, userBooking, cs)
            else if (ride.availableSeats <= 0)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.onSurface.withValues(alpha: 0.1),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                onPressed: null,
                child: Text("Trajet Complet", style: TextStyle(color: subtitleColor.withValues(alpha: 0.5), fontSize: 16)),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
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

  Widget _buildFeuilleDeRoute(BuildContext context, Booking booking, ColorScheme cs, Color textColor, Color subtitleColor, Color dividerColor, bool isDark) {
    return GlassContainer(
      opacity: 0.08,
      borderColor: Colors.teal,
      useWhiteBlend: !isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_rounded, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                "Feuille de Route (Embarquée)",
                style: TextStyle(color: isDark ? Colors.tealAccent : Colors.teal.shade800, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          Divider(color: dividerColor, height: 20),
          const SizedBox(height: 4),
          Text(
            "Téléchargée localement pour accès en zone blanche.",
            style: TextStyle(color: subtitleColor, fontSize: 11, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          // Phone contact
          Row(
            children: [
              Icon(Icons.phone_rounded, color: subtitleColor, size: 18),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Contact Conducteur", style: TextStyle(color: subtitleColor, fontSize: 10)),
                  Text(
                    "+221 77 123 45 67",
                    style: TextStyle(color: cs.primary, fontSize: 13, fontWeight: FontWeight.bold),
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
              Icon(Icons.meeting_room_rounded, color: subtitleColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Point de rendez-vous exact", style: TextStyle(color: subtitleColor, fontSize: 10)),
                    Text(
                      booking.ride.startPoint,
                      style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Route instructions
          Text(
            "Instructions d'itinéraire :",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 6),
          _buildInstructionStep("1", "Rendez-vous à l'adresse de départ 5 minutes avant l'heure.", textColor, subtitleColor, dividerColor),
          _buildInstructionStep("2", "Le conducteur s'arrêtera sur la zone de dépose minute.", textColor, subtitleColor, dividerColor),
          _buildInstructionStep("3", "Trajet direct par la voie rapide vers ${booking.ride.endPoint}.", textColor, subtitleColor, dividerColor),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String step, String text, Color textColor, Color subtitleColor, Color dividerColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: dividerColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              step,
              style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: subtitleColor, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingStatusArea(BuildContext context, Booking booking, ColorScheme cs) {
    Color color = cs.onSurface.withValues(alpha: 0.6);
    String statusText = "";
    Widget? subWidget;

    if (booking.status == 'pending') {
      color = Colors.amber.shade700;
      statusText = "Demande en attente de validation";
    } else if (booking.status == 'accepted') {
      color = Colors.green.shade700;
      statusText = "Réservation acceptée !";
      subWidget = Padding(
        padding: const EdgeInsets.only(top: 14.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(46),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
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
      color = Colors.red.shade700;
      statusText = "Réservation refusée par le conducteur";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
