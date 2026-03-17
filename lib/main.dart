import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:inzaar/core/offline_wrapper.dart';
import 'package:inzaar/core/app_theme.dart';
import 'package:inzaar/core/database_helper.dart';
import 'package:inzaar/features/home/recent_reading_bloc.dart';
import 'package:inzaar/features/library/library_repository.dart';
import 'package:inzaar/features/library/library_bloc.dart';
import 'package:inzaar/features/onboarding/splash_screen.dart';
import 'package:inzaar/features/settings/settings_bloc.dart';
import 'package:inzaar/features/notes/notes_bloc.dart';
import 'package:inzaar/features/notes/notes_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final prefs = await SharedPreferences.getInstance();
  final libraryRepository = LibraryRepository();

  runApp(InzaarReaderApp(prefs: prefs, libraryRepository: libraryRepository));
}

class InzaarReaderApp extends StatelessWidget {
  final SharedPreferences prefs;
  final LibraryRepository libraryRepository;

  const InzaarReaderApp({
    super.key,
    required this.prefs,
    required this.libraryRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SettingsBloc(prefs: prefs)..add(LoadSettings()),
        ),
        BlocProvider(
          create: (context) =>
              LibraryBloc(repository: libraryRepository)..add(LoadLibrary()),
        ),
        BlocProvider(
          create: (context) =>
              RecentReadingBloc()..add(const LoadRecentReading()),
        ),
        BlocProvider(
          create: (context) => NotesBloc(dbHelper: DatabaseHelper.instance)
            ..add(const LoadAllNotes()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          ThemeData themeData;
          if (state.themeMode == 'dark') {
            themeData = AppTheme.darkTheme;
          } else if (state.themeMode == 'sepia') {
            themeData = AppTheme.sepiaTheme;
          } else {
            themeData = AppTheme.lightTheme;
          }

          return MaterialApp(
            title: 'Inzaar',
            debugShowCheckedModeBanner: false,
            theme: themeData,
            home: const SplashScreen(),
            builder: (context, child) {
              return OfflineWrapper(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(state.appFontScale),
                  ),
                  child: child!,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
