import 'package:auto_size_text/auto_size_text.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/utils/app_images.dart';
import 'package:flutter/material.dart';

import '../../extensions/new_colors.dart';
import '../../utils/app_common.dart';
import '../user/home_screen.dart';

class InsightDisplayContainers extends StatelessWidget {
  final Function()? onTap;
  final String? image;
  final String? title;

  const InsightDisplayContainers(
      {Key? key, this.onTap, this.image, this.title});

  @override
  Widget build(BuildContext context) {
    if (image!.contains(ic_default)) {
      return Container(
        padding: EdgeInsets.zero,
        height: kInsightHeight,
        width: kInsightWidth,
        decoration: BoxDecoration(
          color: getRandomColor(),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            randomPosition(ic_leaf),
            Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return AutoSizeText(
                      title ?? "",
                      style: boldTextStyle(
                        size: 16,
                        weight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      minFontSize: 14,
                      stepGranularity: 1,
                      maxFontSize: 16,
                      wrapWords: false,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ).onTap(onTap);
    }

    return Container(
      height: kInsightHeight,
      width: kInsightWidth,
      decoration: BoxDecoration(
        color: mainWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: kInsightWidth,
            height: kInsightHeight,
            child: cachedImage(
              image,
              fit: insightBoxFit,
            ),
          ),
        ),
      ),
    ).onTap(onTap);
  }
}
