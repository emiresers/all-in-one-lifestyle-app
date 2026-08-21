import 'package:flutter/material.dart';

import '../../core/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/screen_ambient.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_choice_chip.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/app_skeleton.dart';
import '../../widgets/app_pressable.dart';
import '../../widgets/app_screen_header.dart';
import '../../widgets/app_search_field.dart';
import 'add_user_screen.dart';
import 'user_detail_screen.dart';

class UsersScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const UsersScreen({super.key, this.scrollController});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<User>> _usersFuture;

  String _selectedGender = 'all';

  @override
  void initState() {
    super.initState();

    _usersFuture = _userService.getUsers();
  }

  void _search(String query) {
    final cleanQuery = query.trim();

    setState(() {
      _selectedGender = 'all';

      if (cleanQuery.isEmpty) {
        _usersFuture = _userService.getUsers();
      } else {
        _usersFuture = _userService.searchUsers(cleanQuery);
      }
    });
  }

  void _filterByGender(String gender) {
    _searchController.clear();

    setState(() {
      _selectedGender = gender;

      if (gender == 'all') {
        _usersFuture = _userService.getUsers();
      } else {
        _usersFuture = _userService.filterUsers(key: 'gender', value: gender);
      }
    });
  }

  Future<void> _openAddUserScreen() async {
    final result = await Navigator.push<bool>(
      context,
      AppPageRoute.to(const AddUserScreen()),
    );

    if (!mounted) return;

    if (result == true) {
      _searchController.clear();

      setState(() {
        _selectedGender = 'all';
        _usersFuture = _userService.getUsers();
      });
    }
  }

  Future<void> _openUserDetail(User user) async {
    final result = await Navigator.push<bool>(
      context,
      AppPageRoute.to(UserDetailScreen(userId: user.id)),
    );

    if (!mounted) return;

    if (result == true) {
      _searchController.clear();

      setState(() {
        _selectedGender = 'all';
        _usersFuture = _userService.getUsers();
      });
    }
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _usersFuture = _userService.getUsers();
      _selectedGender = 'all';
      _searchController.clear();
    });

    await _usersFuture;
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      // Ekranın kendi çok hafif atmosferi; üstte sezilir, altta nötr
      // zemine kavuşur.
      body: ScreenAmbientBackground(
        ambient: ScreenAmbient.users,
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _refreshUsers,
            edgeOffset: 12,
            child: CustomScrollView(
              controller: widget.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // BAŞLIK
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH,
                      AppSpacing.lg,
                      AppSpacing.screenH,
                      0,
                    ),
                    child: AppScreenHeader(
                      title: 'Users',
                      subtitle: 'Browse and manage users',
                      action: AppHeaderButton(
                        icon: Icons.person_add_alt_1_rounded,
                        label: 'Add',
                        onTap: _openAddUserScreen,
                      ),
                    ),
                  ),
                ),

                // ARAMA
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH,
                      AppSpacing.lg,
                      AppSpacing.screenH,
                      0,
                    ),
                    child: AppSearchField(
                      controller: _searchController,
                      hintText: 'Search users',
                      onChanged: _search,
                      onClear: () {
                        _searchController.clear();

                        setState(() {
                          _selectedGender = 'all';
                          _usersFuture = _userService.getUsers();
                        });
                      },
                    ),
                  ),
                ),

                // FİLTRELER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: SizedBox(
                      height: 40,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenH,
                        ),
                        scrollDirection: Axis.horizontal,
                        children: [
                          AppChoiceChip(
                            label: 'All',
                            selected: _selectedGender == 'all',
                            onTap: () {
                              _filterByGender('all');
                            },
                          ),

                          const SizedBox(width: AppSpacing.sm),

                          AppChoiceChip(
                            label: 'Female',
                            selected: _selectedGender == 'female',
                            onTap: () {
                              _filterByGender('female');
                            },
                          ),

                          const SizedBox(width: AppSpacing.sm),

                          AppChoiceChip(
                            label: 'Male',
                            selected: _selectedGender == 'male',
                            onTap: () {
                              _filterByGender('male');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // BÖLÜM BAŞLIĞI
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH,
                      AppSpacing.xxl,
                      AppSpacing.screenH,
                      AppSpacing.md,
                    ),
                    child: AppSectionHeader(
                      title: 'People',
                      // Filtre aktifken temizleme yolu; değilken sade etiket.
                      trailingLabel: 'All users',
                      onSeeAll: _selectedGender == 'all'
                          ? null
                          : () => _filterByGender('all'),
                    ),
                  ),
                ),

                // LİSTE
                FutureBuilder<List<User>>(
                  future: _usersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(
                        child: ListCardSkeleton(cardHeight: 84),
                      );
                    }

                    if (snapshot.hasError) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppErrorState(
                          message: snapshot.error.toString(),
                          onRetry: () {
                            setState(() {
                              _usersFuture = _userService.getUsers();
                            });
                          },
                        ),
                      );
                    }

                    final users = snapshot.data ?? [];

                    if (users.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppEmptyState(
                          icon: Icons.people_outline_rounded,
                          title: 'No users found',
                          subtitle: 'Try another search or filter.',
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenH,
                        0,
                        AppSpacing.screenH,
                        AppSpacing.xxl,
                      ),
                      sliver: SliverList.separated(
                        itemCount: users.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.listGap),
                        itemBuilder: (context, index) {
                          final user = users[index];

                          return _UserCard(
                            user: user,
                            onTap: () {
                              _openUserDetail(user);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md - 2,
        ),
        child: Row(
          children: [
            // Detay ekranındaki büyük görsele Hero ile bağlanır.
            Hero(
              tag: 'user-${user.id}',
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.network(
                    user.image,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person_outline_rounded,
                        size: 24,
                        color: AppColors.textTertiary,
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Ad ve kullanıcı adı tek grup; e-posta detay ekranında.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle,
                  ),

                  const SizedBox(height: 2),

                  Text(
                    '@${user.username} · ${_formatGender(user.gender)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.metadata.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textTertiary,
            ),
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
