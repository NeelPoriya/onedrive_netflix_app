import 'package:flutter/material.dart';
import 'package:onedrive_netflix/src/services/sync_service.dart';

class SyncPage extends StatelessWidget {
  SyncPage({super.key});

  final SyncService _syncService = SyncService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Sync',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Center(
            child: IconButton(
              onPressed: () async {
                if (_syncService.isRunning) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sync is already running...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                if (!context.mounted) return;

                // snackbar for starting sync
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Syncing...'),
                    duration: Duration(seconds: 2),
                  ),
                );

                await _syncService.sync();

                // snackbar for sync completed
                if(!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sync completed'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              iconSize: 200,
              icon: Icon(Icons.sync),
            ),
          ),
        ),
      ],
    );
  }
}
