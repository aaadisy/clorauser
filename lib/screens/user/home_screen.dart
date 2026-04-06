import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crisp_chat/crisp_chat.dart';
import 'package:clora_user/ai/ai_dashboard.dart';
import 'package:clora_user/extensions/extension_util/string_extensions.dart';
import 'package:clora_user/main.dart';
import 'package:clora_user/model/model.dart';
import 'package:clora_user/screens/screens.dart';
import 'package:clora_user/screens/user/pregnancy_detail_screen.dart';
import 'package:clora_user/utils/dynamic_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';
import 'package:menstrual_cycle_widget/ui/model/symptoms_count.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:terminate_restart/terminate_restart.dart';
import 'package:http/http.dart' as http;
import '../../model/video_category_model.dart';
import '../../widgets/video_home_widget.dart';
import '../../widgets/video_section_widget.dart';
import '../../components/user/story_page_component.dart';
import '../../extensions/animated_list/animated_list_view.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extensions.dart';
import '../../extensions/new_colors.dart';
import '../../languageConfiguration/LanguageDataConstant.dart';
import '../../model/doctor/doctor_models/health_expert_model.dart';
import '../../model/user/chatgpt_insight_model.dart';
import '../../model/user/dashboard_response.dart';
import '../../model/user/menstrual_cycle_summary_model.dart' as ms;
import '../../model/user/user_location_model.dart';
import '../../model/user/user_models/pregnancy_detail_model.dart';
import '../../network/chatgpt_network_request.dart';
import '../../network/rest_api.dart';
import '../../service/reminder_service.dart';
import '../../utils/utils.dart';
import '../../widgets/animated_marble_background.dart';
import '../../widgets/home_action_grid.dart';
import '../common/ask_question_widget.dart';
import '../common/expandable_text.dart';
import '../onboarding/fu_style_question_screen.dart';
import '../widgets/article_recommendation_widget.dart';
import '../widgets/common_button.dart';
import '../widgets/cycle_summary_widget.dart';
import '../widgets/disclaimer_widget.dart';
import '../widgets/goal_specific_view.dart';
import '../widgets/insight_display_container_widget.dart';
import 'menstrual_report_screen.dart';

const double kPinkHeight = 450.0;
const double kCurveHeight = 15.0;
const double kCircleHeight = 300.0;
const double kCircleTopMargin = 30.0;
const double kInsightWidth = 126;
const double kInsightHeight = 176;
bool _showAllItems = false;
const int _maxVisibleItems = 3;
const BoxFit insightBoxFit = BoxFit.fill;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }

  Widget buildGlassCard({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.10),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.25),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

}

class _HomeScreenState extends State<HomeScreen> {

