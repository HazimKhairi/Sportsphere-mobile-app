import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../l10n/app_localizations.dart';

class StaffQrDisplayScreen extends StatelessWidget {
  const StaffQrDisplayScreen({
    super.key,
    required this.sessionId,
    required this.sessionName,
    required this.location,
    required this.clubId,
  });

  final String sessionId;
  final String sessionName;
  final String location;
  final String clubId;

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;

    return Scaffold(
      backgroundColor: sc.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SphereSpacing.x16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: SphereSpacing.x12),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: sc.onSurface,
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/schedule');
                      }
                    },
                  ),
                  const SizedBox(width: SphereSpacing.x8),
                  Text(
                    AppLocalizations.of(context)!.sessionQr,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: sc.onSurface),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(SphereSpacing.x24),
                        decoration: BoxDecoration(
                          color: sc.surfaceElev1,
                          borderRadius: SphereRadius.cardRect,
                          border: Border.all(color: sc.borderSubtle),
                        ),
                        child: Column(
                          children: [
                            Text(
                              sessionName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: sc.onSurface),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: SphereSpacing.x8),
                            Text(
                              location,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: sc.onSurfaceMuted),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: SphereSpacing.x24),
                            Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(SphereSpacing.x12),
                              child: QrImageView(
                                data: sessionId,
                                version: QrVersions.auto,
                                size: 220,
                                backgroundColor: Colors.white,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Colors.black,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: SphereSpacing.x16),
                      Text(
                        'Show this to players — they scan to check in',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: sc.onSurfaceMuted),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: SphereSpacing.x24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sc.primary,
                      foregroundColor: sc.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          vertical: SphereSpacing.x16),
                      shape: const RoundedRectangleBorder(
                          borderRadius: SphereRadius.pillRect),
                    ),
                    onPressed: () => context.push(
                      '/staff/session/$sessionId/attendance',
                      extra: {'clubId': clubId, 'name': sessionName},
                    ),
                    child: Text(AppLocalizations.of(context)!.takeAttendance),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
