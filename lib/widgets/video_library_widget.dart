import 'package:flutter/material.dart';
import '../model/video_category_model.dart';
import '../screens/user/video_player.dart';
import '../screens/user/view_all_videos_screen.dart';

class VideoLibraryWidget extends StatefulWidget {
  final List<VideoCategoryModel> categories;

  const VideoLibraryWidget({Key? key, required this.categories}) : super(key: key);

  @override
  State<VideoLibraryWidget> createState() => _VideoLibraryWidgetState();
}

class _VideoLibraryWidgetState extends State<VideoLibraryWidget> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) return const SizedBox.shrink();

    var selectedCategory = widget.categories[selectedIndex];
    var videos = selectedCategory.videos ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Video Library", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                child: const Text("View All", style: TextStyle(color: Colors.pink, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          /// Category Pills
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
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFDE2F3) : const Color(0xFFF6F2F8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category.name ?? '',
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.black54, 
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          /// Video Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: videos.length > 2 ? 2 : videos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              var video = videos[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayScreen(url: video.videoUrl ?? ''))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AspectRatio(
                            aspectRatio: 16 / 10,
                            child: Image.network(video.thumbnailUrl ?? '', fit: BoxFit.cover),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(video.title ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
