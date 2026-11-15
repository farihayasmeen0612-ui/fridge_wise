import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/presentation/components/app_button.dart';
import '../../../../core/presentation/components/app_confirm_dialog.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../auth/data/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = false;

  void _showEditProfileSheet(BuildContext context, AuthUserState user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final colors = Theme.of(bottomSheetContext).extension<AppColorsExtension>() ?? AppColorsExtension.light;
        final colorScheme = Theme.of(bottomSheetContext).colorScheme;

        return StatefulBuilder(
          builder: (dialogContext, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(dialogContext).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: colors.cardBorder)),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.cardBorder,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Edit Profile Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Update your personal profile details below.',
                        style: TextStyle(fontSize: 13, color: colors.textSecondary),
                      ),
                      const SizedBox(height: 20),

                      // Full Name
                      Text(
                        'Full Name',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                          hintText: 'Enter your full name',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Address
                      Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          hintText: 'name@example.com',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Note: Updating your email triggers Firebase Authentication verification.',
                        style: TextStyle(fontSize: 11, color: colors.textSecondary),
                      ),
                      const SizedBox(height: 16),

                      // Phone Number
                      Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                          hintText: '+1 (555) 000-0000',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: colors.cardBorder),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.pop(bottomSheetContext),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              label: 'Save Changes',
                              isLoading: _isLoading,
                              variant: AppButtonVariant.primary,
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  Navigator.pop(bottomSheetContext);
                                  setState(() => _isLoading = true);
                                  await ref.read(authProvider.notifier).updateProfile(
                                        name: nameController.text.trim(),
                                        email: emailController.text.trim(),
                                        phone: phoneController.text.trim(),
                                      );
                                  if (!mounted) return;
                                  setState(() => _isLoading = false);
                                  final currentColors = Theme.of(this.context).extension<AppColorsExtension>() ?? AppColorsExtension.light;
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Profile updated successfully.'),
                                      backgroundColor: currentColors.freshnessSuccess,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final colors = Theme.of(bottomSheetContext).extension<AppColorsExtension>() ?? AppColorsExtension.light;
        final colorScheme = Theme.of(bottomSheetContext).colorScheme;

        return StatefulBuilder(
          builder: (dialogContext, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(dialogContext).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: colors.cardBorder)),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.cardBorder,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enter your current and new password to update security credentials.',
                        style: TextStyle(fontSize: 13, color: colors.textSecondary),
                      ),
                      const SizedBox(height: 20),

                      // Current Password
                      Text(
                        'Current Password',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: currentPassController,
                        obscureText: obscureCurrent,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                          hintText: 'Enter current password',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 18,
                            ),
                            onPressed: () => setSheetState(() => obscureCurrent = !obscureCurrent),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your current password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // New Password
                      Text(
                        'New Password',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: newPassController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20),
                          hintText: 'Minimum 6 characters',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 18,
                            ),
                            onPressed: () => setSheetState(() => obscureNew = !obscureNew),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      Text(
                        'Confirm New Password',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: confirmPassController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                          hintText: 'Re-enter new password',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 18,
                            ),
                            onPressed: () => setSheetState(() => obscureConfirm = !obscureConfirm),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value != newPassController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: colors.cardBorder),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.pop(bottomSheetContext),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              label: 'Update Password',
                              variant: AppButtonVariant.primary,
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  Navigator.pop(bottomSheetContext);
                                  setState(() => _isLoading = true);
                                  try {
                                    await ref.read(authProvider.notifier).updatePassword(
                                          currentPassword: currentPassController.text,
                                          newPassword: newPassController.text,
                                        );
                                    if (!mounted) return;
                                    setState(() => _isLoading = false);
                                    final currentColors = Theme.of(this.context).extension<AppColorsExtension>() ?? AppColorsExtension.light;
                                    ScaffoldMessenger.of(this.context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Password updated securely.'),
                                        backgroundColor: currentColors.freshnessSuccess,
                                      ),
                                    );
                                  } on AuthException catch (e) {
                                    if (!mounted) return;
                                    setState(() => _isLoading = false);
                                    ScaffoldMessenger.of(this.context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.message),
                                        backgroundColor: const Color(0xFFDC2626),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    setState(() => _isLoading = false);
                                    ScaffoldMessenger.of(this.context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to update password: ${e.toString()}'),
                                        backgroundColor: const Color(0xFFDC2626),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  ImageProvider? _getImageProvider(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      return NetworkImage(photoUrl);
    }
    return FileImage(File(photoUrl));
  }

  Future<void> _pickAndUploadPhoto(ImageSource source, AuthUserState user) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile == null || !mounted) return;

      setState(() => _isLoading = true);
      final bytes = await pickedFile.readAsBytes();
      final client = supabaseClient;
      String? photoUrl;
      if (client != null && user.uid.isNotEmpty) {
        final extension = pickedFile.name.split('.').last.toLowerCase();
        final safeExtension = (extension == 'png') ? 'png' : 'jpg';
        final filename = 'avatar_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.$safeExtension';
        await client.storage.from(SupabaseConstants.storageBucket).uploadBinary(
              filename,
              bytes,
              fileOptions: FileOptions(
                contentType: 'image/$safeExtension',
                upsert: true,
              ),
            );
        photoUrl = SupabaseConstants.getPublicPhotoUrl(filename);
      } else {
        photoUrl = pickedFile.path;
      }

      await ref.read(authProvider.notifier).updatePhoto(photoUrl);
      if (!mounted) return;
      final currentColors = Theme.of(context).extension<AppColorsExtension>() ?? AppColorsExtension.light;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile photo updated successfully.'),
          backgroundColor: currentColors.freshnessSuccess,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final currentColors = Theme.of(context).extension<AppColorsExtension>() ?? AppColorsExtension.light;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update photo: $e'),
          backgroundColor: currentColors.dangerRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPhotoOptions(BuildContext context, AuthUserState user) {
    final colors = Theme.of(context).extension<AppColorsExtension>() ?? AppColorsExtension.light;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Profile Picture',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Icon(Icons.photo_library_outlined, color: colorScheme.primary),
                  title: const Text('Choose from Gallery'),
                  subtitle: const Text('Pick an image from your device photos'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickAndUploadPhoto(ImageSource.gallery, user);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt_outlined, color: colorScheme.primary),
                  title: const Text('Take Photo'),
                  subtitle: const Text('Use camera to take a new picture'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickAndUploadPhoto(ImageSource.camera, user);
                  },
                ),
                if (user.photoUrl != null)
                  ListTile(
                    leading: Icon(Icons.delete_outline_rounded, color: colors.dangerRed),
                    title: Text(
                      'Remove Photo',
                      style: TextStyle(color: colors.dangerRed, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Reset to default initials avatar'),
                    onTap: () async {
                      Navigator.pop(bottomSheetContext);
                      setState(() => _isLoading = true);
                      await ref.read(authProvider.notifier).updatePhoto(null);
                      if (!mounted) return;
                      setState(() => _isLoading = false);
                      final currentColors = Theme.of(this.context).extension<AppColorsExtension>() ?? AppColorsExtension.light;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: const Text('Profile photo removed. Restored default avatar.'),
                          backgroundColor: currentColors.freshnessSuccess,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSignOut() async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Sign Out?',
      message: 'Are you sure you want to sign out of your smart fridge profile?',
      confirmLabel: 'Sign Out',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).signOut();
      if (mounted) {
        context.go('/auth/login');
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete Account?',
      message:
          'This action is permanent. All your smart fridge items, logs, and account records will be permanently erased.',
      confirmLabel: 'Delete Forever',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      await ref.read(authProvider.notifier).deleteAccount();
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/auth/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                children: [
                  // 1. Profile Picture Hero Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: colors.freshnessContainer,
                          backgroundImage: _getImageProvider(user.photoUrl),
                          child: user.photoUrl == null || user.photoUrl!.isEmpty
                              ? Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: colors.freshnessSuccess,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Material(
                            color: colorScheme.primary,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _showPhotoOptions(context, user),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Display Name
                  Center(
                    child: Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Personal Information Card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PERSONAL INFORMATION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () => _showEditProfileSheet(context, user),
                        icon: const Icon(Icons.edit_outlined, size: 15),
                        label: const Text('Edit Profile', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        _InfoTile(
                          icon: Icons.person_outline_rounded,
                          label: 'Full Name',
                          value: user.name,
                          colors: colors,
                          colorScheme: colorScheme,
                        ),
                        Divider(height: 1, thickness: 1, color: colors.cardBorder.withValues(alpha: 0.5)),
                        _InfoTile(
                          icon: Icons.email_outlined,
                          label: 'Email Address',
                          value: user.email,
                          colors: colors,
                          colorScheme: colorScheme,
                        ),
                        Divider(height: 1, thickness: 1, color: colors.cardBorder.withValues(alpha: 0.5)),
                        _InfoTile(
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                          value: user.phone.isNotEmpty ? user.phone : 'Not provided',
                          colors: colors,
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Security Section
                  Text(
                    'SECURITY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showChangePasswordSheet(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.lock_reset_rounded,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Change Password',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Update your Firebase Authentication password',
                                      style: TextStyle(fontSize: 12, color: colors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: colors.textSecondary, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 4. Account Management
                  Text(
                    'ACCOUNT ACTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                            ),
                            leading: Icon(Icons.logout_rounded, color: colorScheme.onSurface),
                            title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: const Text('End your session on this device'),
                            trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                            onTap: _handleSignOut,
                          ),
                          Divider(height: 1, thickness: 1, color: colors.cardBorder.withValues(alpha: 0.5)),
                          ListTile(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                            ),
                            leading: Icon(Icons.delete_forever_rounded, color: colors.dangerRed),
                            title: Text(
                              'Delete Account',
                              style: TextStyle(color: colors.dangerRed, fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text('Permanently remove all user data'),
                            trailing: Icon(Icons.chevron_right_rounded, size: 20, color: colors.dangerRed),
                            onTap: _handleDeleteAccount,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    required this.colorScheme,
  });

  final IconData icon;
  final String label;
  final String value;
  final AppColorsExtension colors;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}