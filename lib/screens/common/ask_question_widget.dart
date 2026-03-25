import 'package:clora_user/extensions/colors.dart';
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/new_colors.dart';
import 'package:clora_user/extensions/text_styles.dart';
import 'package:clora_user/main.dart';
import 'package:clora_user/model/user/user_models/user_model.dart';
import 'package:clora_user/screens/common/fullscreen_image_content_screen.dart';
import 'package:clora_user/utils/dynamic_theme.dart';
import 'package:clora_user/utils/utils.dart';
import 'package:flutter/material.dart';
import '../../extensions/constants.dart';
import '../../extensions/decorations.dart';
import '../../model/doctor/doctor_models/health_expert_model.dart';
import 'expandable_text.dart';

class QuestionAnswerCard extends StatelessWidget {
  final String title;
  final String? flow;
  final List<dynamic>? images;
  final String description;
  final String? expertAnswer;
  final String askedOn;
  final String? ansOnDoctor;
  final UserModel? user;
  final HealthExpertData? expert;
  final Function()? onClick;
  final bool showEditTextField;
  final TextEditingController? editAnswerController;
  final VoidCallback? onEditTap;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  QuestionAnswerCard({
    required this.title,
    required this.description,
    this.expertAnswer,
    required this.user,
    this.expert,
    required this.askedOn,
    this.ansOnDoctor,
    this.flow,
    this.onClick,
    this.images,
    this.showEditTextField = false,
    this.editAnswerController,
    this.onEditTap,
    this.onSave,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Question Section
            Stack(
              children: [
                if (flow == "MyQuestions") ...[
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        onClick?.call();
                      },
                      child: Icon(Icons.delete, size: 20, color: Colors.red),
                    ),
                  ),
                ],
                CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: ClipOval(
                    child: cachedImage(
                      user?.profileImage ?? "",
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      usePlaceholderIfUrlEmpty: true,
                    ),
                  ),
                ),
                Row(
                  children: [
                    50.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: boldTextStyle(
                                size: textFontSize_14,
                                weight: FontWeight.w400,
                                color: mainColorText),
                          ),
                          4.height,
                          Text(
                            "${language.askedOn} ${convertUtcToLocal(askedOn)}",
                            style: boldTextStyle(
                                size: textFontSize_12,
                                weight: FontWeight.w400,
                                color: mainColorBodyText),
                          ),
                        ],
                      ),
                    ),
                    if (flow == "MyQuestions") ...[
                      SizedBox(width: 15),
                    ],
                  ],
                ),
              ],
            ),
            Divider(),
            ExpandableText(
              style:
                  boldTextStyle(size: textFontSize_14, weight: FontWeight.w500),
              text: description,
            ),
            SizedBox(height: 10),
            ScrollableNetworkImageRow(
              imageFiles: images ?? [],
              title: user?.displayName ?? '',
            ),
            10.height,
            // Doctor Response Section (Visible only if answered)
            if (expert?.name != null && expertAnswer != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  10.height,
                  Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.purple,
                        child: ClipOval(
                          child: cachedImage(
                            expert?.healthExpertsImage,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                            usePlaceholderIfUrlEmpty: true,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(width: 49),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Doctor Name
                                InkWell(
                                  onTap: () {
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            language.yourAnswer,
                                            style: boldTextStyle(
                                                size: textFontSize_14,
                                                weight: FontWeight.w500,
                                                color: mainColorText),
                                          ),
                                          Spacer(),
                                          GestureDetector(
                                            onTap: onEditTap,
                                            child: Text(
                                              language.edit,
                                              style: boldTextStyle(
                                                  size: textFontSize_14,
                                                  weight: FontWeight.w500,
                                                  color: primaryColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        convertUtcToLocal(ansOnDoctor ?? ''),
                                        style: boldTextStyle(
                                            size: textFontSize_12,
                                            weight: FontWeight.w500,
                                            color: mainColorBodyText),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  if (!showEditTextField)
                    ExpandableText(
                      text: expertAnswer!,
                      style: boldTextStyle(
                          size: textFontSize_14,
                          weight: FontWeight.w500,
                          color: mainColorText),
                    ),
                  if (showEditTextField)
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: bgColor,
                          borderRadius: radius(defaultRadius),
                        ),
                        child: TextField(
                          maxLines: 4,
                          controller: editAnswerController,
                          decoration: InputDecoration(
                            hintText: language.edit,
                            hintStyle: boldTextStyle(
                              size: textFontSize_14,
                              weight: FontWeight.w400,
                              color: mainColorBodyText,
                            ),
                            border: InputBorder.none,
                          ),
                          style: boldTextStyle(size: textFontSize_14),
                        ),
                      ),
                    ),
                  SizedBox(height: showEditTextField ? 16 : 0),
                  if (showEditTextField)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: onSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorUtils.colorPrimary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: Icon(Icons.send, size: 18),
                          label: Text(
                            language.save,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: onCancel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: Icon(Icons.cancel, size: 18),
                          label: Text(
                            language.cancel,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class ScrollableNetworkImageRow extends StatefulWidget {
  final List<dynamic> imageFiles;
  final String? title;

  ScrollableNetworkImageRow({super.key, required this.imageFiles, this.title});

  @override
  _ScrollableNetworkImageRowState createState() =>
      _ScrollableNetworkImageRowState();
}

class _ScrollableNetworkImageRowState extends State<ScrollableNetworkImageRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                widget.imageFiles.length,
                (index) => Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          showFullScreenDialog(context, widget.imageFiles,
                              widget.title ?? '', index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.imageFiles[index],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
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
      ],
    );
  }

  void showFullScreenDialog(BuildContext context, List<dynamic>? imageUrl,
      String? userName, int? index) {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return FullScreenDialogContent(
            imageUrls: imageUrl,
            userName: userName,
            index: index,
          );
        },
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return FadeTransition(opacity: animation, child: child);
        }));
  }
}
