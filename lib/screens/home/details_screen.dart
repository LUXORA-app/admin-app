import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/api_config.dart';
import '../../core/app_localizations.dart';
import '../../core/admin_data_store.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.lat,
    required this.lng,
    required this.about,
  });

  final String title;
  final String subtitle;
  final String image;
  final double lat;
  final double lng;
  final String about;

  factory DetailsPage.fromLandmark(Landmark lm) {
    return DetailsPage(
      title: lm.name,
      subtitle: '${lm.lat.toStringAsFixed(4)}, ${lm.lng.toStringAsFixed(4)}',
      image: lm.photoUrl,
      lat: lm.lat,
      lng: lm.lng,
      about: lm.description,
    );
  }

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final LatLng location = LatLng(widget.lat, widget.lng);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        iconTheme: theme.iconTheme,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamilyFallback: const ['Arial', 'sans-serif'],
              ),
            ),
            Text(
              widget.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamilyFallback: const ['Arial', 'sans-serif'],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 220,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: location,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.admin_luxora',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: location,
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.location_on,
                        color: theme.colorScheme.primary,
                        size: 45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _DetailImage(path: widget.image, height: 160),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamilyFallback: const ['Arial', 'sans-serif'],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_pin, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFamilyFallback: const ['Arial', 'sans-serif'],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loc.translate('about'),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        widget.about.isEmpty
                            ? loc.translate('noDescriptionProvided')
                            : widget.about,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          fontFamilyFallback: const ['Arial', 'sans-serif'],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailImage extends StatelessWidget {
  const _DetailImage({required this.path, required this.height});

  final String path;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedUrl = ApiConfig.mediaUrl(path);

    if (resolvedUrl != null && resolvedUrl.startsWith('http')) {
      return Image.network(
        resolvedUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          color: theme.colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined),
        ),
      );
    }
    return Image.asset(
      path,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: theme.colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined),
      ),
    );
  }
}
