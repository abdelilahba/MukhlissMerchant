import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

class L10n {
  static final all=[
    const Locale('en'),
    const Locale('fr'),
    const Locale('ar'),
  ];

   static AppLocalizations? of(BuildContext context) {
    return AppLocalizations.of(context);
  }
}