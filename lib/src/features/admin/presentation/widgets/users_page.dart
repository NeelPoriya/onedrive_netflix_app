import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:onedrive_netflix/src/models/user.model.dart';
import 'package:onedrive_netflix/src/services/database_service.dart';
import 'package:onedrive_netflix/src/utils/extensions.dart';
import 'package:talker/talker.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Users',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(),
        Expanded(child: UsersListView()),
      ],
    );
  }
}

class UsersListView extends StatefulWidget {
  const UsersListView({
    super.key,
  });

  @override
  State<UsersListView> createState() => _UsersListViewState();
}

class _UsersListViewState extends State<UsersListView> {
  final DatabaseService _databaseService = DatabaseService();

  final Talker talker = Talker();

  UserStatus status = UserStatus.created;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _databaseService
          .getDataStreamWithFilter('users', 'isAdmin', false)
          .onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error in getting users'),
          );
        } else if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(
            child: Text('No users found'),
          );
        } else {
          Map<dynamic, dynamic> usersMap =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<dynamic> usersList = usersMap.entries.toList();

          return ListView.builder(
            itemCount: usersList.length,
            itemBuilder: (context, index) {
              final user = usersList[index].value;
              final userKey = usersList[index].key;

              return Column(
                children: [
                  ListTile(
                    title: Text(user['name']),
                    subtitle: Text(user['email']),
                    trailing: DropdownMenu(
                      dropdownMenuEntries: List<DropdownMenuEntry>.from(
                        UserStatus.values.map(
                          (status) => DropdownMenuEntry(
                            value: status,
                            label:
                                status.toString().split('.').last.toTitleCase(),
                          ),
                        ),
                      ),
                      initialSelection: UserStatus.values.firstWhere(
                        (status) =>
                            status.toString().split('.').last == user['status'],
                        orElse: () => UserStatus.created,
                      ),
                      onSelected: (dynamic status) async {
                        UserStatus newStatus = status as UserStatus;

                        talker.info('Updating user status to $newStatus');

                        await _databaseService.updateData(
                          'users/$userKey',
                          {
                            'status': status.toString().split('.').last,
                            'updatedAt': DateTime.now().toIso8601String()
                          },
                        );

                        talker.info('User status updated to $newStatus');

                        if (context.mounted) {
                          // toast success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'User status updated to ${newStatus.toString().split('.').last.toTitleCase()}'),
                            ),
                          );
                        }

                        setState(() {
                          this.status = newStatus;
                        });
                      },
                    ),
                  ),
                  const Divider(),
                ],
              );
            },
          );
        }
      },
    );
  }
}
