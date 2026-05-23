import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../app/theme/sphere_radius.dart';
import '../../../../app/theme/sphere_spacing.dart';
import '../current_session_providers.dart';

class SessionLiveBanner extends ConsumerWidget {
  const SessionLiveBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(currentSessionProvider);

    return sessionAsync.when(
      data: (session) {
        if (session == null) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: SphereSpacing.x16),
          padding: const EdgeInsets.all(SphereSpacing.x16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF16A34A), Color(0xFF15803D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: SphereRadius.cardRect,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Session is Live',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${session.programName} · ${session.timeStart}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.push('/qr-scan/${session.sessionId}'),
                icon: const Icon(LucideIcons.scanLine, size: 16),
                label: const Text('Scan QR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF16A34A),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, s) => const SizedBox.shrink(),
    );
  }
}
