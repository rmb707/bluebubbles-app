import 'package:bluebubbles/helpers/helpers.dart';
import 'package:bluebubbles/services/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A skin-aware toggle switch — renders [CupertinoSwitch] under the iOS skin
/// and Material [Switch] otherwise. Use this instead of either widget directly.
class BBSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  const BBSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (context.iOS) {
      // iOS switches are always systemGreen, whatever the accent color
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: ThemeSvc.inDarkMode(context) ? const Color(0xFF30D158) : const Color(0xFF34C759),
      );
    }

    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
    );
  }
}
