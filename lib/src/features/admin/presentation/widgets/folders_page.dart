import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:onedrive_netflix/src/models/account.model.dart';
import 'package:onedrive_netflix/src/services/database_service.dart';

class FoldersPage extends StatefulWidget {
  const FoldersPage({super.key});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  List<Account> accounts = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _accountIdController = TextEditingController();

  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    loadAccounts();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _accountIdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildFoldersBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: accounts.isEmpty
            ? () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No accounts found. Please add an account.'),
                  ),
                )
            : () => addFolderFloatingButton(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<dynamic> addFolderFloatingButton(BuildContext context,
      {String? folderId}) {
    if (folderId != null) {
      // Load folder data for editing
      _databaseService.getData('folders/$folderId').then((snapshot) {
        if (snapshot.value != null) {
          var folderData = snapshot.value as Map;
          _nameController.text = folderData['name'];
          _accountIdController.text = folderData['accountId'];
        }
      });
    } else {
      _nameController.clear();
      _accountIdController.clear();
    }

    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Form(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    folderId == null ? 'Add Folder' : 'Edit Folder',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Enter folder name and choose account.'),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Folder Name',
                    ),
                    controller: _nameController,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text('Choose Account: '),
                      const SizedBox(width: 10),
                      DropdownMenu(
                        enableSearch: true,
                        enableFilter: true,
                        width: 200,
                        dropdownMenuEntries:
                            UnmodifiableListView<DropdownMenuEntry<String>>(
                          accounts.map<DropdownMenuEntry<String>>(
                            (Account acc) => DropdownMenuEntry<String>(
                                value: acc.id, label: acc.name),
                          ),
                        ),
                        initialSelection: accounts.first.id,
                        onSelected: (String? value) {
                          _accountIdController.text = value!;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (folderId == null) {
                            saveFolder();
                          } else {
                            updateFolder(folderId);
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  void loadAccounts() async {
    print('Loading accounts');
    DatabaseService service = DatabaseService();
    var snapshot = await service.getDataList('accounts');
    print(snapshot.value);

    List<Account> accounts = [];
    if (snapshot.value == null) {
      setState(() {
        this.accounts = accounts;
      });
      return;
    }

    (snapshot.value as Map).forEach((key, value) {
      accounts.add(Account.fromMap(key, value));
    });

    setState(() {
      this.accounts = accounts;
      _accountIdController.text = accounts.first.id;
    });
  }

  void saveFolder() {
    String name = _nameController.text.trim();
    String accountId = _accountIdController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Folder name is required.'),
        ),
      );

      // pop the modal sheet
      Navigator.pop(context);
      return;
    }

    if (accountId.isEmpty) {
      accountId = accounts.first.id;
    }

    DatabaseService service = DatabaseService();

    service.saveData('folders', {
      'name': name,
      'accountId': accountId,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Folder saved successfully.'),
        ),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save folder: $error'),
        ),
      );
    });

    loadFolders();
  }

  void updateFolder(String folderId) {
    String name = _nameController.text.trim();
    String accountId = _accountIdController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Folder name is required.'),
        ),
      );
      return;
    }

    if (accountId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account is required.'),
        ),
      );
      return;
    }

    DatabaseService service = DatabaseService();

    service.updateData('folders/$folderId', {
      'name': name,
      'accountId': accountId,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Folder updated successfully.'),
        ),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update folder: $error'),
        ),
      );
    });

    loadFolders();
  }

  void deleteFolder(String folderId) {
    DatabaseService service = DatabaseService();

    service.deleteData('folders/$folderId').then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Folder deleted successfully.'),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete folder: $error'),
        ),
      );
    });

    loadFolders();
  }

  buildFoldersBody() {
    return StreamBuilder(
      stream: _databaseService.getDataStream('folders').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading folders'));
        } else if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('No folders found'));
        } else {
          Map<dynamic, dynamic> accountsMap =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<dynamic> folders = accountsMap.entries.toList();
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Folders',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: folders.length,
                  itemBuilder: (BuildContext context, int index) {
                    final folderId = folders[index].key;
                    final folderName = folders[index].value['name'];
                    final accountId = folders[index].value['accountId'];
                    final accountName = accounts
                        .firstWhere((element) => element.id == accountId)
                        .name;
                    return Column(
                      children: [
                        ListTile(
                          title: Text(folderName),
                          subtitle: Text(accountName),
                          leading: const Icon(Icons.folder),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => addFolderFloatingButton(
                                    context,
                                    folderId: folderId),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => deleteFolder(folderId),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  loadFolders() {
    DatabaseService service = DatabaseService();
    return service.getDataList('folders').then((snapshot) {
      if (snapshot.value == null) {
        return [];
      }

      List folders = [];
      (snapshot.value as Map).forEach((key, value) {
        folders.add(value);
      });

      return folders;
    });
  }
}
