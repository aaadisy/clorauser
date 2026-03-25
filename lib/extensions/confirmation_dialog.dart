import 'package:clora_user/main.dart';
import 'package:clora_user/utils/dynamic_theme.dart';
import 'package:flutter/material.dart';

import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../utils/app_images.dart';
import 'app_button.dart';
import 'colors.dart';
import 'common.dart';
import 'constants.dart';
import 'decorations.dart';
import 'loader_widget.dart';

/// Enum for Dialog Type
enum DialogType { CONFIRMATION, ACCEPT, DELETE, UPDATE, ADD, RETRY }

/// Enum for Dialog Animation
enum DialogAnimation {
  DEFAULT,
  ROTATE,
  SLIDE_TOP_BOTTOM,
  SLIDE_BOTTOM_TOP,
  SLIDE_LEFT_RIGHT,
  SLIDE_RIGHT_LEFT,
  SCALE
}

/// dialog primary color
Color getDialogPrimaryColor(
  BuildContext context,
  DialogType dialogType,
  Color? primaryColor,
) {
  if (primaryColor != null) return primaryColor;
  Color color;

  switch (dialogType) {
    case DialogType.DELETE:
      color = Colors.red;
      break;
    case DialogType.UPDATE:
      color = Colors.amber;
      break;
    case DialogType.CONFIRMATION:
    case DialogType.ADD:
    case DialogType.RETRY:
      color = Colors.blue;
      break;
    case DialogType.ACCEPT:
      color = Colors.green;
      break;
  }
  return color;
}

/// build positive text for dialog
String getPositiveText(DialogType dialogType) {
  String positiveText = "";

  switch (dialogType) {
    case DialogType.CONFIRMATION:
      positiveText = "Yes";
      break;
    case DialogType.DELETE:
      positiveText = "Delete";
      break;
    case DialogType.UPDATE:
      positiveText = "Update";
      break;
    case DialogType.ADD:
      positiveText = "Add";
      break;
    case DialogType.ACCEPT:
      positiveText = "Accept";
      break;
    case DialogType.RETRY:
      positiveText = "Retry";
      break;
  }
  return positiveText;
}

/// Build title
String getTitle(DialogType dialogType) {
  String titleText = "";

  switch (dialogType) {
    case DialogType.CONFIRMATION:
      titleText = "Are you sure want to perform this action?";
      break;
    case DialogType.DELETE:
      titleText = "Do you want to delete?";
      break;
    case DialogType.UPDATE:
      titleText = "Do you want to update?";
      break;
    case DialogType.ADD:
      titleText = "Do you want to add?";
      break;
    case DialogType.ACCEPT:
      titleText = "Do you want to accept?";
      break;
    case DialogType.RETRY:
      titleText = "Click to retry";
      break;
  }
  return titleText;
}

/// get icon for dialog
Widget getIcon(DialogType dialogType, {double? size}) {
  Icon icon;

  switch (dialogType) {
    case DialogType.CONFIRMATION:
    case DialogType.RETRY:
    case DialogType.ACCEPT:
      icon = Icon(Icons.done, size: size ?? 20, color: Colors.white);
      break;
    case DialogType.DELETE:
      icon = Icon(Icons.delete_forever_outlined,
          size: size ?? 20, color: Colors.white);
      break;
    case DialogType.UPDATE:
      icon = Icon(Icons.edit, size: size ?? 20, color: Colors.white);
      break;
    case DialogType.ADD:
      icon = Icon(Icons.add, size: size ?? 20, color: Colors.white);
      break;
  }
  return icon;
}

/// Build center image for dialog
Widget? getCenteredImage(
  BuildContext context,
  DialogType dialogType,
  Color? primaryColor,
) {
  Widget? widget;

  switch (dialogType) {
    case DialogType.CONFIRMATION:
      widget = Container(
        decoration: BoxDecoration(
          color: getDialogPrimaryColor(context, dialogType, primaryColor)
              .withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.warning_amber_rounded,
          color: getDialogPrimaryColor(context, dialogType, primaryColor),
          size: 40,
        ),
        padding: EdgeInsets.all(16),
      );
      break;
    case DialogType.DELETE:
      widget = Container(
        decoration: BoxDecoration(
          color: getDialogPrimaryColor(context, dialogType, primaryColor)
              .withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close,
          color: getDialogPrimaryColor(context, dialogType, primaryColor),
          size: 40,
        ),
        padding: EdgeInsets.all(16),
      );
      break;
    case DialogType.UPDATE:
      widget = Container(
        decoration: BoxDecoration(
          color: getDialogPrimaryColor(context, dialogType, primaryColor)
              .withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.edit_outlined,
          color: getDialogPrimaryColor(context, dialogType, primaryColor),
          size: 40,
        ),
        padding: EdgeInsets.all(16),
      );
      break;
    case DialogType.ADD:
    case DialogType.ACCEPT:
      widget = Container(
        decoration: BoxDecoration(
          color: getDialogPrimaryColor(context, dialogType, primaryColor)
              .withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.done_outline,
          color: getDialogPrimaryColor(context, dialogType, primaryColor),
          size: 40,
        ),
        padding: EdgeInsets.all(16),
      );
      break;
    case DialogType.RETRY:
      widget = Container(
        decoration: BoxDecoration(
          color: getDialogPrimaryColor(
            context,
            dialogType,
            primaryColor,
          ).withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.refresh_rounded,
            color: getDialogPrimaryColor(
              context,
              dialogType,
              primaryColor,
            ),
            size: 40),
        padding: EdgeInsets.all(16),
      );
      break;
  }
  return widget;
}

