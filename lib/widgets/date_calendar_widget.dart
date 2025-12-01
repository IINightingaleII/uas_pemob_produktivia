import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DateCalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateCalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  String _getDayAbbreviation(int weekday) {
    // Flutter weekday: 1=Monday, 7=Sunday
    switch (weekday) {
      case 1:
        return 'Mon'; // Monday
      case 2:
        return 'Tue'; // Tuesday
      case 3:
        return 'Wed'; // Wednesday
      case 4:
        return 'Thu'; // Thursday
      case 5:
        return 'Fri'; // Friday
      case 6:
        return 'Sat'; // Saturday
      case 7:
        return 'Sun'; // Sunday
      default:
        return '';
    }
  }

  String _getMonthName(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    // Get the week containing the selected date
    final startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final weekDates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Header dengan bulan/tahun dan icon kalender
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getMonthName(selectedDate)} ${selectedDate.year}',
                style: GoogleFonts.jost(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    onDateSelected(picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 1.0],
                      colors: [
                        Color(0xFFFFB6C1), // Soft pink - top color
                        Color(0xFFDDA0DD), // Light purple - bottom color
                      ],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 1.0],
                        colors: [
                          Color(0xFFFFB6C1), // Soft pink
                          Color(0xFFDDA0DD), // Light purple
                        ],
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Week dates row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDates.map((date) {
              final isSelected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              
              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: isSelected
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 1.0],
                            colors: [
                              Color(0xFFFFB6C1), // Soft pink
                              Color(0xFFDDA0DD), // Light purple
                            ],
                          )
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        date.day.toString(),
                        style: GoogleFonts.jost(
                          fontSize: 14,
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDayAbbreviation(date.weekday),
                        style: GoogleFonts.jost(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

