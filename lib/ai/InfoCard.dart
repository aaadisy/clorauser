import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/extensions/new_colors.dart';
import 'package:clora_user/utils/app_images.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String description;
  final int? index;
  final Function(String)? onClick;

  InfoCard({
    super.key,
    required this.description,
    this.onClick,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClick?.call(description);
      },
      child: Container(
        decoration: BoxDecoration(
          color: mainColorLight,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                ic_starlight,
                width: 22,
                height: 26,
              ),
              16.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    4.height,
                    Text(
                      description,
                      style: boldTextStyle(
                          weight: FontWeight.w500,
                          size: 15,
                          color: mainColorText),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
