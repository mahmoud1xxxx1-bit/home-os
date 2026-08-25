import 'package:intl/intl.dart';

String compactDate(DateTime date, String languageCode) {
  return DateFormat.yMMMd(languageCode).format(date);
}

String relativeDays(DateTime date, String languageCode) {
  final today = DateTime.now();
  final base = DateTime(today.year, today.month, today.day);
  final target = DateTime(date.year, date.month, date.day);
  final days = target.difference(base).inDays;
  if (languageCode == 'ar') {
    if (days == 0) return 'اليوم';
    if (days == 1) return 'غدًا';
    if (days < 0) return 'متأخر ${days.abs()} يوم';
    return 'بعد $days يوم';
  }
  if (days == 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  if (days < 0) return '${days.abs()} days overdue';
  return 'In $days days';
}
