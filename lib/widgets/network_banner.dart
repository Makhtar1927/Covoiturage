import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/state_providers.dart';
import 'glass_container.dart';

class NetworkBanner extends ConsumerWidget {
  const NetworkBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(networkStatusProvider);
    final syncQueue = ref.watch(syncQueueProvider);

    return GlassContainer(
      borderRadius: 16.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      opacity: 0.1,
      fillColor: isOnline ? Colors.teal : Colors.deepOrange,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isOnline ? Colors.tealAccent : Colors.deepOrangeAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isOnline 
                          ? Colors.tealAccent.withOpacity(0.5) 
                          : Colors.deepOrangeAccent.withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isOnline ? "Réseau : En ligne" : "Réseau : Hors-ligne (Zone Blanche)",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontWeight: FontWeight.w600,
                  fontSize: 13.0,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (syncQueue.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${syncQueue.length} en attente",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ref.read(networkStatusProvider.notifier).toggle();
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        !isOnline
                            ? "Connexion réseau restaurée. Synchronisation en cours..."
                            : "Connexion réseau coupée. Mode hors-ligne activé.",
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                  isOnline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                label: Text(
                  isOnline ? "Couper" : "Rétablir",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
