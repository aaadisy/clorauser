import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import '../../network/network_utils.dart';
import '../../utils/stream_chat_helper.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/animated_marble_background.dart';

import '../../extensions/text_styles.dart';
import '../../service/permission_service.dart';
import '../../model/doctor/doctor_models/health_expert_model.dart';
import '../../utils/app_common.dart';
import '../../utils/app_constants.dart';
import '../user/chat_users_list_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../user/chat_users_detail_screen.dart';
import '../../extensions/extensions.dart';
import '../../main.dart';
import '../../utils/dynamic_theme.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart' as stream_video;

// --- LOCAL DEFINITIONS TO BYPASS MISSING constants.dart ---
const String PAYMENT_TYPE_RAZORPAY = 'razorpay';
// Define placeholders for globals used in build methods that likely came from the missing constants file:
const Color kPrimaryColor = ColorUtils.PRIMARY_PINK;
const Color bgColor = ColorUtils.PRIMARY_CREAM;
// --- END LOCAL DEFINITIONS ---

// --- MODELS (Placeholders based on API docs) ---

class MyConsultationModel {
  final int id;
  final String doctorName;
  final String? doctorImage;
  final String? specialization;
  final String? career;
  final String consultationType;
  final String status;
  final String rating;
  final String amount;
  final String? pdfPath;
  final String createdAt;
  final String doctorId;

  MyConsultationModel({
    required this.id,
    required this.doctorName,
    required this.consultationType,
    required this.status,
    required this.rating,
    required this.amount,
    required this.createdAt,
    required this.doctorId,
    this.pdfPath,
    this.doctorImage,
    this.specialization,
    this.career,
  });

  factory MyConsultationModel.fromJson(Map<String, dynamic> json) {
    return MyConsultationModel(
      id: json['id'],
      doctorId: json['doctor_id'].toString(),
      doctorName: json['doctor_name'] ?? "",
      consultationType: json['consultation_type'] ?? "",
      status: json['status'] ?? "",
      rating: json['rating'] ?? "",
      amount: json['amount'].toString(),
      createdAt: json['created_at'] ?? "",
      pdfPath: json['pdf_path'],

      // ✅ NEW FIELDS
      doctorImage: json['doctor_image'],
      specialization: json['specialization'],
      career: json['career'],
    );
  }
}

class HealthExpertData {
  final int? id;
  final String? displayName;
  final String? tagLine;
  final int? experience;
  final int? fee;
  final String? city;
  final String? consultationModes;
  final int? isAccess;
  final String? userId;
  final String? healthExpertsImage;
  final String? specialization;
  final String? qualification;
  final String? hospitalName;
  final double? averageRating;
  final int? totalReviews;
  final String? shortDescription;
  final String? career;
  final String? areaExpertise;
  final List<String>? languages;
  final Map<String, dynamic>? availableDays;
  final int? consultationDuration;
  final String? practiceType;
  final String? gender;
  final bool? isChatAvailable;

  HealthExpertData.fromJson(
      Map<String, dynamic> json, Map<String, dynamic> parentJson)
      : id = json['id'],
        displayName = json['display_name'] ?? parentJson['display_name'],
        tagLine = json['tag_line'],
        experience = json['experience'],
        fee = json['fee'],
        city = json['city'],
        consultationModes = (json['consultation_modes'] is List)
            ? (json['consultation_modes'] as List<dynamic>).join(', ')
            : json['consultation_modes'] as String?,
        isAccess = json['is_access'],
        userId = parentJson['id']?.toString() ?? json['user_id'] as String?,
        healthExpertsImage = json['health_experts_image'],
        specialization = json['tag_line'],
        qualification = json['education'],
        hospitalName = json['clinic_name'],
        averageRating = json['average_rating'] != null
            ? double.tryParse(json['average_rating'].toString())
            : null,
        totalReviews = int.tryParse(json['total_reviews']?.toString() ?? '0'),
        shortDescription = json['short_description'],
        career = json['career'],
        areaExpertise = json['area_expertise'],
        languages = json['languages'] != null
            ? List<String>.from(json['languages'])
            : null,
        availableDays = json['available_days'],
        consultationDuration = json['consultation_duration'],
        practiceType = json['practice_type'],
        gender = json['gender'],
        isChatAvailable = parentJson['is_chat_available'];
}

class ConsultDoctorItem {
  final HealthExpertData? healthExpert;

  ConsultDoctorItem.fromJson(Map<String, dynamic> json)
      : healthExpert = json['health_expert'] != null
            ? HealthExpertData.fromJson(json['health_expert'], json)
            : null;
}

class ConsultNowResponse {
  final List<ConsultDoctorItem> doctors;
  final int currentPage;
  final int lastPage;

