import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  static const _languageKey = 'selected_language';

  LanguageBloc() : super(const LanguageState(locale: Locale('en'))) {
    on<LoadSavedLanguage>(_onLoadSavedLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
  }

  /// 🔹 Load language on app start
  Future<void> _onLoadSavedLanguage(
    LoadSavedLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_languageKey) ?? 'en';

    emit(LanguageState(locale: Locale(code)));
  }

  /// 🔹 Change language & save it
  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, event.locale.languageCode);

    emit(LanguageState(locale: event.locale));
  }
}
