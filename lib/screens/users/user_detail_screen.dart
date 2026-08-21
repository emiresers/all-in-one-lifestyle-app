import 'package:flutter/material.dart';

import '../../core/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user.dart';

import '../../services/user_service.dart';

import '../auth/login_screen.dart';
import 'edit_user_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;
  final bool showSignOut;

  const UserDetailScreen({
    super.key,
    required this.userId,
    this.showSignOut = false,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final UserService _userService = UserService();

  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();

    _loadUser();
  }

  void _loadUser() {
    _userFuture = _userService.getUser(widget.userId);
  }

  Future<void> _openEditScreen(User user) async {
    final result = await Navigator.push<bool>(
      context,

      AppPageRoute.to(EditUserScreen(user: user)),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        _loadUser();
      });
    }
  }

  Future<void> _deleteUser(User user) async {
    final shouldDelete = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          title: const Text(
            'Delete User',

            style: TextStyle(fontWeight: FontWeight.w700),
          ),

          content: Text('Are you sure you want to delete ${user.fullName}?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _userService.deleteUser(user.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not delete user: $e')));
    }
  }

  Future<void> _confirmSignOut() async {
    final bool? shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true || !mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      AppPageRoute.to(const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userFuture,

      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: Colors.transparent,

          appBar: AppBar(
            title: const Text(
              'User Detail',

              style: TextStyle(fontWeight: FontWeight.w700),
            ),

            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),

                tooltip: 'Edit User',

                onPressed: snapshot.hasData
                    ? () {
                        _openEditScreen(snapshot.data!);
                      }
                    : null,
              ),

              IconButton(
                icon: const Icon(Icons.delete_outline),

                tooltip: 'Delete User',

                onPressed: snapshot.hasData
                    ? () {
                        _deleteUser(snapshot.data!);
                      }
                    : null,
              ),

              const SizedBox(width: 8),
            ],
          ),

          body: _buildBody(snapshot),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<User> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return _UserDetailError(
        message: snapshot.error.toString(),

        onRetry: () {
          setState(() {
            _loadUser();
          });
        },
      );
    }

    if (!snapshot.hasData) {
      return const Center(child: Text('User not found.'));
    }

    final user = snapshot.data!;

    return SafeArea(
      top: false,

      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            // PROFILE

            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),

              decoration: BoxDecoration(
                color: AppColors.surface,

                borderRadius: BorderRadius.circular(26),

                border: Border.all(color: AppColors.border),

                boxShadow: AppColors.softShadow,
              ),

              child: Column(
                children: [
                  Container(
                    width: 146,

                    height: 146,

                    padding: const EdgeInsets.all(5),

                    decoration: BoxDecoration(
                      color: AppColors.surface,

                      shape: BoxShape.circle,

                      border: Border.all(color: AppColors.border, width: 2),
                    ),

                    child: ClipOval(
                      // Listedeki avatarla eşleşen Hero geçişi.
                      child: Hero(
                        tag: 'user-${user.id}',
                        child: Image.network(
                          user.image,

                          fit: BoxFit.cover,

                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surfaceSecondary,

                              child: const Icon(
                                Icons.person_outline_rounded,

                                size: 58,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    user.fullName,

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 28,

                      fontWeight: FontWeight.w800,

                      letterSpacing: -0.7,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '@${user.username}',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 15,

                      color: AppColors.textSecondary,

                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,

                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      _formatGender(user.gender),

                      style: TextStyle(
                        fontSize: 12.5,

                        fontWeight: FontWeight.w600,

                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Personal Information',

              style: TextStyle(
                fontSize: 20,

                fontWeight: FontWeight.w800,

                letterSpacing: -0.4,
              ),
            ),

            const SizedBox(height: 12),

            _ModernUserInfoCard(
              icon: Icons.email_outlined,

              title: 'Email',

              value: user.email,
            ),

            _ModernUserInfoCard(
              icon: Icons.phone_outlined,

              title: 'Phone',

              value: user.phone,
            ),

            _ModernUserInfoCard(
              icon: Icons.cake_outlined,

              title: 'Age',

              value: '${user.age}',
            ),

            _ModernUserInfoCard(
              icon: Icons.person_outline,

              title: 'Gender',

              value: _formatGender(user.gender),
            ),

            if (user.maidenName.isNotEmpty)
              _ModernUserInfoCard(
                icon: Icons.badge_outlined,

                title: 'Maiden Name',

                value: user.maidenName,
              ),

            if (widget.showSignOut) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _confirmSignOut,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    side: BorderSide(
                      color: AppColors.danger.withValues(alpha: 0.28),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatGender(String gender) {
    if (gender.isEmpty) {
      return 'Unknown';
    }

    return '${gender[0].toUpperCase()}${gender.substring(1)}';
  }
}

class _ModernUserInfoCard extends StatelessWidget {
  final IconData icon;

  final String title;

  final String value;

  const _ModernUserInfoCard({
    required this.icon,

    required this.title,

    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: AppColors.border),
      ),

      child: Row(
        children: [
          Container(
            width: 44,

            height: 44,

            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,

              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, size: 21),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: TextStyle(
                    fontSize: 12.5,

                    color: AppColors.textTertiary,

                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                // Uzun e-posta adresi satır sonunda kelime ortasından
                // bölünmesin: sığmadığında kısalmak yerine ölçeklenir.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    softWrap: false,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserDetailError extends StatelessWidget {
  final String message;

  final VoidCallback onRetry;

  const _UserDetailError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.error_outline_rounded, size: 52),

            const SizedBox(height: 16),

            const Text(
              'User couldn’t be loaded',

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            Text(
              message,

              textAlign: TextAlign.center,

              style: TextStyle(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: onRetry,

              icon: const Icon(Icons.refresh_rounded),

              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
