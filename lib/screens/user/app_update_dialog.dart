import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/main.dart';
import 'package:clora_user/utils/dynamic_theme.dart';
import 'package:flutter/material.dart';

import '../../utils/app_constants.dart';

class ShakingUpdateDialog extends StatefulWidget {
  @override
  _ShakingUpdateDialogState createState() => _ShakingUpdateDialogState();
}

class _ShakingUpdateDialogState extends State<ShakingUpdateDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500), // Animation duration
    );

    // Create a shaking animation using Tween
    _animation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation when the dialog shows
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value, // Apply the shaking effect
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.system_update_alt,
                  size: 48,
                  color: ColorUtils.colorPrimary,
                ),
                16.height,
                Text(
                  language.timeToUpdate,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                8.height,
                Text(
                  language.weMadeYourAppEvenBetter,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                16.height,
                Text(
                  language.toContinueEnjoyingTheLatestFeaturesAndImprovements,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                24.height,
                ElevatedButton(
                  onPressed: () {
                    launchAppStore();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorUtils.colorPrimary,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    language.updateNow,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                24.height.visible(isCurrentPlatformForceUpdate() == false),
                TextButton(
                  onPressed: () {
                    pop();
                    setValue(IS_UPDATE_POP_DISMISSED, true);
                  },
                  child: Text(
                    language.noThankYou,
                    style: TextStyle(
                      fontSize: 16,
                      color: ColorUtils.colorPrimary,
                    ),
                  ),
                ).visible(isCurrentPlatformForceUpdate() == false),
              ],
            ),
          ),
        );
      },
    );
  }
}
