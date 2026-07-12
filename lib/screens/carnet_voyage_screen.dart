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

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final textColor = cs.onSurface;
    final subtitleColor = cs.onSurface.withValues(alpha: 0.6);
    final dividerColor = cs.onSurface.withValues(alpha: 0.12);

    // List bookings that have status 'accepted' where this user is passenger or driver
    final activeBookings = bookings.where((b) {
      final isPassenger = b.passenger.id == user?.id;
      final isDriver = b.ride.driver.id == user?.id;
      return b.status == 'accepted' && (isPassenger || isDriver);
    }).toList();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          "Carnet de Voyage",
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
            child: activeBookings.isEmpty
                ? _buildEmptyState(textColor, subtitleColor)
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
                          borderColor: isDriver ? cs.primary : Colors.teal,
                          useWhiteBlend: !isDark,
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
                                          ? cs.primary.withValues(alpha: 0.12) 
                                          : Colors.teal.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        color: isDriver 
                                            ? cs.primary.withValues(alpha: 0.3) 
                                            : Colors.teal.withValues(alpha: 0.3)
                                      ),
                                    ),
                                    child: Text(
                                      isDriver ? "Conducteur" : "Passager",
                                      style: TextStyle(
                                        color: isDriver ? cs.primary : Colors.teal,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.download_done_rounded, color: Colors.green, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Sauvegardé hors-ligne",
                                        style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Divider(color: dividerColor, height: 20),
                              
                              // Route
                              Text(
                                "${ride.startPoint} ➔ ${ride.endPoint}",
                                style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Date : ${DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(ride.dateTime)}",
                                style: TextStyle(color: subtitleColor, fontSize: 11),
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
                                  Expanded(
                                    child: Text(
                                      isDriver 
                                          ? "Passager : ${booking.passenger.name} (${booking.passenger.circle})" 
                                          : "Conducteur : ${ride.driver.name} (${ride.driver.circle})",
                                      style: TextStyle(color: subtitleColor, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              
                              Divider(color: dividerColor, height: 24),
                              
                              // Checkpoint validators (Départ / Arrivée)
                              Text(
                                "Validation de la course :",
                                style: TextStyle(color: subtitleColor, fontSize: 12, fontWeight: FontWeight.bold),
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
                                cs: cs,
                                textColor: textColor,
                                subtitleColor: subtitleColor,
                                dividerColor: dividerColor,
                                isDark: isDark,
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
                                cs: cs,
                                textColor: textColor,
                                subtitleColor: subtitleColor,
                                dividerColor: dividerColor,
                                isDark: isDark,
                              ),

                              // Offline Warning text if validated offline
                              if (booking.offlineActionTimestamp != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.hourglass_empty_rounded, color: Colors.orange, size: 14),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          "Mémorisé localement. La validation sera synchronisée dès qu'une connexion sera disponible.",
                                          style: TextStyle(color: Colors.orange, fontSize: 10),
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
    required ColorScheme cs,
    required Color textColor,
    required Color subtitleColor,
    required Color dividerColor,
    required bool isDark,
  }) {
    Color color = isDark ? Colors.white38 : Colors.black38;
    Widget trailing = const SizedBox();

    if (isValidated) {
      if (isPending) {
        color = Colors.orange;
        trailing = Row(
          children: [
            const Text(
              "En attente de sync. ⏳",
              style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            Icon(Icons.hourglass_top_rounded, color: Colors.orange.withValues(alpha: 0.8), size: 18),
          ],
        );
      } else {
        color = Colors.teal;
        trailing = Row(
          children: [
            Text(
              "Validé ✓",
              style: TextStyle(color: Colors.teal.shade800, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.check_circle_rounded, color: Colors.teal, size: 18),
          ],
        );
      }
    } else {
      if (isEnabled) {
        color = cs.primary;
        trailing = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          onPressed: onValidate,
          child: const Text("Valider", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        );
      } else {
        color = isDark ? Colors.white24 : Colors.black26;
        trailing = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.onSurface.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          onPressed: null,
          child: Text("Verrouillé", style: TextStyle(color: subtitleColor.withValues(alpha: 0.5), fontSize: 11)),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isValidated 
            ? (isPending ? Colors.orange.withValues(alpha: 0.05) : Colors.teal.withValues(alpha: 0.05))
            : cs.onSurface.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isValidated 
              ? (isPending ? Colors.orange.withValues(alpha: 0.2) : Colors.teal.withValues(alpha: 0.2))
              : dividerColor,
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

  Widget _buildEmptyState(Color textColor, Color subtitleColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 72, color: subtitleColor.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              "Aucun trajet actif",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              "Dès qu'une réservation est validée, la feuille de route s'affiche ici pour vos validations Départ & Arrivée, y compris hors-ligne.",
              textAlign: TextAlign.center,
              style: TextStyle(color: subtitleColor, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
