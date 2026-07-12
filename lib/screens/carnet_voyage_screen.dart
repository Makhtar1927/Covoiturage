import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/state_providers.dart';
import '../widgets/glass_container.dart';
import '../widgets/network_banner.dart';
import '../widgets/user_avatar.dart';

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

    // Show all accepted bookings for demo — role is determined per-card by booking ID.
    final activeBookings = bookings.where((b) => b.status == 'accepted').toList();

    // Split into ongoing (not fully completed) and completed
    final ongoing = activeBookings.where((b) => !b.arrivalValidated).toList();
    final completed = activeBookings.where((b) => b.arrivalValidated).toList();

    // Stats
    final totalKm = activeBookings.length * 7; // mock average 7 km
    final totalSaved = activeBookings.fold<double>(0, (sum, b) => sum + b.ride.price);

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ─── Premium SliverAppBar ───────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primary.withValues(alpha: 0.85),
                          cs.tertiary.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // Blur overlay
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: Container(color: Colors.transparent),
                  ),
                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Carnet de Voyage',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Stats row
                          Row(
                            children: [
                              _StatChip(
                                icon: Icons.route_rounded,
                                label: '${activeBookings.length} trajet${activeBookings.length > 1 ? 's' : ''}',
                              ),
                              const SizedBox(width: 8),
                              _StatChip(
                                icon: Icons.explore_outlined,
                                label: '$totalKm km',
                              ),
                              const SizedBox(width: 8),
                              _StatChip(
                                icon: Icons.payments_outlined,
                                label: '${totalSaved.toStringAsFixed(0)} FCFA',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Network Banner ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: const NetworkBanner(),
            ),
          ),

          // ─── Empty state ────────────────────────────────────────────────
          if (activeBookings.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(textColor, subtitleColor),
            )
          else ...[
            // ─── Ongoing section ───────────────────────────────────────
            if (ongoing.isNotEmpty) ...[
              _SectionHeader(
                label: 'En cours',
                count: ongoing.length,
                color: cs.primary,
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _BookingCard(
                      booking: ongoing[i],
                      userId: user?.id ?? '',
                      syncQueue: syncQueue,
                      ref: ref,
                      cs: cs,
                      isDark: isDark,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      dividerColor: dividerColor,
                    ),
                  ),
                  childCount: ongoing.length,
                ),
              ),
            ],

            // ─── Completed section ─────────────────────────────────────
            if (completed.isNotEmpty) ...[
              _SectionHeader(
                label: 'Trajets terminés',
                count: completed.length,
                color: Colors.teal,
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _BookingCard(
                      booking: completed[i],
                      userId: user?.id ?? '',
                      syncQueue: syncQueue,
                      ref: ref,
                      cs: cs,
                      isDark: isDark,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      dividerColor: dividerColor,
                    ),
                  ),
                  childCount: completed.length,
                ),
              ),
            ],

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color subtitleColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: subtitleColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_travel_rounded,
                size: 48,
                color: subtitleColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun trajet actif',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 10),
            Text(
              'Vos trajets confirmés apparaîtront ici. Vous pourrez valider vos départs et arrivées — même sans connexion internet !',
              textAlign: TextAlign.center,
              style: TextStyle(color: subtitleColor, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SectionHeader({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                '$count',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Chip ───────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Booking Card ─────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final String userId;
  final List<SyncAction> syncQueue;
  final WidgetRef ref;
  final ColorScheme cs;
  final bool isDark;
  final Color textColor;
  final Color subtitleColor;
  final Color dividerColor;

  const _BookingCard({
    required this.booking,
    required this.userId,
    required this.syncQueue,
    required this.ref,
    required this.cs,
    required this.isDark,
    required this.textColor,
    required this.subtitleColor,
    required this.dividerColor,
  });

  bool _isPending(String bookingId, String actionType) =>
      syncQueue.any((a) => a.bookingId == bookingId && a.actionType == actionType);

  @override
  Widget build(BuildContext context) {
    final ride = booking.ride;
    // Use pre-partitioned mock role OR real user match
    const driverBookingIds = {'b1', 'b4', 'b6', 'b9'};
    final isDriver = driverBookingIds.contains(booking.id) || ride.driver.id == userId;
    final roleColor = isDriver ? cs.primary : const Color(0xFF00897B);
    final contactUser = isDriver ? booking.passenger : ride.driver;
    final contactLabel = isDriver ? 'Passager' : 'Conducteur';

    final isFullyDone = booking.departureValidated && booking.arrivalValidated;
    final depPending = _isPending(booking.id, 'VALIDATE_DEPARTURE');
    final arrPending = _isPending(booking.id, 'VALIDATE_ARRIVAL');

    return GlassContainer(
      opacity: 0.07,
      borderColor: isFullyDone ? Colors.teal : roleColor,
      useWhiteBlend: !isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _RoleBadge(label: isDriver ? 'Conducteur' : 'Passager', color: roleColor),
                  const SizedBox(width: 8),
                  if (isFullyDone)
                    _RoleBadge(label: '✓ Terminé', color: Colors.teal),
                ],
              ),
              // Offline badge
              if (booking.offlineActionTimestamp != null)
                Row(
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 12, color: Colors.orange.shade700),
                    const SizedBox(width: 4),
                    Text('Hors-ligne',
                        style: TextStyle(color: Colors.orange.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                )
              else
                Row(
                  children: [
                    const Icon(Icons.cloud_done_rounded, color: Colors.green, size: 13),
                    const SizedBox(width: 4),
                    Text('Sauvegardé',
                        style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),

          Divider(color: dividerColor, height: 20),

          // ── Route visual ────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline dots & line
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: roleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: ride.intermediateStops.isEmpty ? 28 : 14.0 + ride.intermediateStops.length * 18,
                    color: roleColor.withValues(alpha: 0.3),
                  ),
                  if (ride.intermediateStops.isNotEmpty)
                    ...ride.intermediateStops.map((stop) => Column(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                border: Border.all(color: roleColor, width: 1.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 14,
                              color: roleColor.withValues(alpha: 0.3),
                            ),
                          ],
                        )),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              // Stop labels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ride.startPoint,
                        style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13)),
                    if (ride.intermediateStops.isNotEmpty)
                      ...ride.intermediateStops.map((stop) => Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('↳ $stop',
                                style: TextStyle(color: subtitleColor, fontSize: 11, fontStyle: FontStyle.italic)),
                          )),
                    const SizedBox(height: 4),
                    Text(ride.endPoint,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Date, price, seats row ───────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _InfoChip(
                icon: Icons.schedule_rounded,
                label: DateFormat('dd MMM · HH:mm', 'fr_FR').format(ride.dateTime),
                color: subtitleColor,
              ),
              _InfoChip(
                icon: Icons.payments_outlined,
                label: '${ride.price.toStringAsFixed(0)} FCFA',
                color: subtitleColor,
              ),
              _InfoChip(
                icon: Icons.people_outline_rounded,
                label: '${ride.totalSeats - ride.availableSeats}/${ride.totalSeats} places',
                color: subtitleColor,
              ),
            ],
          ),

          Divider(color: dividerColor, height: 20),

          // ── Contact person ──────────────────────────────────────────────
          Row(
            children: [
              UserAvatar(
                name: contactUser.name,
                avatarUrl: contactUser.avatar,
                radius: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$contactLabel : ${contactUser.name}',
                      style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        if (contactUser.isVerified)
                          Row(
                            children: [
                              Icon(Icons.verified_rounded, size: 11, color: cs.primary),
                              const SizedBox(width: 3),
                            ],
                          ),
                        Text(contactUser.circle ?? '',
                            style: TextStyle(color: subtitleColor, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              // Star rating
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    contactUser.rating.toStringAsFixed(1),
                    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),

          Divider(color: dividerColor, height: 20),

          // ── Checkpoint validators ───────────────────────────────────────
          Text(
            'Validation de la course',
            style: TextStyle(color: subtitleColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),

          _CheckpointRow(
            title: '1. Départ du covoiturage',
            isValidated: booking.departureValidated,
            isPending: depPending,
            isEnabled: true,
            onValidate: () => ref.read(bookingProvider.notifier).validateDeparture(booking.id),
            cs: cs,
            textColor: textColor,
            subtitleColor: subtitleColor,
            dividerColor: dividerColor,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _CheckpointRow(
            title: '2. Arrivée à destination',
            isValidated: booking.arrivalValidated,
            isPending: arrPending,
            isEnabled: booking.departureValidated,
            onValidate: () => ref.read(bookingProvider.notifier).validateArrival(booking.id),
            cs: cs,
            textColor: textColor,
            subtitleColor: subtitleColor,
            dividerColor: dividerColor,
            isDark: isDark,
          ),

          // ── Offline warning ─────────────────────────────────────────────
          if (booking.offlineActionTimestamp != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
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
                      'Mémorisé localement. La validation sera synchronisée dès qu\'une connexion sera disponible.',
                      style: TextStyle(color: Colors.orange, fontSize: 10, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Info Chip ───────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}

// ─── Role Badge ──────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _RoleBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ─── Checkpoint Row ──────────────────────────────────────────────────────────

class _CheckpointRow extends StatelessWidget {
  final String title;
  final bool isValidated;
  final bool isPending;
  final bool isEnabled;
  final VoidCallback onValidate;
  final ColorScheme cs;
  final Color textColor;
  final Color subtitleColor;
  final Color dividerColor;
  final bool isDark;

  const _CheckpointRow({
    required this.title,
    required this.isValidated,
    required this.isPending,
    required this.isEnabled,
    required this.onValidate,
    required this.cs,
    required this.textColor,
    required this.subtitleColor,
    required this.dividerColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    Widget trailing;

    if (isValidated) {
      if (isPending) {
        color = Colors.orange;
        trailing = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sync. ⏳',
                style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Icon(Icons.hourglass_top_rounded, color: Colors.orange.withValues(alpha: 0.8), size: 16),
          ],
        );
      } else {
        color = Colors.teal;
        trailing = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Validé ✓',
                style: TextStyle(color: Colors.teal.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            const Icon(Icons.check_circle_rounded, color: Colors.teal, size: 16),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          onPressed: onValidate,
          child: const Text('Valider', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        );
      } else {
        color = isDark ? Colors.white24 : Colors.black26;
        trailing = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.onSurface.withValues(alpha: 0.08),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          onPressed: null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded, size: 11, color: subtitleColor.withValues(alpha: 0.5)),
              const SizedBox(width: 4),
              Text('Verrouillé',
                  style: TextStyle(color: subtitleColor.withValues(alpha: 0.5), fontSize: 11)),
            ],
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isValidated
            ? (isPending ? Colors.orange.withValues(alpha: 0.05) : Colors.teal.withValues(alpha: 0.05))
            : cs.onSurface.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
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
                fontSize: 12,
                fontWeight: isValidated ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}
