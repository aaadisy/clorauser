import 'package:flutter/material.dart';
import '../../model/video_category_model.dart';
import '../../model/video_model.dart';
import '../user/video_player.dart';

class ViewAllScreen extends StatelessWidget {
  final int categoryId;
  final String categoryName;
  final List<VideoModel> videos;

  const ViewAllScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    required this.videos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
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

                /// THUMBNAIL
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      video.thumbnailUrl ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
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
    );
  }
}