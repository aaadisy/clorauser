import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/string_extensions.dart';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/extensions/new_colors.dart';
import 'package:clora_user/model/user/question_model.dart';
import 'package:clora_user/screens/user/about_screen.dart';
import 'package:clora_user/screens/user/inter_settings_screen.dart';
import 'package:clora_user/screens/user/period_prediction_screen.dart';
import 'package:clora_user/screens/user/processing_screen.dart';
import 'package:clora_user/screens/user/reminders/cycle_reminder_screen.dart';
import 'package:clora_user/screens/user/reminders/deafult_reminder_setting_screen.dart';
import 'package:clora_user/screens/user/reminders/secret_reminder_screen.dart';
import 'package:clora_user/screens/user/secret_chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:terminate_restart/terminate_restart.dart';

import '../../components/common/settings_components.dart';
import '../../extensions/colors.dart';
import '../../extensions/common.dart';
import '../../extensions/confirmation_dialog.dart';
import '../../extensions/constants.dart';
import '../../extensions/loader_widget.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../network/rest_api.dart';
import '../../service/reminder_service.dart';
import '../../utils/custom_dialog.dart';
import '../../utils/dynamic_theme.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/utils.dart';
import 'faq_screen.dart';
import 'home_screen.dart';
import 'user_edit_profile_screen.dart';
import 'ask_expert_list_screen.dart';
import 'bookmark_screen.dart';
import 'calculator/calculator_screen.dart';
import 'user_dashboard_screen.dart';
import 'graphs_reports_screen.dart';
import '../../model/reminder_model.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF6F6F6),
      bottomNavigationBar: _bottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔹 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade200,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.notifications_none),
                  )
                ],
              ),

              SizedBox(height: 20),

              /// 🔹 Profile Card
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [

                        /// 🔹 Profile Image CLICKABLE
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfileScreen(),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 35,
                            backgroundImage: NetworkImage(
                                userStore.user?.profileImage ?? ''),
                          ),
                        ),

                        /// 🔹 Edit Icon CLICKABLE (TOP RIGHT)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditProfileScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.edit, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    Text(
                      "${userStore.user?.firstName ?? ''} ${userStore.user?.lastName ?? ''}",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    SizedBox(height: 4),

                    Text("Age: 27  UID: 63511133"),
                    Text(userStore.user?.phone ?? ''),

                    SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _infoCard("CYCLE DAY", "2"),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _infoCard("MOOD", "?"),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              SizedBox(height: 20),

              /// 🔹 Account Settings
              Text("Account Settings",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),

              SizedBox(height: 10),

              _menuItem(Icons.history, "Order History"),
              _menuItem(Icons.location_on, "Saved Address"),
              _menuItem(Icons.help_outline, "Support"),

              SizedBox(height: 20),

              /// 🔹 Legal & Privacy
              Text("Legal & Privacy",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),

              SizedBox(height: 10),

              _menuItem(Icons.gavel, "Terms & Conditions"),
              _menuItem(Icons.privacy_tip, "Privacy Policy"),

              SizedBox(height: 20),

              /// 🔹 Logout
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Logout",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Menu Item
  Widget _menuItem(IconData icon, String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, color: Colors.black54),
          ),
          SizedBox(width: 12),
          Expanded(child: Text(title)),
          Icon(Icons.arrow_forward_ios, size: 16)
        ],
      ),
    );
  }

  /// 🔹 Info Card
  Widget _infoCard(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(height: 6),
          Text(value,
              style:
              TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// 🔹 Bottom Nav
  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: 3,
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.home), label: "HOME"),
        BottomNavigationBarItem(
            icon: Icon(Icons.medical_services), label: "CONSULT"),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag), label: "SHOP"),
        BottomNavigationBarItem(
            icon: Icon(Icons.person), label: "PROFILE"),
      ],
    );
  }
}


