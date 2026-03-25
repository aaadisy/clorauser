import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../extensions/text_styles.dart';
import '../consult/consult_now_screen.dart'; //  startAudioCall aur startVideoCall hai

class ChatUsersDetailScreen extends StatelessWidget {
  final Channel channel;
  final User targetUser;

  const ChatUsersDetailScreen({
    required this.channel,
    required this.targetUser,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamChannel(
      channel: channel,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            targetUser.name ?? "User",
            style: boldTextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,

          /// 👇 CALL BUTTONS
          actions: [

            /// AUDIO CALL
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: () {
                startAudioCall(
                  doctorId: targetUser.id,
                );
              },
            ),

            /// VIDEO CALL
            IconButton(
              icon: const Icon(Icons.videocam),
              onPressed: () {
                startVideoCall(
                  doctorId: targetUser.id,
                );
              },
            ),

          ],
        ),

        body: Column(
          children: [
            Expanded(
              child: StreamMessageListView(),
            ),
            StreamMessageInput(),
          ],
        ),
      ),
    );
  }
}