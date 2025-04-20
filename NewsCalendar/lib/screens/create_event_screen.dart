import 'package:flutter/material.dart';

class CreateEventScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final Function(Map<String, dynamic>) createCallback;

  const CreateEventScreen({
    Key? key,
    required this.event,
    required this.createCallback,
  }) : super(key: key);

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final FocusScopeNode _focusNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event['title'] ?? '');
    _descriptionController = TextEditingController(
      text: widget.event['description'] ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updates = {
      "title":
          _titleController.text.isNotEmpty
              ? _titleController.text
              : widget.event['title'],
      "description":
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : widget.event['description'],
      "start_date": widget.event['start_date'],
      "end_date": widget.event['end_date'],
    };

    widget.createCallback(updates);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
        ],
      ),
      body: FocusScope(
        node: _focusNode,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                onEditingComplete: () => _focusNode.nextFocus(),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 100,
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
