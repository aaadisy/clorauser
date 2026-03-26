import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../screens/user/view_all_videos_screen.dart';
import '../model/video_category_model.dart';

class VideoSectionWidget extends StatelessWidget {
  final List<VideoCategoryModel> categories;

  const VideoSectionWidget({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: categories.map<Widget>((category) {

        /// ✅ SAFE CHECK
        if (category.videos == null || category.videos!.isEmpty) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 CATEGORY HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /// CATEGORY NAME
                  Text(
                    category.name ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  /// VIEW MORE
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewAllScreen(
                            categoryId: category.id ?? 0,
                            categoryName: category.name ?? '',
                            videos: category.videos ?? [], // ✅ FIXED
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "View More",
                      style: TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),

            /// 🎬 VIDEO LIST
            SizedBox(
              height: 190,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: category.videos!.length, // ✅ FIXED
                itemBuilder: (context, index) {

                  var video = category.videos![index]; // ✅ FIXED

                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// 🎬 THUMBNAIL
                        Stack(
                          alignment: Alignment.center,
                          children: [

                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: video.thumbnailUrl ?? '',
                                height: 110,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(color: Colors.grey[300]),
                                errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                              ),
                            ),

                            /// ▶ PLAY ICON
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// 🎬 TITLE
                        Text(
                          video.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),

                        const SizedBox(height: 4),

                        /// ⏱ DURATION
                        Text(
                          video.duration ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        );

      }).toList(),
    );
  }
}