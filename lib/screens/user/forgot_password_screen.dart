import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/cupertino.dart';

import '../../widgets/animated_marble_background.dart';
import '../../extensions/extensions.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../utils/app_common.dart';
import '../../utils/app_constants.dart';
import '../../network/rest_api.dart';
import '../../main.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> formKey =
  GlobalKey<FormState>();

  final TextEditingController forgotEmailController =
  TextEditingController();

  final FocusNode emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    logScreenView("Forgot password screen");
  }

  @override
  void dispose() {
    forgotEmailController.dispose();
    emailFocus.dispose();
    super.dispose();
  }

  /// 🔒 ORIGINAL API – UNTOUCHED
  Future<void> submit() async {
    emailFocus.unfocus();

    if (!formKey.currentState!.validate()) return;

    Map req = {
      'email': forgotEmailController.text.trim(),
    };

    appStore.setLoading(true);

    await forgotPasswordApi(req).then((value) {
      if (value.status == false) {
        toast(value.message);
        appStore.setLoading(false);
        return;
      }

      toast(value.message.validate());
      appStore.setLoading(false);
      finish(context);
    }).catchError((e) {
      appStore.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedMarbleBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 45, sigmaY: 45),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 40),
                    decoration: BoxDecoration(
                      color:
                      Colors.white.withOpacity(0.30),
                      borderRadius:
                      BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white
                            .withOpacity(0.6),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink
                              .withOpacity(0.25),
                          blurRadius: 50,
                          offset:
                          const Offset(0, 25),
                        ),
                      ],
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [

                          /// 🔹 Back Button
                          Align(
                            alignment:
                            Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () =>
                                  Navigator.pop(
                                      context),
                              icon: Icon(
                                CupertinoIcons.back,
                                color: Colors
                                    .pink.shade700,
                              ),
                            ),
                          ),

                          const SizedBox(
                              height: 10),

                          Text(
                            language
                                .forgotPassword,
                            style: boldTextStyle(
                              size: 24,
                              color: Colors
                                  .pink.shade700,
                            ),
                          ),

                          const SizedBox(
                              height: 35),

                          /// ✉️ EMAIL INPUT
                          ClipRRect(
                            borderRadius:
                            BorderRadius
                                .circular(
                                26),
                            child: BackdropFilter(
                              filter:
                              ImageFilter.blur(
                                  sigmaX:
                                  25,
                                  sigmaY:
                                  25),
                              child: Container(
                                height: 58,
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                    horizontal:
                                    18),
                                decoration:
                                BoxDecoration(
                                  color: Colors
                                      .white
                                      .withOpacity(
                                      0.55),
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      26),
                                  border: Border.all(
                                    color: Colors
                                        .white
                                        .withOpacity(
                                        0.8),
                                  ),
                                ),
                                child:
                                TextFormField(
                                  controller:
                                  forgotEmailController,
                                  focusNode:
                                  emailFocus,
                                  keyboardType:
                                  TextInputType
                                      .emailAddress,
                                  style: TextStyle(
                                    color: Colors
                                        .pink
                                        .shade800,
                                  ),
                                  decoration:
                                  InputDecoration(
                                    hintText:
                                    language
                                        .email,
                                    hintStyle:
                                    TextStyle(
                                      color: Colors
                                          .pink
                                          .shade400,
                                    ),
                                    border:
                                    InputBorder
                                        .none,
                                  ),
                                  validator:
                                      (value) {
                                    if (value ==
                                        null ||
                                        value
                                            .isEmpty) {
                                      return language
                                          .emailIsRequired;
                                    }
                                    if (!value
                                        .contains(
                                        "@")) {
                                      return language
                                          .pleaseEnterAValidEmail;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                              height: 35),

                          /// 💗 SUBMIT BUTTON
                          GestureDetector(
                            onTap: submit,
                            child: Container(
                              height: 56,
                              width:
                              double.infinity,
                              decoration:
                              BoxDecoration(
                                gradient:
                                const LinearGradient(
                                  colors: [
                                    Color(
                                        0xFFFF5DA2),
                                    Color(
                                        0xFFFF2E8A),
                                  ],
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                    28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors
                                        .pink
                                        .withOpacity(
                                        0.5),
                                    blurRadius:
                                    30,
                                    offset:
                                    const Offset(
                                        0,
                                        15),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  language
                                      .submit,
                                  style:
                                  boldTextStyle(
                                    color: Colors
                                        .white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      /// 🔄 LOADER
      floatingActionButtonLocation:
      FloatingActionButtonLocation
          .centerFloat,
      floatingActionButton: Observer(
        builder: (_) =>
        appStore.isLoading
            ? Loader()
            : const SizedBox(),
      ),
    );
  }
}
