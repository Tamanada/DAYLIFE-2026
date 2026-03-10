import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../services/supabase_service.dart';
import '../../services/profile_service.dart';
import '../../services/star_service.dart';
import '../../services/auth_service.dart';
import '../../services/dicebear_service.dart';
import '../../models/user_profile_model.dart';
import '../../models/star_transaction_model.dart';
import '../../core/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfileModel? _profile;
  Map<String, int> _stats = {};
  List<StarTransactionModel> _transactions = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = SupabaseService.instance.getCurrentUserId();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (_userId == null) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ProfileService().getProfile(_userId!),
        StarService().getStats(_userId!),
        StarService().getTransactions(_userId!, limit: 20),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = results[0] as UserProfileModel;
        _stats = results[1] as Map<String, int>;
        _transactions = results[2] as List<StarTransactionModel>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: 'Failed to load profile');
    }
  }

  void _showAvatarPicker() {
    if (_userId == null || _profile == null) return;
    String selectedStyle = _profile!.dicebearStyle;
    final seed = _profile!.dicebearSeed ?? _userId!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha:0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Choose Avatar',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                    children: AvatarStyles.all.map((style) {
                      final url =
                          AvatarStyles.url(style, seed, size: 200);
                      final isSelected = style == selectedStyle;
                      return GestureDetector(
                        onTap: () async {
                          setModalState(() => selectedStyle = style);
                          try {
                            await ProfileService()
                                .updateAvatar(_userId!, seed, style);
                            if (!mounted) return;
                            Navigator.of(ctx).pop();
                            _loadProfile();
                          } catch (e) {
                            Fluttertoast.showToast(
                                msg: 'Failed to update avatar');
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: DaylifeColors.silverBright,
                                        width: 3,
                                      )
                                    : null,
                              ),
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: url,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Icon(
                                      Icons.person,
                                      size: 32,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.person, size: 32),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DiceBearService.styleName(style),
                              style: Theme.of(context).textTheme.labelSmall,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final picked = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (picked == null) return;
                        await ProfileService()
                            .uploadProfilePhoto(_userId!, File(picked.path));
                        if (!mounted) return;
                        Navigator.of(ctx).pop();
                        _loadProfile();
                      } catch (e) {
                        Fluttertoast.showToast(
                            msg: 'Failed to upload photo');
                      }
                    },
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Upload Photo'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showStarHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha:0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Star History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _transactions.isEmpty
                        ? Center(
                            child: Text(
                              'No transactions yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha:0.5),
                                  ),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _transactions.length,
                            itemBuilder: (ctx, index) {
                              final tx = _transactions[index];
                              return ListTile(
                                leading: Icon(
                                  tx.icon,
                                  color: DaylifeColors.starYellow,
                                ),
                                title: Text(tx.displayReason),
                                trailing: Text(
                                  '+${tx.amount}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: DaylifeColors.starYellow,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                subtitle: Text(
                                  DateFormat.yMMMd().format(tx.createdAt),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha:0.5),
                                      ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: Text('Not signed in')),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return const Scaffold(
        body: Center(child: Text('Profile not found')),
      );
    }

    final profile = _profile!;
    final streak = profile.currentStreak;
    final longest = profile.longestStreak;
    final streakProgress = (streak % StarRewards.streakInterval) /
        StarRewards.streakInterval;
    final daysUntilBonus =
        StarRewards.streakInterval - (streak % StarRewards.streakInterval);

    final isDarkMode = profile.themePreference == 'dark';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Profile Header
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showAvatarPicker,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 56,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: profile.avatarUrl,
                                width: 104,
                                height: 104,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Icon(
                                  Icons.person,
                                  size: 48,
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.person, size: 48),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color:
                                    Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.displayName ?? 'Dreamer',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Day ${profile.daysLived} of $kTotalLifeDays',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha:0.6),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Star Card
              GestureDetector(
                onTap: _showStarHistory,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 32,
                        color: DaylifeColors.starYellow,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${profile.totalStars}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: DaylifeColors.starYellow,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Total Stars',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha:0.6),
                                  ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha:0.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Streak Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 28,
                          color: DaylifeColors.errorCoral,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '$streak day streak',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          'Best: $longest',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha:0.5),
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: streakProgress,
                        minHeight: 6,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha:0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          DaylifeColors.errorCoral,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$daysUntilBonus days until next streak bonus',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha:0.5),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildStatCard(
                    'Dreams Created',
                    _stats['dreams_created'] ?? 0,
                    Icons.auto_awesome,
                    DaylifeColors.starYellow,
                  ),
                  _buildStatCard(
                    'Completed',
                    _stats['dreams_completed'] ?? 0,
                    Icons.check_circle_rounded,
                    DaylifeColors.successGreen,
                  ),
                  _buildStatCard(
                    'Reflections',
                    _stats['reflections'] ?? 0,
                    Icons.edit_note_rounded,
                    DaylifeColors.cosmicPurple,
                  ),
                  _buildStatCard(
                    'Days Active',
                    _stats['days_active'] ?? 0,
                    Icons.calendar_today_rounded,
                    DaylifeColors.sandGold,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 5. Settings
              Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.dark_mode_rounded),
                title: const Text('Dark Mode'),
                contentPadding: EdgeInsets.zero,
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) async {
                    final newTheme = value ? 'dark' : 'light';
                    try {
                      await ProfileService()
                          .updateTheme(_userId!, newTheme);
                      _loadProfile();
                    } catch (e) {
                      Fluttertoast.showToast(
                          msg: 'Failed to update theme');
                    }
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('About'),
                contentPadding: EdgeInsets.zero,
                trailing: Text(
                  'v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha:0.5),
                      ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: DaylifeColors.errorCoral,
                ),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(color: DaylifeColors.errorCoral),
                ),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text(
                          'Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await AuthService().signOut();
                            if (!mounted) return;
                            Navigator.of(context)
                                .pushNamedAndRemoveUntil(
                              '/onboarding',
                              (route) => false,
                            );
                          },
                          child: const Text(
                            'Sign Out',
                            style:
                                TextStyle(color: DaylifeColors.errorCoral),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
