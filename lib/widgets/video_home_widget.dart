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
    var selectedCategory = widget.categories[selectedIndex];
    var videos = selectedCategory.videos;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔥 HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Text(
                  selectedCategory.name ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                    "View More",
                    style: TextStyle(color: Colors.pink),
                  ),
                )
              ],
            ),
          ),

          /// 🔝 CATEGORY SCROLL (with thumbnail)
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
                var category = widget.categories[index];
                bool isSelected = index == selectedIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.pink : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [

                        /// IMAGE (FIXED RATIO)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 1.6, // 🔥 fix overlap
                            child: Image.network(
                              category.thumbnailUrl ?? '',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        /// NAME
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            category.name ?? '',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          /// 🎬 VIDEO GRID (WITH THUMBNAIL FIXED)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: videos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              var video = videos[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPlayScreen(
                        url: video.videoUrl ?? '',
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// THUMBNAIL (FIXED)
                    Stack(
                      alignment: Alignment.center,
                      children: [

                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9, // 🔥 FIX OVERFLOW
                            child: Image.network(
                              video.thumbnailUrl ?? '',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        /// PLAY ICON
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

                    const SizedBox(height: 6),

                    /// TITLE
                    Text(
                      video.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}