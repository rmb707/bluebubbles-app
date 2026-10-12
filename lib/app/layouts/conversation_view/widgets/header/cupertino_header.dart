import 'dart:async';
import 'dart:ui';

import 'package:bluebubbles/app/layouts/conversation_details/conversation_details.dart';
import 'package:bluebubbles/app/layouts/conversation_view/widgets/header/header_widgets.dart';
import 'package:bluebubbles/app/components/avatars/contact_avatar_group_widget.dart';
import 'package:bluebubbles/app/components/ios_glass.dart';
import 'package:bluebubbles/app/state/chat_state_scope.dart';
import 'package:bluebubbles/app/wrappers/theme_switcher.dart';
import 'package:bluebubbles/app/wrappers/stateful_boilerplate.dart';
import 'package:bluebubbles/helpers/helpers.dart';
import 'package:bluebubbles/database/models.dart';
import 'package:bluebubbles/services/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:universal_io/io.dart';

class CupertinoHeader extends StatelessWidget implements PreferredSizeWidget {
  const CupertinoHeader({super.key, required this.controller});

  final ConversationViewController controller;

  // simulate apple's saturatioon
  static const List<double> darkMatrix = <double>[
    1.385, -0.56, -0.112, 0.0, 0.3, //
    -0.315, 1.14, -0.112, 0.0, 0.3, //
    -0.315, -0.56, 1.588, 0.0, 0.3, //
    0.0, 0.0, 0.0, 1.0, 0.0
  ];

  static const List<double> lightMatrix = <double>[
    1.74, -0.4, -0.17, 0.0, 0.0, //
    -0.26, 1.6, -0.17, 0.0, 0.0, //
    -0.26, -0.4, 1.83, 0.0, 0.0, //
    0.0, 0.0, 0.0, 1.0, 0.0
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
          filter: ImageFilter.compose(
              outer: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              inner: ColorFilter.matrix(
                CupertinoTheme.maybeBrightnessOf(context) == Brightness.dark ? darkMatrix : lightMatrix,
              )),
          child: Stack(
            children: [
              Container(
                // iOS 26: no bar, just a scroll-edge fade behind floating glass controls
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    tileMode: TileMode.clamp,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.theme.colorScheme.surface.withValues(alpha: 0.92),
                      context.theme.colorScheme.surface.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 20.0,
                        right: 20,
                        top: (MediaQuery.of(context).viewPadding.top - 2).clamp(0, double.infinity)),
                    child: Stack(alignment: Alignment.center, children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: XGestureDetector(
                              supportTouch: true,
                              onTap: !kIsDesktop
                                  ? null
                                  : (details) {
                                      if (controller.inSelectMode.value) {
                                        controller.inSelectMode.value = false;
                                        controller.selected.clear();
                                        return;
                                      }
                                      if (LifecycleSvc.isBubble) {
                                        SystemNavigator.pop();
                                        return;
                                      }
                                      controller.close();
                                      if (Get.isSnackbarOpen) {
                                        Get.closeAllSnackbars();
                                      }
                                      Navigator.of(context).pop();
                                    },
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  if (kIsDesktop) return;
                                  if (controller.inSelectMode.value) {
                                    controller.inSelectMode.value = false;
                                    controller.selected.clear();
                                    return;
                                  }
                                  if (LifecycleSvc.isBubble) {
                                    SystemNavigator.pop();
                                    return;
                                  }
                                  controller.close();
                                  if (Get.isSnackbarOpen) {
                                    Get.closeAllSnackbars();
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: _UnreadIcon(controller: controller),
                                ),
                              ),
                            ),
                          )),
                      Align(
                        alignment: Alignment.center,
                        child: XGestureDetector(
                          supportTouch: true,
                          onTap: !kIsDesktop
                              ? null
                              : (details) {
                                  Navigator.of(context).push(
                                    ThemeSwitcher.buildPageRoute(
                                      builder: (context) => ConversationDetails(
                                        chat: controller.chat,
                                      ),
                                    ),
                                  );
                                },
                          child: InkWell(
                            onTap: () {
                              if (kIsDesktop) return;
                              Navigator.of(context).push(
                                ThemeSwitcher.buildPageRoute(
                                  builder: (context) => ConversationDetails(
                                    chat: controller.chat,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: _ChatIconAndTitle(parentController: controller),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Align(alignment: Alignment.topRight, child: ManualMark(controller: controller))),
                    ]),
                  ),
                ),
              ),
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: HeaderProgressIndicator(),
              ),
            ],
          )),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight((Get.context!.orientation == Orientation.landscape && Platform.isAndroid ? 55 : 106) *
          SettingsSvc.settings.avatarScale.value);
}

class _UnreadIcon extends StatefulWidget {
  const _UnreadIcon({required this.controller});

  final ConversationViewController controller;

  @override
  State<StatefulWidget> createState() => _UnreadIconState();
}

class _UnreadIconState extends State<_UnreadIcon> {
  late final StreamSubscription<Query<Chat>> sub;
  bool hasStream = false;

  @override
  void dispose() {
    if (!kIsWeb && hasStream) sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final icon = widget.controller.inSelectMode.value ? CupertinoIcons.xmark : CupertinoIcons.back;
      final count = widget.controller.inSelectMode.value ? widget.controller.selected.length : ChatsSvc.unreadCount.value;
      // iOS 26: 44pt glass circle; grows into a capsule with the unread count
      return IosGlass(
        circle: count == 0,
        width: count == 0 ? 44 : null,
        height: 44,
        padding: count == 0 ? EdgeInsets.zero : const EdgeInsets.only(left: 10, right: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              String.fromCharCode(icon.codePoint),
              style: TextStyle(
                fontFamily: icon.fontFamily,
                package: icon.fontPackage,
                fontSize: 26,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            if (count > 0)
              Text(
                count > 99 ? "99+" : count.toString(),
                style: context.textTheme.bodyLarge!
                    .copyWith(fontSize: 17, fontWeight: FontWeight.w600, color: context.theme.colorScheme.onSurface),
              ),
          ],
        ),
      );
    });
  }
}

class _ChatIconAndTitle extends CustomStateful<ConversationViewController> {
  const _ChatIconAndTitle({required super.parentController});

  @override
  State<StatefulWidget> createState() => _ChatIconAndTitleState();
}

class _ChatIconAndTitleState extends CustomState<_ChatIconAndTitle, void, ConversationViewController> {
  @override
  void initState() {
    super.initState();
    tag = controller.chat.guid;
    // keep controller in memory since the widget is part of a list
    // (it will be disposed when scrolled out of view)
    forceDelete = false;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Get chat state from scope - handles title logic including redacted mode
      final chatState = ChatStateScope.of(context);
      final _title = chatState.title.value ?? controller.chat.getTitle();

      final nameStyle = context.theme.textTheme.bodyLarge!
          .copyWith(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.43);
      final children = [
        const IgnorePointer(
          ignoring: true,
          child: ContactAvatarGroupWidget(
            size: 60,
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -8),
          child: IosGlass(
            height: 32,
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: NavigationSvc.width(context) / 2),
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    text: TextSpan(style: nameStyle, children: MessageHelper.buildEmojiText(_title, nameStyle)),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 13,
                  color: context.theme.colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        ),
      ];

      if (context.orientation == Orientation.landscape && Platform.isAndroid) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      }
    });
  }
}
