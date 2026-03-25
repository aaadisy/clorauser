import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream_chat_flutter;
import '../../extensions/text_styles.dart';
import '../../service/permission_service.dart';
import '../../utils/app_common.dart';
import 'chat_users_detail_screen.dart';
import '../../main.dart'; // To access global client and userStore
import '../../extensions/extensions.dart'; // To import missing int.height extension

class ChatUsersListScreen extends StatefulWidget {
  const ChatUsersListScreen({super.key});

  @override
  State<ChatUsersListScreen> createState() => _ChatUsersListScreenState();
}

class _ChatUsersListScreenState extends State<ChatUsersListScreen> {
  // Store the connection status locally
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    // Start connection check after the first frame to ensure inherited widgets are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAndConnectUser();
      }
    });
  }

  void _checkAndConnectUser() {
    try {
      final currentUser =
          stream_chat_flutter.StreamChat.of(context).currentUser;

      if (userStore.isLoggedIn && currentUser == null) {
        _connectUserToChat();
      }
    } catch (e) {
      log("Error checking Stream Chat user: $e");
    }
  }

  /// Handles the entire chat initiation flow, including permissions.
  Future<void> _startChatWithUser(
      stream_chat_flutter.User targetUser) async {
    // 1. Request permissions before starting chat.
    final permissionsGranted =
        await PermissionService.requestCommunicationPermissions(context);
    if (!permissionsGranted || !mounted) return;

    // Show an immediate loading indicator for a seamless experience.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final currentUser =
          stream_chat_flutter.StreamChat.of(context).currentUser;
      if (currentUser == null || targetUser.id == null) {
        throw Exception("Current or target user is invalid.");
      }

      // --- LOGGING START ---
      final patientStreamId = currentUser.id;
      final doctorStreamId = targetUser.id!;
      final channelId = 'chat_${patientStreamId}_$doctorStreamId';

      log('Patient Stream user ID: $patientStreamId');
      log('Doctor Stream user ID: $doctorStreamId');
      log('Generated channel ID: $channelId');
      // --- LOGGING END ---

      // 2. Generate or connect to the one-to-one channel.
      final channel = client.channel(
        'messaging',
        extraData: {
          'members': [currentUser.id, targetUser.id!],
        },
      );

      // 3. Create the channel if it's new, or open it if it exists.
      await channel.watch();

      // All checks and setup are complete.
      // Dismiss the loading indicator.
      if (mounted) {
        Navigator.of(context, rootNavigator: true)
            .pop(); // Use rootNavigator to pop the dialog
      }

      // 4. Seamlessly navigate to the chat screen.
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatUsersDetailScreen(
                channel: channel, targetUser: targetUser),
          ),
        );
      }
    } catch (e) {
      // In case of an error, dismiss the loader and log the issue.
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not start chat. Please try again later.'),
        ));
      }
      log("Error starting chat: $e");
    }
  }

  Future<void> _connectUserToChat() async {
    if (_isConnecting) return;

    final userId = userStore.userId;
    final userName = userStore.user?.displayName ?? userStore.user?.firstName ?? 'User';
    final userIdString = userId.toString();
    final streamChatClient = client; // Use global Stream Chat client

    if (userId == 0) {
      log('User ID is 0, cannot connect to Stream Chat.');
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      final token = streamChatClient.devToken(userIdString).rawValue;

      await streamChatClient.connectUser(
        stream_chat_flutter.User(
          id: userIdString,
          name: userName,
          extraData: {
            'image': userStore.user?.profileImage,
          },
        ),
        token,
      );
      log("Stream Chat user connected successfully: User ID $userId");
    } catch (e) {
      log("Stream connect failed: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We use StreamChatBuilder to reactively handle connection status changes
    return stream_chat_flutter.StreamChat(
      client: stream_chat_flutter.StreamChat.of(context).client,
      child: Builder(
        builder: (context) {
          final currentUser =
              stream_chat_flutter.StreamChat.of(context).currentUser;

          if (_isConnecting || (userStore.isLoggedIn && currentUser == null)) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text('Consult',
                    style: boldTextStyle(color: Colors.white, size: 18)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    16.height,
                    Text(
                      'Connecting to chat service...',
                      style: secondaryTextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            );
          }

          if (currentUser == null) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text('Consult',
                    style: boldTextStyle(color: Colors.white, size: 18)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
              ),
              body: Center(
                child: Text(
                  'Cannot load chat: User is not connected to Stream Chat.',
                  style: secondaryTextStyle(color: Colors.white70),
                ),
              ),
            );
          }

          final userListController =
              stream_chat_flutter.StreamUserListController(
            client: stream_chat_flutter.StreamChat.of(context).client,
            filter: stream_chat_flutter.Filter.notEqual('id', currentUser.id),
          );

          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                'Consult',
                style: boldTextStyle(color: Colors.white, size: 18),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
            body: stream_chat_flutter.StreamUserListView(
              controller: userListController,
              itemBuilder: (context, users, index, user) {
                // FIX: Directly using 'user' which should be the model object.
                final streamUser = user as stream_chat_flutter.User;

                return Card(
                  color: Colors.white12,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _startChatWithUser(streamUser),
                    leading: stream_chat_flutter.StreamUserAvatar(
                      user: streamUser,
                      constraints: const BoxConstraints.tightFor(
                        width: 40,
                        height: 40,
                      ),
                    ),
                    title: Text(
                      streamUser.name,
                      style: primaryTextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      streamUser.online ? 'Online' : 'Offline',
                      style: secondaryTextStyle(
                          color: streamUser.online
                              ? Colors.greenAccent
                              : Colors.white70),
                    ),
                  ),
                );
              },
              emptyBuilder: (context) {
                return Center(
                  child: Text(
                    'No other Stream Chat users available for consulting.',
                    style: secondaryTextStyle(color: Colors.white70),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}