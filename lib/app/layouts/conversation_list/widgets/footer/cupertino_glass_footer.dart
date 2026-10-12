import 'dart:ui';

import 'package:bluebubbles/app/layouts/conversation_list/pages/conversation_list.dart';
import 'package:bluebubbles/app/layouts/conversation_list/pages/search/search_view.dart';
import 'package:get/get.dart';
import 'package:bluebubbles/services/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// iOS 26 Messages bottom bar: a Liquid Glass search capsule and a separate glass compose button,
/// replacing the FAB and the header search button on the iOS skin.
///
/// Metrics are taken from the iOS 26.2 simulator Messages list (iPhone 17 Pro Max):
/// 48pt tall controls, 20pt side inset, 12pt gap, fill #191919 in dark mode.
class CupertinoGlassFooter extends StatelessWidget {
  const CupertinoGlassFooter({super.key, required this.controller});

  final ConversationListController controller;

  static const double height = 48;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 20,
      right: 20,
      bottom: bottomInset + 12,
      child: Row(
        children: [
          Expanded(
            child: _GlassSurface(
              shape: const StadiumBorder(),
              onTap: () => NavigationSvc.pushLeft(context, const SearchView()),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.search, size: 21, color: _secondary(context)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Search",
                        style: context.theme.textTheme.bodyLarge!.copyWith(
                          fontSize: 17,
                          letterSpacing: -0.43,
                          color: _secondary(context),
                        ),
                      ),
                    ),
                    Icon(CupertinoIcons.mic_fill, size: 20, color: _secondary(context)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _GlassSurface(
            shape: const CircleBorder(),
            width: height,
            onTap: () => controller.openNewChatCreator(context),
            child: Icon(CupertinoIcons.square_pencil, size: 22, color: context.theme.colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  static Color _secondary(BuildContext context) =>
      ThemeSvc.inDarkMode(context) ? const Color(0xFF98989F) : const Color(0xFF6E6E73);
}

class _GlassSurface extends StatelessWidget {
  const _GlassSurface({required this.shape, required this.child, required this.onTap, this.width});

  final ShapeBorder shape;
  final Widget child;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final dark = ThemeSvc.inDarkMode(context);
    // Liquid Glass approximation: backdrop blur, a translucent fill and a hairline highlight edge.
    return ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Material(
          color: dark ? const Color(0xFF191919).withValues(alpha: 0.82) : Colors.white.withValues(alpha: 0.72),
          shape: shape is StadiumBorder
              ? StadiumBorder(side: _edge(dark))
              : CircleBorder(side: _edge(dark)),
          child: InkWell(
            onTap: onTap,
            customBorder: shape,
            child: SizedBox(width: width, height: CupertinoGlassFooter.height, child: Center(child: child)),
          ),
        ),
      ),
    );
  }

  static BorderSide _edge(bool dark) => BorderSide(
        color: dark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.06),
        width: 0.5,
      );
}
