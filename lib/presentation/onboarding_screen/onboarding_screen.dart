import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/supabase_service.dart';
import '../../services/profile_service.dart';
import '../../services/dicebear_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDob;
  String _selectedStyle = 'adventurer';
  bool _isLoading = false;

  static const List<String> _avatarStyles = [
    'adventurer',
    'avataaars',
    'bottts',
    'fun-emoji',
    'lorelei',
    'notionists',
    'pixel-art',
    'thumbs',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final thirteenYearsAgo = DateTime(now.year - 13, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? thirteenYearsAgo,
      firstDate: DateTime(1920),
      lastDate: thirteenYearsAgo,
    );

    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  Future<void> _onGetStarted() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDob == null) {
      Fluttertoast.showToast(msg: 'Please select your date of birth');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseService.instance.getCurrentUserId();
      if (userId == null) {
        Fluttertoast.showToast(msg: 'Not signed in');
        setState(() => _isLoading = false);
        return;
      }

      final profileService = ProfileService();
      await profileService.completeOnboarding(
        userId: userId,
        displayName: _nameController.text.trim(),
        dateOfBirth: _selectedDob!,
        dicebearSeed: _nameController.text.trim(),
        dicebearStyle: _selectedStyle,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/main');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Something went wrong. Please try again.');
      setState(() => _isLoading = false);
    }
  }

  String get _avatarSeed =>
      _nameController.text.isEmpty ? 'user' : _nameController.text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Welcome section
                Text(
                  'Welcome to DAYLIFE',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set up your profile to begin your journey',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha:0.6),
                      ),
                ),
                const SizedBox(height: 32),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),

                // Date of birth
                InkWell(
                  onTap: _pickDateOfBirth,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of birth',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _selectedDob != null
                          ? '${_selectedDob!.month}/${_selectedDob!.day}/${_selectedDob!.year}'
                          : 'Tap to select your date of birth',
                      style: _selectedDob != null
                          ? null
                          : TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha:0.4),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Avatar section
                Text(
                  'Choose your avatar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _avatarStyles.length,
                  itemBuilder: (context, index) {
                    final style = _avatarStyles[index];
                    final isSelected = style == _selectedStyle;
                    final url = DiceBearService.getAvatarUrl(
                      _avatarSeed,
                      style: style,
                    );

                    return GestureDetector(
                      onTap: () => setState(() => _selectedStyle = style),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: const Color(0xFFC0C0C0),
                                  width: 3,
                                )
                              : null,
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: url,
                              placeholder: (context, url) => const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.person),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Fluttertoast.showToast(msg: 'Coming soon');
                    },
                    child: const Text('Upload photo'),
                  ),
                ),
                const SizedBox(height: 32),

                // Get Started button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onGetStarted,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Get Started'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
