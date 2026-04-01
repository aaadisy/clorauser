import 'package:flutter/material.dart';
import '../model/video_category_model.dart';
import '../screens/user/video_player.dart';
import '../screens/user/view_all_videos_screen.dart';

class VideoHomeWidget extends StatefulWidget {
  final List<VideoCategoryModel> categories;

  const VideoHomeWidget({Key? key, required this.categories}) : super(key: key);

  @override
  State<VideoHomeWidget> createState() => _VideoHomeWidgetState();
}

class _VideoHomeWidgetState extends State<VideoHomeWidget> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) return const SizedBox.shrink();

    var selectedCategory = widget.categories[selectedIndex];
    var videos = selectedCategory.videos ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🔥 HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Video Library",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewAllScreen(
                      categoryId: selectedCategory.id ?? 0,
                      categoryName: selectedCategory.name ?? '',
                      videos: videos,
                    ),
                  ),
                );
              },
              child: const Text(
                "View All",
                style: TextStyle(color: Colors.pink, fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),

        const SizedBox(height: 12),

        /// 🔥 CATEGORY PILLS
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              var category = widget.categories[index];
              bool isSelected = index == selectedIndex;

              return GestureDetector(
                onTap: () => setState(() => selectedIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFDE2F3)
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      category.name ?? '',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        /// 🔥 GRID VIDEOS (MAIN FIX)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videos.length > 4 ? 4 : videos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            var video = videos[index];

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayScreen(url: video.videoUrl ?? ''),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 🔥 THUMBNAIL
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          video.thumbnailUrl ?? '',
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),

                        /// PLAY BUTTON
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.85),
                          ),
                          child: const Icon(Icons.play_arrow, size: 18),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// 🔥 TITLE
                  Text(
                    video.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}