  List<VideoCategoryModel> videoCategories = [];
  bool isVideoLoading = true;
  final String _assistantId = "asst_7oxnV6JsbZ2rSsgNgEfQ1un2";

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  Widget _buildUserProfileHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), // 🔥 glass blur
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),

                /// 🔥 GLASS LOOK
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                /// 🔥 subtle border for depth
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),

                /// optional soft shadow (3D feel)
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),

              child: Row(
                children: [
                  /// PROFILE IMAGE
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFFDE2F3),
                    backgroundImage: userStore.user?.profileImage != null &&
                        userStore.user!.profileImage!.isNotEmpty
                        ? CachedNetworkImageProvider(
                        userStore.user!.profileImage!)
                        : null,
                    child: userStore.user?.profileImage == null ||
                        userStore.user!.profileImage!.isEmpty
                        ? Icon(Icons.person, color: Color(0xFFEC4899))
                        : null,
                  ),

                  12.width,

                  /// TEXT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                    "Hello, ${
                    ((userStore.user?.firstName?.isNotEmpty ?? false) ||
                        (userStore.user?.lastName?.isNotEmpty ?? false))
                      ? "${userStore.user?.firstName ?? ''} ${userStore.user?.lastName ?? ''}".trim()
                      : (userStore.user?.displayName?.isNotEmpty ?? false)
                      ? userStore.user!.displayName!
                      : 'User'
              }",
                          style: boldTextStyle(
                            size: 16,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          _getGreeting(),
                          style: secondaryTextStyle(
                            size: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// NOTIFICATION ICON
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    child: Icon(
                      Icons.notifications_none,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassGoalSwitcher() {
    final isCycle = userStore.goalIndex == 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final segmentWidth = (width - 16) / 2;

        return ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), // 🔥 magnified blur
            child: Container(
              height: 60, // slightly bigger
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white.withOpacity(0.25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.35),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [

                  /// SLIDING ACTIVE BACKGROUND
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: isCycle ? 0 : segmentWidth,
                    top: 0,
                    bottom: 0,
                    width: segmentWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFDA4AF),
                            Color(0xFFF472B6),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// CENTER ICON
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    alignment:
                    isCycle ? Alignment.centerLeft : Alignment.centerRight,
                    curve: Curves.easeInOut,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.95),
                      ),
                      child: Icon(
                        isCycle
                            ? Icons.water_drop_rounded // 🔥 blood drop
                            : Icons.pregnant_woman_rounded,
                        size: 16,
                        color: const Color(0xFFF472B6),
                      ),
                    ),
                  ),

                  /// TEXT ROW
                  Row(
                    children: [

                      /// TRACK CYCLE
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => _handleGoalSwitch(0),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: boldTextStyle(
                                size: 14,
                                color:
                                isCycle ? Colors.white : Colors.black87,
                              ),
                              child: Text(language.trackCycle),
                            ),
                          ),
                        ),
                      ),

                      /// TRACK PREGNANCY
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => _handleGoalSwitch(1),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: boldTextStyle(
                                size: 14,
                                color:
                                !isCycle ? Colors.white : Colors.black87,
                              ),
                              child: Text(language.trackPregnancy),
                            ),
                          ),
                        ),
                      ),
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



  void _handleGoalSwitch(int newIndex) async {
    if (newIndex == userStore.goalIndex) return;

    /// 🚫 Track Pregnancy Coming Soon
    if (newIndex == 1) {
      showComingSoonDialog(context);
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(language.confirmation),
        content: Text(language.areYouSureYouWantToSwitchYourGoalType),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(language.no),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
            ),
            onPressed: () async {
              Navigator.pop(context);

              await setValue(GOAL, newIndex);
              userStore.setGoal(newIndex);

              setState(() {});
              init(isDayClick: false);
            },
            child: Text(language.yes),
          ),
        ],
      ),
    );
  }

  void showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFF1F5),
                  Color(0xFFFDE2F3),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pregnant_woman,
                    size: 40, color: Color(0xFFEC4899)),

                SizedBox(height: 12),

                Text(
                  "Coming Soon",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB83280),
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "Track Pregnancy feature is coming soon 💖",
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEC4899),
                    shape: StadiumBorder(),
                  ),
                  child: Text("Got it"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Objects
  ChatGptInsight? chatgptInsights;

  // Lists
  List<Insights> mInsights = [];
  List<SymptomsCount> predictedSymptoms = [];
  List<SymptomsCount> predictedTomorrowSymptoms = [];
  List<Article> mArticles = [];
  List<String> urls = [];
  List<CycleDateDay> cycleDays = [];
  List<PersonalisedInsight> personalizedInsight = [];
  List<PregnancyData> pregnancyData = [];
  List<CombinedItem> combinedList = [];
  List<SymptomsCount> predictionTodaySymptomsText = [];
  List<PregnancyData> mPregnancyData = [];
  List<InsightPregnancyWeek> mInsightPregnancyWeek = [];
  List<AskExpertList> mAskQuestionsData = [];
  List<DailyInsights> dailyInsights = [];
  UniqueKey _key = UniqueKey();

  // Ints
  int? weekNumber = 1;
  int? cycleDay = 0;
  int? expectedDateDifference = 0;
  int currentTrimester = 1;

  // Strings
  String? currentPhase;
  String? cycleDayImage;
  String? pregnancyImageUrl;
  String? expectedDueDate;
  String? crispChatIcon;
  String? encryptedDataString;
  String encData = "";

  // Booleans
  bool hasCycleTrend = false;
  bool hasCyclePeriod = false;
  bool hasCycleHistory = false;
  bool hasEstrogenProgesterone = false;
  bool isDayClick = false;
  bool? isCrispChatEnabled = false;
  bool? isChatgptEnabled = false;
  bool isRemovePaidPlan = false;

  ms.MenstrualCycleSummaryData? summaryData = null;

  late CrispConfig configData;

  Map locationDetails = {};

  DateTime? lastPeriodDateToUpdate;

  @override
  void initState() {
    logScreenView("Home screen");
   // checkIfAppIsUpdate(context);
    getMenstrualCycleData();
    // configureCrispChat();
    init(isDayClick: false);
    reaction(
          (_) => appStore.isHomeScreenUpdated,
          (updated) async {
        if (updated == true && mounted) {
          init(isDayClick: false);
          isDayClick = false;
          appStore.setHomeScreenUpdated(false);
        }
      },
    );
    super.initState();
    fetchVideos(); // 👈 ADD THIS
  }

  init({required bool isDayClick}) async {
    if (mounted) {
      // logScreenView("Dashboard");
      Future.wait([
        getList(), /* updateUserStatus()*/
      ]);
      setState(() {});
    }
  }

  Future<void> debugStorageData() async {
    print("🧠 ================= STORAGE DEBUG START =================");

    final isLogin = await getBoolAsync(IS_LOGIN);
    final token = await getStringAsync(TOKEN);
    final profileCompleted = await getStringAsync("PROFILE_COMPLETED");
    final userId = await getStringAsync("USER_ID");

    print("🔐 IS_LOGIN: $isLogin");
    print("🔑 TOKEN: $token");
    print("👤 USER_ID: $userId");
    print("📊 PROFILE_COMPLETED: $profileCompleted");

    /// Extra useful keys
    print("🎯 GOAL: ${getIntAsync(GOAL)}");
    print("📅 CURRENT_USER_CYCLE_DAY: ${getIntAsync(CURRENT_USER_CYCLE_DAY)}");
    print("🤰 CURRENT_USER_PREGNANCY_WEEK: ${getIntAsync(CURRENT_USER_PREGNANCY_WEEK)}");

    print("🧠 ================= STORAGE DEBUG END =================");
  }

  Future<void> fetchVideos() async {
    try {
      var data = await getVideoCategories(); // 👈 REST API use

      setState(() {
        videoCategories = data;
        isVideoLoading = false;
      });

    } catch (e) {
      print("VIDEO ERROR 👉 $e");

      setState(() {
        isVideoLoading = false;
      });
    }
  }

  Future<void> getMenstrualCycleData() async {
    final String? lastPeriodDate = await instance.getPreviousPeriodDay();
    try {
      // Get results from cycle widget
      if (getIntAsync(GOAL) == 0) {
        final results = await Future.wait([
          instance.getMenstrualCycleSummary(),
          instance.getSymptomsPattern(),
          instance.hasCycleTrendsGraphData(),
          instance.hasPeriodGraphData(),
          instance.hasCycleHistoryGraphData(),
          instance.getSymptomsPattern(isForTomorrow: true)
        ]);

        // Process results
        summaryData = ms.MenstrualCycleSummaryData.fromJson(
            results[0] as Map<String, dynamic>);
        predictedSymptoms = results[1] as List<SymptomsCount>;
        hasCycleTrend = results[2] as bool;
        hasCyclePeriod = results[3] as bool;
        hasCycleHistory = results[4] as bool;
        hasEstrogenProgesterone =
        lastPeriodDate != null && lastPeriodDate != "" ? true : false;
        predictedTomorrowSymptoms = results[5] as List<SymptomsCount>;
      }

      // Calculate symptoms algorithm based on accuracy
      if (getIntAsync(GOAL) == 0) {
        fetchSymptomsPatternForToday();
      }

      setState(() {});
    } catch (e) {}
  }

  getCurrentTrimesterName() async {
    int currentTrimester = await instance.getCurrentTrimester();
    if (currentTrimester == 1) {
      return "1st Trimester";
    } else if (currentTrimester == 2) {
      return "2nd Trimester";
    } else if (currentTrimester == 3) {
      return "3rd Trimester";
    } else {
      return "";
    }
  }

  updateConfiguration() async {
    final String? prevPeriodDay = instance.getPreviousPeriodDay();
    final DateTime? prevPeriodDt = prevPeriodDay != null && prevPeriodDay != ""
        ? DateTime.parse(prevPeriodDay)
        : null;
    lastPeriodDateToUpdate = (prevPeriodDt == null ||
        prevPeriodDt.isAtSameMomentAs(DateTime(1971, 1, 1)))
        ? null
        : prevPeriodDt;
    int cycleLength = getIntAsync(CYCLE_LENGTH);
    int periodLength = getIntAsync(PERIOD_LENGTH);

    if (cycleLength == 0) {
      cycleLength = DEFAULT_CYCLE_LENGTH;
      setValue(CYCLE_LENGTH, cycleLength);
    }

    if (periodLength == 0) {
      periodLength = DEFAULT_PERIOD_LENGTH;
      setValue(PERIOD_LENGTH, periodLength);
    }

    instance.updateConfiguration(
      cycleLength: cycleLength,
      periodDuration: periodLength,
      customerId: userStore.userId.toString(),
      lastPeriodDate: lastPeriodDateToUpdate,
    );

    updateMenstrualWidgetLanguage();
  }

  Future<int> daysUntilDueDate() async {
    expectedDueDate = await instance.getExpectedDueDate();

    DateTime dueDate = DateFormat("dd-MM-yyyy").parse(expectedDueDate!);
    DateTime now = DateTime.now();

    return dueDate.difference(now).inDays;
  }

  Future<String?> performDataBackup() async {
    // Check if backup is enabled
    final isBackupEnabled =
    getBoolAsync(IS_BACKUP_ENABLED, defaultValue: false);
    if (!isBackupEnabled) {
      return null;
    }

    // Get current time and last backup time
    final now = DateTime.now();
    DateTime? lastBackupTime;
    try {
      final lastBackupString = getStringAsync(
        LAST_DATA_SYNC_DATETIME,
        defaultValue: '',
      );
      lastBackupTime =
      lastBackupString.isNotEmpty ? DateTime.parse(lastBackupString) : null;
    } catch (e) {
      lastBackupTime = null;
    }

    // Calculate time difference
    final difference = lastBackupTime != null
        ? now.difference(lastBackupTime)
        : const Duration(hours: 13);
    // Force backup if no previous backup

    // Perform backup if 12+ hours have passed or no previous backup
    if (difference.inHours >= 12) {
      try {
        final result = await instance.getBackupOfMenstrualCycleData();

        // Validate and extract encrypted data
        final encryptedData = result['encryptedData'] as String?;
        if (encryptedData == null || encryptedData.isEmpty) {
          return null;
        }

        // Update last backup time
        await setValue(LAST_DATA_SYNC_DATETIME, now.toIso8601String());

        return encryptedData;
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<void> checkAndShowBackupPopup(BuildContext context, dateString) async {
    bool isBackupPopupShown = getBoolAsync(IS_BACKUP_POP_DISPLAYED);
    String? lastSyncDate = getStringAsync(LAST_DATA_SYNC_DATETIME);
    String? lastSyncDateFromDb = dateString;

    if (isBackupPopupShown) {
      return;
    }

    // Convert strings to DateTime for safe comparison
    DateTime? lastSyncDateTime =
    lastSyncDate.isNotEmpty ? DateTime.tryParse(lastSyncDate) : null;
    DateTime? lastSyncDateTimeFromDb =
    lastSyncDateFromDb != null && lastSyncDateFromDb.isNotEmpty
        ? DateTime.tryParse(lastSyncDateFromDb)
        : null;

    if (lastSyncDateTime != lastSyncDateTimeFromDb &&
        lastSyncDateTimeFromDb != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          bool isRestoring = false;

          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text(
                  language.backupFound,
                  style: boldTextStyle(
                    size: textFontSize_18,
                    weight: FontWeight.w600,
                    color: mainColorText,
                  ),
                ),
                content: Text(
                  language.backupFoundDescription,
                  style: secondaryTextStyle(
                    size: textFontSize_14,
                    color: Colors.grey[600],
                  ),
                ),
                titleTextStyle: primaryTextStyle(),
                actions: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: isRestoring
                        ? SizedBox(
                      width: context.width(),
                      child: ElevatedButton(
                        key: const ValueKey('restoring'),
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )
                        : Row(
                      key: const ValueKey('buttons'),
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            await setValue(IS_BACKUP_POP_DISPLAYED, true);
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            language.noIDont,
                            style: boldTextStyle(
                              size: textFontSize_16,
                              weight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              isRestoring = true; // Trigger animation
                            });
                            await Future.delayed(
                                Duration(milliseconds: 1000));
                            final result = await restoreBackupApi();

                            result.fold(
                                  (error) => toast(language.backupNotFound),
                                  (success) async {
                                Map<String, dynamic> data = {
                                  "encryptedData":
                                  success.data!.encryptedUserData
                                };

                                final result = await instance
                                    .restoreBackupOfMenstrualCycleData(
                                  backupData: data,
                                  customerId:
                                  userStore.user!.id!.toString(),
                                );

                                if (result == false) {
                                  setValue(LAST_DATA_SYNC_DATETIME,
                                      lastSyncDateFromDb);
                                  setValue(IS_BACKUP_POP_DISPLAYED, true);
                                  appStore.setLoading(false);
                                  toast(language.backupRestoredSuccess);
                                  await TerminateRestart.instance
                                      .restartApp(
                                    options:
                                    const TerminateRestartOptions(
                                      terminate: true,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            language.yesRestore,
                            style: boldTextStyle(
                              size: textFontSize_16,
                              weight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  Future<UserLocationModel?> getUserLocation() async {
    instance.getMenstrualCycleReportData();
    try {
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));
      if (response.statusCode == 200) {
        return UserLocationModel.fromJson(jsonDecode(response.body));
      } else {
        printEraAppLogs('Failed to fetch location: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      printEraAppLogs('Error fetching location: $e');
      return null;
    }
  }

  Future<void> getList() async {
    try {
      appStore.setLoading(true);
      combinedList.clear();

      encryptedDataString = await performDataBackup();

      int currentUserCycleDay = getIntAsync(CURRENT_USER_CYCLE_DAY);
      int currentUserPregnancyWeek = getIntAsync(CURRENT_USER_PREGNANCY_WEEK);

      List<int> symptomsIds = await instance.getSymptomsId(DateTime.now());
      encData = Encryption.instance.encrypt(symptomsIds.toString());
      if (!isDayClick) {
        cycleDay = await instance.getCurrentCycleDay();
      }

      if (getIntAsync(GOAL) == 1) {
        weekNumber = await instance.getCurrentPregnancyWeek();
      }
      currentPhase = (getIntAsync(GOAL) == 0)
          ? await instance.getCurrentPhaseName()
          : await getCurrentTrimesterName();

      if (getBoolAsync(IS_USER_LOCATION_UPDATED) == false) {
        UserLocationModel? location = await getUserLocation();
        // log("Location Model => ${location?.toJson()}");
        if (location != null) {
          locationDetails = {
            "city": location.city,
            "region": location.region,
            "country_name": location.countryName,
            "country_code": location.countryCode,
          };

          setValue(IS_USER_LOCATION_UPDATED, true);
        }
      }

      int currentTrimester = await instance.getCurrentTrimester();
      expectedDateDifference =
      (getIntAsync(GOAL) == 1) ? await daysUntilDueDate() : 0;
      final value = await getDashboardListApi({
        "encData": encData,
        "week": weekNumber,
        "cycle_day": cycleDay,
        "remove_paid_plan": isRemovePaidPlan,
        "trimester": currentTrimester,
        "app_version": getStringAsync(APP_VERSION),
        "app_source": getStringAsync(APP_SOURCE),
        "last_actived_at": DateTime.now().toLocal().toString(),
        if (getStringAsync(PLAYER_ID).isNotEmpty) "player_id": getStringAsync(PLAYER_ID),
        "encrypted_user_data": encryptedDataString,
        if (locationDetails.isNotEmpty) ...locationDetails,
      });

      // SetState
      mInsights = value.insights ?? [];
      mPregnancyData = value.pregnancyDate ?? [];
      mArticles = value.articles ?? [];
      if (cycleDay!.toInt() <= 40) {
        cycleDays = value.cycleDateDays ?? [];
      }
      personalizedInsight = value.personalizedInsight ?? [];
      cycleDayImage = value.cycleDayImage;
      pregnancyData = value.pregnancyDate ?? [];
      mInsightPregnancyWeek = value.insightPregnancyWeek ?? [];
      pregnancyImageUrl = value.pregnancyImage;
      mAskQuestionsData = value.askExpertList ?? [];
      dailyInsights = value.dailyInsights ?? [];
      isChatgptEnabled = value.isChatgptEnabled;
      userStore.setUserModelData(value.user!);
      saveUserToLocalStorage(value.user!);
      isCrispChatEnabled = value.isCrispChatEnabled;
      crispChatIcon = value.crispChatIcon;
      chatgptKey = value.chatgptKey;
      appStore.setFacebookAdsConfiguration(value.adsConfiguration!);
      appStore.setSubscriptionStatus(value.subscriprtionAccess ?? false);
      appStore.setAskExpertStatus(value.futureaskexpert ?? false);
      appStore.setDummyDataStatusStatus(value.futuredummydata ?? false);
      appStore.setShowAdsBasedOnConfig(value.showAdsBasedOnConfig!);
      bool enabled = value.user?.isBackup == "off" ? false : true;
      setValue(IS_BACKUP_ENABLED, enabled);

      // 🔥 DIRECT REDIRECT (NO DELAY, NO UI BUILD)
      if (value.user?.profileCompleted == "0") {
        log("🚨 DIRECT Onboarding Redirect");

        AiOnboardingScreen().launch(context, isNewTask: true);

        return; // ❗ VERY IMPORTANT (stop dashboard execution)
      }

      /// Config crispChat
      if (value.crispChatWebsiteId != null &&
          value.crispChatWebsiteId!.isNotEmpty) {
        User user = User(
            email: userStore.user!.email,
            nickName: "${userStore.user!.displayName}",
            avatar: userStore.user?.profileImage ?? "");
        configData = CrispConfig(
          user: user,
          tokenId: userStore.user!.id!.toString(),
          enableNotifications: true,
          websiteID: value.crispChatWebsiteId!,
        );

        configureCrispChat();
      }

      try {
        final user = userStore.user!;
        final shouldFetchChatGPT =
            (user.goalType == 0 && currentUserCycleDay != cycleDay) ||
                (user.goalType == 1 && weekNumber != currentUserPregnancyWeek);

        print("Should call ChatGPT: $shouldFetchChatGPT");

        if (!shouldFetchChatGPT) {
          final prefs = await SharedPreferences.getInstance();
          final cacheKey = user.goalType == 0
              ? 'chatgpt_cycle_$currentUserCycleDay'
              : 'chatgpt_pregnancy_$currentUserPregnancyWeek';

          final cachedResponse = prefs.getString(cacheKey);

          if (cachedResponse != null) {
            chatgptInsights =  ChatGptInsight.parseCachedResponse(cachedResponse);
          }
        }

        if (shouldFetchChatGPT &&
            value.chatgptKey != null &&
            chatgptKey != null &&
            value.isChatgptEnabled == true) {

          print("Calling ChatGPT API");
          final langCode = getLanguageName(getStringAsync(SELECTED_LANGUAGE_CODE));

          if (user.goalType == 0) {
            if (cycleDay != null && cycleDay != 0 && cycleDay! <= 40) {
              final cycleLength = instance.getCycleLength();
              final periodLength = instance.getPeriodDuration();
              chatgptInsights = await ChatGptService.getCycleDayInfo(
                  cycleDay!.toInt(),
                  cycleLength,
                  periodLength,
                  langCode
              );
            }
          } else if (user.goalType == 1 && weekNumber != null) {
            chatgptInsights = await ChatGptService.getPregnancyWeekInfo(
                weekNumber!,
                langCode
            );
          }


          if (chatgptInsights != null) {
            final prefs = await SharedPreferences.getInstance();
            final cacheKey = user.goalType == 0
                ? 'chatgpt_cycle_$cycleDay'
                : 'chatgpt_pregnancy_$weekNumber';

            await prefs.setString(
                cacheKey,
                jsonEncode(chatgptInsights!.toJson())
            );
          }
        }
      } catch (e, s) {
        printEraAppLogs("ChatGPT API Error: $e\nStack Trace: $s");
      }

      combinedList = [
        ...mInsights.map((e) => CombinedItem(item: e, isInsight: true)),
        ...cycleDays.map((e) => CombinedItem(item: e, isInsight: false)),
        ...personalizedInsight
            .map((e) => CombinedItem(item: e, isInsight: false)),
        ...mInsightPregnancyWeek
            .map((e) => CombinedItem(item: e, isInsight: false)),
        if (chatgptInsights != null)
          CombinedItem(item: chatgptInsights!, isInsight: true),
      ];

      appStore.setLoading(false);
      isDayClick = false;
      updateConfiguration();
      getMenstrualCycleData();
      setValue(CURRENT_USER_CYCLE_DAY, cycleDay);
      if(userStore.user!.goalType == 1) {
        setValue(CURRENT_USER_PREGNANCY_WEEK, weekNumber);
      }
      if (mounted) {
        setState(() {
          _key = UniqueKey();
        });

        checkAndShowBackupPopup(context, value.user?.lastSyncDate);
      }
    } catch (e) {
      log("CatchError(${e}");
      appStore.setLoading(false);
      isDayClick = false;
      if (mounted) {
        setState(() {
          _key = UniqueKey();
        });
      }
    }
  }

  configureCrispChat() async {
    FlutterCrispChat.setSessionString(
      key: userStore.user!.id!.toString(),
      value: userStore.user!.id!.toString(),
    );

    /// Checking session ID After 5 sec
    await Future.delayed(const Duration(seconds: 5), () async {
      if (kDebugMode) {}
    });
  }

  fetchSymptomsPatternForToday() {
    try {
      predictionTodaySymptomsText.clear();
      for (int i = 0; i < predictedSymptoms.length; i++) {
        try {
          double accuracy = predictedSymptoms[i].accuracy ?? 0;
          if (accuracy >= 30) {
            predictionTodaySymptomsText.add(predictedSymptoms[i]);
          }
        } catch (e) {}
      }
    } catch (e) {}
  }

  bool areAllDataEmpty() {
    return personalizedInsight.isEmpty &&
        pregnancyData.isEmpty &&
        combinedList.isEmpty &&
        pregnancyImageUrl == null &&
        mAskQuestionsData.isEmpty &&
        hasCycleHistory == false &&
        hasCyclePeriod == false &&
        hasCycleTrend == false &&
        dailyInsights.isEmpty;
  }

  bool onlyCombinedListHasData() {
    return combinedList.isNotEmpty &&
        personalizedInsight.isEmpty &&
        pregnancyData.isEmpty &&
        pregnancyImageUrl == null &&
        mAskQuestionsData.isEmpty &&
        hasCycleHistory == false &&
        hasCyclePeriod == false &&
        hasCycleTrend == false &&
        dailyInsights.isEmpty;
  }

  Widget _buildNoDataView() {
    return IntrinsicHeight(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.transparent, // 🔥 IMPORTANT
            borderRadius: BorderRadius.circular(defaultRadius),
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                ic_woman_with_flower,
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
              16.height,
              Text(
                language.noSataAvailableToGenerateYourGraph,
                textAlign: TextAlign.center,
                style: boldTextStyle(
                  weight: FontWeight.w500,
                  size: textFontSize_16,
                ),
              ),
              16.height,
              CustomListTile(
                icon: Icons.check,
                normalText1: language.pleaseLogYourData,
                boldText: "",
                normalText2: language.toGenerateDetailedGraphs,
              ),
              16.height,
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: ColorUtils.colorPrimary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      language.logPreviousCycle,
                      style: boldTextStyle(
                        color: Colors.white,
                        isHeader: true,
                      ),
                    ),
                  ],
                ),
              ).center().onTap(() {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MenstrualCycleMonthlyCalenderView(
                      themeColor: Colors.black,
                      isShowCloseIcon: true,
                      onDataChanged: (value) {
                        if (value) {
                          DashboardScreen(currentIndex: 0)
                              .launch(context, isNewTask: true);
                        }
                      },
                    ),
                  ),
                );
                // PushReplacement Dashboard();
              }),
            ],
          ),
        ),
      ),
    ).center();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ));
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cycleDaysList = combinedList
        .where((item) => item.item is CycleDateDay)
        .map((item) => item.item as CycleDateDay)
        .toList();

    return Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: AnimatedMarbleBackground(
          child: CustomScrollView(
            slivers: [

              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                automaticallyImplyLeading: false,
                elevation: 0,
                expandedHeight: 180,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top + 10),
                      _buildUserProfileHeader(),
                      _buildGlassGoalSwitcher(),
                    ],
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildListDelegate([
                  Column(
                    children: [

                      /// 🌸 HERO SECTION (FLO STYLE)
                      Container(
                        constraints: BoxConstraints(
                          minHeight: kPinkHeight - 40,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent, // 🔥 IMPORTANT
                        ),
                        child: Center(

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              /// 🔥 FLO CIRCLE
                              Container(
                                padding: EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFFD6E0).withOpacity(0.4),
                                      Color(0xFFFBCFE8).withOpacity(0.4),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.pink.withOpacity(0.25),
                                      blurRadius: 30,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: GoalSpecificView(
                                    key: _key,
                                    goalIndex: userStore.goalIndex,
                                    isDayClick: isDayClick,
                                    cycleDay: cycleDay,
                                    pregnancyImageUrl: pregnancyImageUrl,
                                    onDaySelected: (selectedDay) => null,
                                    viewKey: _key,
                                  ),
                                ),
                              ),

                              SizedBox(height: 16),

                              /// 🔥 BUTTON
                              ElevatedButton(
                                onPressed: () {
                                  showAdBeforeNavigation(
                                    context: context,
                                    screen: MenstrualCycleMonthlyCalenderView(
                                      themeColor: Colors.black,
                                      isShowCloseIcon: true,
                                      onDataChanged: (value) {
                                        if (value) {
                                          logAnalyticsEvent(
                                              category: "period", action: "logged");
                                        }
                                      },
                                    ),
                                    postAction: () async {
                                      updateRemindersForDateChange();
                                      setState(() {
                                        _key = UniqueKey();
                                      });
                                      init(isDayClick: false);
                                    },
                                    showAd: (appStore.adsConfig?.adsconfigAccess ?? false) &&
                                        (appStore.showAdsBasedOnConfig?.editPeriodData ?? false),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFEC4899),
                                  shape: StadiumBorder(),
                                ),

                                child: Text(language.logPeriod),
                              ),

                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),

                      /// 🔥 ADDED ACTIONS GRID
                      const HomeActionGrid(),

                      _buildGlassVideoSection(),

                      // add some space
                      SizedBox(height: 16),


                      /// 🔽 CONTENT SECTION
                      appStore.isLoading
                          ? Center(child: Loader()).paddingSymmetric(vertical: 8)
                          :
                      Transform.translate(
                        offset: Offset(0, -10), // 👈 overlap fix
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), // 🔥 SAME AS SWITCHER
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25), // 🔥 GLASS
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.35),
                                  ),
                                ),
                          child: Column(
                            children: [

                              /// HANDLE BAR
                              Container(
                                width: 46,
                                height: 4,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),

                              /// 🔥 GRAPH SECTION (FLO STYLE)
                              _buildGraphPlaceholder(
                                headerTitle: language.cycleTrends,
                                isVisible: hasCycleTrend,
                                isGraphInSubscription: false,
                                graphWidget: MenstrualCycleTrendsGraph(
                                  isShowMoreOptions: false,
                                  isShowXAxisTitle: true,
                                  isShowHeader: false,
                                  isShowSeriesColor: true,
                                  onPdfDownloadCallback: () {},
                                  isShowYAxisTitle: true,
                                ),
                              ),

                              _buildGraphPlaceholder(
                                headerTitle: language.EstrogenProgesterone,
                                isGraphInSubscription: false,
                                isVisible: hasEstrogenProgesterone,
                                graphWidget: EstrogenProgesteroneGraph(),
                              ),

                              _buildGraphPlaceholder(
                                headerTitle: language.cyclePeriod,
                                isGraphInSubscription: false,
                                isVisible: hasCyclePeriod,
                                graphWidget: MenstrualCyclePeriodsGraph(),
                              ),

                              _buildGraphPlaceholder(
                                headerTitle: "",
                                isCycleHistory: true,
                                isGraphInSubscription: false,
                                isVisible: hasCycleHistory,
                                graphWidget: MenstrualCycleHistoryGraph(),
                              ),

                              SizedBox(height: 40),


                            ],
                          ),
                        ),
                      ),
                          ),
                      ),
                    ],
                  )
                ]),
              )
            ],
          ),
        )
    );
  }

  Widget _buildGlassVideoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withOpacity(0.25),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
              ),
            ),

            child: isVideoLoading
                ? const Center(child: CircularProgressIndicator())
                : VideoHomeWidget(categories: videoCategories),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionAnswerItem({
    required String title,
    required String description,
    required String askedOn,
    required String? expertAnswer,
    required String? ansOnDoctor,
    required String? userImage,
    required String? expertImage,
    required String? expertName,
    required List<dynamic>? images,
    required dynamic language,
    String? flow,
    Function()? onClick,
    bool isEducation = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: mainBgLightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Question Section
          Stack(
            children: [
              if (flow == "MyQuestions")
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: onClick,
                    child: Icon(Icons.delete, size: 20, color: Colors.red),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(userImage ?? ""),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  12.width,
                  // Question Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: boldTextStyle(
                            size: textFontSize_16,
                            weight: FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        4.height,
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 14, color: Colors.grey[600]),
                            4.width,
                            Expanded(
                              child: Text(
                                "${language.askedOn} ${convertUtcToLocal(askedOn)}",
                                style: primaryTextStyle(
                                    size: textFontSize_12,
                                    color: Colors.grey[700]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          12.height,
          // Question Content
          ExpandableText(text: description),
          10.height,
          // Images (if any)
          if (images != null && images.isNotEmpty)
            ScrollableNetworkImageRow(
              imageFiles: images,
              title: title,
            ),
          // Doctor Response Section
          if (expertName != null && expertAnswer != null) ...[
            16.height,
            Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            12.height,
            Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(expertImage ?? ""),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    12.width,
                    // Doctor Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            language.AnsweredBy,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              // Handle doctor profile navigation
                              HealthExpertData data = HealthExpertData(
                                healthExpertsImage: expertImage,
                                name: expertName,
                                // Add other fields as needed
                              );
                              //
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expertName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  convertUtcToLocal(ansOnDoctor ?? ''),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            12.height,
            // Doctor's Answer
            ExpandableText(text: expertAnswer),
          ],
        ],
      ),
    );
  }

  Widget _buildGraphPlaceholder({
    required bool isVisible,
    required Widget graphWidget,
    required String headerTitle,
    required bool isGraphInSubscription,
    bool? isCycleHistory = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          /// 🌸 FLO SOFT GRADIENT
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.transparent,
            ],
          ),

          /// ✨ REMOVED SHADOW
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🌸 HEADER
            if (isCycleHistory != true)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  headerTitle,
                  style: boldTextStyle(
                    size: 16,
                    weight: FontWeight.w600,
                    color: Color(0xFFB83280), // deep pink
                  ),
                ),
              ),

            /// GRAPH AREA
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),

              child: Container(
                height: isCycleHistory == true ? null : GRAPH_HEIGHT,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),

                  /// 🫧 INNER CONTAINER TRANSPARENT
                  color: Colors.transparent,
                ),

                child: graphWidget,
              ),
            ),
          ],
        ),
      ),
    ).visible(isVisible && userStore.goalIndex == 0);
  }


  bool validateYouTubeUrl(String? url) {
    if (url != null) {
      RegExp regExp = RegExp(
        r'^(https?://)?(www\.)?(youtube|youtu\.be)(/[a-zA-Z0-9_\-]+/?(?:v=|embed/|live/|v/)?)?([a-zA-Z0-9_\-]+)(\S+)?$',
      );
      return regExp.hasMatch(url);
    }
    return false;
  }
}

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String normalText1;
  final String normalText2;
  final String boldText;

  const CustomListTile({
    Key? key,
    required this.icon,
    required this.normalText1,
    required this.normalText2,
    required this.boldText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: ColorUtils.colorPrimary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: ' $normalText1',
                      style: primaryTextStyle(
                          size: textFontSize_16,
                          wordSpacing: 2,
                          weight: FontWeight.normal),
                    ),
                    TextSpan(
                      text: boldText,
                      style: primaryTextStyle(
                          size: textFontSize_16,
                          wordSpacing: 2,
                          weight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' $normalText2',
                      style: primaryTextStyle(
                          size: textFontSize_16,
                          wordSpacing: 2,
                          weight: FontWeight.normal),
                    ),
                  ],
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CombinedItem {
  final dynamic item;
  final bool isInsight;

  CombinedItem({required this.item, required this.isInsight});
}

class ChatGptInsightCycleView extends StatelessWidget {
  final int cycleDay;
  final ChatGptInsight insight;

  const ChatGptInsightCycleView({
    super.key,
    required this.cycleDay,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showInsightStory(context),
      child: Container(
        height: kInsightHeight,
        width: kInsightWidth,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              ic_ai_insights,
              fit: insightBoxFit,
              width: double.infinity,
              height: double.infinity,
            ),
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  // Customize gradient colors
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Text(
                cycleDay.toString(),
                style: boldTextStyle(
                  size: 64,
                  weight: FontWeight.bold,
                  color: Colors.white,
                  // Base color (white ensures gradient visibility)
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ).visible(cycleDay != 0).paddingOnly(top: 16),
            ),
          ],
        ),
      ),
    );
  }





  void _showInsightStory(BuildContext context) {
    final storyController = StoryController();

    final storyItems = [
      _buildStatusPage(),
      _buildOverviewPage(),
      _buildStoryPage('Hormones', [
        'Estrogen: ${insight.hormones!.estrogen}',
        'Progesterone: ${insight.hormones!.progesterone}',
      ]),
      _buildStoryPage('Nutrition Tips', insight.nutritionTips!),
      _buildStoryPage('Exercise', insight.exerciseRecommendations!),
      _buildStoryPage('Health Tips', insight.healthTips!),
      _buildStoryPage('Mood Changes', insight.moodChanges!),
      _buildStoryPage('Self-Care', insight.selfCareTips!),
      _buildStoryPage('Skin-Care Tips', insight.skin!),
      _buildStoryPage('Hydration Tips', insight.hydration!),
      _buildStoryPage('Energy Tips', insight.energy!),
      _buildStoryPage('Motivational Tips', insight.motivation!),
      _buildStoryPage('Fitness', insight.fitness!),
      _buildStoryPage('Societal Tips', insight.social!),
      _buildStoryPage('Calm', insight.calm!),
      _buildStoryPage('Sleeping Tips', insight.sleep!),
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryView(
          indicatorHeight: IndicatorHeight.small,
          storyItems: storyItems,
          controller: storyController,
          onComplete: () => Navigator.pop(context),
        ),
      ),
    );
  }

  StoryItem _buildStoryPage(String title, List<String> items) {
    final richTextWidget = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$title\n\n',
            style: boldTextStyle(
              size: 24,
              weight: FontWeight.w500,
              color: Colors.white,
              height: 1,
            ),
          ),
          // Bullet points
          ...items
              .map((item) => TextSpan(
            text: '• $item\n\n',
            style: primaryTextStyle(
              size: 20,
              weight: FontWeight.normal,
              color: Colors.white,
              height: 1.4,
            ),
          ))
              .toList(),
        ],
      ),
    );

    Color backgroundColor;
    switch (title) {
      case 'Nutrition Tips':
        backgroundColor = const Color(0xFFB71C1C);
        break;
      case 'Exercise':
        backgroundColor = const Color(0xFF880E4F);
        break;
      case 'Health Tips':
        backgroundColor = const Color(0xFFAD1457);
        break;
      case 'Mood Changes':
        backgroundColor = const Color(0xFF6A1B9A);
        break;
      case 'Self-Care':
        backgroundColor = const Color(0xFF4E342E);
        break;
      case 'Skin-Care Tips':
        backgroundColor = const Color(0xFFB71C1C);
        break;
      case 'Hydration Tips':
        backgroundColor = const Color(0xFF880E4F);
        break;
      case 'Energy Tips':
        backgroundColor = const Color(0xFFAD1457);
        break;
      case 'Motivational Tips':
        backgroundColor = const Color(0xFF6A1B9A);
        break;
      case 'Fitness':
        backgroundColor = const Color(0xFF4E342E);
        break;
      case 'Societal Tips':
        backgroundColor = const Color(0xFF6A1B9A);
        break;
      case 'Calm':
        backgroundColor = const Color(0xFF4E342E);
        break;
      case 'Sleeping Tips':
        backgroundColor = const Color(0xFFD81B60);
        break;
      default:
        backgroundColor = const Color(0xFFD81B60);
    }

    return StoryItem(
      Container(
        color: backgroundColor,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Center(child: richTextWidget)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  language.poweredByAI,
                  style: primaryTextStyle(
                    size: 14,
                    color: Colors.white70,
                    weight: FontWeight.w500,
                    decoration: TextDecoration.none,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: INSIGHT_STORY_IMAGE_DURATION),
    );
  }

  StoryItem _buildOverviewPage() {
    final richTextWidget = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          // Day number with emphasis
          TextSpan(
            text: '${language.day} $cycleDay\n\n',
            style: boldTextStyle(
              size: 24,
              weight: FontWeight.w500,
              color: Colors.white,
              height: 1,
            ),
          ),
          // Overview text
          TextSpan(
            text: insight.overview,
            style: primaryTextStyle(
              size: 18,
              weight: FontWeight.normal,
              color: Colors.white,
              height: 1,
            ),
          ),
        ],
      ),
    );

    return StoryItem(
      Container(
        color: const Color(0xFFC2185B),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Center(child: richTextWidget)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  language.poweredByAI,
                  style: primaryTextStyle(
                    size: 14,
                    color: Colors.white70,
                    weight: FontWeight.w500,
                    decoration: TextDecoration.none,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      duration: Duration(seconds: INSIGHT_STORY_IMAGE_DURATION),
    );
  }

  StoryItem _buildStatusPage() {
    final richTextWidget = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          // Day number with emphasis
          TextSpan(
            text: '${language.statusOfCycleDay} $cycleDay\n\n',
            style: boldTextStyle(
              size: 24,
              weight: FontWeight.w500,
              color: Colors.white,
              height: 1,
            ),
          ),
          // Overview text
          TextSpan(
            text: insight.status,
            style: primaryTextStyle(
              size: 18,
              weight: FontWeight.normal,
              color: Colors.white,
              height: 1,
            ),
          ),
        ],
      ),
    );

    return StoryItem(
      Container(
        color: const Color(0xFF00695C),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Center(child: richTextWidget)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  language.poweredByAI,
                  style: primaryTextStyle(
                    size: 14,
                    color: Colors.white70,
                    weight: FontWeight.w500,
                    decoration: TextDecoration.none,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      duration: Duration(seconds: INSIGHT_STORY_IMAGE_DURATION),
    );
  }
}

