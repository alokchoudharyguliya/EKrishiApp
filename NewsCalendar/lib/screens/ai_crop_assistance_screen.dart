import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AICropAssistantScreen extends StatefulWidget {
  const AICropAssistantScreen({Key? key}) : super(key: key);

  @override
  State<AICropAssistantScreen> createState() => _AICropAssistantScreenState();
}

class _AICropAssistantScreenState extends State<AICropAssistantScreen> {
  int _step = 0;
  String? _selectedType;
  File? _imageFile;
  final _cropController = TextEditingController();
  final _problemController = TextEditingController();
  final _ageController = TextEditingController();
  bool? _recentWeather;
  bool _loading = false;
  String? _aiResult;

  final List<String> _types = ['Leaf', 'Stem', 'Soil', 'Whole Plant'];
  final List<String> _crops = ['Wheat', 'Rice', 'Sugarcane', 'Maize', 'Other'];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _nextStep() {
    setState(() {
      _step++;
    });
  }

  void _prevStep() {
    setState(() {
      if (_step > 0) _step--;
    });
  }

  Future<void> _analyze() async {
    setState(() {
      _loading = true;
    });
    // Simulate AI analysis delay
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _loading = false;
      _aiResult =
          "Possible diagnosis: Early blight detected.\n\n"
          "Suggestions:\n"
          "- Remove affected leaves\n"
          "- Apply recommended fungicide\n"
          "- Ensure proper drainage\n\n"
          "References:\n"
          "• https://agri-research.org/early-blight\n"
          "• https://youtube.com/watch?v=example";
      _step++;
    });
  }

  @override
  void dispose() {
    _cropController.dispose();
    _problemController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Crop Assistant'),
        backgroundColor: Colors.green[700],
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _step,
        onStepContinue: () async {
          if (_step == 0 && _selectedType != null) {
            _nextStep();
          } else if (_step == 1 && _imageFile != null) {
            _nextStep();
          } else if (_step == 2 &&
              _cropController.text.isNotEmpty &&
              _problemController.text.isNotEmpty &&
              _ageController.text.isNotEmpty &&
              _recentWeather != null) {
            await _analyze();
          } else if (_step == 3) {
            Navigator.pop(context);
          }
        },
        onStepCancel: _prevStep,
        controlsBuilder: (context, details) {
          return Row(
            children: [
              if (_step < 3)
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(_step == 2 ? 'Analyze' : 'Next'),
                ),
              if (_step > 0 && _step < 3)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Back'),
                ),
              if (_step == 3)
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
            ],
          );
        },
        steps: [
          Step(
            title: const Text('Select Image Type'),
            isActive: _step >= 0,
            content: Wrap(
              spacing: 12,
              children:
                  _types.map((type) {
                    return ChoiceChip(
                      label: Text(type),
                      selected: _selectedType == type,
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                    );
                  }).toList(),
            ),
          ),
          Step(
            title: const Text('Upload Image'),
            isActive: _step >= 1,
            content: Column(
              children: [
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Image.file(_imageFile!, height: 160),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Answer Questions'),
            isActive: _step >= 2,
            content: Column(
              children: [
                DropdownButtonFormField<String>(
                  value:
                      _cropController.text.isNotEmpty
                          ? _cropController.text
                          : null,
                  decoration: const InputDecoration(labelText: 'Crop Type'),
                  items:
                      _crops
                          .map(
                            (crop) => DropdownMenuItem(
                              value: crop,
                              child: Text(crop),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (val) => setState(() => _cropController.text = val ?? ''),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _problemController,
                  decoration: const InputDecoration(
                    labelText: 'Observed Problem',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Plant Age (days)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Recent Weather Event?'),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text('Yes'),
                      selected: _recentWeather == true,
                      onSelected:
                          (selected) => setState(() => _recentWeather = true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('No'),
                      selected: _recentWeather == false,
                      onSelected:
                          (selected) => setState(() => _recentWeather = false),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Step(
            title: const Text('AI Diagnosis'),
            isActive: _step >= 3,
            content:
                _loading
                    ? const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : _aiResult != null
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_aiResult!, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.medical_information),
                          label: const Text('Contact Expert'),
                          onPressed: () {
                            Navigator.pushNamed(context, '/doctor-contact');
                          },
                        ),
                      ],
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