/// placeholder for dialog
Widget defaultPlaceHolder(
  BuildContext context,
  DialogType dialogType,
  double? height,
  double? width,
  Color? primaryColor, {
  Widget? child,
  ShapeBorder? shape,
}) {
  return Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      color: getDialogPrimaryColor(context, dialogType, primaryColor)
          .withOpacity(0.2),
    ),
    alignment: Alignment.center,
    child: child ?? getCenteredImage(context, dialogType, primaryColor),
  );
}

/// title for dialog
Widget buildTitleWidget(
  BuildContext context,
  DialogType dialogType,
  Color? primaryColor,
  Widget? customCenterWidget,
  double height,
  double width,
  String? centerImage,
  ShapeBorder? shape,
) {
  if (customCenterWidget != null) {
    return Container(
      child: customCenterWidget,
      constraints: BoxConstraints(maxHeight: height, maxWidth: width),
    );
  } else {
    if (centerImage != null) {
      return Image.network(
        centerImage,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (_, object, stack) {
          log(object.toString());
          return defaultPlaceHolder(
            context,
            dialogType,
            height,
            width,
            primaryColor,
            shape: shape,
          );
        },
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return defaultPlaceHolder(
            context,
            dialogType,
            height,
            width,
            primaryColor,
            shape: shape,
            child: Loader(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      return defaultPlaceHolder(
        context,
        dialogType,
        height,
        width,
        primaryColor,
        shape: shape,
      );
    }
  }
}

/// show confirm dialog box
Future<bool?> showConfirmDialogCustom(
  BuildContext context, {
  required Function(BuildContext) onAccept,
  Widget? actions,
  Widget? imageShow,
  String? title,
  String? subTitle,
  String? positiveText,
  String? negativeText,
  String? centerImage,
  Widget? customCenterWidget,
  Color? primaryColor = primaryColor,
  Color? positiveBg,
  Color? negativeBg,
  Color? positiveTextColor,
  Color? negativeTextColor,
  Color? iconColor,
  Color? bgColor,
  ShapeBorder? shape,
  String? image,
  Function(BuildContext)? onCancel,
  bool barrierDismissible = true,
  double? height,
  double? width,
  bool cancelable = true,
  Color? barrierColor,
  DialogType dialogType = DialogType.CONFIRMATION,
  DialogAnimation dialogAnimation = DialogAnimation.DEFAULT,
  Duration? transitionDuration,
  Curve curve = Curves.easeInBack,
}) async {
  hideKeyboard(context);

  return await showGeneralDialog(
    context: context,
    barrierColor: barrierColor ?? Colors.black54,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Container();
    },
    barrierDismissible: barrierDismissible,
    barrierLabel: '',
    transitionDuration: transitionDuration ?? 400.milliseconds,
    transitionBuilder: (_, animation, secondaryAnimation, child) {
      return dialogAnimatedWrapperWidget(
        animation: animation,
        dialogAnimation: dialogAnimation,
        curve: curve,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: shape ?? dialogShape(),
          titlePadding: EdgeInsets.zero,
          //backgroundColor: _.cardColor,
          elevation: defaultElevation.toDouble(),

          content: Container(
            width: 330,
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                imageShow ??
                    Container(
                      padding: EdgeInsets.all(18),
                      decoration: boxDecorationWithRoundedCorners(
                          borderRadius: radius(150),
                          border: Border.all(color: primaryColor!),
                          backgroundColor: bgColor ?? primaryLightColor),
                      child: Image.asset(
                          image.isEmptyOrNull ? ic_app_logo : image!,
                          color: iconColor ?? primaryColor,
                          height: 28,
                          width: 28),
                    ).center(),
                14.height,
                Text(
                  title ?? getTitle(dialogType),
                  style: boldTextStyle(size: 16),
                  textAlign: TextAlign.center,
                ),
                8.height.visible(subTitle.validate().isNotEmpty),
                Text(
                  subTitle.validate(),
                  style: secondaryTextStyle(size: 14),
                  textAlign: TextAlign.start,
                ).visible(subTitle.validate().isNotEmpty),
                20.height,
                actions ??
                    Row(
                      children: [
                        AppButton(
                          height: 30,
                          elevation: 0,
                          shapeBorder: RoundedRectangleBorder(
                              borderRadius: radius(defaultAppButtonRadius),
                              side: BorderSide(color: primaryColor!, width: 1)),
                          color: negativeBg ?? context.cardColor,
                          child: Text(negativeText ?? language.cancel,
                                  style: boldTextStyle(
                                      color: negativeTextColor ?? primaryColor))
                              .fit(),
                          onTap: () {
                            if (cancelable) finish(_, false);
                            onCancel?.call(_);
                          },
                        ).expand(),
                        16.width,
                        AppButton(
                          disabledColor: ColorUtils.colorPrimary,
                          height: 30,
                          elevation: 0,
                          color: getDialogPrimaryColor(
                              _, dialogType, positiveBg ?? primaryColor),
                          child: Text(
                                  positiveText ?? getPositiveText(dialogType),
                                  style: boldTextStyle(
                                      color: positiveTextColor ?? Colors.white))
                              .fit(),
                          onTap: () {
                            onAccept.call(_);
                            if (cancelable) finish(_, true);
                          },
                        ).expand(),
                      ],
                    ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