  ConsultNowResponse({
    required this.doctors,
    required this.currentPage,
    required this.lastPage,
  });

  factory ConsultNowResponse.fromJson(Map<String, dynamic> json) {
    final responseData = json['responseData'] as Map<String, dynamic>? ?? json;
    var dataList = responseData['data'] as List? ?? [];
    return ConsultNowResponse(
      doctors: dataList.map((i) => ConsultDoctorItem.fromJson(i)).toList(),
      currentPage: responseData['current_page'] as int? ?? 1,
      lastPage: responseData['last_page'] as int? ?? 1,
    );
  }
}

// --- SERVICE ---

class ConsultService {
  static Future<ConsultNowResponse> fetchDoctorList(int page) async {
    if (!(await isNetworkAvailable())) {
      log('ConsultService: Network check failed.');
      throw Exception("No Internet Connection");
    }

    final url = Uri.parse(
        'https://apis.getclora.com/api/user/consultnowlist?page=$page');
    final token = getStringAsync(TOKEN);
    log('ConsultService: Fetching page $page with Token: ${token ?? "NULL"}');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      },
    );

    log('ConsultService: Response Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      log('ConsultService: Response Body: ${response.body.substring(0, 200)}...'); // Log first 200 chars
    }

    if (response.statusCode == 200) {
      return ConsultNowResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load doctors: ${response.statusCode}');
    }
  }
}

// --- SCREEN: CONSULT NOW LIST ---

class ConsultNowScreen extends StatefulWidget {
  static String tag = '/ConsultNowScreen';

  const ConsultNowScreen({super.key});

  @override
  State<ConsultNowScreen> createState() => _ConsultNowScreenState();
}

