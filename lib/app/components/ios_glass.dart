import 'dart:ui';

import 'package:bluebubbles/services/services.dart';
import 'package:flutter/material.dart';

/// iOS 26 Liquid Glass approximation shared by the iOS skin's floating controls
/// (chat list search/compose bar, conversation header buttons, title capsule).
///
/// Real Liquid Glass refracts its backdrop; this uses backdrop blur, a translucent fill sampled from
/// the iOS 26.2 simulator (#191919 in dark mode) and a hairline highlight edge.
class IosGlass extends StatelessWidget {
  const IosGlass({
    super.key,
    required this.child,
    this.onTap,
    this.circle = false,
    this.width,
    this.height,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Circle when true, capsule otherwise.
  final bool circle;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;

  static Color fill(BuildContext context) => ThemeSvc.inDarkMode(context)
      ? const Color(0xFF191919).withValues(alpha: 0.82)
      : Colors.white.withValues(alpha: 0.72);

  static BorderSide edge(BuildContext context) => BorderSide(
        color: ThemeSvc.inDarkMode(context) ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.06),
        width: 0.5,
      );

  @override
  Widget build(BuildContext context) {
    final OutlinedBorder shape = circle ? CircleBorder(side: edge(context)) : StadiumBorder(side: edge(context));
    return ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Material(
          color: fill(context),
          shape: shape,
          child: InkWell(
            onTap: onTap,
            customBorder: shape,
            child: Container(
              width: width,
              height: height,
              padding: padding,
              // Only center inside fixed-size glass; capsules without a width hug their content
              alignment: width != null ? Alignment.center : null,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
