
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:onedrive_netflix/src/models/user.model.dart';
import 'package:onedrive_netflix/src/services/database_service.dart';
import 'package:talker/talker.dart';

class NotificationButton extends StatefulWidget {
  const NotificationButton({
    super.key,
  });

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  final DatabaseService _databaseService = DatabaseService();
  final Talker _talker = Talker();
  List<User> usersList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
    _talker.info('dispose');
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) => Dialog.fullscreen(
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Notifications',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const Divider(),
                      if (isLoading)
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (usersList.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text('No users found'),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: usersList.length,
                            itemBuilder: (context, index) {
                              final userData = usersList[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage:
                                      userData.photoUrl.toString().isNotEmpty
                                          ? NetworkImage(userData.photoUrl)
                                          : null,
                                  child: userData.photoUrl.toString().isEmpty
                                      ? Text(userData.name[0].toUpperCase())
                                      : null,
                                ),
                                title: Text(userData.name),
                                subtitle: Text(userData.email),
                                trailing: SizedBox(
                                  width: 100,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          await _databaseService.updateData(
                                              'users/${userData.id}', {
                                            'status': UserStatus.approved
                                                .toString()
                                                .split('.')
                                                .last
                                          });
                                          await _loadData();
                                          setState(
                                              () {}); // Rebuild dialog with new data
                                        },
                                        icon: const Icon(Icons.check),
                                        focusColor: const Color.fromARGB(
                                            255, 63, 118, 0),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          await _databaseService.updateData(
                                              'users/${userData.id}', {
                                            'status': UserStatus.rejected
                                                .toString()
                                                .split('.')
                                                .last
                                          });
                                          await _loadData();
                                          setState(
                                              () {}); // Rebuild dialog with new data
                                        },
                                        icon: const Icon(Icons.close),
                                        focusColor: Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
        _loadData(); // Load data after showing dialog
      },
      icon: const Icon(
        Icons.notifications,
      ),
    );
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    _talker.info('Loading users in notification button');

    try {
      final DataSnapshot users = await _databaseService.getData('users');
      if (users.value != null) {
        final usersMap = users.value as Map<dynamic, dynamic>;

        List<User> usersList = [];
        usersMap.forEach((key, value) {
          if (value['status'] ==
                  UserStatus.pending.toString().split('.').last &&
              value['isAdmin'] == false) {
            usersList.add(User.fromMap(value, key));
          }
        });

        setState(() {
          this.usersList = usersList;
          isLoading = false;
        });
      } else {
        setState(() {
          usersList = [];
          isLoading = false;
        });
      }
    } catch (e) {
      _talker.error('Error loading users: $e');
      setState(() {
        usersList = [];
        isLoading = false;
      });
    }

    _talker.info('Users loaded in notification button');
  }
}
