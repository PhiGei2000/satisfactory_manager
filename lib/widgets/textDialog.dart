import 'package:flutter/material.dart';

class TextDialog extends StatefulWidget {
  final String? initialText;
  final String title;

  const TextDialog({super.key, this.initialText, this.title = ""});

  @override
  State<StatefulWidget> createState() => TextDialogState();
}

class TextDialogState extends State<TextDialog> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 0.8 * screenSize.width,
        height: 0.5 * screenSize.height,
        child: TextField(
          controller: _textController,
        ),
      ),
      actions: [
        IconButton(onPressed: submit, icon: const Icon(Icons.done)),
        IconButton(onPressed: cancel, icon: const Icon(Icons.close)),
      ],
    );
  }

  void submit() {
    Navigator.pop(context, _textController.text);
  }

  void cancel() {
    Navigator.pop(context, null);
  }
}
