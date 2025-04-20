// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class UpdateEventScreen extends StatefulWidget {
//   final Map<String, dynamic> event;
//   final Function(Map<String, dynamic>, String) updateCallback;

//   const UpdateEventScreen({
//     Key? key,
//     required this.event,
//     required this.updateCallback,
//   }) : super(key: key);

//   @override
//   _UpdateEventScreenState createState() => _UpdateEventScreenState();
// }

// class _UpdateEventScreenState extends State<UpdateEventScreen> {
//   late TextEditingController _titleController;
//   late TextEditingController _descriptionController;
//   final FocusScopeNode _focusNode = FocusScopeNode();

//   // Rich text formatting states
//   bool _isBold = false;
//   bool _isItalic = false;
//   bool _isUnderlined = false;
//   bool _isBulletList = false;
//   bool _isNumberedList = false;
//   Color _textColor = Colors.black;
//   Color _highlightColor = Colors.transparent;
//   double _fontSize = 14.0;
//   String _fontFamily = 'Roboto';

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.event['title'] ?? '');
//     _descriptionController = TextEditingController(
//       text: widget.event['description'] ?? '',
//     );
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   void _saveChanges() {
//     final updates = {
//       "title":
//           _titleController.text.isNotEmpty
//               ? _titleController.text
//               : widget.event['title'],
//       "description":
//           _descriptionController.text.isNotEmpty
//               ? _descriptionController.text
//               : widget.event['description'],
//       "textStyles": {
//         "bold": _isBold,
//         "italic": _isItalic,
//         "underlined": _isUnderlined,
//         "color": _textColor.value,
//         "highlight": _highlightColor.value,
//         "fontSize": _fontSize,
//         "fontFamily": _fontFamily,
//       },
//     };

//     widget.updateCallback(updates, widget.event['id']);
//     Navigator.pop(context);
//   }

//   void _applyTextStyle(TextStyle style) {
//     final text = _descriptionController.text;
//     final selection = _descriptionController.selection;

//     // Get current text and selection
//     final currentText = _descriptionController.text;
//     final basePosition = selection.baseOffset;
//     final extentPosition = selection.extentOffset;

//     // Apply style to selected text or prepare for new text
//     if (selection.isCollapsed) {
//       // No text selected - style will apply to next input
//       _descriptionController.value = _descriptionController.value.copyWith(
//         composing: TextRange.empty,
//       );
//     } else {
//       // Text is selected - wrap with formatting tags
//       final start = selection.start;
//       final end = selection.end;
//       final selectedText = currentText.substring(start, end);

//       // This is a simplified approach - in a real app you'd use a more robust
//       // rich text editing solution or a package like flutter_quill
//       String formattedText;
//       if (_isBold) {
//         formattedText = '<b>$selectedText</b>';
//       } else if (_isItalic) {
//         formattedText = '<i>$selectedText</i>';
//       } else if (_isUnderlined) {
//         formattedText = '<u>$selectedText</u>';
//       } else {
//         formattedText = selectedText;
//       }

//       final newText = currentText.replaceRange(start, end, formattedText);
//       _descriptionController.value = TextEditingValue(
//         text: newText,
//         selection: TextSelection.collapsed(
//           offset: start + formattedText.length,
//         ),
//       );
//     }
//   }

//   Future<void> _showColorPicker(bool isTextColor) async {
//     final Color? pickedColor = await showDialog<Color>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text(
//               isTextColor ? 'Select Text Color' : 'Select Highlight Color',
//             ),
//             content: SingleChildScrollView(
//               child: ColorPicker(
//                 pickerColor: isTextColor ? _textColor : _highlightColor,
//                 onColorChanged: (color) {
//                   Navigator.pop(context, color);
//                 },
//               ),
//             ),
//           ),
//     );

//     if (pickedColor != null) {
//       setState(() {
//         if (isTextColor) {
//           _textColor = pickedColor;
//         } else {
//           _highlightColor = pickedColor;
//         }
//       });
//     }
//   }

//   void _insertBulletList() {
//     final selection = _descriptionController.selection;
//     final text = _descriptionController.text;
//     final position = selection.baseOffset;

//     _descriptionController.value = TextEditingValue(
//       text: text.substring(0, position) + '\n• ' + text.substring(position),
//       selection: TextSelection.collapsed(offset: position + 3),
//     );
//   }

//   void _insertNumberedList() {
//     final selection = _descriptionController.selection;
//     final text = _descriptionController.text;
//     final position = selection.baseOffset;

//     // Count existing list items to determine next number
//     final lines = text.substring(0, position).split('\n');
//     int count = 1;
//     for (var line in lines) {
//       if (line.trim().startsWith(RegExp(r'^\d+\.'))) {
//         count++;
//       }
//     }

//     _descriptionController.value = TextEditingValue(
//       text:
//           text.substring(0, position) + '\n$count. ' + text.substring(position),
//       selection: TextSelection.collapsed(offset: position + 4),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Update Event'),
//         actions: [
//           IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
//         ],
//       ),
//       body: FocusScope(
//         node: _focusNode,
//         child: Column(
//           children: [
//             // Title field
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: TextField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(
//                   labelText: 'Title',
//                   border: OutlineInputBorder(),
//                 ),
//                 textInputAction: TextInputAction.next,
//                 onEditingComplete: () => _focusNode.nextFocus(),
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),

//             // Formatting toolbar
//             Container(
//               height: 50,
//               color: Colors.grey[200],
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     // Bold button
//                     IconButton(
//                       icon: Icon(Icons.format_bold),
//                       color: _isBold ? Colors.blue : Colors.black,
//                       onPressed: () {
//                         setState(() {
//                           _isBold = !_isBold;
//                           _applyTextStyle(
//                             TextStyle(
//                               fontWeight:
//                                   _isBold ? FontWeight.bold : FontWeight.normal,
//                             ),
//                           );
//                         });
//                       },
//                     ),

//                     // Italic button
//                     IconButton(
//                       icon: Icon(Icons.format_italic),
//                       color: _isItalic ? Colors.blue : Colors.black,
//                       onPressed: () {
//                         setState(() {
//                           _isItalic = !_isItalic;
//                           _applyTextStyle(
//                             TextStyle(
//                               fontStyle:
//                                   _isItalic
//                                       ? FontStyle.italic
//                                       : FontStyle.normal,
//                             ),
//                           );
//                         });
//                       },
//                     ),

//                     // Underline button
//                     IconButton(
//                       icon: Icon(Icons.format_underline),
//                       color: _isUnderlined ? Colors.blue : Colors.black,
//                       onPressed: () {
//                         setState(() {
//                           _isUnderlined = !_isUnderlined;
//                           _applyTextStyle(
//                             TextStyle(
//                               decoration:
//                                   _isUnderlined
//                                       ? TextDecoration.underline
//                                       : TextDecoration.none,
//                             ),
//                           );
//                         });
//                       },
//                     ),

//                     // Text color button
//                     IconButton(
//                       icon: Icon(Icons.format_color_text),
//                       onPressed: () => _showColorPicker(true),
//                     ),

//                     // Highlight color button
//                     IconButton(
//                       icon: Icon(Icons.format_color_fill),
//                       onPressed: () => _showColorPicker(false),
//                     ),

//                     // Bullet list button
//                     IconButton(
//                       icon: Icon(Icons.format_list_bulleted),
//                       color: _isBulletList ? Colors.blue : Colors.black,
//                       onPressed: () {
//                         setState(() {
//                           _isBulletList = !_isBulletList;
//                           _isNumberedList = false;
//                           if (_isBulletList) _insertBulletList();
//                         });
//                       },
//                     ),

//                     // Numbered list button
//                     IconButton(
//                       icon: Icon(Icons.format_list_numbered),
//                       color: _isNumberedList ? Colors.blue : Colors.black,
//                       onPressed: () {
//                         setState(() {
//                           _isNumberedList = !_isNumberedList;
//                           _isBulletList = false;
//                           if (_isNumberedList) _insertNumberedList();
//                         });
//                       },
//                     ),

//                     // Font size dropdown
//                     DropdownButton<double>(
//                       value: _fontSize,
//                       items:
//                           [10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 24.0, 28.0, 32.0]
//                               .map(
//                                 (size) => DropdownMenuItem(
//                                   value: size,
//                                   child: Text(size.toString()),
//                                 ),
//                               )
//                               .toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _fontSize = value!;
//                         });
//                       },
//                     ),

//                     // Font family dropdown
//                     DropdownButton<String>(
//                       value: _fontFamily,
//                       items:
//                           [
//                                 'Roboto',
//                                 'Arial',
//                                 'Times New Roman',
//                                 'Courier New',
//                                 'Verdana',
//                               ]
//                               .map(
//                                 (family) => DropdownMenuItem(
//                                   value: family,
//                                   child: Text(family),
//                                 ),
//                               )
//                               .toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _fontFamily = value!;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Description field
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: TextField(
//                   controller: _descriptionController,
//                   decoration: const InputDecoration(
//                     labelText: 'Description',
//                     border: OutlineInputBorder(),
//                     alignLabelWithHint: true,
//                   ),
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                   textAlignVertical: TextAlignVertical.top,
//                   style: TextStyle(
//                     fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
//                     fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
//                     decoration:
//                         _isUnderlined
//                             ? TextDecoration.underline
//                             : TextDecoration.none,
//                     color: _textColor,
//                     backgroundColor: _highlightColor,
//                     fontSize: _fontSize,
//                     fontFamily: _fontFamily,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Simple color picker widget
// class ColorPicker extends StatefulWidget {
//   final Color pickerColor;
//   final ValueChanged<Color> onColorChanged;

//   const ColorPicker({required this.pickerColor, required this.onColorChanged});

//   @override
//   _ColorPickerState createState() => _ColorPickerState();
// }

// class _ColorPickerState extends State<ColorPicker> {
//   late Color _currentColor;

//   @override
//   void initState() {
//     super.initState();
//     _currentColor = widget.pickerColor;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Wrap(
//           spacing: 5,
//           runSpacing: 5,
//           children: [
//             _buildColorBox(Colors.black),
//             _buildColorBox(Colors.white),
//             _buildColorBox(Colors.red),
//             _buildColorBox(Colors.pink),
//             _buildColorBox(Colors.purple),
//             _buildColorBox(Colors.deepPurple),
//             _buildColorBox(Colors.indigo),
//             _buildColorBox(Colors.blue),
//             _buildColorBox(Colors.lightBlue),
//             _buildColorBox(Colors.cyan),
//             _buildColorBox(Colors.teal),
//             _buildColorBox(Colors.green),
//             _buildColorBox(Colors.lightGreen),
//             _buildColorBox(Colors.lime),
//             _buildColorBox(Colors.yellow),
//             _buildColorBox(Colors.amber),
//             _buildColorBox(Colors.orange),
//             _buildColorBox(Colors.deepOrange),
//             _buildColorBox(Colors.brown),
//             _buildColorBox(Colors.grey),
//             _buildColorBox(Colors.blueGrey),
//           ],
//         ),
//         SizedBox(height: 20),
//         ElevatedButton(
//           onPressed: () => widget.onColorChanged(_currentColor),
//           child: Text('Select Color'),
//         ),
//       ],
//     );
//   }

//   Widget _buildColorBox(Color color) {
//     return GestureDetector(
//       onTap: () => setState(() => _currentColor = color),
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: color,
//           border: Border.all(
//             color: _currentColor == color ? Colors.blue : Colors.grey,
//             width: _currentColor == color ? 3 : 1,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'dart:convert';

// // class RichTextEditorScreen extends StatefulWidget {
// //   final Map<String, dynamic> event;
// //   final Function(Map<String, dynamic>, String) updateCallback;

// //   const RichTextEditorScreen({
// //     Key? key,
// //     required this.event,
// //     required this.updateCallback,
// //   }) : super(key: key);

// //   @override
// //   _RichTextEditorScreenState createState() => _RichTextEditorScreenState();
// // }

// // class _RichTextEditorScreenState extends State<RichTextEditorScreen> {
// //   late TextEditingController _titleController;
// //   late TextEditingController _descriptionController;
// //   final FocusNode _descriptionFocusNode = FocusNode();

// //   // Current formatting for new text or selections
// //   TextStyle _currentStyle = const TextStyle();
// //   TextSelection _currentSelection = const TextSelection.collapsed(offset: 0);

// //   // Store rich text information
// //   List<TextSpan> _richTextSpans = [];
// //   String _plainText = '';

// //   @override
// //   void initState() {
// //     super.initState();
// //     _titleController = TextEditingController(text: widget.event['title'] ?? '');
// //     _descriptionController = TextEditingController();

// //     // Initialize with existing content
// //     if (widget.event['formattedText'] != null) {
// //       _loadFormattedText(widget.event['formattedText']);
// //     } else {
// //       _plainText = widget.event['description'] ?? '';
// //       _descriptionController.text = _plainText;
// //       _richTextSpans = [TextSpan(text: _plainText)];
// //     }
// //   }

// //   void _loadFormattedText(String formattedText) {
// //     try {
// //       final json = jsonDecode(formattedText);
// //       _plainText = json['text'];
// //       _descriptionController.text = _plainText;

// //       _richTextSpans =
// //           (json['spans'] as List).map((span) {
// //             return TextSpan(
// //               text: span['text'],
// //               style: TextStyle(
// //                 fontWeight: span['bold'] ? FontWeight.bold : null,
// //                 fontStyle: span['italic'] ? FontStyle.italic : null,
// //                 decoration: span['underline'] ? TextDecoration.underline : null,
// //                 color: span['color'] != null ? Color(span['color']) : null,
// //                 backgroundColor:
// //                     span['highlight'] != null ? Color(span['highlight']) : null,
// //                 fontSize: span['fontSize']?.toDouble(),
// //                 fontFamily: span['fontFamily'],
// //               ),
// //             );
// //           }).toList();
// //     } catch (e) {
// //       _plainText = widget.event['description'] ?? '';
// //       _descriptionController.text = _plainText;
// //       _richTextSpans = [TextSpan(text: _plainText)];
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _titleController.dispose();
// //     _descriptionController.dispose();
// //     _descriptionFocusNode.dispose();
// //     super.dispose();
// //   }

// //   void _saveChanges() {
// //     final spansJson =
// //         _richTextSpans.map((span) {
// //           return {
// //             'text': span.text,
// //             'bold': span.style?.fontWeight == FontWeight.bold,
// //             'italic': span.style?.fontStyle == FontStyle.italic,
// //             'underline': span.style?.decoration == TextDecoration.underline,
// //             'color': span.style?.color?.value,
// //             'highlight': span.style?.backgroundColor?.value,
// //             'fontSize': span.style?.fontSize,
// //             'fontFamily': span.style?.fontFamily,
// //           };
// //         }).toList();

// //     final updates = {
// //       "title": _titleController.text,
// //       "description": _plainText,
// //       "formattedText": jsonEncode({"text": _plainText, "spans": spansJson}),
// //     };

// //     widget.updateCallback(updates, widget.event['id']);
// //     Navigator.pop(context);
// //   }

// //   void _applyFormattingToSelection() {
// //     final selection = _descriptionController.selection;
// //     if (!selection.isValid || selection.isCollapsed) return;

// //     final start = selection.start;
// //     final end = selection.end;
// //     String fullText = _descriptionController.text;

// //     List<TextSpan> newSpans = [];
// //     int currentPosition = 0;

// //     for (final span in _richTextSpans) {
// //       final spanText = span.text ?? '';
// //       final spanEnd = currentPosition + spanText.length;

// //       if (spanEnd <= start) {
// //         // Before selection - keep unchanged
// //         newSpans.add(span);
// //         currentPosition = spanEnd;
// //         continue;
// //       }

// //       if (currentPosition >= end) {
// //         // After selection - keep unchanged
// //         newSpans.add(span);
// //         currentPosition = spanEnd;
// //         continue;
// //       }

// //       // Split span into parts if needed
// //       final beforeSelection =
// //           start > currentPosition
// //               ? spanText.substring(0, start - currentPosition)
// //               : '';
// //       final inSelection = spanText.substring(
// //         start > currentPosition ? start - currentPosition : 0,
// //         end < spanEnd ? end - currentPosition : spanText.length,
// //       );
// //       final afterSelection =
// //           end < spanEnd ? spanText.substring(end - currentPosition) : '';

// //       if (beforeSelection.isNotEmpty) {
// //         newSpans.add(TextSpan(text: beforeSelection, style: span.style));
// //       }

// //       if (inSelection.isNotEmpty) {
// //         newSpans.add(
// //           TextSpan(text: inSelection, style: _currentStyle.merge(span.style)),
// //         );
// //       }

// //       if (afterSelection.isNotEmpty) {
// //         newSpans.add(TextSpan(text: afterSelection, style: span.style));
// //       }

// //       currentPosition = spanEnd;
// //     }

// //     setState(() {
// //       _richTextSpans = newSpans;
// //       _updatePlainText();
// //     });
// //   }

// //   void _updatePlainText() {
// //     _plainText = _richTextSpans.map((span) => span.text).join();
// //     if (_descriptionController.text != _plainText) {
// //       _descriptionController.text = _plainText;
// //     }
// //   }

// //   void _toggleBold() {
// //     setState(() {
// //       _currentStyle = _currentStyle.copyWith(
// //         fontWeight:
// //             _currentStyle.fontWeight == FontWeight.bold
// //                 ? FontWeight.normal
// //                 : FontWeight.bold,
// //       );
// //     });
// //     _applyFormattingToSelection();
// //   }

// //   void _toggleItalic() {
// //     setState(() {
// //       _currentStyle = _currentStyle.copyWith(
// //         fontStyle:
// //             _currentStyle.fontStyle == FontStyle.italic
// //                 ? FontStyle.normal
// //                 : FontStyle.italic,
// //       );
// //     });
// //     _applyFormattingToSelection();
// //   }

// //   void _toggleUnderline() {
// //     setState(() {
// //       _currentStyle = _currentStyle.copyWith(
// //         decoration:
// //             _currentStyle.decoration == TextDecoration.underline
// //                 ? null
// //                 : TextDecoration.underline,
// //       );
// //     });
// //     _applyFormattingToSelection();
// //   }

// //   Future<void> _changeTextColor() async {
// //     final color = await showDialog<Color>(
// //       context: context,
// //       builder:
// //           (context) => ColorPickerDialog(
// //             initialColor: _currentStyle.color ?? Colors.black,
// //           ),
// //     );

// //     if (color != null) {
// //       setState(() {
// //         _currentStyle = _currentStyle.copyWith(color: color);
// //       });
// //       _applyFormattingToSelection();
// //     }
// //   }

// //   Future<void> _changeHighlightColor() async {
// //     final color = await showDialog<Color>(
// //       context: context,
// //       builder:
// //           (context) => ColorPickerDialog(
// //             initialColor: _currentStyle.backgroundColor ?? Colors.transparent,
// //           ),
// //     );

// //     if (color != null) {
// //       setState(() {
// //         _currentStyle = _currentStyle.copyWith(backgroundColor: color);
// //       });
// //       _applyFormattingToSelection();
// //     }
// //   }

// //   void _changeFontSize(double size) {
// //     setState(() {
// //       _currentStyle = _currentStyle.copyWith(fontSize: size);
// //     });
// //     _applyFormattingToSelection();
// //   }

// //   void _changeFontFamily(String family) {
// //     setState(() {
// //       _currentStyle = _currentStyle.copyWith(fontFamily: family);
// //     });
// //     _applyFormattingToSelection();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Edit Event'),
// //         actions: [
// //           IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           // Title field
// //           Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: TextField(
// //               controller: _titleController,
// //               decoration: const InputDecoration(
// //                 labelText: 'Title',
// //                 border: OutlineInputBorder(),
// //               ),
// //               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //           ),

// //           // Formatting toolbar
// //           Container(
// //             height: 50,
// //             color: Colors.grey[200],
// //             child: SingleChildScrollView(
// //               scrollDirection: Axis.horizontal,
// //               child: Row(
// //                 children: [
// //                   // Bold button
// //                   IconButton(
// //                     icon: const Icon(Icons.format_bold),
// //                     color:
// //                         _currentStyle.fontWeight == FontWeight.bold
// //                             ? Colors.blue
// //                             : Colors.black,
// //                     onPressed: _toggleBold,
// //                   ),

// //                   // Italic button
// //                   IconButton(
// //                     icon: const Icon(Icons.format_italic),
// //                     color:
// //                         _currentStyle.fontStyle == FontStyle.italic
// //                             ? Colors.blue
// //                             : Colors.black,
// //                     onPressed: _toggleItalic,
// //                   ),

// //                   // Underline button
// //                   IconButton(
// //                     icon: const Icon(Icons.format_underline),
// //                     color:
// //                         _currentStyle.decoration == TextDecoration.underline
// //                             ? Colors.blue
// //                             : Colors.black,
// //                     onPressed: _toggleUnderline,
// //                   ),

// //                   // Text color
// //                   IconButton(
// //                     icon: Icon(
// //                       Icons.format_color_text,
// //                       color: _currentStyle.color ?? Colors.black,
// //                     ),
// //                     onPressed: _changeTextColor,
// //                   ),

// //                   // Highlight color
// //                   IconButton(
// //                     icon: Icon(
// //                       Icons.format_color_fill,
// //                       color: _currentStyle.backgroundColor ?? Colors.grey,
// //                     ),
// //                     onPressed: _changeHighlightColor,
// //                   ),

// //                   // Font size
// //                   DropdownButton<double>(
// //                     value: _currentStyle.fontSize ?? 14.0,
// //                     items:
// //                         [10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 24.0, 28.0]
// //                             .map(
// //                               (size) => DropdownMenuItem(
// //                                 value: size,
// //                                 child: Text('${size.toInt()}'),
// //                               ),
// //                             )
// //                             .toList(),
// //                     onChanged: (size) => _changeFontSize(size!),
// //                   ),

// //                   // Font family
// //                   DropdownButton<String>(
// //                     value: _currentStyle.fontFamily ?? 'Roboto',
// //                     items:
// //                         const [
// //                               'Roboto',
// //                               'Arial',
// //                               'Times New Roman',
// //                               'Courier New',
// //                             ]
// //                             .map(
// //                               (family) => DropdownMenuItem(
// //                                 value: family,
// //                                 child: Text(family),
// //                               ),
// //                             )
// //                             .toList(),
// //                     onChanged: (family) => _changeFontFamily(family!),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           // Description editor
// //           Expanded(
// //             child: Padding(
// //               padding: const EdgeInsets.all(16.0),
// //               child: TextField(
// //                 controller: _descriptionController,
// //                 focusNode: _descriptionFocusNode,
// //                 maxLines: null,
// //                 keyboardType: TextInputType.multiline,
// //                 decoration: const InputDecoration(
// //                   border: OutlineInputBorder(),
// //                   hintText: 'Enter description...',
// //                 ),
// //                 onChanged: (text) {
// //                   if (text != _plainText) {
// //                     _plainText = text;
// //                     // In a full implementation, you'd update spans here
// //                     // This is simplified for demonstration
// //                     _richTextSpans = [TextSpan(text: text)];
// //                   }
// //                 },
// //                 onSelectionChanged: (selection) {
// //                   _currentSelection = selection;
// //                   // Here you would analyze the selection to update the formatting buttons
// //                   // to reflect the style at the cursor position
// //                 },
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class ColorPickerDialog extends StatefulWidget {
// //   final Color initialColor;

// //   const ColorPickerDialog({Key? key, required this.initialColor})
// //     : super(key: key);

// //   @override
// //   _ColorPickerDialogState createState() => _ColorPickerDialogState();
// // }

// // class _ColorPickerDialogState extends State<ColorPickerDialog> {
// //   late Color _selectedColor;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _selectedColor = widget.initialColor;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return AlertDialog(
// //       title: const Text('Select Color'),
// //       content: SingleChildScrollView(
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             _buildColorGrid(),
// //             const SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: () => Navigator.pop(context, _selectedColor),
// //               child: const Text('Select'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildColorGrid() {
// //     const colors = [
// //       Colors.black,
// //       Colors.white,
// //       Colors.red,
// //       Colors.pink,
// //       Colors.purple,
// //       Colors.deepPurple,
// //       Colors.indigo,
// //       Colors.blue,
// //       Colors.lightBlue,
// //       Colors.cyan,
// //       Colors.teal,
// //       Colors.green,
// //       Colors.lightGreen,
// //       Colors.lime,
// //       Colors.yellow,
// //       Colors.amber,
// //       Colors.orange,
// //       Colors.deepOrange,
// //       Colors.brown,
// //       Colors.grey,
// //       Colors.blueGrey,
// //     ];

// //     return Wrap(
// //       spacing: 8,
// //       runSpacing: 8,
// //       children:
// //           colors.map((color) {
// //             return GestureDetector(
// //               onTap: () => setState(() => _selectedColor = color),
// //               child: Container(
// //                 width: 40,
// //                 height: 40,
// //                 decoration: BoxDecoration(
// //                   color: color,
// //                   border: Border.all(
// //                     color: _selectedColor == color ? Colors.blue : Colors.grey,
// //                     width: _selectedColor == color ? 3 : 1,
// //                   ),
// //                 ),
// //               ),
// //             );
// //           }).toList(),
// //     );
// //   }
// // }

// // import 'package:flutter/material.dart';
// // import 'dart:convert';

// // class RichTextEditorScreen extends StatefulWidget {
// //   final Map<String, dynamic> event;
// //   final Function(Map<String, dynamic>, String) updateCallback;

// //   const RichTextEditorScreen({
// //     Key? key,
// //     required this.event,
// //     required this.updateCallback,
// //   }) : super(key: key);

// //   @override
// //   _RichTextEditorScreenState createState() => _RichTextEditorScreenState();
// // }

// // class _RichTextEditorScreenState extends State<RichTextEditorScreen> {
// //   late TextEditingController _titleController;
// //   late TextEditingController _descriptionController;
// //   final FocusNode _descriptionFocusNode = FocusNode();

// //   // Current formatting for new text or selections
// //   TextStyle _currentStyle = const TextStyle();
// //   TextSelection _currentSelection = const TextSelection.collapsed(offset: 0);

// //   // Store rich text information
// //   List<TextSpan> _richTextSpans = [];
// //   String _plainText = '';

// //   @override
// //   void initState() {
// //     super.initState();
// //     _titleController = TextEditingController(text: widget.event['title'] ?? '');
// //     _descriptionController = TextEditingController();

// //     // Initialize with existing content
// //     if (widget.event['formattedText'] != null) {
// //       _loadFormattedText(widget.event['formattedText']);
// //     } else {
// //       _plainText = widget.event['description'] ?? '';
// //       _descriptionController.text = _plainText;
// //       _richTextSpans = [TextSpan(text: _plainText)];
// //     }
// //   }

// //   void _loadFormattedText(String formattedText) {
// //     try {
// //       final json = jsonDecode(formattedText);
// //       _plainText = json['text'];
// //       _descriptionController.text = _plainText;

// //       _richTextSpans =
// //           (json['spans'] as List).map((span) {
// //             return TextSpan(
// //               text: span['text'],
// //               style: TextStyle(
// //                 fontWeight: span['bold'] ? FontWeight.bold : null,
// //                 fontStyle: span['italic'] ? FontStyle.italic : null,
// //                 decoration: span['underline'] ? TextDecoration.underline : null,
// //                 color: span['color'] != null ? Color(span['color']) : null,
// //                 backgroundColor:
// //                     span['highlight'] != null ? Color(span['highlight']) : null,
// //                 fontSize: span['fontSize']?.toDouble(),
// //                 fontFamily: span['fontFamily'],
// //               ),
// //             );
// //           }).toList();
// //     } catch (e) {
// //       _plainText = widget.event['description'] ?? '';
// //       _descriptionController.text = _plainText;
// //       _richTextSpans = [TextSpan(text: _plainText)];
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _titleController.dispose();
// //     _descriptionController.dispose();
// //     _descriptionFocusNode.dispose();
// //     super.dispose();
// //   }

// //   void _saveChanges() {
// //     final spansJson =
// //         _richTextSpans.map((span) {
// //           return {
// //             'text': span.text,
// //             'bold': span.style?.fontWeight == FontWeight.bold,
// //             'italic': span.style?.fontStyle == FontStyle.italic,
// //             'underline': span.style?.decoration == TextDecoration.underline,
// //             'color': span.style?.color?.value,
// //             'highlight': span.style?.backgroundColor?.value,
// //             'fontSize': span.style?.fontSize,
// //             'fontFamily': span.style?.fontFamily,
// //           };
// //         }).toList();

// //     final updates = {
// //       "title": _titleController.text,
// //       "description": _plainText,
// //       "formattedText": jsonEncode({"text": _plainText, "spans": spansJson}),
// //     };

// //     widget.updateCallback(updates, widget.event['id']);
// //     Navigator.pop(context);
// //   }

// //   void _applyFormattingToSelection() {
// //     final selection = _descriptionController.selection;
// //     if (!selection.isValid || selection.isCollapsed) return;

// //     final start = selection.start;
// //     final end = selection.end;
// //     String fullText = _descriptionController.text;

// //     List<TextSpan> newSpans = [];
// //     int currentPosition = 0;

// //     for (final span in _richTextSpans) {
// //       final spanText = span.text ?? '';
// //       final spanEnd = currentPosition + spanText.length;

// //       if (spanEnd <= start) {
// //         // Before selection - keep unchanged
// //         newSpans.add(span);
// //         currentPosition = spanEnd;
// //         continue;
// //       }

// //       if (currentPosition >= end) {
// //         // After selection - keep unchanged
// //         newSpans.add(span);
// //         currentPosition = spanEnd;
// //         continue;
// //       }

// //       // Split span into parts if needed
// //       final beforeSelection =
// //           start > currentPosition
// //               ? spanText.substring(0, start - currentPosition)
// //               : '';
// //       final inSelection = spanText.substring(
// //         start > currentPosition ? start - currentPosition : 0,
// //         end < spanEnd ? end - currentPosition : spanText.length,
// //       );
// //       final afterSelection =
// //           end < spanEnd ? spanText.substring(end - currentPosition) : '';

// //       if (beforeSelection.isNotEmpty) {
// //         newSpans.add(TextSpan(text: beforeSelection, style: span.style));
// //       }

// //       if (inSelection.isNotEmpty) {
// //         newSpans.add(
// //           TextSpan(text: inSelection, style: _currentStyle.merge(span.style)),
// //         );
// //       }

// //       if (afterSelection.isNotEmpty) {
// //         newSpans.add(TextSpan(text: afterSelection, style: span.style));
// //       }

// //       currentPosition = spanEnd;
// //     }

// //     setState(() {
// //       _richTextSpans = newSpans;
// //       _updatePlainText();
// //     });
// //   }

// //   void _updatePlainText() {
// //     _plainText = _richTextSpans.map((span) => span.text).join();
// //     if (_descriptionController.text != _plainText) {
// //       _descriptionController.text = _plainText;
// //     }
// //   }

// //   void _updateCurrentStyleFromSelection() {
// //     if (_descriptionController.selection.isCollapsed) {
// //       // For collapsed selection, get style at cursor position
// //       final position = _descriptionController.selection.baseOffset;
// //       int currentPos = 0;

// //       for (final span in _richTextSpans) {
// //         final spanText = span.text ?? '';
// //         final spanEnd = currentPos + spanText.length;

// //         if (position >= currentPos && position <= spanEnd) {
// //           setState(() {
// //             _currentStyle = span.style ?? const TextStyle();
// //           });
// //           return;
// //         }
// //         currentPos = spanEnd;
// //       }
// //     } else {
// //       // For non-collapsed selection, find common styles
// //       final start = _descriptionController.selection.start;
// //       final end = _descriptionController.selection.end;
// //       int currentPos = 0;

// //       TextStyle? commonStyle;
// //       bool firstSpan = true;

// //       for (final span in _richTextSpans) {
// //         final spanText = span.text ?? '';
// //         final spanEnd = currentPos + spanText.length;

// //         if (spanEnd <= start) {
// //           currentPos = spanEnd;
// //           continue;
// //         }

// //         if (currentPos >= end) {
// //           break;
// //         }

// //         if (firstSpan) {
// //           commonStyle = span.style;
// //           firstSpan = false;
// //         } else {
// //           commonStyle = _mergeCommonStyles(commonStyle, span.style);
// //         }

// //         currentPos = spanEnd;
// //       }

// //       setState(() {
// //         _currentStyle = commonStyle ?? const TextStyle();
// //       });
// //     }
// //   }

// //   TextStyle? _mergeCommonStyles(TextStyle? style1, TextStyle? style2) {
// //     if (style1 == null || style2 == null) return null;

// //     return TextStyle(
// //       fontWeight:
// //           style1.fontWeight == style2.fontWeight ? style1.fontWeight : null,
// //       fontStyle: style1.fontStyle == style2.fontStyle ? style1.fontStyle : null,
// //       decoration:
// //           style1.decoration == style2.decoration ? style1.decoration : null,
// //       color: style1.color == style2.color ? style1.color : null,
// //       backgroundColor:
// //           style1.backgroundColor == style2.backgroundColor
// //               ? style1.backgroundColor
// //               : null,
// //       fontSize: style1.fontSize == style2.fontSize ? style1.fontSize : null,
// //       fontFamily:
// //           style1.fontFamily == style2.fontFamily ? style1.fontFamily : null,
// //     );
// //   }

// //   void _toggleBold() {
// //     setState(() {
// //       _currentStyle = _currentStyle.copyWith(
// //         fontWeight:
// //             _currentStyle.fontWeight == FontWeight.bold
// //                 ? FontWeight.normal
// //                 : FontWeight.bold,
// //       );
// //     });
// //     _applyFormattingToSelection();
// //   }

// //   void _toggleItalic() {
// //     setState(() {
// //       _currentStyle = _currentStyle.copyWith(
// //         fontStyle:
// //             _currentStyle.fontStyle == FontStyle.italic
// //                 ? FontStyle.normal
// //                 : FontStyle.italic,
// //       );
// //     });
// //     _applyFormattingToSelection();
// //   }

// //   void _toggleUnderline() {
// //     setState(() {
// //       _currentStyle = _currentStyle.copyWith(
// //         decoration:
// //             _currentStyle.decoration == TextDecoration.underline
// //                 ? null
// //                 : TextDecoration.underline,
// //       );
// //     });
// //     _applyFormattingToSelection();
// //   }

// //   Future<void> _changeTextColor() async {
// //     final color = await showDialog<Color>(
// //       context: context,
// //       builder:
// //           (context) => ColorPickerDialog(
// //             initialColor: _currentStyle.color ?? Colors.black,
// //           ),
// //     );

// //     if (color != null) {
// //       setState(() {
// //         _currentStyle = _currentStyle.copyWith(color: color);
// //       });
// //       _applyFormattingToSelection();
// //     }
// //   }

// //   Future<void> _changeHighlightColor() async {
// //     final color = await showDialog<Color>(
// //       context: context,
// //       builder:
// //           (context) => ColorPickerDialog(
// //             initialColor: _currentStyle.backgroundColor ?? Colors.transparent,
// //           ),
// //     );

// //     if (color != null) {
// //       setState(() {
// //         _currentStyle = _currentStyle.copyWith(backgroundColor: color);
// //       });
// //       _applyFormattingToSelection();
// //     }
// //   }

// //   void _changeFontSize(double size) {
// //     setState(() {
// //       _currentStyle = _currentStyle.copyWith(fontSize: size);
// //     });
// //     _applyFormattingToSelection();
// //   }

// //   void _changeFontFamily(String family) {
// //     setState(() {
// //       _currentStyle = _currentStyle.copyWith(fontFamily: family);
// //     });
// //     _applyFormattingToSelection();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Edit Event'),
// //         actions: [
// //           IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           // Title field
// //           Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: TextField(
// //               controller: _titleController,
// //               decoration: const InputDecoration(
// //                 labelText: 'Title',
// //                 border: OutlineInputBorder(),
// //               ),
// //               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //           ),

// //           // Formatting toolbar
// //           Container(
// //             height: 50,
// //             color: Colors.grey[200],
// //             child: SingleChildScrollView(
// //               scrollDirection: Axis.horizontal,
// //               child: Row(
// //                 children: [
// //                   // Bold button
// //                   IconButton(
// //                     icon: const Icon(Icons.format_bold),
// //                     color:
// //                         _currentStyle.fontWeight == FontWeight.bold
// //                             ? Colors.blue
// //                             : Colors.black,
// //                     onPressed: _toggleBold,
// //                   ),

// //                   // Italic button
// //                   IconButton(
// //                     icon: const Icon(Icons.format_italic),
// //                     color:
// //                         _currentStyle.fontStyle == FontStyle.italic
// //                             ? Colors.blue
// //                             : Colors.black,
// //                     onPressed: _toggleItalic,
// //                   ),

// //                   // Underline button
// //                   IconButton(
// //                     icon: const Icon(Icons.format_underline),
// //                     color:
// //                         _currentStyle.decoration == TextDecoration.underline
// //                             ? Colors.blue
// //                             : Colors.black,
// //                     onPressed: _toggleUnderline,
// //                   ),

// //                   // Text color
// //                   IconButton(
// //                     icon: Icon(
// //                       Icons.format_color_text,
// //                       color: _currentStyle.color ?? Colors.black,
// //                     ),
// //                     onPressed: _changeTextColor,
// //                   ),

// //                   // Highlight color
// //                   IconButton(
// //                     icon: Icon(
// //                       Icons.format_color_fill,
// //                       color: _currentStyle.backgroundColor ?? Colors.grey,
// //                     ),
// //                     onPressed: _changeHighlightColor,
// //                   ),

// //                   // Font size
// //                   DropdownButton<double>(
// //                     value: _currentStyle.fontSize ?? 14.0,
// //                     items:
// //                         [10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 24.0, 28.0]
// //                             .map(
// //                               (size) => DropdownMenuItem(
// //                                 value: size,
// //                                 child: Text('${size.toInt()}'),
// //                               ),
// //                             )
// //                             .toList(),
// //                     onChanged: (size) => _changeFontSize(size!),
// //                   ),

// //                   // Font family
// //                   DropdownButton<String>(
// //                     value: _currentStyle.fontFamily ?? 'Roboto',
// //                     items:
// //                         const [
// //                               'Roboto',
// //                               'Arial',
// //                               'Times New Roman',
// //                               'Courier New',
// //                             ]
// //                             .map(
// //                               (family) => DropdownMenuItem(
// //                                 value: family,
// //                                 child: Text(family),
// //                               ),
// //                             )
// //                             .toList(),
// //                     onChanged: (family) => _changeFontFamily(family!),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           // Description editor
// //           Expanded(
// //             child: Padding(
// //               padding: const EdgeInsets.all(16.0),
// //               child: TextField(
// //                 controller: _descriptionController,
// //                 focusNode: _descriptionFocusNode,
// //                 maxLines: null,
// //                 keyboardType: TextInputType.multiline,
// //                 decoration: const InputDecoration(
// //                   border: OutlineInputBorder(),
// //                   hintText: 'Enter description...',
// //                 ),
// //                 onChanged: (text) {
// //                   if (text != _plainText) {
// //                     _plainText = text;
// //                     // In a full implementation, you'd update spans here
// //                     // This is simplified for demonstration
// //                     _richTextSpans = [TextSpan(text: text)];
// //                   }
// //                 },
// //                 onSelectionChanged: (selection, _) {
// //                   setState(() {
// //                     _currentSelection = selection;
// //                   });
// //                   _updateCurrentStyleFromSelection();
// //                 },
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class ColorPickerDialog extends StatefulWidget {
// //   final Color initialColor;

// //   const ColorPickerDialog({Key? key, required this.initialColor})
// //     : super(key: key);

// //   @override
// //   _ColorPickerDialogState createState() => _ColorPickerDialogState();
// // }

// // class _ColorPickerDialogState extends State<ColorPickerDialog> {
// //   late Color _selectedColor;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _selectedColor = widget.initialColor;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return AlertDialog(
// //       title: const Text('Select Color'),
// //       content: SingleChildScrollView(
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             _buildColorGrid(),
// //             const SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: () => Navigator.pop(context, _selectedColor),
// //               child: const Text('Select'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildColorGrid() {
// //     const colors = [
// //       Colors.black,
// //       Colors.white,
// //       Colors.red,
// //       Colors.pink,
// //       Colors.purple,
// //       Colors.deepPurple,
// //       Colors.indigo,
// //       Colors.blue,
// //       Colors.lightBlue,
// //       Colors.cyan,
// //       Colors.teal,
// //       Colors.green,
// //       Colors.lightGreen,
// //       Colors.lime,
// //       Colors.yellow,
// //       Colors.amber,
// //       Colors.orange,
// //       Colors.deepOrange,
// //       Colors.brown,
// //       Colors.grey,
// //       Colors.blueGrey,
// //     ];

// //     return Wrap(
// //       spacing: 8,
// //       runSpacing: 8,
// //       children:
// //           colors.map((color) {
// //             return GestureDetector(
// //               onTap: () => setState(() => _selectedColor = color),
// //               child: Container(
// //                 width: 40,
// //                 height: 40,
// //                 decoration: BoxDecoration(
// //                   color: color,
// //                   border: Border.all(
// //                     color: _selectedColor == color ? Colors.blue : Colors.grey,
// //                     width: _selectedColor == color ? 3 : 1,
// //                   ),
// //                 ),
// //               ),
// //             );
// //           }).toList(),
// //     );
// //   }
// // }

// // import 'package:flutter/material.dart';
// // import 'dart:convert';

// // class RichTextEditorScreen extends StatefulWidget {
// //   final Map<String, dynamic> event;
// //   final Function(Map<String, dynamic>, String) updateCallback;

// //   const RichTextEditorScreen({
// //     Key? key,
// //     required this.event,
// //     required this.updateCallback,
// //   }) : super(key: key);

// //   @override
// //   _RichTextEditorScreenState createState() => _RichTextEditorScreenState();
// // }

// // class _RichTextEditorScreenState extends State<RichTextEditorScreen> {
// //   late TextEditingController _titleController;
// //   late TextEditingController _descriptionController;
// //   final FocusNode _descriptionFocusNode = FocusNode();

// //   // Current formatting for new text or selections
// //   TextStyle _currentStyle = const TextStyle();
// //   TextSelection _currentSelection = const TextSelection.collapsed(offset: 0);

// //   // Store rich text information
// //   List<TextSpan> _richTextSpans = [];
// //   String _plainText = '';

// //   @override
// //   void initState() {
// //     super.initState();
// //     _titleController = TextEditingController(text: widget.event['title'] ?? '');
// //     _descriptionController = TextEditingController();

// //     // Initialize with existing content
// //     if (widget.event['formattedText'] != null) {
// //       _loadFormattedText(widget.event['formattedText']);
// //     } else {
// //       _plainText = widget.event['description'] ?? '';
// //       _descriptionController.text = _plainText;
// //       _richTextSpans = [TextSpan(text: _plainText)];
// //     }

// //     // Listen for selection changes
// //     _descriptionController.addListener(_handleSelectionChange);
// //   }

// //   void _handleSelectionChange() {
// //     if (_descriptionController.selection != _currentSelection) {
// //       setState(() {
// //         _currentSelection = _descriptionController.selection;
// //       });
// //       _updateCurrentStyleFromSelection();
// //     }
// //   }

// //   void _loadFormattedText(String formattedText) {
// //     try {
// //       final json = jsonDecode(formattedText);
// //       _plainText = json['text'];
// //       _descriptionController.text = _plainText;

// //       _richTextSpans =
// //           (json['spans'] as List).map((span) {
// //             return TextSpan(
// //               text: span['text'],
// //               style: TextStyle(
// //                 fontWeight: span['bold'] ? FontWeight.bold : null,
// //                 fontStyle: span['italic'] ? FontStyle.italic : null,
// //                 decoration: span['underline'] ? TextDecoration.underline : null,
// //                 color: span['color'] != null ? Color(span['color']) : null,
// //                 backgroundColor:
// //                     span['highlight'] != null ? Color(span['highlight']) : null,
// //                 fontSize: span['fontSize']?.toDouble(),
// //                 fontFamily: span['fontFamily'],
// //               ),
// //             );
// //           }).toList();
// //     } catch (e) {
// //       _plainText = widget.event['description'] ?? '';
// //       _descriptionController.text = _plainText;
// //       _richTextSpans = [TextSpan(text: _plainText)];
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _titleController.dispose();
// //     _descriptionController.dispose();
// //     _descriptionFocusNode.dispose();
// //     super.dispose();
// //   }

// //   void _saveChanges() {
// //     final spansJson =
// //         _richTextSpans.map((span) {
// //           return {
// //             'text': span.text,
// //             'bold': span.style?.fontWeight == FontWeight.bold,
// //             'italic': span.style?.fontStyle == FontStyle.italic,
// //             'underline': span.style?.decoration == TextDecoration.underline,
// //             'color': span.style?.color?.value,
// //             'highlight': span.style?.backgroundColor?.value,
// //             'fontSize': span.style?.fontSize,
// //             'fontFamily': span.style?.fontFamily,
// //           };
// //         }).toList();

// //     final updates = {
// //       "title": _titleController.text,
// //       "description": _plainText,
// //       "formattedText": jsonEncode({"text": _plainText, "spans": spansJson}),
// //     };

// //     widget.updateCallback(updates, widget.event['id']);
// //     Navigator.pop(context);
// //   }

// //   // ... [keep all other methods unchanged] ...

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Edit Event'),
// //         actions: [
// //           IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           // Title field
// //           Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: TextField(
// //               controller: _titleController,
// //               decoration: const InputDecoration(
// //                 labelText: 'Title',
// //                 border: OutlineInputBorder(),
// //               ),
// //               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //           ),

// //           // Formatting toolbar
// //           Container(
// //             height: 50,
// //             color: Colors.grey[200],
// //             child: SingleChildScrollView(
// //               scrollDirection: Axis.horizontal,
// //               child: Row(
// //                 children: [
// //                   // ... [keep all toolbar buttons unchanged] ...
// //                 ],
// //               ),
// //             ),
// //           ),

// //           // Description editor - using TextSelectionGestureDetector
// //           Expanded(
// //             child: Padding(
// //               padding: const EdgeInsets.all(16.0),
// //               child: TextSelectionGestureDetector(
// //                 onSelectionChanged: (selection, _) {
// //                   setState(() {
// //                     _currentSelection = selection;
// //                   });
// //                   _updateCurrentStyleFromSelection();
// //                 },
// //                 child: TextField(
// //                   controller: _descriptionController,
// //                   focusNode: _descriptionFocusNode,
// //                   maxLines: null,
// //                   keyboardType: TextInputType.multiline,
// //                   decoration: const InputDecoration(
// //                     border: OutlineInputBorder(),
// //                     hintText: 'Enter description...',
// //                   ),
// //                   onChanged: (text) {
// //                     if (text != _plainText) {
// //                       _plainText = text;
// //                       // In a full implementation, you'd update spans here
// //                       // This is simplified for demonstration
// //                       _richTextSpans = [TextSpan(text: text)];
// //                     }
// //                   },
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // ... [keep ColorPickerDialog implementation unchanged] ...

import 'package:flutter/material.dart';

class UpdateEventScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final Function(Map<String, dynamic>, String) updateCallback;

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
    };

    widget.updateCallback(updates, widget.event['id']);
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
