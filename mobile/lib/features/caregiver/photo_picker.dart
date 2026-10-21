import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme.dart';
import 'camera_screen.dart';

/// Max photos picked from the gallery at once.
const maxGalleryPhotos = 10;

/// Asks "Kamera" or "Galeri" and returns the chosen image paths; empty when
/// cancelled. The gallery allows several photos at once.
Future<List<String>> pickPhotos(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Tambah foto', style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                _SourceTile(icon: Icons.photo_camera, label: 'Kamera', source: ImageSource.camera),
                const SizedBox(width: 12),
                _SourceTile(icon: Icons.photo_library, label: 'Galeri', source: ImageSource.gallery),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (source == null || !context.mounted) return const [];
  if (source == ImageSource.camera) {
    final path = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const CameraScreen()));
    return path == null ? const [] : [path];
  }
  final files = await ImagePicker().pickMultiImage(limit: maxGalleryPhotos);
  return [for (final f in files) f.path];
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.icon, required this.label, required this.source});

  final IconData icon;
  final String label;
  final ImageSource source;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Material(
      color: AppColors.brand.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pop(context, source),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, size: 36, color: AppColors.brand),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.brand),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
