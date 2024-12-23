import 'package:flutter/material.dart';

class FormWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final FocusNode nameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode saveFocusNode;
  final VoidCallback onSave;
  final String title;
  final String buttonText;

  const FormWidget({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.nameFocusNode,
    required this.emailFocusNode,
    required this.saveFocusNode,
    required this.onSave,
    required this.title,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FocusScope(
          autofocus: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text('Enter name and email.'),
              const SizedBox(height: 20),
              Focus(
                child: TextField(
                  controller: nameController,
                  focusNode: nameFocusNode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                  ),
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(emailFocusNode);
                  },
                  autofocus: true,
                ),
              ),
              const SizedBox(height: 20),
              Focus(
                child: TextField(
                  controller: emailController,
                  focusNode: emailFocusNode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(saveFocusNode);
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      onSave();
                      Navigator.pop(context);
                    },
                    focusNode: saveFocusNode,
                    child: Text(buttonText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
