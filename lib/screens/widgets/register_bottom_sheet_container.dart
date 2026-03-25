import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../extensions/app_button.dart';
import '../../extensions/app_text_field.dart';
import '../../extensions/constants.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../utils/dynamic_theme.dart';

class RegisterBottomSheetContainer extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController fnameController;
  final TextEditingController lnameController;
  final VoidCallback onTap;
  final GlobalKey<FormState> formKey;

  const RegisterBottomSheetContainer({
    required this.emailController,
    required this.passwordController,
    required this.fnameController,
    required this.lnameController,
    required this.onTap,
    required this.formKey,
    Key? key,
  }) : super(key: key);

  @override
  _RegisterBottomSheetContainerState createState() =>
      _RegisterBottomSheetContainerState();
}

class _RegisterBottomSheetContainerState
    extends State<RegisterBottomSheetContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Observer(
          builder: (context) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: widget.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(language.keepYourHealthDataSafe.capitalizeWords(),
                        style: boldTextStyle(
                            size: textFontSize_24, isHeader: true)),
                    8.height,
                    Text(language.createYourAccountToSaveInformation,
                        style: primaryTextStyle(size: textFontSize_14),
                        textAlign: TextAlign.center),
                    16.height,
                    AppTextField(
                      controller: widget.fnameController,
                      textFieldType: TextFieldType.NAME,
                      errorThisFieldRequired: language.pleaseEnterFirstName,
                      decoration: InputDecoration(
                          labelText: language.firstName,
                          border: OutlineInputBorder()),
                      autoFillHints: [AutofillHints.name],
                    ),
                    16.height,
                    AppTextField(
                      controller: widget.lnameController,
                      textFieldType: TextFieldType.NAME,
                      errorThisFieldRequired: language.pleaseEnterLastName,
                      decoration: InputDecoration(
                          labelText: language.lastName,
                          border: OutlineInputBorder()),
                      autoFillHints: [AutofillHints.name],
                    ),
                    16.height,
                    AppTextField(
                      controller: widget.emailController,
                      textFieldType: TextFieldType.EMAIL,
                      errorThisFieldRequired: language.pleaseEnterEmail,
                      errorInvalidEmail: language.pleaseEnterValidEmail,
                      decoration: InputDecoration(
                          labelText: language.email,
                          border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return language.pleaseEnterEmail;
                        }
                        if (value.contains("nomail")) {
                          return language.pleaseEnterValidEmail;
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return language.pleaseEnterValidEmail;
                        }
                        return null;
                      },
                      autoFillHints: [AutofillHints.email],
                    ),
                    16.height,
                    AppTextField(
                      controller: widget.passwordController,
                      textFieldType: TextFieldType.PASSWORD,
                      decoration: InputDecoration(
                          labelText: language.password,
                          border: OutlineInputBorder()),
                      autoFillHints: [AutofillHints.password],
                      errorThisFieldRequired: language.pleaseEnterPassword,
                      errorMinimumPasswordLength: language.minimumlength,
                      onFieldSubmitted: (s) {
                        //signIn();
                      },
                    ),
                    16.height,
                    AppButton(
                      disabledColor: ColorUtils.colorPrimary,
                      onTap: widget.onTap,
                      width: context.width(),
                      text: language.signUp,
                    ),
                    16.height,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
