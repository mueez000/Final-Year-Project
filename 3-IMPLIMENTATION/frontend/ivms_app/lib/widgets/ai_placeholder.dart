import 'package:flutter/material.dart';

/// HOW TO IMPLEMENT AI (TensorFlow Lite) LATER:
/// 1. Add `tflite_flutter` and `tflite_flutter_helper` to pubspec.yaml
/// 2. Place your trained `.tflite` model files in an `assets/models/` folder.
/// 3. Update pubspec.yaml to include the assets folder.
/// 4. Create an `AIService` class (e.g. in `lib/services/ai_service.dart`) that:
///    - Loads the model: `Interpreter.fromAsset('models/your_model.tflite')`
///    - Prepares the input tensor (e.g., image from camera, or sensor data array).
///    - Runs inference: `interpreter.run(input, output)`
///    - Returns the parsed result.
/// 5. Replace this placeholder widget with your live camera feed or data display 
///    that feeds into the `AIService`.
class AIPlaceholderWidget extends StatelessWidget {
  final String title;

  const AIPlaceholderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.psychology, size: 48, color: Colors.blue),
          const SizedBox(height: 8),
          Text(
            "AI Integration Placeholder: \$title",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Replace this widget with your TFLite Inference UI.\nSee ai_placeholder.dart for instructions.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
