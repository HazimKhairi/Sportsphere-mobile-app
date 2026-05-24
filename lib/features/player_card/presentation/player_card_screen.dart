import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../domain/player_card_data.dart';
import '_widgets/sphere_player_fifa_card.dart';
import 'player_card_providers.dart';
import '../../../l10n/app_localizations.dart';

// ─── CONSTANTS ────────────────────────────────────────────────────────────────

const _kDark = Color(0xFF0A0A0A);

// ─── SCREEN ───────────────────────────────────────────────────────────────────

class PlayerCardScreen extends ConsumerWidget {
  const PlayerCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerCardProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kDark,
        extendBodyBehindAppBar: true,
        body: state.when(
          loading: () => const _LoadingView(),
          error: (e, _) =>
              _ErrorView(onRetry: () => ref.invalidate(playerCardProvider)),
          data: (data) => _CardBody(
            card: data.card,
            summary: data.summary,
            onRefresh: () => ref.invalidate(playerCardProvider),
          ),
        ),
      ),
    );
  }
}

// ─── LOADING ──────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white54),
    );
  }
}

// ─── BODY ─────────────────────────────────────────────────────────────────────

class _CardBody extends StatefulWidget {
  const _CardBody({
    required this.card,
    required this.summary,
    required this.onRefresh,
  });
  final PlayerCardData card;
  final TrainingSummary? summary;
  final VoidCallback onRefresh;

  @override
  State<_CardBody> createState() => _CardBodyState();
}

class _CardBodyState extends State<_CardBody> {
  final _cardKey = GlobalKey();
  bool _downloading = false;

  Future<void> _downloadCard() async {
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      final hasAccess = await Gal.requestAccess();
      if (!hasAccess) {
        if (!mounted) return;
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.failedToSaveCard)));
        return;
      }
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      await Gal.putImageBytes(
        byteData.buffer.asUint8List(),
        name: 'sportsphere_card_${widget.card.playerName.replaceAll(' ', '_')}',
      );
      if (!mounted) return;
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.cardSavedToGallery,
              style: const TextStyle(fontFamily: 'Lexend')),
          backgroundColor: const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.failedToSaveCard)));
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, top + 56, 20, bottom + 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - top - 56 - bottom - 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RepaintBoundary(
                      key: _cardKey,
                      child: SphereFifaCard(card: widget.card),
                    ),
                    const SizedBox(height: 16),
                    _DownloadButton(loading: _downloading, onTap: _downloadCard),
                  ],
                ),
              ),
            );
          },
        ),

        // Back button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ─── DOWNLOAD BUTTON ──────────────────────────────────────────────────────────

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({required this.loading, required this.onTap});
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: loading ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white54),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.download,
                      size: 16, color: Color(0xFF0A0A0A)),
                  const SizedBox(width: 8),
                  Text(
                    l.saveCardToGallery,
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── ERROR ────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.idCard, size: 56, color: Colors.white24),
                const SizedBox(height: 16),
                const Text(
                  'Card not available',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your player card appears when a coach has rated your attributes at least once.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white38,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
