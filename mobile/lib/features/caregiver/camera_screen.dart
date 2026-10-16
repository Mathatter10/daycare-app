import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart' show ExifPreferences;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Full-screen camera. Pops with the captured JPEG path, or null.
/// GPS is never written into the photo, and the server strips all
/// metadata again on upload.
class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CameraAwesomeBuilder.awesome(
        saveConfig: SaveConfig.photo(
          pathBuilder: (sensors) async {
            final dir = await getTemporaryDirectory();
            return SingleCaptureRequest('${dir.path}/${const Uuid().v4()}.jpg', sensors.first);
          },
          exifPreferences: ExifPreferences(saveGPSLocation: false),
        ),
        sensorConfig: SensorConfig.single(
          sensor: Sensor.position(SensorPosition.back),
          flashMode: FlashMode.auto,
          aspectRatio: CameraAspectRatios.ratio_4_3,
        ),
        enablePhysicalButton: true,
        onMediaCaptureEvent: (event) {
          if (event.status != MediaCaptureStatus.success || !event.isPicture) return;
          event.captureRequest.when(
            single: (single) {
              final path = single.file?.path;
              if (path != null && context.mounted) Navigator.pop(context, path);
            },
          );
        },
      ),
    );
  }
}
