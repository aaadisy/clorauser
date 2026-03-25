import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/main.dart';
import 'package:flutter/material.dart';
import '../../../../extensions/colors.dart';
import '../../../../extensions/decorations.dart';
import '../../../../extensions/text_styles.dart';
import '../../../../utils/app_common.dart';
import '../../../components/user/settings/delete_app_data_dialog.dart';
import '../../../extensions/widgets.dart';

class DeleteAppData extends StatefulWidget {
  const DeleteAppData({super.key});

  @override
  State<DeleteAppData> createState() => _DeleteAppDataState();
}

class _DeleteAppDataState extends State<DeleteAppData> {
  @override
  void initState() {
    super.initState();
    logScreenView("Delete App Data screen");
  }

  bool deleteData = false;

  void _toggleDialog(bool value) {
    setState(() {
      deleteData = value;
    });
    if (value) {
      _showDialog(context);
    }
  }

  void _showDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteAppDataDialog();
      },
    ).then((_) {
      // Reset the switch value when the dialog is closed
      setState(() {
        deleteData = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          appBarWidget(language.deleteAppData, context1: context, elevation: 1),
      bottomNavigationBar: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
              border: Border.all(color: textSecondaryColor)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.deleteAppData, style: secondaryTextStyle()),
                  4.height,
                  // Text("Read more", style: secondaryTextStyle(color: primaryColor))
                ],
              ).expand()
            ],
          )),
      body: Column(
        children: [
          reminderCommon(
              "${language.deleteDataFromPhone}",
              "${language.deleteDataFromPhoneText}",
              Switch(value: deleteData, onChanged: _toggleDialog)),
        ],
      ),
    );
  }
}
