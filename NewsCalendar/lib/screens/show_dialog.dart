// import 'package:flutter/material.dart';

// class CustomDialog {
//   static Future<void> showUpdateEventDialog({
//     required BuildContext context,
//     required Map<String, dynamic> event,
//     required Function(Map<String, dynamic>, String) updateCallback,
//     required VoidCallback removeOverlay,
//   }) async {
//     String _newEventTitle = event['title'] ?? '';
//     String _newEventDescription = event['description'] ?? '';
//     final FocusScopeNode currentFocus = FocusScope.of(context);

//     removeOverlay();

//     return showDialog(
//       context: context,
//       builder:
//           (context) => Dialog(
//             insetPadding: const EdgeInsets.all(20),
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 maxHeight: MediaQuery.of(context).size.height * 0.7,
//                 minWidth: MediaQuery.of(context).size.width * 0.8,
//               ),
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       const Text(
//                         'Update Current Event',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 20),
//                       TextField(
//                         decoration: InputDecoration(
//                           labelText: 'Title',
//                           border: const OutlineInputBorder(),
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 16,
//                           ),
//                         ),
//                         controller: TextEditingController(text: event['title']),
//                         onChanged: (value) => _newEventTitle = value,
//                       ),
//                       const SizedBox(height: 20),
//                       ConstrainedBox(
//                         constraints: BoxConstraints(
//                           minHeight: 100,
//                           maxHeight: MediaQuery.of(context).size.height * 0.3,
//                         ),
//                         child: TextField(
//                           decoration: InputDecoration(
//                             labelText: 'Description',
//                             border: const OutlineInputBorder(),
//                             alignLabelWithHint: true,
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 16,
//                             ),
//                           ),
//                           controller: TextEditingController(
//                             text: event['description'],
//                           ),
//                           onChanged: (value) => _newEventDescription = value,
//                           maxLines: null,
//                           keyboardType: TextInputType.multiline,
//                           textAlignVertical: TextAlignVertical.top,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           TextButton(
//                             onPressed: () {
//                               if (!currentFocus.hasPrimaryFocus) {
//                                 currentFocus.unfocus();
//                               }
//                               Navigator.pop(context);
//                             },
//                             child: const Text('Cancel'),
//                           ),
//                           const SizedBox(width: 10),
//                           ElevatedButton(
//                             onPressed: () {
//                               final updates = {
//                                 "title":
//                                     _newEventTitle.isNotEmpty
//                                         ? _newEventTitle
//                                         : event['title'],
//                                 "description":
//                                     _newEventDescription.isNotEmpty
//                                         ? _newEventDescription
//                                         : event['description'],
//                               };
//                               updateCallback(updates, event['id']);
//                               if (!currentFocus.hasPrimaryFocus) {
//                                 currentFocus.unfocus();
//                               }
//                               Navigator.pop(context);
//                             },
//                             child: const Text('Update'),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//     );
//   }
// }
