import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

class MonthSelector extends StatefulWidget {
  final int selectedMonth;
  final int selectedYear;
  final Function(int month, int year) onMonthChanged;

  const MonthSelector({
    Key? key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onMonthChanged,
  }) : super(key: key);

  @override
  State<MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  late ScrollController _scrollController;
  late List<_MonthItem> _months;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _generateMonths();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  void _generateMonths() {
    _months = [];
    final now = DateTime.now();
    // Generar 24 meses hacia atrás y 12 hacia adelante
    for (int i = -24; i <= 12; i++) {
      final date = DateTime(now.year, now.month + i);
      _months.add(_MonthItem(month: date.month, year: date.year));
    }
  }

  void _scrollToSelected() {
    final selectedIndex = _months.indexWhere(
      (m) => m.month == widget.selectedMonth && m.year == widget.selectedYear,
    );
    if (selectedIndex != -1 && _scrollController.hasClients) {
      final itemWidth = 80.0;
      final screenWidth = MediaQuery.of(context).size.width;
      final offset = (selectedIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
      _scrollController.animateTo(
        offset.clamp(0, _scrollController.position.maxScrollExtent),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void didUpdateWidget(MonthSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMonth != widget.selectedMonth ||
        oldWidget.selectedYear != widget.selectedYear) {
      _scrollToSelected();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _months.length,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        itemBuilder: (context, index) {
          final item = _months[index];
          final isSelected = item.month == widget.selectedMonth &&
              item.year == widget.selectedYear;

          return GestureDetector(
            onTap: () => widget.onMonthChanged(item.month, item.year),
            child: Container(
              width: 70,
              margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.textLight.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('MMM', 'es_ES').format(DateTime(item.year, item.month)).toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '${item.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? AppColors.primary : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MonthItem {
  final int month;
  final int year;

  _MonthItem({required this.month, required this.year});
}
