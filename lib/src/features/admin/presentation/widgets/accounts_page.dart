import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:onedrive_netflix/src/features/admin/presentation/widgets/form_widget.dart';
import 'package:onedrive_netflix/src/services/database_service.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode saveFocusNode = FocusNode();

  final DatabaseService _databaseService = DatabaseService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void saveToDatabase() {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();

    if (name.isNotEmpty && email.isNotEmpty) {
      _databaseService
          .saveData('accounts', {'name': name, 'email': email}).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account saved successfully')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save account: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Email cannot be empty')),
      );
    }
  }

  void updateAccount(String key, String name, String email) {
    _databaseService
        .updateData('accounts/$key', {'name': name, 'email': email}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account updated successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update account: $error')),
      );
    });
  }

  void deleteAccount(String key) {
    _databaseService.deleteData('accounts/$key').then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildAccountList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return FormWidget(
              nameController: _nameController,
              emailController: _emailController,
              nameFocusNode: nameFocusNode,
              emailFocusNode: emailFocusNode,
              saveFocusNode: saveFocusNode,
              onSave: saveToDatabase,
              title: 'Add a new Account',
              buttonText: 'Save',
            );
          },
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildAccountList() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Accounts',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(),
        Expanded(
          child: StreamBuilder(
            stream: _databaseService.getDataStream('accounts').onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading accounts'));
              } else if (!snapshot.hasData ||
                  snapshot.data!.snapshot.value == null) {
                return const Center(child: Text('No accounts found'));
              } else {
                Map<dynamic, dynamic> accountsMap =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                List<dynamic> accountsList = accountsMap.entries.toList();

                return ListView.builder(
                  itemCount: accountsList.length,
                  itemBuilder: (context, index) {
                    final account = accountsList[index].value;
                    final accountKey = accountsList[index].key;
                    return Column(
                      children: [
                        ListTile(
                          title: Text(account['name']),
                          subtitle: Text(account['email']),
                          leading: CircleAvatar(
                            child: Text(
                              account['name'][0].toUpperCase(),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _nameController.text = account['name'];
                                  _emailController.text = account['email'];
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return FormWidget(
                                        nameController: _nameController,
                                        emailController: _emailController,
                                        nameFocusNode: nameFocusNode,
                                        emailFocusNode: emailFocusNode,
                                        saveFocusNode: saveFocusNode,
                                        onSave: () {
                                          updateAccount(
                                              accountKey,
                                              _nameController.text.trim(),
                                              _emailController.text.trim());
                                        },
                                        title: 'Edit Account',
                                        buttonText: 'Update',
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  deleteAccount(accountKey);
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
