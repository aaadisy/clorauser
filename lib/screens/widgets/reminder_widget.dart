import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../extensions/app_text_field.dart';
import '../../extensions/constants.dart';
import '../../extensions/decorations.dart';
import '../../extensions/text_styles.dart';

class ReminderWidget extends StatefulWidget {
  final String titleText;
  final String descriptionText;
  final String? reminderName;
  final bool isReminderOn;
  final Function(bool) onSwitchChanged;
  final TextEditingController messageController;
  final VoidCallback onEditTimePressed;
  final VoidCallback onConfirmPressed;
  final String cancelButtonText;
  final String confirmButtonText;
  final Color primaryColor;
  final String? reminderType;
  final String? selectedDay;
  final DateTime? reminderDateTime;

  const ReminderWidget({
    Key? key,
    required this.titleText,
    required this.descriptionText,
    required this.isReminderOn,
    required this.onSwitchChanged,
    required this.messageController,
    required this.onEditTimePressed,
    required this.onConfirmPressed,
    required this.cancelButtonText,
    required this.confirmButtonText,
    required this.primaryColor,
    this.reminderName,
    this.reminderDateTime,
    this.selectedDay,
    this.reminderType,
  }) : super(key: key);

  @override
  State<ReminderWidget> createState() => _ReminderWidgetState();
}

class _ReminderWidgetState extends State<ReminderWidget> {
  @override
  Widget build(BuildContext context) {
    // Format the date and time dynamically if provided, otherwise use a default
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
    final String? formattedDateTime = widget.reminderDateTime != null
        ? dateFormat.format(widget.reminderDateTime!)
        : null; // Fallback if null

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.titleText,
                style: boldTextStyle(
                  color: Colors.black,
                  size: textFontSize_16,
                ),
              ),
              CupertinoSwitch(
                value: widget.isReminderOn,
                activeTrackColor: widget.primaryColor,
                onChanged: widget.onSwitchChanged,
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            widget.descriptionText,
            style: boldTextStyle(
              color: Colors.grey[600],
              size: textFontSize_14,
            ),
          ),
          if (widget.isReminderOn) ...[
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: boldTextStyle(
                  color: Colors.black,
                  size: textFontSize_14,
                ),
                children: [
                  TextSpan(
                    text: [
                      language.Your,
                      if (widget.reminderType != null)
                        ' ${widget.reminderType}',
                      if (widget.reminderName != null)
                        ' ${widget.reminderName}',
                      ' ${language.reminderIsSetAt} ',
                    ].join(),
                  ),
                  formattedDateTime != null
                      ? TextSpan(
                          text: formattedDateTime,
                          style: boldTextStyle(
                            color: widget.primaryColor,
                            weight: FontWeight.w600,
                            size: textFontSize_14,
                          ),
                        )
                      : TextSpan(
                          text: widget.selectedDay,
                          style: boldTextStyle(
                            color: widget.primaryColor,
                            weight: FontWeight.w600,
                            size: textFontSize_14,
                          ),
                        )
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: widget.messageController,
              textFieldType: TextFieldType.MULTILINE,
              textInputAction: TextInputAction.none,
              maxLines: 8,
              minLines: 2,
              decoration: defaultInputDecoration(
                context,
                label: language.enterYourMessageForReminder,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onEditTimePressed,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.cancelButtonText,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onConfirmPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.confirmButtonText,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).paddingSymmetric(horizontal: 16);
  }
}
