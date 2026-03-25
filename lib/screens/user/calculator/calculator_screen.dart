import 'package:clora_user/extensions/animated_list/animated_list_view.dart';
import 'package:clora_user/extensions/colors.dart';
import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/model/user/calculator_model.dart';
import 'package:clora_user/screens/user/calculator/period_calculator_screen.dart';
import 'package:clora_user/screens/user/calculator/pregnancy_due_date_calculator_screen.dart';
import 'package:clora_user/screens/user/calculator/pregnancy_test_calculator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../network/rest_api.dart';
import '../../../components/common/settings_components.dart';
import '../../../extensions/loader_widget.dart';
import '../../../extensions/new_colors.dart';
import '../../../extensions/text_styles.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import 'implantation_calculator_screen.dart';
import 'ovulation_calculator.dart';

class CalculatorScreen extends StatefulWidget {
  final bool isFromDoctor;

  const CalculatorScreen({super.key, required this.isFromDoctor});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  List<CalculatorItem> calculatorOptions = [];

  // Map of calculator IDs to corresponding screens (functions that return Widgets)
  final Map<int, Widget Function(CalculatorItem)> _calculatorScreens = {
    1: (data) => OvulationCalculatorScreen(calculatorData: data),
    2: (data) => PregnancyTestCalculator(calculatorData: data),
    3: (data) => PeriodCalculatorScreen(calculatorData: data),
    4: (data) => ImplantationCalculatorScreen(calculatorData: data),
    5: (data) => PregnancyDueDataCalculator(calculatorData: data),
  };

  @override
  void initState() {
    super.initState();
    fetchCalculatorOptions();
    logScreenView("Calculator screen");
  }

  /// Fetch calculator options from API
  Future<void> fetchCalculatorOptions() async {
    appStore.setLoading(true);
    try {
      final response = await fetchCalculatorToolsListApi();
      if (response.data!.isNotEmpty && response.data != null) {
        setState(() {
          calculatorOptions =
              response.data!.where((item) => item.status == 1).toList();
        });
      } else {}
    } catch (e) {
    } finally {
      appStore.setLoading(false);
    }
  }

  void _navigateToCalculator(CalculatorItem data) {
    if (_calculatorScreens.containsKey(data.id)) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => _calculatorScreens[data.id]!(data)),
      );
    } else {}
  }

  Widget mSettingOption(String mTitle, String mImg, Function onTapCall) {
    return SettingItemWidget(
      onTap: () {
        onTapCall.call();
      },
      title: mTitle,
      leading: cachedImage(mImg, height: 24, width: 24, color: primaryColor),
      // leading: Image.asset(mImg, height: 20, width: 20, color: primaryColor),
      trailing: Icon(Icons.arrow_forward_ios_sharp, color: grayColor, size: 18),
      paddingAfterLeading: 10,
      paddingBeforeTrailing: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: mainColorLight,
            pinned: true,
            leading: IconButton(
              icon: Icon(CupertinoIcons.back, color: mainColorText),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Text(
              language.calculatorTools,
              style: boldTextStyle(
                color: mainColorText,
                size: 18,
                weight: FontWeight.w500,
              ),
            ),
            expandedHeight: 0,
            elevation: 0,
            surfaceTintColor: mainColorLight,
            forceElevated: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Stack(
                  children: [
                    Container(
                      height: 40,
                      color: mainColorLight,
                    ),
                  ],
                ),
                Transform.translate(
                  offset: Offset(0, -30),
                  child: Container(
                    width: context.width(),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        20.height,
                        Observer(
                          builder: (context) {
                            if (appStore.isLoading) {
                              return SizedBox(
                                height: context.height() -
                                    kToolbarHeight -
                                    context.statusBarHeight -
                                    80,
                                child: Center(
                                  child: Loader(),
                                ),
                              );
                            } else if (calculatorOptions.isEmpty) {
                              return SizedBox(
                                height: context.height() -
                                    kToolbarHeight -
                                    context.statusBarHeight -
                                    80,
                                // Adjust for SliverAppBar, status bar, and header
                                child: Center(
                                  child: emptyWidget(),
                                ),
                              );
                            } else {
                              return AnimatedListView(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: calculatorOptions.length,
                                itemBuilder: (context, index) {
                                  final option = calculatorOptions[index];
                                  return Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(12)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            mSettingOption(
                                                option.name.toString(),
                                                option.calculatorThumbailImage
                                                    .toString(), () {
                                              _navigateToCalculator(option);
                                            }),
                                          ],
                                        ),
                                      ),
                                      10.height,
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
