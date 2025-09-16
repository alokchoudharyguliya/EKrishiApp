import '../models/events.dart' as eventModel;
import 'package:flutter/material.dart';

class UpdateEventScreen extends StatefulWidget {
  final eventModel.Event event;
  final Function(eventModel.Event, String) updateCallback;

  const UpdateEventScreen({
    Key? key,
    required this.event,
    required this.updateCallback,
  }) : super(key: key);

  @override
  _UpdateEventScreenState createState() => _UpdateEventScreenState();
}

class _UpdateEventScreenState extends State<UpdateEventScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final FocusScopeNode _focusNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.event.description ?? '',
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
    // final updates = {
    //   "title":
    //       _titleController.text.isNotEmpty
    //           ? _titleController.text
    //           : widget.event['title'],
    //   "description":
    //       _descriptionController.text.isNotEmpty
    //           ? _descriptionController.text
    //           : widget.event['description'],
    // };
    final updatedEvent = new eventModel.Event.create(
      id: widget.event.id,
      title:
          _titleController.text.isNotEmpty
              ? _titleController.text
              : widget.event.title,
      description:
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : widget.event.description,
      startDate: widget.event.startDate,
      endDate: widget.event.endDate,
      userId: widget.event.userId,
      changeType: "UPDATE",
    );
    widget.updateCallback(updatedEvent, widget.event.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Event'),
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
