import 'package:flutter/material.dart';

/// HOW TO IMPLEMENT MAPS LATER:
/// 1. Add `google_maps_flutter` (or `flutter_map` for open source) to pubspec.yaml
/// 2. For Google Maps, you need to get an API Key from Google Cloud Console.
/// 3. Add the API Key to:
///    - Android: `android/app/src/main/AndroidManifest.xml` inside `<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_KEY"/>`
///    - Web: `web/index.html` as a `<script>` tag.
/// 4. Replace this placeholder with the `GoogleMap` widget provided by the package.
///    Example:
///    ```dart
///    GoogleMap(
///      initialCameraPosition: CameraPosition(target: LatLng(37.4, -122.0), zoom: 14),
///      markers: _markers,
///    )
///    ```
class MapPlaceholderWidget extends StatelessWidget {
  const MapPlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map, size: 48, color: Colors.green),
            SizedBox(height: 8),
            Text(
              "Map Integration Placeholder",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Replace with GoogleMap widget.\nSee map_placeholder.dart for instructions.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