class _ConsultNowScreenState extends State<ConsultNowScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _selectedCategory = "All";
  String _searchQuery = "";
  bool _isStreamReady = false;
  final List<String> _categories = [
    "All",
    "Gynecologist",
    "Endocrinologist",
    "Dermatologist",
    "Therapist",
  ];

  Future<void> downloadPrescription(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();

        final filePath =
            "${dir.path}/prescription_${DateTime.now().millisecondsSinceEpoch}.pdf";

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        toast("Downloaded successfully");

        print("Saved at: $filePath");

        // ❌ OPEN नहीं करना (as per your requirement)
        final result = await OpenFile.open(filePath);

        print("📂 Open result: ${result.message}");
      } else {
        toast("Download failed");
      }
    } catch (e) {
      print("Download error: $e");
      toast("Download failed");
    }
  }

  Future<void> submitRating({
    required int consultationId,
    required int rating,
  }) async {
    try {
      print("📡 HIT API: myconsultation/rate");

      var response = await handleResponse(
        await buildHttpResponse(
          'myconsultation/rate',
          method: HttpMethod.post,
          request: {
            "consultation_id": consultationId,
            "rating": rating,
          },
        ),
      );

      print("📥 API RESPONSE: $response");

      if (response['status'] == true) {
        toast(response['message'] ?? "Rating submitted");

        /// 🔄 refresh
        await _fetchMyConsultations();
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      print("❌ API ERROR: $e");
      rethrow;
    }
  }

  void showRatingDialog(BuildContext context, MyConsultationModel item) {
    double rating = 0;

    showDialog(
      context: context,
      barrierDismissible: false, // ❗ user bahar tap karke close na kare
      builder: (_) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text("Rate Doctor"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// ⭐ STAR SELECT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 10),

                  /// 🔄 LOADER
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                /// ❌ CANCEL
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                /// ✅ SUBMIT
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (rating == 0) {
                            toast("Please select rating");
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          /// 🔥 LOG START
                          print("📤 RATING API CALL START");
                          print("consultation_id: ${item.id}");
                          print("rating: $rating");

                          try {
                            await submitRating(
                              consultationId: item.id,
                              rating: rating.toInt(),
                            );

                            print("✅ RATING SUCCESS");

                            Navigator.pop(context);
                          } catch (e) {
                            print("❌ RATING ERROR: $e");

                            toast("Something went wrong");

                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// ---------------- DOCTOR LIST ----------------
  final List<ConsultDoctorItem> _doctors = [];
  bool _isLoadingDoctors = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  int _lastPage = 1;
  final ScrollController _scrollController = ScrollController();

  /// ---------------- REPORTS ----------------
  List<MyConsultationModel> _consultations = [];
  bool _isLoadingReports = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      setState(() {}); // 🔥 THIS FIXES YOUR ISSUE
      if (_tabController.index == 1) {
        _fetchMyConsultations();
      }
    });

    /// 🔥 ADD THIS (MOST IMPORTANT)
    _initStreamConnect();

    print("isLoggedIn: ${userStore.isLoggedIn}");
    print("StreamUserId: ${client.state.currentUser?.id}");
    _fetchDoctors();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// ============================
  /// DOCTOR LIST API
  /// ============================

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingDoctors) {
      if (_currentPage < _lastPage) {
        _fetchDoctors(isLoadMore: true);
      }
    }
  }

  Future<void> _initStreamConnect() async {
    print("🚀 FETCHING STREAM TOKEN FROM API");

    final data = await getStreamTokenApi();

    if (data == null) {
      print("❌ API FAILED");
      return;
    }

    final token = data['stream_token'];

    if (token == null || token.isEmpty) {
      print("❌ TOKEN EMPTY");
      return;
    }

    await setValue("STREAM_TOKEN", token);

    /// ✅ STEP 1: Already connected check
    if (client.state.currentUser != null) {
      print("✅ Already connected: ${client.state.currentUser!.id}");

      if (mounted) {
        setState(() {
          _isStreamReady = true;
        });
      }
      return;
    }

    int retry = 0;

    while (retry < 5) {
      try {
        print("🔁 TRY ${retry + 1}");

        await client.connectUser(
          User(
            id: data['user_id'].toString(),
            name: data['name'] ?? "User",
            image: data['image'],
          ),
          token,
        );

        print("✅ STREAM CONNECT SUCCESS");

        if (mounted) {
          setState(() {
            _isStreamReady = true;
          });
        }

        return;
      } catch (e) {
        print("❌ ERROR: $e");

        /// ✅ STEP 2: Already connected error handle
        if (e.toString().contains("Connection already available")) {
          print("⚠️ Already connected - treating as success");

          if (mounted) {
            setState(() {
              _isStreamReady = true;
            });
          }
          return;
        }
      }

      retry++;
      await Future.delayed(const Duration(seconds: 1));
    }

    print("❌ STREAM FAILED");
  }

  /// 🔥 STREAM TOKEN API
  Future<Map?> getStreamTokenApi() async {
    try {
      var response = await handleResponse(
        await buildHttpResponse(
          'get-stream-token',
          method: HttpMethod.get,
        ),
      );

      /// ✅ CORRECT STRUCTURE
      if (response['status'] == true) {
        userStore.setLogin(true);
        return response['responseData'];
      }
    } catch (e) {
      print("❌ STREAM TOKEN API ERROR: $e");
    }

    return null;
  }

  Future<void> _fetchDoctors({bool isLoadMore = false}) async {
    if (!isLoadMore) {
      setState(() {
        _isLoadingDoctors = true;
        _hasError = false;
      });
    }

    try {
      final response = await ConsultService.fetchDoctorList(_currentPage);

      setState(() {
        if (isLoadMore) {
          _doctors.addAll(response.doctors);
        } else {
          _doctors.clear();
          _doctors.addAll(response.doctors);
        }

        _currentPage = response.currentPage;
        _lastPage = response.lastPage;
        _isLoadingDoctors = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDoctors = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  /// ============================
  /// MY CONSULTATION API
  /// ============================

  Future<void> _fetchMyConsultations() async {
    setState(() => _isLoadingReports = true);

    try {
      final token = getStringAsync(TOKEN);

      final response = await http.get(
        Uri.parse("https://apis.getclora.com/api/user/myconsultation"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['responseData']['data'] as List;

        setState(() {
          _consultations =
              data.map((e) => MyConsultationModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      print("REPORT ERROR: $e");
    } finally {
      setState(() => _isLoadingReports = false);
    }
  }

  /// ============================
  /// UI BUILD
  /// ============================

  @override
  Widget build(BuildContext context) {
    /// 🔥 BLOCK UNTIL STREAM READY
    if (!_isStreamReady) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Connecting chat..."),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            toolbarHeight: 0, // 🔥 completely hides AppBar

            backgroundColor: Colors.transparent,
            elevation: 0,
          ),

          // ----------------- CUSTOM SEGMENT CONTROL -----------------
          _ConsultSegmentControl(
            controller: _tabController,
            selectedColor:
                ColorUtils.colorPrimary, // Using the primary pink color
            unselectedColor: Colors.transparent,
            titles: const ["Doctors", "Reports"],
          ),
          // ----------------------------------------------------------

          /// TAB BAR VIEW (Now expanded to fill remaining space)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDoctorsTab(),
                _buildReportsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ============================
  /// DOCTORS TAB
  /// ============================
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: ColorUtils.colorPrimary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: Colors.grey.shade200,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: "Search doctor...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorsTab() {
    if (_isLoadingDoctors) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(child: Text(_errorMessage));
    }

    if (_doctors.isEmpty) {
      return const Center(child: Text("No doctors available"));
    }

    /// FILTERED LIST
    List<ConsultDoctorItem> filteredDoctors = _doctors.where((doctor) {
      final specialization =
          doctor.healthExpert?.specialization?.toLowerCase() ?? "";

      final name = doctor.healthExpert?.displayName?.toLowerCase() ?? "";

      final matchesCategory = _selectedCategory == "All" ||
          specialization.contains(_selectedCategory.toLowerCase());

      final matchesSearch = name.contains(_searchQuery);

      return matchesCategory && matchesSearch;
    }).toList();

    return Column(
      children: [
        /// SEARCH BAR
        _buildSearchBar(),

        /// CATEGORY FILTER
        _buildCategoryFilter(),

        const SizedBox(height: 10),

        /// DOCTOR LIST
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: filteredDoctors.length,
            itemBuilder: (context, index) {
              final doctor = filteredDoctors[index].healthExpert;

              return DoctorCard(
                doctor: doctor,
                onConsultNowTap: (doc) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorDetailScreen(doctor: doc),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Duration getRemainingTime(String createdAt) {
    DateTime created = DateTime.parse(createdAt).toLocal();
    DateTime expiry = created.add(Duration(hours: 48));
    return expiry.difference(DateTime.now());
  }

  bool isFollowUpActive(String createdAt) {
    return getRemainingTime(createdAt).inSeconds > 0;
  }

  String formatDuration(Duration d) {
    if (d.isNegative) return "Follow-up closed";

    int h = d.inHours;
    int m = d.inMinutes % 60;

    return "Follow-up available for ${h}h ${m}m";
  }

  /// ============================
  /// REPORTS TAB
  /// ============================
  Widget premiumReportCard(MyConsultationModel item) {
    final remaining = getRemainingTime(item.createdAt);
    final isActive = isFollowUpActive(item.createdAt);

    DateTime parsedDate = DateTime.parse(item.createdAt).toLocal();

    String formattedDate =
        DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);

    final isRated =
        item.rating != null && item.rating.toString().trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFFF7F3FA),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔝 HEADER
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: item.doctorImage != null
                    ? NetworkImage(item.doctorImage!)
                    : null,
                child:
                    item.doctorImage == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🧑‍⚕️ NAME + ⭐ RATING
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Dr. ${item.doctorName}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        /// ⭐ अगर rating NULL है → show star icon
                        /// ⭐ अगर rating है → show value
                        GestureDetector(
                          onTap: !isRated
                              ? () {
                                  showRatingDialog(context, item); // popup
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: isRated
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      const SizedBox(width: 2),
                                      Text(
                                        item.rating.toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                : const Icon(
                                    Icons.star_border_rounded,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ],
                    ),

                    Text(
                      item.specialization ?? "",
                      style: const TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if (item.career != item.specialization)
                      Text(
                        item.career!,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 📅 DATE
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14),
              const SizedBox(width: 6),
              Text(formattedDate),
            ],
          ),

          const SizedBox(height: 6),

          Text("ID: CLR-${item.id}"),

          const SizedBox(height: 12),

          /// ⏱ FOLLOW-UP STATUS
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isActive
                        ? formatDuration(remaining)
                        : "Follow-up closed. Book a fresh consultation.",
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          /// 🔘 BUTTONS
          Row(
            children: [
              /// DOWNLOAD
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: item.pdfPath != null
                      ? () => downloadPrescription(item.pdfPath!)
                      : () {
                    /// 🔥 OPEN CHAT
                    openConsultationChat(
                      context: context,
                      doctorId: item.doctorId,
                      doctorName: item.doctorName,
                      doctorImage: item.doctorImage, // 👈 add this
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.pdfPath != null
                        ? Colors.white
                        : Colors.green, // chat ke liye alag color (optional)
                    foregroundColor:
                    item.pdfPath != null ? Colors.black87 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  icon: Icon(
                    item.pdfPath != null ? Icons.download : Icons.chat,
                    size: 18,
                  ),
                  label: Text(
                    item.pdfPath != null
                        ? "Download Prescription"
                        : "Open Chat",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              /// 🔁 FOLLOW-UP / BOOK SLOT
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (isActive) {
                      /// 👉 follow-up API call yaha
                    } else {
                      /// ✅ SAME FLOW AS CONSULT NOW
                      final doctor = HealthExpertData.fromJson(
                        {
                          "id": int.tryParse(item.doctorId),
                          "display_name": item.doctorName,
                          "tag_line": item.specialization,
                          "career": item.career,
                          "health_experts_image": item.doctorImage,
                          "fee": 0,
                        },
                        {
                          "id": item.doctorId,
                          "display_name": item.doctorName,
                          "is_chat_available": true,
                        },
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoctorDetailScreen(doctor: doctor),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isActive ? Colors.purple.shade200 : Colors.pink,
                  ),
                  child: Text(
                    isActive ? "Request Follow-up" : "Book New Slot",
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    if (_isLoadingReports) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_consultations.isEmpty) {
      return const Center(
        child: Text(
          "No consultation history",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _consultations.length,
      itemBuilder: (context, index) {
        return premiumReportCard(_consultations[index]);
      },
    );
  }
}

class ConsultationDetailScreen extends StatelessWidget {
  final MyConsultationModel consultation;

  const ConsultationDetailScreen({
    super.key,
    required this.consultation,
  });

  @override
  Widget build(BuildContext context) {
    bool isActive = consultation.status.toLowerCase() == "active";

    DateTime parsedDate = DateTime.parse(consultation.createdAt).toUtc();
    DateTime indianTime = parsedDate.add(const Duration(hours: 5, minutes: 30));

    String formattedDate =
        DateFormat('dd MMM yyyy • hh:mm a').format(indianTime);

    Color statusColor;

    switch (consultation.status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'completed':
        statusColor = Colors.blue;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return AnimatedMarbleBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Consultation Details"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// DOCTOR CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isActive ? ColorUtils.colorPrimary : Colors.transparent,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          ColorUtils.colorPrimary.withOpacity(0.15),
                      child: Icon(
                        Icons.person,
                        color: ColorUtils.colorPrimary,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            consultation.doctorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// STATUS BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        consultation.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// CONSULTATION INFO
              const Text(
                "Consultation Info",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Date"),
                        Text(formattedDate),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Amount"),
                        Text("₹${consultation.amount}"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Status"),
                        Text(
                          consultation.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// CHAT SECTION
              const Text(
                "Consultation Chat",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat),
                  label: const Text("Open Chat"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isActive ? ColorUtils.colorPrimary : Colors.grey,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: isActive
                      ? () {
                          openConsultationChat(
                            context: context,
                            doctorId: consultation.doctorId,
                            doctorName: consultation.doctorName,
                              doctorImage: consultation.doctorImage,
                          );
                        }
                      : null,
                ),
              ),

              const SizedBox(height: 24),

              /// PRESCRIPTION
              /// PRESCRIPTION
              if (consultation.pdfPath != null) ...[
                const Text(
                  "Prescription",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "Doctor Prescription",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          /// OPEN
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.visibility),
                              label: const Text("View"),
                              onPressed: () async {
                                final url = consultation.pdfPath!;

                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(
                                    Uri.parse(url),
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                            ),
                          ),

                          const SizedBox(width: 8),

                          /// DOWNLOAD
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.download),
                              label: const Text("Download"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorUtils.colorPrimary,
                              ),
                              onPressed: () async {
                                final url = consultation.pdfPath!;

                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(
                                    Uri.parse(url),
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              /// FEEDBACK
              const Text(
                "Feedback",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 12),

              /// FEEDBACK (Only when consultation completed)
              if (consultation.status.toLowerCase() == "completed") ...[
                const Text(
                  "Feedback",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _RatingCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingCard extends StatefulWidget {
  const _RatingCard();

  @override
  State<_RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<_RatingCard> {
  double rating = 0;

  Widget star(int index) {
    return IconButton(
      icon: Icon(
        index < rating ? Icons.star : Icons.star_border,
        color: Colors.orange,
        size: 32,
      ),
      onPressed: () {
        setState(() {
          rating = index + 1.0;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            "Rate your consultation",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => star(i)),
          ),
          const SizedBox(height: 12),
          if (rating > 0)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Rating submitted: $rating ⭐"),
                  ),
                );
              },
              child: const Text("Submit Rating"),
            )
        ],
      ),
    );
  }
}

// --- WIDGET: DOCTOR CARD ---
class DoctorCard extends StatelessWidget {
  final HealthExpertData? doctor;
  final Function(HealthExpertData) onConsultNowTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onConsultNowTap,
  });

  @override
  Widget build(BuildContext context) {
    if (doctor == null) return const SizedBox();

    final imageUrl = doctor!.healthExpertsImage ?? "";
    final rating = doctor!.averageRating ?? 0;
    final reviews = doctor!.totalReviews ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F2F8),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 TOP ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 60,
                        width: 60,
                        color: Colors.white,
                        child: const Icon(Icons.person),
                      ),
              ),

              const SizedBox(width: 12),

              /// RIGHT CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// NAME + RATING
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Dr. ${doctor!.displayName ?? ""}",
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        /// ⭐ RATING (ONLY IF > 0)
                        if (rating > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.pink.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 16, color: Colors.pink),
                                const SizedBox(width: 4),
                                Text(
                                  rating.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    /// SPECIALIZATION
                    Text(
                      doctor!.tagLine ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.pink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    /// EDUCATION + EXPERIENCE
                    Text(
                      "${(doctor!.qualification ?? "").replaceAll(RegExp(r'<[^>]*>'), '')} - ${doctor!.experience ?? 0} yrs exp",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// LOCATION + PRICE
                    Row(
                      children: [
                        /// LOCATION
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16, color: Colors.black54),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  doctor!.hospitalName ??
                                      doctor!.city ??
                                      "Location",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// PRICE
                        Text(
                          "₹${doctor!.fee ?? 0}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    /// 🧾 REVIEWS (ONLY IF > 0)
                    if (reviews > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        "$reviews reviews",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// 🔥 GRADIENT BUTTON (PINK MIX)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Material(
              color: Colors.transparent, // VERY IMPORTANT
              child: InkWell(
                onTap: () => onConsultNowTap(doctor!),
                borderRadius: BorderRadius.circular(30),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFE8C6FF), // light pink purple
                        Color(0xFFFFC1CC), // soft pink
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      "Consult Now",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- SCREEN: DOCTOR DETAIL ---
class DoctorDetailScreen extends StatefulWidget {
  final HealthExpertData doctor;
  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isChatAvailable = false;
  bool _isLoadingChatConnection = false;
  late TabController _tabController;
  late Razorpay _razorpay;

  // Payment Flow State
  String? _orderId;
  bool _isProcessingPayment = false;

  // Configuration: Using test key provided
  static const String RAZORPAY_KEY_ID = "rzp_test_SAV9mMV1MhOyLx";
  static const String BASE_API_URL = 'https://apis.getclora.com/api';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    logScreenView(
        "Doctor Detail screen for doctor ID: ${widget.doctor.userId}");
    _checkChatAvailability();
    _initializeRazorpay();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _razorpay.clear(); // Clean up Razorpay instance
    super.dispose();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _checkChatAvailability() {
    // Check if Stream client is ready and user is logged in
    if (userStore.isLoggedIn && client.state.currentUser?.id != null) {
      setState(() {
        _isChatAvailable = true;
      });
    } else {
      setState(() {
        _isChatAvailable = false;
      });
    }
  }

  // --- PAYMENT & BOOKING HANDLERS ---

  Future<void> _createOrderAndInitiatePayment() async {
    if (_isProcessingPayment) return;

    final doctorId = widget.doctor.userId;
    final amount = widget.doctor.fee;

    if (!userStore.isLoggedIn || client.state.currentUser?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: You must be logged in to book.')),
      );
      return;
    }

    if (doctorId == null || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Invalid doctor or consultation fee.')),
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
      _isLoadingChatConnection =
          true; // Reusing this flag for payment loading indicator
    });

    try {
      final patientStreamId = client.state.currentUser!.id;
      final token = getStringAsync(TOKEN);

      final response = await http.post(
        Uri.parse('$BASE_API_URL/consultation/create-order'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'doctor_id': int.tryParse(doctorId),
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        print("CREATE ORDER RESPONSE: $decoded");

        if (decoded['status'] == true) {
          final data = decoded['data'];

          final orderId = data['order_id']?.toString();
          final finalAmount = data['amount'] is int
              ? data['amount']
              : int.tryParse(data['amount']?.toString() ?? '');

          if (orderId != null && finalAmount != null) {
            _orderId = orderId;
            _openRazorpayCheckout(finalAmount, patientStreamId, doctorId);
          } else {
            throw Exception(
                'Order creation failed: Missing order_id or amount.');
          }
        } else {
          throw Exception(decoded['message'] ?? 'Order creation failed');
        }
      } else {
        throw Exception(
            'Backend returned status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _handlePaymentError(
          e.toString()); // Reuse error handler for backend errors
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
          _isLoadingChatConnection = false; // Reset connection/loader
        });
      }
    }
  }

  void _openRazorpayCheckout(
      int amountInPaise, String patientId, String doctorId) {
    final options = {
      'key': RAZORPAY_KEY_ID,
      'amount': amountInPaise, // Amount in smallest currency unit (paise)
      'name': 'Clora Consultation',
      'description': 'Consultation with Doctor ID: $doctorId',
      'order_id': _orderId,
      'prefill': {
        'contact': '9999999999', // Optional: Prefill contact
        'email': 'user@example.com', // Optional: Prefill email
      },
      'external': {
        'upi': true,
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _handlePaymentError('Failed to open checkout: $e');
    }
  }

  Future<void> _verifyPaymentAndBookConsultation(
      PaymentSuccessResponse response) async {
    setState(() {
      _isProcessingPayment = true;
      _isLoadingChatConnection =
          true; // Use connection loader to show verification in progress
    });

    final token = getStringAsync(TOKEN);
    final patientStreamId = client.state.currentUser!.id;
    final doctorId = widget.doctor.userId;

    if (doctorId == null || _orderId == null) {
      _handlePaymentError('Missing Doctor ID or Order ID for verification.');
      return;
    }

    try {
      final verifyResponse = await http.post(
        Uri.parse(
            '$BASE_API_URL/consultation/verify-payment'), // ASSUMED API ENDPOINT FOR VERIFICATION
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'razorpay_order_id': _orderId,
          'razorpay_payment_id': response.paymentId,
          'razorpay_signature': response.signature,
          'doctor_id': int.tryParse(doctorId),
          'patient_id': patientStreamId,
          'payment_method': PAYMENT_TYPE_RAZORPAY,
        }),
      );

      if (verifyResponse.statusCode == 200) {
        final verificationData = jsonDecode(verifyResponse.body);

        print("VERIFY RESPONSE: $verificationData");

        if (verificationData['success'] == true) {
          openConsultationChat(
            context: context,
            doctorId: doctorId,
            doctorName: widget.doctor.displayName ?? 'Doctor',
            doctorImage: widget.doctor.healthExpertsImage,

          );
        } else {
          throw Exception(verificationData['message'] ?? 'Verification failed');
        }
      } else {
        throw Exception('Verification API error: ${verifyResponse.statusCode}');
      }
    } catch (e) {
      _handlePaymentError('Verification Failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
          _isLoadingChatConnection = false;
        });
      }
    }
  }

  void _openChatAfterBooking(String doctorId) async {
    try {
      final currentUser = client.state.currentUser?.id;

      if (currentUser == null) {
        print("Stream user not connected");
        return;
      }

      final members = [
        currentUser.toString(),
        doctorId.toString(),
      ]..sort(); // IMPORTANT

      final channelId = "chat_${members[0]}_${members[1]}";

      final channel = client.channel(
        'messaging',
        id: channelId,
        extraData: {
          'members': members,
        },
      );

      await channel.watch();

      print("CHANNEL CREATED SUCCESS");

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatUsersDetailScreen(
            channel: channel,
            targetUser: User(
              id: doctorId.toString(),
              name: widget.doctor.displayName ?? 'Doctor',

              image:  widget.doctor.healthExpertsImage,
            ),
          ),
        ),
      );
    } catch (e) {
      print("CHAT ERROR: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful, but failed to open chat.'),
          ),
        );
      }
    }
  }

  // --- RAZORPAY CALLBACKS ---

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log('Payment Success: ${response.paymentId}');
    _verifyPaymentAndBookConsultation(response);
  }

  void _handlePaymentError(dynamic response) {
    log('Payment Error: $response');
    if (mounted) {
      Navigator.of(context, rootNavigator: true)
          .pop(); // Dismiss loader if open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Failed or Cancelled: $response'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _isProcessingPayment = false;
      _isLoadingChatConnection = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log('External Wallet Selected: ${response.walletName}');
    // Optional: Show info about external wallet usage
  }

  // --- WIDGET BUILDERS ---

  @override
  Widget build(BuildContext context) {
    return AnimatedMarbleBackground(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Doctor Profile',
            style: boldTextStyle(color: Colors.black.withOpacity(0.8))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: Stack(
        // Use Stack to overlay loader during payment processing
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDoctorHeader(),
                20.height,
                _buildDetailSection(
                    'Specialization', widget.doctor.tagLine ?? 'N/A'),
                _buildDetailSection(
                    'Experience', '${widget.doctor.experience ?? 0} Years'),
                _buildDetailSection(
                    'Fee', '₹${widget.doctor.fee ?? 0} per consult'),
                _buildDetailSection('Location', widget.doctor.city ?? 'N/A'),
                _buildDetailSection(
                    'Modes', widget.doctor.consultationModes ?? 'Chat/Call'),
              ],
            ),
          ),
          if (_isProcessingPayment)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  16.height,
                  Text(
                    'Processing payment...',
                    style: secondaryTextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomChatBar(),
    ));
  }

  Widget _buildDoctorHeader() {
    final image = widget.doctor.healthExpertsImage ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEADCF8),
            Color(0xFFF8F5FF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          /// 🔥 PROFILE IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: image.isNotEmpty
                ? Image.network(
                    image,
                    height: 85,
                    width: 85,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackAvatar(),
                  )
                : _fallbackAvatar(),
          ),

          const SizedBox(width: 16),

          /// 🔥 INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// NAME
                Text(
                  "Dr. ${widget.doctor.displayName ?? ""}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                /// SPECIALIZATION
                Text(
                  widget.doctor.tagLine ?? "",
                  style: const TextStyle(
                    color: Color(0xFF7B3FE4),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                /// EXPERIENCE
                Text(
                  "${widget.doctor.experience ?? 0} yrs experience",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 6),

                /// ⭐ RATING
                if ((widget.doctor.averageRating ?? 0) > 0)
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text("${widget.doctor.averageRating}"),
                      const SizedBox(width: 4),
                      Text(
                        "(${widget.doctor.totalReviews ?? 0})",
                        style: const TextStyle(
                            color: Colors.black45, fontSize: 12),
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

  Widget _buildDetailSection(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      height: 85,
      width: 85,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.person,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildBottomChatBar() {
    // The button logic is now entirely replaced to handle payment first.
    print("isLoggedIn: ${userStore.isLoggedIn}");
    print("StreamUserId: ${client.state.currentUser?.id}");
    print("_isProcessingPayment: $_isProcessingPayment");

    final isReadyForPayment = userStore.isLoggedIn &&
        client.state.currentUser?.id != null &&
        !_isProcessingPayment;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10) +
          EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color:
            Colors.black.withOpacity(0.4), // Dark, translucent base for footer
        border: Border(
            top: BorderSide(
                color: Colors.white.withOpacity(0.2))), // Subtle glass border
      ),
      child: ElevatedButton(
        onPressed: isReadyForPayment
            ? _createOrderAndInitiatePayment // NEW ENTRY POINT: Handles Order Creation -> Payment Checkout
            : null, // Disables the button if not authenticated or already processing
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorUtils.colorPrimary, // Pastel Pink background
          minimumSize: Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 0, // No harsh shadow
        ),
        child: _isProcessingPayment
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                "Book Consultation (₹${widget.doctor.fee ?? 0})", // Label updated to show fee and requirement
                style: boldTextStyle(color: Colors.white, size: 16),
              ),
      ),
    );
  }
}
// NOTE: Models and Services are defined conceptually above or assumed to exist in their respective files (e.g., HealthExpertData model structure assumed to align with doctor_models/health_expert_model.dart)
// NOTE: Assumes ChatUsersDetailScreen, PermissionService, Loader, ColorUtils, and stream_chat_flutter are correctly imported and available.
// NOTE: Assumes you have added 'razorpay_flutter' to your pubspec.yaml dependencies.
// NOTE: Assumes a backend endpoint '/consultation/verify-payment' exists for signature verification.
// NOTE: Final adjustments made for v1.4.0 compatibility in event registration.

void startAudioCall({required String doctorId}) async {
  if (streamVideo == null) return;

  final currentUserId = client.state.currentUser?.id;
  if (currentUserId == null) return;

  final members = [currentUserId, doctorId]..sort();

  final callId = "audio_${members[0]}_${members[1]}";

  final call = streamVideo!.makeCall(
    callType: stream_video.StreamCallType.audioRoom(),
    id: callId,
  );

  await call.getOrCreate(
    ring: const stream_video.StreamRingSettings(),
  );

  await call.join();

  navigatorKey.currentState!.push(
    MaterialPageRoute(
      builder: (_) => stream_video.StreamCallContainer(
        call: call,
      ),
    ),
  );
}

void startVideoCall({required String doctorId}) async {
  if (streamVideo == null) return;

  final currentUserId = client.state.currentUser?.id;
  if (currentUserId == null) return;

  final members = [currentUserId, doctorId]..sort();

  final callId = "video_${members[0]}_${members[1]}";

  final call = streamVideo!.makeCall(
    callType: stream_video.StreamCallType.defaultType(),
    id: callId,
  );

  await call.getOrCreate(
    ring: const stream_video.StreamRingSettings(),
  );

  await call.join();

  navigatorKey.currentState!.push(
    MaterialPageRoute(
      builder: (_) => stream_video.StreamCallContainer(
        call: call,
      ),
    ),
  );
}

// --- CUSTOM WIDGET FOR TAB SEGMENT CONTROL ---
class _ConsultSegmentControl extends StatelessWidget {
  final TabController controller;
  final Color selectedColor;
  final Color unselectedColor;
  final List<String> titles;

  const _ConsultSegmentControl({
    required this.controller,
    required this.selectedColor,
    required this.unselectedColor,
    required this.titles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(
            0.5), // Background for the unselected state, similar to dashboard pill background
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.7)),
      ),
      child: Row(
        children: List.generate(titles.length, (index) {
          final isSelected = controller.index == index;
          return Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  if (controller.index != index) {
                    controller.animateTo(index);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: isSelected ? selectedColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    titles[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
