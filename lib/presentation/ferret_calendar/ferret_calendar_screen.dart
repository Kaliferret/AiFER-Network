import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// FerretCalendar - Calendar App
/// Placeholder implementation for AIFER v11 integration
class FerretCalendarScreen extends StatelessWidget {
  const FerretCalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF536DFE)),
            SizedBox(width: 2.w),
            Text('FerretCalendar'),
          ],
        ),
        backgroundColor: isDark ? Color(0xFF0A0A0A) : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Go to today'),
                  backgroundColor: Color(0xFF536DFE),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$view coming soon!')),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Month', child: Text('Month View')),
              const PopupMenuItem(value: 'Week', child: Text('Week View')),
              const PopupMenuItem(value: 'Day', child: Text('Day View')),
            ],
          ),
        ],
      ),
      backgroundColor: isDark ? Color(0xFF0A0A0A) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              size: 20.w,
              color: Color(0xFF536DFE),
            ),
            SizedBox(height: 3.h),
            Text(
              'FerretCalendar',
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF536DFE),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'AIFER v11 Calendar App',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 3.h),
            Container(
              padding: EdgeInsets.all(3.w),
              width: 60.w,
              decoration: BoxDecoration(
                color: Color(0xFF536DFE).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(color: Color(0xFF536DFE), width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'January 2025',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                        .map((day) => Text(
                              day,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 1.h),
                  // Placeholder calendar grid
                  ...List.generate(5, (week) {
                    return Padding(
                      padding: EdgeInsets.only(top: 0.5.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(7, (dayIndex) {
                          final dayNum = week * 7 + dayIndex;
                          final isToday = week == 2 && dayIndex == 2; // Today is Wednesday
                          return Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: isToday
                                  ? Color(0xFF536DFE)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                dayNum < 32 ? '$dayNum' : '',
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  color: isToday
                                      ? Colors.white
                                      : isDark ? Colors.white : Colors.black87,
                                  fontWeight: isToday ? FontWeight.bold : null,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 4.w,
                        height: 4.w,
                        decoration: BoxDecoration(
                          color: Color(0xFF39FF14),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text('Today'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Add event coming soon!'),
                    backgroundColor: Color(0xFF536DFE),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Event'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF536DFE),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}