class ChatGptInsightPregnancyView extends StatelessWidget {
  final int pregnancyWeek;
  final ChatGptInsight insight;

  const ChatGptInsightPregnancyView({
    super.key,
    required this.pregnancyWeek,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showInsightStory(context),
      child: Container(
        height: kInsightHeight,
        width: kInsightWidth,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              ic_ai_insights_two,
              fit: insightBoxFit,
              width: double.infinity,
              height: double.infinity,
            ),
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [Colors.green, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Text(
                pregnancyWeek.toString(),
                style: boldTextStyle(
                  size: 64,
                  weight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ).paddingOnly(top: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _showInsightStory(BuildContext context) {
    final storyController = StoryController();

    final storyItems = [
      _buildStoryPage('Highlights', insight.highlightsOfWeek!),
      _buildBabyGrowthPage(),
      _buildStoryPage('Pregnancy Checklist', insight.pregnancyChecklist!),
      _buildStoryPage('Symptoms', insight.pregnancySymptoms!),
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryView(
          indicatorHeight: IndicatorHeight.small,
          storyItems: storyItems,
          controller: storyController,
          onComplete: () => Navigator.pop(context),
        ),
      ),
    );
  }

  StoryItem _buildStoryPage(String title, List<String> items) {
    final richTextWidget = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$title\n\n',
            style: boldTextStyle(
              size: 24,
              weight: FontWeight.w500,
              color: Colors.white,
              height: 1,
            ),
          ),
          ...items
              .map((item) => TextSpan(
            text: '• $item\n\n',
            style: primaryTextStyle(
              size: 20,
              weight: FontWeight.normal,
              color: Colors.white,
              height: 1.4,
            ),
          ))
              .toList(),
        ],
      ),
    );

    Color backgroundColor;
    switch (title) {
      case 'Pregnancy Checklist':
        backgroundColor = const Color(0xFF388E3C);
        break;
      case 'Symptoms':
        backgroundColor = const Color(0xFF1976D2);
        break;
      case 'Highlights':
        backgroundColor = const Color(0xFF7B1FA2);
        break;
      case 'Nutrition Tips':
        backgroundColor = const Color(0xFFF57C00);
        break;
      default:
        backgroundColor = const Color(0xFFD81B60);
    }

    return StoryItem(
      Container(
        color: backgroundColor,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Center(child: richTextWidget)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  language.poweredByAI,
                  style: primaryTextStyle(
                    size: 14,
                    color: Colors.white70,
                    weight: FontWeight.w500,
                    decoration: TextDecoration.none,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: INSIGHT_STORY_IMAGE_DURATION),
    );
  }

  StoryItem _buildBabyGrowthPage() {
    final richTextWidget = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: '${language.yourBabyAtWeek} $pregnancyWeek\n\n',
            style: boldTextStyle(
              size: 24,
              weight: FontWeight.w500,
              color: Colors.white,
              height: 1,
            ),
          ),
          TextSpan(
            text: '${insight.massOfBaby ?? language.notAvailable}\n\n',
            style: primaryTextStyle(
              size: 20,
              weight: FontWeight.w500,
              color: Colors.white,
              height: 1,
            ),
          ),
          TextSpan(
            text: insight.babyGrowth ?? language.noGrowthInformationAvailable,
            style: primaryTextStyle(
              size: 18,
              weight: FontWeight.normal,
              color: Colors.white,
              height: 1,
            ),
          ),
        ],
      ),
    );

    return StoryItem(
      Container(
        color: const Color(0xFF0288D1),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Center(child: richTextWidget)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  language.poweredByAI,
                  style: primaryTextStyle(
                    size: 14,
                    color: Colors.white70,
                    weight: FontWeight.w500,
                    decoration: TextDecoration.none,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      duration: Duration(seconds: INSIGHT_STORY_IMAGE_DURATION),
    );
  }
}

