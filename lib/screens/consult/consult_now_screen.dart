import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import '../../utils/stream_chat_helper.dart';
import 'package:intl/intl.dart';

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
  final String doctorId;
  final String doctorName;
  final String consultationType;
  final String status;
  final String amount;
  final String? pdfPath;
  final String createdAt;

  MyConsultationModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.consultationType,
    required this.status,
    required this.amount,
    required this.createdAt,
    this.pdfPath,
  });

  factory MyConsultationModel.fromJson(Map<String, dynamic> json) {
    return MyConsultationModel(
      id: json['id'],
      doctorId: json['doctor_id'].toString(),
      doctorName: json['doctor_name'] ?? '',
      consultationType: json['consultation_type'] ?? '',
      status: json['status'] ?? '',
      amount: json['amount'].toString(),
      pdfPath: json['pdf_path'],
      createdAt: json['created_at'] ?? '',
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
        totalReviews = int.tryParse(
            json['total_reviews']?.toString() ?? '0');

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

  final List<String> _categories = [
    "All",
    "Gynecologist",
    "Endocrinologist",
    "Dermatologist",
    "Therapist",
  ];
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
      if (_tabController.index == 1) {
        _fetchMyConsultations();
      }
    });

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

  Future<void> _fetchDoctors({bool isLoadMore = false}) async {
    if (!isLoadMore) {
      setState(() {
        _isLoadingDoctors = true;
        _hasError = false;
      });
    }

    try {
      final response =
      await ConsultService.fetchDoctorList(_currentPage);

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
        Uri.parse(
            "https://apis.getclora.com/api/user/myconsultation"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data =
        decoded['responseData']['data'] as List;

        setState(() {
          _consultations = data
              .map((e) =>
              MyConsultationModel.fromJson(e))
              .toList();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Consult Doctors"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorUtils.colorPrimary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Doctors"),
            Tab(text: "Reports"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDoctorsTab(),
          _buildReportsTab(),
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

      final name =
          doctor.healthExpert?.displayName?.toLowerCase() ?? "";

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
                      builder: (_) =>
                          DoctorDetailScreen(doctor: doc),
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

  /// ============================
  /// REPORTS TAB
  /// ============================

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
        final item = _consultations[index];

        /// ------------------ DATE (IST) ------------------
        DateTime parsedDate = DateTime.parse(item.createdAt).toUtc();
        DateTime indianTime =
        parsedDate.add(const Duration(hours: 5, minutes: 30));
        String formattedDate =
        DateFormat('dd MMM yyyy • hh:mm a').format(indianTime);

        /// ------------------ STATUS ------------------
        bool isActive =
            item.status.toLowerCase() == "active";

        Color statusColor;
        String statusText;

        switch (item.status.toLowerCase()) {
          case 'active':
            statusColor = Colors.green;
            statusText = "Active";
            break;
          case 'completed':
            statusColor = Colors.blue;
            statusText = "Completed";
            break;
          case 'pending':
            statusColor = Colors.orange;
            statusText = "Pending";
            break;
          case 'cancelled':
            statusColor = Colors.red;
            statusText = "Cancelled";
            break;
          default:
            statusColor = Colors.grey;
            statusText = item.status;
        }

        return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConsultationDetailScreen(
                    consultation: item,
                  ),
                ),
              );
            },
            child:
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: isActive
                    ? LinearGradient(
                  colors: [
                    ColorUtils.colorPrimary.withOpacity(0.10),
                    Colors.white
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : const LinearGradient(
                  colors: [Colors.white, Colors.white],
                ),
                border: Border.all(
                  color: isActive
                      ? ColorUtils.colorPrimary
                      : Colors.grey.shade200,
                  width: isActive ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TOP ROW
                  Row(
                    children: [

                      /// IMAGE
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                        ColorUtils.colorPrimary.withOpacity(0.15),
                        child: Icon(
                          Icons.person,
                          color: ColorUtils.colorPrimary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            /// NAME
                            Text(
                              item.doctorName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),

                            const SizedBox(height: 2),

                            /// DATE
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      /// STATUS
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// AMOUNT (NOW BELOW STATUS)
                  Row(
                    children: [
                      const Icon(Icons.currency_rupee,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        item.amount,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// ACTION BUTTONS
                  Row(
                    children: [

                      /// VIEW
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.visibility),
                          label: const Text("View"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ConsultationDetailScreen(
                                      consultation: item,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),

                      /// CHAT (ONLY ACTIVE)
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.chat),
                            label: const Text("Chat"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              ColorUtils.colorPrimary,
                            ),
                            onPressed: () {
                              openConsultationChat(
                                context: context,
                                doctorId: item.doctorId,
                                doctorName: item.doctorName,
                              );
                            },
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
        );
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
    DateTime indianTime =
    parsedDate.add(const Duration(hours: 5, minutes: 30));

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
                    color: isActive
                        ? ColorUtils.colorPrimary
                        : Colors.transparent,
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
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Date"),
                        Text(formattedDate),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Amount"),
                        Text("₹${consultation.amount}"),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
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
                    backgroundColor: isActive
                        ? ColorUtils.colorPrimary
                        : Colors.grey,
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
        index < rating
            ? Icons.star
            : Icons.star_border,
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: doctor!.healthExpertsImage != null
                ? Image.network(
              doctor!.healthExpertsImage!,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            )
                : Container(
              height: 80,
              width: 80,
              color: Colors.grey.shade200,
              child: const Icon(Icons.person, size: 40),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// NAME > CLINIC
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        doctor!.displayName ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      doctor!.hospitalName ?? "",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 4),

                /// EDUCATION
                Text(
                  doctor!.qualification ?? "",
                  style: const TextStyle(fontSize: 12),
                ),

                const SizedBox(height: 8),

                /// EXPERIENCE > FEE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Row(
                      children: [
                        const Icon(Icons.work_outline,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          "${doctor!.experience ?? 0} yrs exp",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        const Icon(Icons.currency_rupee,
                            size: 14, color: Colors.grey),
                        Text(
                          "${doctor!.fee ?? 0}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                /// CONSULTATIONS > RATING
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      "${doctor!.totalReviews ?? 0} consultations",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),

                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 14, color: Colors.orange),
                        const SizedBox(width: 3),
                        Text(
                          "${doctor!.averageRating ?? 0}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                /// LOCATION
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(
                      doctor!.city ?? "",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// BOOK NOW BUTTON
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => onConsultNowTap(doctor!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorUtils.colorPrimary,
                      minimumSize: const Size(90, 34),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Book Now",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                )
              ],
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
            throw Exception('Order creation failed: Missing order_id or amount.');
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
          );


        } else {
          throw Exception(verificationData['message'] ?? 'Verification failed');
        }

      } else {
        throw Exception(
            'Verification API error: ${verifyResponse.statusCode}');
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
    return GlassContainer(
      // 2️⃣ Replaced Card with GlassContainer
      borderRadius: 20.0,
      baseColor:
          ColorUtils.PRIMARY_CREAM.withOpacity(0.4), // Cream base for card
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor:
                  Colors.white.withOpacity(0.4), // Translucent white
              child: Icon(Icons.person,
                  color: ColorUtils.colorPrimary.withOpacity(0.8)),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctor.displayName ?? 'Doctor Unknown',
                    style: boldTextStyle(
                        color: Colors.black.withOpacity(0.8), size: 20),
                  ),
                  Text(
                    widget.doctor.tagLine ?? 'General Practitioner',
                    style: secondaryTextStyle(
                        color: Colors.black.withOpacity(0.6), size: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: secondaryTextStyle(
                  color: Colors.black.withOpacity(0.7), size: 16)),
          Text(value,
              style: primaryTextStyle(
                  color: Colors.black.withOpacity(0.8), size: 16)),
        ],
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