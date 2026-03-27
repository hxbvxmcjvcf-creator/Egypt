// lib/features/auth/presentation/widgets/trust_indicator_widget.dart

import 'package:flutter/material.dart';
import 'package:edu_auth_31/features/auth/data/models/verification_models.dart';

// =============================================================================
// TrustIndicatorWidget — "The Cube" Trust Meter
// =============================================================================

/// Displays a visual trust meter based on [trustScore] (0.0 – 1.0).
///
/// Score thresholds:
///   > 0.8  → 🟢  Verified
///   0.5–0.8 → 🟡  Partial
///   < 0.5  → 🔴  Unverified
class TrustIndicatorWidget extends StatelessWidget {
  const TrustIndicatorWidget({
    super.key,
    required this.trustScore,
    required this.schoolName,
    this.showLabel = true,
    this.compact = false,
  });

  final double trustScore;
  final String schoolName;
  final bool showLabel;
  final bool compact;

  // ── helpers ────────────────────────────────────────────────────────────────

  _TrustLevel get _level {
    if (trustScore > 0.8) return _TrustLevel.verified;
    if (trustScore >= 0.5) return _TrustLevel.partial;
    return _TrustLevel.unverified;
  }

  Color _resolveColor(BuildContext context) {
    switch (_level) {
      case _TrustLevel.verified:
        return const Color(0xFF4CAF50); // green
      case _TrustLevel.partial:
        return const Color(0xFFFFC107); // amber
      case _TrustLevel.unverified:
        return const Color(0xFFF44336); // red
    }
  }

  String _resolveEmoji() {
    switch (_level) {
      case _TrustLevel.verified:
        return '🟢';
      case _TrustLevel.partial:
        return '🟡';
      case _TrustLevel.unverified:
        return '🔴';
    }
  }

  String _resolveLabel() {
    switch (_level) {
      case _TrustLevel.verified:
        return 'موثّقة';
      case _TrustLevel.partial:
        return 'توثيق جزئي';
      case _TrustLevel.unverified:
        return 'غير موثّقة';
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return compact ? _buildCompact(context) : _buildFull(context);
  }

  Widget _buildCompact(BuildContext context) {
    final color = _resolveColor(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(_resolveEmoji(), style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          _resolveLabel(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFull(BuildContext context) {
    final color = _resolveColor(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.35), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Header row ──────────────────────────────────────────────────
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.school_rounded, color: color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      schoolName.isEmpty ? 'المدرسة' : schoolName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        Text(
                          _resolveEmoji(),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _resolveLabel(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Score badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(trustScore * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Progress bar ────────────────────────────────────────────────
          if (showLabel) ...<Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'مستوى الثقة',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  trustScore.toStringAsFixed(2),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],

          // Segmented progress bar
          _TrustProgressBar(trustScore: trustScore, color: color),
        ],
      ),
    );
  }
}

// =============================================================================
// _TrustProgressBar — internal segmented bar
// =============================================================================

class _TrustProgressBar extends StatelessWidget {
  const _TrustProgressBar({required this.trustScore, required this.color});

  final double trustScore;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: <Widget>[
          // Background track
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          // Filled portion
          FractionallySizedBox(
            widthFactor: trustScore.clamp(0.0, 1.0),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[color.withOpacity(0.6), color],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// _TrustLevel — private enum
// =============================================================================

enum _TrustLevel { verified, partial, unverified }

// =============================================================================
// TrustStatusBadge — small reusable badge (optional helper widget)
// =============================================================================

/// Lightweight badge version used inside list tiles or cards.
class TrustStatusBadge extends StatelessWidget {
  const TrustStatusBadge({super.key, required this.status});

  final TrustStatus status;

  @override
  Widget build(BuildContext context) {
    final (String label, Color color, IconData icon) = switch (status) {
      TrustStatus.verified => ('موثّق', const Color(0xFF4CAF50), Icons.verified_rounded),
      TrustStatus.partial => ('جزئي', const Color(0xFFFFC107), Icons.access_time_rounded),
      TrustStatus.unverified => ('غير موثّق', const Color(0xFFF44336), Icons.cancel_rounded),
      TrustStatus.pending => ('قيد المراجعة', const Color(0xFF90A4AE), Icons.hourglass_top_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
