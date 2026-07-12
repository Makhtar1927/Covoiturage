import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final double radius;
  final BoxBorder? border;

  const UserAvatar({
    super.key,
    required this.name,
    required this.avatarUrl,
    this.radius = 20,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final hasRealImage = avatarUrl.isNotEmpty && 
        avatarUrl.startsWith('http') && 
        !avatarUrl.contains('dicebear.com');

    if (hasRealImage) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: border,
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: Image.network(
              avatarUrl,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: radius * 0.8,
                    height: radius * 0.8,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    final initials = name.isNotEmpty ? name.trim().split(' ').map((e) => e[0]).take(2).join('').toUpperCase() : '?';
    final colors = _getGradient(name);

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.85,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            shadows: const [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getGradient(String name) {
    if (name.isEmpty) return [const Color(0xFF2193b0), const Color(0xFF6dd5ed)];
    final int hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
    final List<List<Color>> gradients = [
      [const Color(0xFFFF5F6D), const Color(0xFFFFC371)], // Coral sunset
      [const Color(0xFF2193b0), const Color(0xFF6dd5ed)], // Sky blue
      [const Color(0xFFEE0979), const Color(0xFFFF6A00)], // Neon pink
      [const Color(0xFF11998e), const Color(0xFF38ef7d)], // Emerald
      [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)], // Purple royal
      [const Color(0xFFf953c6), const Color(0xFFb91d73)], // Plum
      [const Color(0xFF00c6ff), const Color(0xFF0072ff)], // Deep ocean
      [const Color(0xFFfe8c00), const Color(0xFFf83600)], // Bright orange
    ];
    return gradients[hash % gradients.length];
  }
}
