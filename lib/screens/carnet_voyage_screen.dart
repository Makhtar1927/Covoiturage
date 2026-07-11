import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/state_providers.dart';
import '../widgets/glass_container.dart';
import '../widgets/network_banner.dart';

class CarnetVoyageScreen extends ConsumerWidget {
  const CarnetVoyageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final bookings = ref.watch(bookingProvider);
    final syncQueue = ref.watch(syncQueueProvider);


    // List bookings that have status 'accepted' where this user is passenger or driver
    final activeBookings = bookings.where((b) {
      final isPassenger = b.passenger.id == user?.id;
      final isDriver = b.ride.driver.id == user?.id;
      return b.status == 'accepted' && (isPassenger || isDriver);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Carnet de Voyage",
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
            child: activeBookings.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activeBookings.length,
                    itemBuilder: (context, index) {
                      final booking = activeBookings[index];
                      final ride = booking.ride;
                      final isDriver = ride.driver.id == user?.id;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: GlassContainer(
                          opacity: 0.08,
                          borderColor: Colors.tealAccent.withOpacity(0.3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Card Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDriver 
                                          ? Colors.cyan.shade900.withOpacity(0.4) 
                                          : Colors.teal.shade900.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isDriver 
                                            ? Colors.cyanAccent.withOpacity(0.3) 
                                            : Colors.tealAccent.withOpacity(0.3)
                                      ),
                                    ),
                                    child: Text(
                                      isDriver ? "Conducteur" : "Passager",
                                      style: TextStyle(
                                        color: isDriver ? Colors.cyanAccent : Colors.tealAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.download_done_rounded, color: Colors.greenAccent, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Sauvegardé hors-ligne",
                                        style: TextStyle(color: Colors.greenAccent.shade100, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white24, height: 20),
                              
                              // Route
                              Text(
                                "${ride.startPoint} ➔ ${ride.endPoint}",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Date : ${DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(ride.dateTime)}",
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                              ),
                              const SizedBox(height: 10),
                              
                              // Contact Person details
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      isDriver ? booking.passenger.avatar : ride.driver.avatar
                                    ),
                                    radius: 14,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isDriver 
                                        ? "Passager : ${booking.passenger.name} (${booking.passenger.circle})" 
                                        : "Conducteur : ${ride.driver.name} (${ride.driver.circle})",
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),

                                  ),
                                ],
                              ),
                              
                              const Divider(color: Colors.white12, height: 24),
                              
                              // Checkpoint validators (Départ / Arrivée)
                              const Text(
                                "Validation de la course :",
                                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              
                              // 1. Departure Checkpoint
                              _buildCheckpointRow(
                                context: context,
                                ref: ref,
                                title: "1. Départ du covoiturage",
                                isValidated: booking.departureValidated,
                                isPending: _isActionPending(syncQueue, booking.id, 'VALIDATE_DEPARTURE'),
                                onValidate: () => ref.read(bookingProvider.notifier).validateDeparture(booking.id),
                              ),
                              const SizedBox(height: 12),
                              
                              // 2. Arrival Checkpoint
                              _buildCheckpointRow(
                                context: context,
                                ref: ref,
                                title: "2. Arrivée à destination",
                                isValidated: booking.arrivalValidated,
                                isPending: _isActionPending(syncQueue, booking.id, 'VALIDATE_ARRIVAL'),
                                isEnabled: booking.departureValidated, // only enable after departure is validated
                                onValidate: () => ref.read(bookingProvider.notifier).validateArrival(booking.id),
                              ),

                              // Offline Warning text if validated offline
                              if (booking.offlineActionTimestamp != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade900.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.hourglass_empty_rounded, color: Colors.orangeAccent, size: 14),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          "Mémorisé localement. La validation sera synchronisée dès qu'une connexion sera disponible.",
                                          style: TextStyle(color: Colors.orangeAccent, fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _isActionPending(List<SyncAction> queue, String bookingId, String actionType) {
    return queue.any((action) => action.bookingId == bookingId && action.actionType == actionType);
  }

  Widget _buildCheckpointRow({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required bool isValidated,
    required bool isPending,
    bool isEnabled = true,
    required VoidCallback onValidate,
  }) {
    Color color = Colors.white30;
    Widget trailing = const SizedBox();

    if (isValidated) {
      if (isPending) {
        color = Colors.orangeAccent;
        trailing = Row(
          children: [
            const Text(
              "En attente de sync. ⏳",
              style: TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            Icon(Icons.hourglass_top_rounded, color: Colors.orangeAccent.withOpacity(0.8), size: 18),
          ],
        );
      } else {
        color = Colors.tealAccent;
        trailing = Row(
          children: [
            Text(
              "Validé ✓",
              style: TextStyle(color: Colors.tealAccent.shade100, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.check_circle_rounded, color: Colors.tealAccent, size: 18),
          ],
        );
      }
    } else {
      if (isEnabled) {
        color = Colors.cyanAccent;
        trailing = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: onValidate,
          child: const Text("Valider", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        );
      } else {
        color = Colors.white24;
        trailing = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white10,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: null,
          child: const Text("Verrouillé", style: TextStyle(color: Colors.white30, fontSize: 11)),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isValidated 
            ? (isPending ? Colors.orange.withOpacity(0.05) : Colors.tealAccent.withOpacity(0.05))
            : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValidated 
              ? (isPending ? Colors.orangeAccent.withOpacity(0.2) : Colors.tealAccent.withOpacity(0.2))
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: isValidated ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 72, color: Colors.white30),
            const SizedBox(height: 16),
            const Text(
              "Aucun trajet actif",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              "Dès qu'une réservation est validée, la feuille de route s'affiche ici pour vos validations Départ & Arrivée, y compris hors-ligne.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
