import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../widgets/app_background.dart';
import '../../core/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/api_config.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = const AuthService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();

  static const List<String> _defaultNationalities = [
    'Egyptian',
    'American',
    'French',
    'German',
    'Italian',
  ];

  late List<String> _nationalityOptions;
  String? selectedNationality;

  bool hidePassword = true;
  bool hideConfirmPassword = true;

  File? profileImage;
  final ImagePicker picker = ImagePicker();

  Map<String, dynamic>? _user;
  bool _loading = true;
  bool _saving = false;
  String? _avatarNetworkUrl;

  @override
  void initState() {
    super.initState();
    _nationalityOptions = List<String>.from(_defaultNationalities);
    _load();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    try {
      final u = await _auth.getCurrentUser();
      if (!mounted) return;
      nameController.text = u['name']?.toString() ?? '';
      emailController.text = u['email']?.toString() ?? '';
      final nat = u['nationality']?.toString();
      if (nat != null && nat.isNotEmpty && !_nationalityOptions.contains(nat)) {
        _nationalityOptions = [nat, ..._nationalityOptions];
      }
      selectedNationality = (nat != null && nat.isNotEmpty) ? nat : null;
      _avatarNetworkUrl = ApiConfig.mediaUrl(u['avatar_url']?.toString());
      _user = u;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> pickImage() async {
    PermissionStatus status;
    if (Platform.isAndroid) {
      // Check SDK version for Android
      // On Android 13+ (SDK 33), we use Permission.photos
      // For older versions, Permission.storage
      status = await Permission.photos.status;
      if (status.isDenied) {
        status = await Permission.photos.request();
      }
      // If it's still denied, try storage (for older devices)
      if (status.isDenied) {
        status = await Permission.storage.status;
        if (status.isDenied) {
          status = await Permission.storage.request();
        }
      }
    } else {
      status = await Permission.photos.status;
      if (status.isDenied) {
        status = await Permission.photos.request();
      }
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionDialog();
      }
      return;
    }

    if (status.isGranted || status.isLimited) {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          profileImage = File(image.path);
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('galleryPermissionRequired'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showPermissionDialog() {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(loc.translate('galleryPermission')),
        content: Text(loc.translate('galleryPermissionBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(loc.translate('openSettings')),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final loc = AppLocalizations.of(context);
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('pleaseEnterYourName'))),
      );
      return;
    }

    final p1 = passwordController.text;
    final p2 = passwordConfirmController.text;
    if (p1.isNotEmpty || p2.isNotEmpty) {
      if (p1 != p2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('passwordsDoNotMatch'))),
        );
        return;
      }
      if (p1.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('passwordMinLength'))),
        );
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final updated = await _auth.updateProfile(
        name: name,
        nationality: selectedNationality,
        password: p1.isNotEmpty ? p1 : null,
        passwordConfirmation: p2.isNotEmpty ? p2 : null,
        avatarFile: profileImage,
      );
      if (!mounted) return;
      passwordController.clear();
      passwordConfirmController.clear();
      setState(() {
        profileImage = null;
        _user = updated;
        _avatarNetworkUrl = ApiConfig.mediaUrl(updated['avatar_url']?.toString());
        nameController.text = updated['name']?.toString() ?? name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('profileUpdated'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final displayName = nameController.text.isNotEmpty
        ? nameController.text
        : (_user?['name']?.toString() ?? '');
    final displayEmail = emailController.text;

    return AppBackground(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      loc.translate('profile'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary,
                          child: profileImage != null
                              ? ClipOval(
                                  child: Image.file(
                                    profileImage!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : (_avatarNetworkUrl != null &&
                                      _avatarNetworkUrl!.isNotEmpty)
                                  ? ClipOval(
                                      child: Image.network(
                                        _avatarNetworkUrl!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                        ),
                        GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Text(
                      displayName.isNotEmpty ? displayName : loc.translate('emDash'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      displayEmail,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    loc.translate('editProfile'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: loc.translate('name'),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: emailController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: loc.translate('emailAddress'),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  InputDecorator(
                    decoration: InputDecoration(
                      hintText: loc.translate('nationality'),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        isExpanded: true,
                        value: selectedNationality,
                        hint: Text(loc.translate('nationality')),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(loc.translate('emDash')),
                          ),
                          ..._nationalityOptions.map((String nationality) {
                            return DropdownMenuItem<String?>(
                              value: nationality,
                              child: Text(nationality),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedNationality = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      hintText: loc.translate('newPasswordOptional'),
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: passwordConfirmController,
                    obscureText: hideConfirmPassword,
                    decoration: InputDecoration(
                      hintText: loc.translate('confirmNewPassword'),
                      suffixIcon: IconButton(
                        icon: Icon(
                          hideConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            hideConfirmPassword = !hideConfirmPassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(
                              color: theme.colorScheme.outline,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(loc.translate('cancel')),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(loc.translate('save')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
