import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../providers/locale_provider.dart';

String localeToIntlName(Locale locale) {
  if (locale.scriptCode != null && locale.scriptCode!.isNotEmpty) {
    return '${locale.languageCode}_${locale.scriptCode}';
  }
  return locale.languageCode;
}

String intlLocaleOf(BuildContext context) {
  return localeToIntlName(Localizations.localeOf(context));
}

DateFormat appDateFormat(BuildContext context, String pattern) {
  return DateFormat(pattern, intlLocaleOf(context));
}

DateFormat appYMMMd(BuildContext context) {
  return DateFormat.yMMMd(intlLocaleOf(context));
}

Future<void> initializeAppDateFormatting() {
  return Future.wait([
    for (final locale in AppLocales.supported)
      initializeDateFormatting(localeToIntlName(locale)),
  ]);
}

String formatEventDate(BuildContext context, DateTime dt) {
  return appDateFormat(context, 'EEE, d MMM').format(dt);
}

String formatEventTimeRange(
  BuildContext context,
  DateTime start,
  DateTime? end,
) {
  final fmt = DateFormat.jm(intlLocaleOf(context));
  final a = fmt.format(start);
  if (end == null) return a;
  return '$a – ${fmt.format(end)}';
}
