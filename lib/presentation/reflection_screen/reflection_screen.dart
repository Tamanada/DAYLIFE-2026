import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../services/supabase_service.dart';
import '../../services/reflection_service.dart';
import '../../models/reflection_model.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({super.key});

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  DateTime _currentDate = DateTime.now();
  ReflectionModel? _reflection;
  List<ReflectionModel> _history = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _showHistory = false;
  String? _userId;

  final TextEditingController _learnedController = TextEditingController();
  final TextEditingController _gratefulController = TextEditingController();
  final TextEditingController _improveController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userId = SupabaseService.instance.getCurrentUserId();
    _loadReflection();
  }

  @override
  void dispose() {
    _learnedController.dispose();
    _gratefulController.dispose();
    _improveController.dispose();
    super.dispose();
  }

  Future<void> _loadReflection() async {
    if (_userId == null) return;

    setState(() => _isLoading = true);

    try {
      final service = ReflectionService();
      final reflection =
          await service.getReflectionForDate(_userId!, _currentDate);
      final history =
          await service.getReflections(_userId!, limit: 10);

      if (!mounted) return;

      setState(() {
        _reflection = reflection;
        _history = history;
        _isLoading = false;
      });

      if (reflection != null) {
        _learnedController.text = reflection.learned ?? '';
        _gratefulController.text = reflection.grateful ?? '';
        _improveController.text = reflection.improve ?? '';
      } else {
        _learnedController.clear();
        _gratefulController.clear();
        _improveController.clear();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveReflection() async {
    if (_userId == null) return;

    setState(() => _isSaving = true);

    try {
      final isNew = _reflection == null;
      await ReflectionService().saveReflection(
        userId: _userId!,
        date: _currentDate,
        learned: _learnedController.text.trim(),
        grateful: _gratefulController.text.trim(),
        improve: _improveController.text.trim(),
      );

      if (!mounted) return;

      Fluttertoast.showToast(
        msg: isNew ? '+1 star!' : 'Saved!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      await _loadReflection();
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'Failed to save reflection',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _navigateDate(int days) {
    final newDate = _currentDate.add(Duration(days: days));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(newDate.year, newDate.month, newDate.day);

    if (target.isAfter(today)) return;

    setState(() => _currentDate = newDate);
    _loadReflection();
  }

  bool get _isToday {
    final now = DateTime.now();
    return _currentDate.year == now.year &&
        _currentDate.month == now.month &&
        _currentDate.day == now.day;
  }

  bool get _allFieldsEmpty =>
      _learnedController.text.trim().isEmpty &&
      _gratefulController.text.trim().isEmpty &&
      _improveController.text.trim().isEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to use reflections.')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateHeader(theme),
                    const SizedBox(height: 20),
                    _buildSection(
                      icon: Icons.nights_stay_rounded,
                      iconColor: const Color(0xFFC0C0C0),
                      label: 'What I learned today',
                      controller: _learnedController,
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      icon: Icons.star_rounded,
                      iconColor: const Color(0xFFFFD700),
                      label: 'What I\'m grateful for',
                      controller: _gratefulController,
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      icon: Icons.hourglass_bottom_rounded,
                      iconColor: const Color(0xFFCDB38B),
                      label: 'What I want to improve',
                      controller: _improveController,
                    ),
                    const SizedBox(height: 20),
                    _buildSaveButton(theme),
                    const SizedBox(height: 20),
                    _buildPastReflections(theme),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDateHeader(ThemeData theme) {
    final formatted = DateFormat('EEEE, MMMM d, yyyy').format(_currentDate);

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _navigateDate(-1),
        ),
        Expanded(
          child: Text(
            formatted,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _isToday ? null : () => _navigateDate(1),
        ),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Write here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_allFieldsEmpty || _isSaving) ? null : _saveReflection,
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Save Reflection'),
      ),
    );
  }

  Widget _buildPastReflections(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _showHistory = !_showHistory),
          child: Row(
            children: [
              Icon(
                _showHistory ? Icons.expand_less : Icons.expand_more,
              ),
              const SizedBox(width: 4),
              Text(
                'Past Reflections (${_history.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (_showHistory) ...[
          const SizedBox(height: 12),
          Column(
            children: _history.map((r) => _buildHistoryCard(r, theme)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildHistoryCard(ReflectionModel reflection, ThemeData theme) {
    final dateStr =
        DateFormat('MMM d, yyyy').format(reflection.reflectionDate);
    final preview = [
      if (reflection.learned?.isNotEmpty ?? false) reflection.learned!,
      if (reflection.grateful?.isNotEmpty ?? false) reflection.grateful!,
      if (reflection.improve?.isNotEmpty ?? false) reflection.improve!,
    ].join(' | ');

    final truncated =
        preview.length > 80 ? '${preview.substring(0, 80)}...' : preview;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateStr,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (truncated.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              truncated,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
