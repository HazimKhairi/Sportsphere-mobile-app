import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../l10n/app_localizations.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../home/presentation/_widgets/sphere_hero_gradient.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';

const _faqs = [
  (
    'How do I join a club?',
    'Your coach will send you an invite link or QR code. Open it in SportSphere and follow the prompts to join. You can also browse available programs and register directly.',
  ),
  (
    'How do I pay for a program?',
    'Go to Programs, select the program, and tap Register. You can pay by card (Stripe), FPX online banking, or cash. Cash payments require coach approval before they\'re confirmed.',
  ),
  (
    'Where can I see my invoices?',
    'Go to Profile → Payment history. Tap any transaction to view its receipt. For card and FPX payments, an "Open receipt" button links to the Stripe receipt.',
  ),
  (
    'Why does my body composition page show a permission error?',
    'Your coach needs to update the app\'s Firestore security rules to allow players to read and write their own data. Ask your club admin to redeploy the rules.',
  ),
  (
    'How do I earn points?',
    'Points are awarded for completing drills, attending sessions, and hitting milestones. Check Points & History in your profile for a full breakdown.',
  ),
  (
    'How do I redeem rewards?',
    'Go to Profile → Rewards. Browse your club\'s reward catalog and tap any item you can afford. Your voucher code will appear in the My Vouchers tab.',
  ),
  (
    'How do I update my profile photo?',
    'Tap your avatar on the Profile screen to pick a new photo from your gallery or take one with the camera.',
  ),
  (
    'I forgot my password. What do I do?',
    'On the login screen, tap "Forgot password?" and enter your email. You\'ll receive a reset link within a few minutes.',
  ),
  (
    'How do I switch between clubs?',
    'Go to Profile → Switch club to select a different club associated with your account.',
  ),
  (
    'Who do I contact for support?',
    'For app issues, email support@sportsphere.my. For club-specific questions, reach out to your coach or club admin.',
  ),
];

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

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
                        AppLocalizations.of(context)!.help,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: SphereSpacing.x8),
                  Text(
                    'Common questions and answers.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                  const SizedBox(height: SphereSpacing.x32),
                  const SphereSectionLabel('Frequently asked'),
                  const SizedBox(height: SphereSpacing.x12),
                  Container(
                    decoration: BoxDecoration(
                      color: context.sc.surfaceElev1,
                      borderRadius: SphereRadius.cardRect,
                      border: Border.all(color: context.sc.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < _faqs.length; i++) ...[
                          _FaqItem(
                            question: _faqs[i].$1,
                            answer: _faqs[i].$2,
                          ),
                          if (i < _faqs.length - 1)
                            Divider(
                                color: context.sc.borderSubtle, height: 1),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: SphereSpacing.x32),
                  Container(
                    padding: const EdgeInsets.all(SphereSpacing.x20),
                    decoration: BoxDecoration(
                      color: context.sc.surfaceElev1,
                      borderRadius: SphereRadius.cardRect,
                      border: Border.all(color: context.sc.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.sc.primary.withValues(alpha: 0.12),
                          ),
                          child: Icon(LucideIcons.mail,
                              color: context.sc.primary, size: 20),
                        ),
                        const SizedBox(width: SphereSpacing.x16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Still need help?',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: context.sc.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'support@sportsphere.my',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: context.sc.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FaqItem extends StatefulWidget {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: SphereRadius.cardRect,
      child: Padding(
        padding: const EdgeInsets.all(SphereSpacing.x16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.sc.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Icon(
                  _expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 16,
                  color: context.sc.onSurfaceMuted,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: SphereSpacing.x8),
              Text(
                widget.answer,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.sc.onSurfaceMuted,
                      height: 1.5,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
