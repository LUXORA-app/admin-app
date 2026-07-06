import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api_config.dart';
import '../../core/app_localizations.dart';
import '../../core/admin_data_store.dart';
import '../../widgets/app_background.dart';
import 'details_screen.dart';

class LandmarksAdminScreen extends StatefulWidget {
  const LandmarksAdminScreen({super.key});

  @override
  State<LandmarksAdminScreen> createState() => _LandmarksAdminScreenState();
}

class _LandmarksAdminScreenState extends State<LandmarksAdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminDataStore>().fetchLandmarks();
    });
  }

  void _showLandmarkEditor(BuildContext context, Landmark? existing) {
    final isNew = existing == null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final latCtrl = TextEditingController(
      text: existing != null ? '${existing.lat}' : '',
    );
    final lngCtrl = TextEditingController(
      text: existing != null ? '${existing.lng}' : '',
    );
    final photoCtrl = TextEditingController(text: existing?.photoUrl ?? '');
    File? selectedFile;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final modalLoc = AppLocalizations.of(ctx);
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isNew
                          ? modalLoc.translate('addLandmark')
                          : modalLoc.translate('editLandmark'),
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(labelText: modalLoc.translate('name')),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      decoration: InputDecoration(labelText: modalLoc.translate('description')),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: latCtrl,
                            decoration: InputDecoration(
                              labelText: modalLoc.translate('latitude'),
                              hintText: modalLoc.translate('latHint'),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: lngCtrl,
                            decoration: InputDecoration(
                              labelText: modalLoc.translate('longitude'),
                              hintText: modalLoc.translate('lngHint'),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      modalLoc.translate('landmarkImage'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (selectedFile != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              selectedFile!,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                onPressed: () => setModalState(() => selectedFile = null),
                                icon: const Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      if (existing != null && existing.photoUrl.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _LandmarkImage(url: existing.photoUrl, height: 120),
                          ),
                        ),
                      TextField(
                        controller: photoCtrl,
                        decoration: InputDecoration(
                          labelText: modalLoc.translate('photoUrl'),
                          hintText: modalLoc.translate('httpsHint'),
                          suffixIcon: IconButton(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final img = await picker.pickImage(source: ImageSource.gallery);
                              if (img != null) {
                                setModalState(() {
                                  selectedFile = File(img.path);
                                  photoCtrl.clear();
                                });
                              }
                            },
                            icon: const Icon(Icons.add_photo_alternate_outlined),
                            tooltip: modalLoc.translate('pickFromDevice'),
                          ),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final desc = descCtrl.text.trim();
                        final photo = photoCtrl.text.trim();
                        final latText = latCtrl.text.trim();
                        final lngText = lngCtrl.text.trim();

                        if (name.isEmpty) {
                          _showToast(ctx, modalLoc.translate('nameRequired'));
                          return;
                        }

                        final lat = double.tryParse(latText);
                        if (lat == null || lat < -90 || lat > 90) {
                          _showToast(ctx, modalLoc.translate('latitudeRange'));
                          return;
                        }

                        final lng = double.tryParse(lngText);
                        if (lng == null || lng < -180 || lng > 180) {
                          _showToast(ctx, modalLoc.translate('longitudeRange'));
                          return;
                        }

                        if (photo.isEmpty && selectedFile == null) {
                          _showToast(ctx, modalLoc.translate('photoRequired'));
                          return;
                        }

                        final store = context.read<AdminDataStore>();
                        if (isNew) {
                          store
                              .addLandmark(
                            name: name,
                            description: desc,
                            lat: lat,
                            lng: lng,
                            photoUrl: photo.isNotEmpty ? photo : null,
                            imageFile: selectedFile,
                          )
                              .catchError((e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                            );
                          });
                        } else {
                          store
                              .updateLandmark(
                            existing,
                            name: name,
                            description: desc,
                            lat: lat,
                            lng: lng,
                            photoUrl: photo.isNotEmpty ? photo : null,
                            imageFile: selectedFile,
                          )
                              .catchError((e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                            );
                          });
                        }
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        isNew
                            ? modalLoc.translate('addLandmark')
                            : modalLoc.translate('saveChanges'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showToast(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Landmark lm) async {
    final loc = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.translate('deleteLandmark')),
        content: Text(
          loc.translateWith('removeLandmarkConfirm', {'name': lm.name}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.translate('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.translate('delete')),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      try {
        await context.read<AdminDataStore>().deleteLandmark(lm);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  List<List<Landmark>> _pairs(List<Landmark> items) {
    final out = <List<Landmark>>[];
    for (var i = 0; i < items.length; i += 2) {
      if (i + 1 < items.length) {
        out.add([items[i], items[i + 1]]);
      } else {
        out.add([items[i]]);
      }
    }
    return out;
  }

  String _subtitle(Landmark lm) {
    final d = lm.description.trim();
    if (d.isEmpty) {
      return '${lm.lat.toStringAsFixed(4)}, ${lm.lng.toStringAsFixed(4)}';
    }
    final line = d.split(RegExp(r'\s+')).take(8).join(' ');
    return line.length < d.length ? '$line…' : line;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return AppBackground(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Consumer<AdminDataStore>(
                builder: (context, store, _) {
                  if (store.loadingLandmarks && store.landmarks.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (store.lastError != null && store.landmarks.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          store.lastError!,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  final items = store.landmarks;
                  final bottomInset =
                      MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/images/logo_trans.png',
                              height: screenHeight * 0.14,
                              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  loc.translate('landmarks'),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                loc.translate('addShort'),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _showLandmarkEditor(context, null),
                                icon: Icon(Icons.add_location_alt_outlined, color: theme.colorScheme.primary),
                                tooltip: loc.translate('addLandmark'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (items.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Center(
                                child: Text(
                                  loc.translate('noLandmarksEmpty'),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          else
                            ..._pairs(items).map((pair) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _landmarksRow(
                                  context,
                                  pair,
                                  screenHeight,
                                  onOpen: (lm) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetailsPage.fromLandmark(lm),
                                      ),
                                    );
                                  },
                                  onEdit: (lm) => _showLandmarkEditor(context, lm),
                                  onDelete: (lm) => _confirmDelete(context, lm),
                                ),
                              );
                            }),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _landmarksRow(
    BuildContext context,
    List<Landmark> pair,
    double screenHeight, {
    required void Function(Landmark) onOpen,
    required void Function(Landmark) onEdit,
    required void Function(Landmark) onDelete,
  }) {
    if (pair.length == 2) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _exploreStyleLandmarkCard(
              context,
              pair[0],
              screenHeight,
              onOpen: () => onOpen(pair[0]),
              onEdit: () => onEdit(pair[0]),
              onDelete: () => onDelete(pair[0]),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _exploreStyleLandmarkCard(
              context,
              pair[1],
              screenHeight,
              onOpen: () => onOpen(pair[1]),
              onEdit: () => onEdit(pair[1]),
              onDelete: () => onDelete(pair[1]),
            ),
          ),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _exploreStyleLandmarkCard(
            context,
            pair[0],
            screenHeight,
            onOpen: () => onOpen(pair[0]),
            onEdit: () => onEdit(pair[0]),
            onDelete: () => onDelete(pair[0]),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(child: SizedBox()),
      ],
    );
  }

  Widget _exploreStyleLandmarkCard(
    BuildContext context,
    Landmark lm,
    double screenHeight, {
    required VoidCallback onOpen,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onOpen,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: _LandmarkImage(url: lm.photoUrl, height: screenHeight * 0.17),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        color: theme.colorScheme.surface.withValues(alpha: 0.92),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          icon: Icon(Icons.edit_outlined, size: 18, color: theme.colorScheme.primary),
                          onPressed: onEdit,
                          tooltip: AppLocalizations.of(context).translate('edit'),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Material(
                        color: theme.colorScheme.surface.withValues(alpha: 0.92),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                          onPressed: onDelete,
                          tooltip: AppLocalizations.of(context).translate('delete'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lm.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitle(lm),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandmarkImage extends StatelessWidget {
  const _LandmarkImage({required this.url, required this.height});

  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedUrl = ApiConfig.mediaUrl(url);

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
      url,
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
