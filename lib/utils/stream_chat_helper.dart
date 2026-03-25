import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../main.dart';
import '../screens/user/chat_users_detail_screen.dart';

Future<void> openConsultationChat({
  required BuildContext context,
  required String doctorId,
  required String doctorName,
}) async {

  final currentUser = client.state.currentUser?.id;

  if (currentUser == null) {
    print("Stream user not connected");
    return;
  }

  final members = [
    currentUser,
    doctorId,
  ]..sort();

  final channelId = "chat_${members[0]}_${members[1]}";

  final channel = client.channel(
    'messaging',
    id: channelId,
    extraData: {
      "members": members,
    },
  );

  /// ⭐ getOrCreate instead of create/watch
  await channel.watch();

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatUsersDetailScreen(
        channel: channel,
        targetUser: User(
          id: doctorId,
          name: doctorName,
        ),
      ),
    ),
  );
}