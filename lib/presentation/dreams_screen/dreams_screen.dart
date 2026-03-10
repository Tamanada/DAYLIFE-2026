import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../services/supabase_service.dart';
import '../../services/dream_service.dart';
import '../../models/dream_model.dart';
import '../../core/constants.dart';

class DreamsScreen extends StatefulWidget {
  const DreamsScreen({super.key});

  @override
  State<DreamsScreen> createState() => _DreamsScreenState();
}

class _DreamsScreenState extends State<DreamsScreen> {
  DateTime _selectedMonth = DateTime.now();
  DateTime? _selectedDay;
  List<DreamModel> _dreams = [];
  bool _isLoading = true;
  bool _completedExpanded = false;

  final DreamService _dreamService = DreamService();

  @override
  void initState() {
    super.initState();
    _loadDreams();
  }

  Future<void> _loadDreams() async {
    final userId = SupabaseService.instance.getCurrentUserId();
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final dreams = await _dreamService.getDreams(userId);
      setState(() {
        _dreams = dreams;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<DreamModel> get _inProgressDreams =>
      _dreams.where((d) => !d.isCompleted).toList();

  List<DreamModel> get _completedDreams =>
      _dreams.where((d) => d.isCompleted).toList();

  bool _hasDreamOnDay(DateTime day) {
    return _dreams.any((d) =>
        d.deadline != null &&
        d.deadline!.year == day.year &&
        d.deadline!.month == day.month &&
        d.deadline!.day == day.day);
  }

  Color? _dreamColorOnDay(DateTime day) {
    final dream = _dreams.cast<DreamModel?>().firstWhere(
          (d) =>
              d!.deadline != null &&
              d.deadline!.year == day.year &&
              d.deadline!.month == day.month &&
              d.deadline!.day == day.day,
          orElse: () => null,
        );
    return dream?.color;
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
      _selectedDay = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
      );
      _selectedDay = null;
    });
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _firstWeekdayOffset(DateTime date) {
    // Monday = 0, Sunday = 6
    final weekday = DateTime(date.year, date.month, 1).weekday;
    return weekday - 1; // DateTime.monday == 1
  }

  Future<void> _toggleDreamCompletion(DreamModel dream) async {
    final userId = SupabaseService.instance.getCurrentUserId();
    if (userId == null) return;

    try {
      if (dream.isCompleted) {
        await _dreamService.uncompleteDream(dream.id);
      } else {
        await _dreamService.completeDream(dream.id, userId);
      }
      await _loadDreams();
    } catch (_) {
      // Silently handle errors
    }
  }

  Future<void> _deleteDream(DreamModel dream) async {
    try {
      await _dreamService.deleteDream(dream.id);
      await _loadDreams();
    } catch (_) {
      // Silently handle errors
    }
  }

  String _colorToHex(Color color) {
    final argb = color.toARGB32();
    return '#${(argb & 0x00FFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  void _showAddDreamDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = DreamCategories.all.first;
    Color selectedColor = DreamCategories.colors.values.first;
    DateTime? selectedDeadline;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Add a Dream',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Title
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: 'Dream title',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Description
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Description (optional)',
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          hintText: 'Category',
                        ),
                        items: DreamCategories.all.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(DreamCategories.label(cat)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() {
                              selectedCategory = value;
                              selectedColor =
                                  DreamCategories.colors[value] ??
                                      selectedColor;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Color picker
                      Text(
                        'Color',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: DreamCategories.colors.values.map((color) {
                          final isSelected =
                              _colorToHex(selectedColor) ==
                              _colorToHex(color);
                          return GestureDetector(
                            onTap: () {
                              setModalState(() => selectedColor = color);
                            },
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: color,
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 18,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Deadline
                      TextButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                selectedDeadline ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 5),
                            ),
                          );
                          if (picked != null) {
                            setModalState(
                              () => selectedDeadline = picked,
                            );
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          selectedDeadline != null
                              ? DateFormat.yMMMd().format(selectedDeadline!)
                              : 'Set deadline (optional)',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Add button
                      ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final userId =
                              SupabaseService.instance.getCurrentUserId();
                          if (userId == null) return;

                          try {
                            await _dreamService.createDream(
                              userId: userId,
                              title: titleController.text.trim(),
                              description:
                                  descriptionController.text.trim().isNotEmpty
                                      ? descriptionController.text.trim()
                                      : null,
                              category: selectedCategory,
                              colorHex: _colorToHex(selectedColor),
                              deadline: selectedDeadline,
                            );

                            Fluttertoast.showToast(
                              msg: '+2 stars!',
                              backgroundColor: DaylifeColors.starYellow,
                              textColor: DaylifeColors.midnightBlue,
                            );

                            if (mounted) Navigator.pop(context);
                            await _loadDreams();
                          } catch (_) {
                            // Silently handle errors
                          }
                        },
                        child: const Text('Add Dream'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final daysInMonth = _daysInMonth(_selectedMonth);
    final firstOffset = _firstWeekdayOffset(_selectedMonth);
    const weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // A) Calendar
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Month header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _previousMonth,
                          ),
                          Text(
                            DateFormat.yMMMM().format(_selectedMonth),
                            style: theme.textTheme.titleMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _nextMonth,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Weekday headers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: weekdays.map((day) {
                          return SizedBox(
                            width: 36,
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 4),

                      // Day grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1,
                        ),
                        itemCount: firstOffset + daysInMonth,
                        itemBuilder: (context, index) {
                          if (index < firstOffset) {
                            return const SizedBox.shrink();
                          }
                          final dayNum = index - firstOffset + 1;
                          final dayDate = DateTime(
                            _selectedMonth.year,
                            _selectedMonth.month,
                            dayNum,
                          );
                          final isToday = dayDate.year == now.year &&
                              dayDate.month == now.month &&
                              dayDate.day == now.day;
                          final isSelected = _selectedDay != null &&
                              dayDate.year == _selectedDay!.year &&
                              dayDate.month == _selectedDay!.month &&
                              dayDate.day == _selectedDay!.day;
                          final hasDream = _hasDreamOnDay(dayDate);
                          final dreamColor = _dreamColorOnDay(dayDate);

                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              setState(() => _selectedDay = dayDate);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isToday
                                    ? theme.colorScheme.primary
                                        .withValues(alpha: 0.1)
                                    : null,
                                border: isSelected
                                    ? Border.all(
                                        color: DaylifeColors.silverLight,
                                        width: 1.5,
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$dayNum',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  if (hasDream)
                                    Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.only(top: 2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: dreamColor ??
                                            DaylifeColors.sandGold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // B) Dream list
                Expanded(
                  child: _dreams.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.nights_stay_outlined,
                                size: 64,
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No dreams yet',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          children: [
                            // In Progress
                            if (_inProgressDreams.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'In Progress (${_inProgressDreams.length})',
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                              ..._inProgressDreams.map(
                                (dream) => _buildDreamTile(dream, theme),
                              ),
                            ],

                            // Completed
                            if (_completedDreams.isNotEmpty) ...[
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _completedExpanded = !_completedExpanded;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Completed (${_completedDreams.length})',
                                        style: theme.textTheme.titleSmall,
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        _completedExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_completedExpanded)
                                ..._completedDreams.map(
                                  (dream) => Opacity(
                                    opacity: 0.6,
                                    child: _buildDreamTile(dream, theme),
                                  ),
                                ),
                            ],
                          ],
                        ),
                ),
              ],
            ),

      // C) FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFD700),
        onPressed: _showAddDreamDialog,
        child: const Icon(Icons.star),
      ),
    );
  }

  Widget _buildDreamTile(DreamModel dream, ThemeData theme) {
    return Slidable(
      key: ValueKey(dream.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _deleteDream(dream),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Card(
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left color stripe
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: dream.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),

              // Checkbox
              Checkbox(
                value: dream.isCompleted,
                onChanged: (_) => _toggleDreamCompletion(dream),
                activeColor: DaylifeColors.successGreen,
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dream.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: dream.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (dream.description != null &&
                          dream.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          dream.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      if (dream.deadline != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.yMMMd().format(dream.deadline!),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: dream.isOverdue
                                ? DaylifeColors.errorCoral
                                : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
