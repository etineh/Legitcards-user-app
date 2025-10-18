class DateAndTimeUtils {
  // from 1759699993157 to Sun. 5th Oct, 2025
  static String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

    // Short weekday names
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Short month names
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    final suffix = _getDaySuffix(day);
    final month = months[date.month - 1];
    final year = date.year;

    return '$weekday. $day$suffix $month, $year';
  }

  // from 1759699993157 to Sun. 5th Oct, 2025 - 7:20 AM
  static String formatToDateAndTime(String? dateString) {
    try {
      final date =
          dateString != null ? DateTime.parse(dateString) : DateTime.now();

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];

      int hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final ampm = hour >= 12 ? 'PM' : 'AM';
      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }

      final day = date.day;
      final suffix = _getDaySuffix(day);
      final month = months[date.month - 1];
      final year = date.year;

      return '$month $day$suffix, $year - ${hour.toString().padLeft(2, '0')}:$minute $ampm';
    } catch (e) {
      final now = DateTime.now();
      return formatToDateAndTime(now.toIso8601String());
    }
  }

  static String formatToDateAndTimeLong(int timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];

      int hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final ampm = hour >= 12 ? 'PM' : 'AM';
      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }

      final day = date.day;
      final suffix = _getDaySuffix(day);
      final month = months[date.month - 1];
      final year = date.year;

      return '$month $day$suffix, $year - ${hour.toString().padLeft(2, '0')}:$minute $ampm';
    } catch (e) {
      final now = DateTime.now();
      return formatToDateAndTimeLong(now.millisecondsSinceEpoch);
    }
  }

  static String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