class CountdownWidget extends StatefulWidget {
  final bool isVisible;
  final String Function(String) formatDateToDayFirst;
  final Future<int> Function() daysUntilDueDate;
  final String? expectedDueDate;

  const CountdownWidget({
    super.key,
    required this.isVisible,
    required this.formatDateToDayFirst,
    this.expectedDueDate,
    required this.daysUntilDueDate,
  });

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  double progress = 0.0;

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible ||
        widget.expectedDueDate == null ||
        widget.expectedDueDate!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: mainColorLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Countdown digits section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<int>(
                future: widget.daysUntilDueDate(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done ||
                      !snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final totalDays = snapshot.data!;
                  final now = DateTime.now();
                  final startDate = DateTime(now.year, now.month, 1);
                  int daysPassed = now.difference(startDate).inDays;
                  if (daysPassed > totalDays) daysPassed = totalDays;

                  // Calculate progress without setState
                  progress = (daysPassed / totalDays).clamp(0.0, 1.0);

                  final digits =
                  snapshot.data!.toString().padLeft(3, '0').split('');

                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          DigitBox(digit: digits[0]),
                          8.width,
                          DigitBox(digit: digits[1]),
                          8.width,
                          DigitBox(digit: digits[2]),
                          8.width,
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              language.days,
                              style: boldTextStyle(
                                color: mainColorText,
                                size: 16,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      10.height,
                      // Linear Progress Indicator
                      Container(
                        width: 160,
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          16.width,
          // Due date section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      ic_calender,
                      width: 18,
                      height: 18,
                      color: mainColor,
                    ),
                    8.width,
                    Text(
                      language.dueDate,
                      style: boldTextStyle(
                          weight: FontWeight.w400,
                          color: mainColorText,
                          size: 14),
                    ),
                  ],
                ),
                8.height,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.formatDateToDayFirst(widget.expectedDueDate!),
                      style: boldTextStyle(
                        color: mainColor,
                        size: 16,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DigitBox extends StatelessWidget {
  final String digit;

  DigitBox({required this.digit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: mainColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          digit,
          style: TextStyle(
            color: Colors.white, // White text
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
