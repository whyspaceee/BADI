import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:sports_buddy/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:sports_buddy/models/user_model.dart';
import 'package:sports_buddy/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({Key? key, required this.room}) : super(key: key);

  final types.Room room;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  void _handleSendPressed(types.PartialText message) {
    FirebaseChatCore.instance.sendMessage(
      message,
      widget.room.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: orange1,
        elevation: 0,
      ),
      body: StreamBuilder<types.Room>(
        initialData: widget.room,
        stream: FirebaseChatCore.instance.room(widget.room.id),
        builder: (context, snapshot) {
          return StreamBuilder<List<types.Message>>(
            initialData: const [],
            stream: FirebaseChatCore.instance.messages(snapshot.data!),
            builder: (context, snapshot) {
              return SafeArea(
                bottom: false,
                child: Chat(
                  onSendPressed: _handleSendPressed,
                  messages: snapshot.data ?? [],
                  theme: DefaultChatTheme(
                      inputBackgroundColor: gray1,
                      inputTextColor: Colors.black,
                      sendButtonIcon: Icon(
                        Icons.send,
                        color: orange1,
                      ),
                      primaryColor: gray1,
                      sentMessageBodyTextStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.5),
                      receivedMessageBodyTextStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.5)),
                  user: types.User(
                    id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FollowingList extends StatelessWidget {
  const FollowingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    print(user.uid);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: orange1,
          elevation: 0,
          title: const Text('Following'),
        ),
        body: SafeArea(
            child: Container(
          margin: EdgeInsets.all(15),
          padding: EdgeInsets.all(15),
          child: FutureBuilder(
            future: context.read<FirestoreService>().getFollowing(user.uid),
            builder: (context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data);
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: ((context, index) {
                      return FutureBuilder(
                          future: context
                              .read<FirestoreService>()
                              .getSingleUser(
                                  user: snapshot.data!.elementAt(index)),
                          builder:
                              (context, AsyncSnapshot<UserModel> userModel) {
                            if (userModel.hasData) {
                              return UsersWidget(userModel.data!);
                            } else {
                              return Container();
                            }
                          });
                    }));
              } else {
                return Container();
              }
            },
          ),
        )));
  }
}

class UsersWidget extends StatelessWidget {
  final UserModel user;
  UsersWidget(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: InkWell(
          child: Ink(
              child: Container(
            child: Row(children: [
              CircleAvatar(foregroundImage: NetworkImage(user.imageUrl!)),
              SizedBox(
                width: 15,
              ),
              Text(user.firstName! + " " + user.lastName!),
            ]),
          )),
        ));
  }
}

class UsersPage extends StatelessWidget {
  const UsersPage({Key? key}) : super(key: key);

  Widget _buildAvatar(types.User user) {
    final hasImage = user.imageUrl != null;
    final name = user.firstName! + " " + user.lastName!;

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundImage: hasImage ? NetworkImage(user.imageUrl!) : null,
        radius: 20,
        child: !hasImage
            ? Text(
                name.isEmpty ? '' : name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
    );
  }

  _handlePressed(types.User otherUser, BuildContext context) async {
    final room = await FirebaseChatCore.instance.createRoom(otherUser);

    Navigator.of(context).pop();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatWidget(
          room: room,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: orange1,
        elevation: 0,
        title: const Text('Users'),
      ),
      body: StreamBuilder<List<types.User>>(
        stream: FirebaseChatCore.instance.users(),
        initialData: const [],
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(
                bottom: 200,
              ),
              child: const Text('No users'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];

              return GestureDetector(
                onTap: () async {
                  await _handlePressed(user, context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _buildAvatar(user),
                      Text(user.firstName! + " " + user.lastName!),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
