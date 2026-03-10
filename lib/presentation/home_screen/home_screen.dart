import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/supabase_service.dart';
import '../../services/profile_service.dart';
import '../../services/quote_service.dart';
import '../../models/user_profile_model.dart';
import '../../models/quote_model.dart';
import '../../models/slogan_model.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? loginResult;

  const HomeScreen({super.key, this.loginResult});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfileModel? _profile;
  QuoteModel? _quote;
  SloganModel? _slogan;
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = SupabaseService.instance.getCurrentUserId();
    if (_userId != null) {
      _loadData();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    try {
      final profileService = ProfileService();
      final quoteService = QuoteService();

      final results = await Future.wait([
        profileService.getProfile(_userId!),
        quoteService.getDailyQuote(),
        quoteService.getDailySlogan(),
      ]);

      if (mounted) {
        setState(() {
          _profile = results[0] as UserProfileModel;
          _quote = results[1] as QuoteModel;
          _slogan = results[2] as SloganModel;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please log in',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFFF5F5F0),
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final profile = _profile;
    if (profile == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Unable to load profile',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFFF5F5F0),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 1. Profile Avatar
            Center(
              child: GestureDetector(
                onTap: () {},
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF1B2838),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: profile.avatarUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFFC0C0C0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Life Counter
            Center(
              child: Column(
                children: [
                  Text(
                    'Day #${profile.daysLived}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF5F5F0),
                        ),
                  ),
                  Text(
                    'of 30,000',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFCDB38B),
                        ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // 3. Progress Bar
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF1B2838),
              ),
              height: 24,
              child: Stack(
                children: [
                  // Background
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF1B2838),
                    ),
                  ),
                  // Foreground
                  FractionallySizedBox(
                    widthFactor: profile.lifeProgress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFC0C0C0),
                            Color(0xFFCDB38B),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Center text
                  Center(
                    child: Text(
                      '${(profile.lifeProgress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF5F5F0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Below progress bar: days lived / days remaining
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${profile.daysLived} days lived',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFC0C0C0),
                      ),
                ),
                Text(
                  '${profile.daysRemaining} days remaining',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFC0C0C0),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Quote Card
            if (_quote != null || _slogan != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.format_quote,
                      color: Color(0xFFC0C0C0),
                      size: 28,
                    ),
                    if (_quote != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _quote!.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFFF5F5F0),
                            ),
                      ),
                    ],
                    if (_slogan != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _slogan!.text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFCDB38B),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // 5. Login Result Banner (stars awarded / streak bonus)
            if (widget.loginResult != null)
              _buildStarsBanner(widget.loginResult!),
          ],
        ),
      ),
    );
  }

  Widget _buildStarsBanner(Map<String, dynamic> loginResult) {
    final starsAwarded = loginResult['stars_awarded'] as int? ?? 0;
    final streakBonus = loginResult['streak_bonus'] as int? ?? 0;
    final totalStars = starsAwarded + streakBonus;

    if (totalStars <= 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFCDB38B),
            Color(0xFFC0C0C0),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.star,
            color: Color(0xFF1B2838),
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            '+$totalStars stars',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2838),
            ),
          ),
        ],
      ),
    );
  }
}
