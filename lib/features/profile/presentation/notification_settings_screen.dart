import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../home/presentation/_widgets/sphere_hero_gradient.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _scheduleReminders = true;
  bool _paymentUpdates = true;
  bool _achievements = true;
  bool _loaded = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final status = await FirebaseMessaging.instance.getNotificationSettings();
    setState(() {
      _pushEnabled = prefs.getBool('notif_push') ?? true;
      _scheduleReminders = prefs.getBool('notif_schedule') ?? true;
      _paymentUpdates = prefs.getBool('notif_payments') ?? true;
      _achievements = prefs.getBool('notif_achievements') ?? true;
      _permissionDenied =
          status.authorizationStatus == AuthorizationStatus.denied;
      _loaded = true;
    });
  }

  Future<void> _toggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    if (key == 'notif_push' && value) {
      final result = await FirebaseMessaging.instance.requestPermission();
      if (result.authorizationStatus == AuthorizationStatus.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifications blocked. Enable in device settings.'),
            ),
          );
        }
        setState(() => _permissionDenied = true);
        await prefs.setBool('notif_push', false);
        setState(() => _pushEnabled = false);
        return;
      }
      setState(() => _permissionDenied = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: SphereHeroGradient()),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                SphereSpacing.x24,
                SphereSpacing.x16,
                SphereSpacing.x24,
                90,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Material(
                        color: context.sc.surfaceElev1,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () => context.canPop()
                              ? context.pop()
                              : context.go('/profile'),
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(LucideIcons.chevronLeft,
                                size: 20, color: context.sc.onSurface),
                          ),
                        ),
                      ),
                      const SizedBox(width: SphereSpacing.x12),
                      Text(
                        AppLocalizations.of(context)!.notifications,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: SphereSpacing.x8),
                  Text(
                    AppLocalizations.of(context)!.chooseWhatToNotify,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                  const SizedBox(height: SphereSpacing.x32),
                  if (_permissionDenied) ...[
                    Container(
                      padding: const EdgeInsets.all(SphereSpacing.x16),
                      decoration: BoxDecoration(
                        color: context.sc.warning.withValues(alpha: 0.12),
                        borderRadius: SphereRadius.cardRect,
                        border: Border.all(
                            color: context.sc.warning.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.alertTriangle,
                              size: 16, color: context.sc.warning),
                          const SizedBox(width: SphereSpacing.x12),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.notificationsBlocked,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: context.sc.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SphereSpacing.x24),
                  ],
                  if (!_loaded) ...[
                    Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(context.sc.primary),
                        ),
                      ),
                    ),
                  ] else ...[
                    SphereSectionLabel(AppLocalizations.of(context)!.general),
                    const SizedBox(height: SphereSpacing.x12),
                    _NotifCard(
                      children: [
                        _NotifRow(
                          icon: LucideIcons.bell,
                          label: AppLocalizations.of(context)!.pushNotifications,
                          subtitle: AppLocalizations.of(context)!.receiveAllNotifications,
                          value: _pushEnabled,
                          onChanged: (v) {
                            setState(() => _pushEnabled = v);
                            _toggle('notif_push', v);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: SphereSpacing.x24),
                    SphereSectionLabel(AppLocalizations.of(context)!.categories),
                    const SizedBox(height: SphereSpacing.x12),
                    _NotifCard(
                      children: [
                        _NotifRow(
                          icon: LucideIcons.calendar,
                          label: AppLocalizations.of(context)!.scheduleReminders,
                          subtitle: AppLocalizations.of(context)!.trainingSessionsAndEvents,
                          value: _scheduleReminders && _pushEnabled,
                          enabled: _pushEnabled,
                          onChanged: (v) {
                            setState(() => _scheduleReminders = v);
                            _toggle('notif_schedule', v);
                          },
                        ),
                        Divider(color: context.sc.borderSubtle, height: 1),
                        _NotifRow(
                          icon: LucideIcons.receipt,
                          label: AppLocalizations.of(context)!.paymentUpdates,
                          subtitle: 'Invoices, approvals, and confirmations',
                          value: _paymentUpdates && _pushEnabled,
                          enabled: _pushEnabled,
                          onChanged: (v) {
                            setState(() => _paymentUpdates = v);
                            _toggle('notif_payments', v);
                          },
                        ),
                        Divider(color: context.sc.borderSubtle, height: 1),
                        _NotifRow(
                          icon: LucideIcons.award,
                          label: AppLocalizations.of(context)!.achievements,
                          subtitle: AppLocalizations.of(context)!.badgesAndMilestones,
                          value: _achievements && _pushEnabled,
                          enabled: _pushEnabled,
                          onChanged: (v) {
                            setState(() => _achievements = v);
                            _toggle('notif_achievements', v);
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotifCard extends StatelessWidget {
  const _NotifCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Column(children: children),
    );
  }
}

class _NotifRow extends StatelessWidget {
  const _NotifRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SphereSpacing.x16,
        vertical: SphereSpacing.x12,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.sc.primary.withValues(alpha: 0.12),
            ),
            child: Icon(icon, size: 16, color: context.sc.primary),
          ),
          const SizedBox(width: SphereSpacing.x12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: enabled
                            ? context.sc.onSurface
                            : context.sc.onSurfaceMuted,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.sc.onSurfaceMuted,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: context.sc.primary,
            activeTrackColor: context.sc.primary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
