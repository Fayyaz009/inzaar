import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object> get props => [];
}

class LoadSettings extends SettingsEvent {}

class ChangeTheme extends SettingsEvent {
  final String themeMode; // 'light', 'dark', 'sepia'
  const ChangeTheme(this.themeMode);
  @override
  List<Object> get props => [themeMode];
}

class ChangeFontSize extends SettingsEvent {
  final double fontSize;
  const ChangeFontSize(this.fontSize);
  @override
  List<Object> get props => [fontSize];
}

class ChangeReadingFontFamily extends SettingsEvent {
  final String fontFamily;
  const ChangeReadingFontFamily(this.fontFamily);
  @override
  List<Object> get props => [fontFamily];
}

class ChangeUrduFontSize extends SettingsEvent {
  final double fontSize;
  const ChangeUrduFontSize(this.fontSize);
  @override
  List<Object> get props => [fontSize];
}

class ChangeUrduFontFamily extends SettingsEvent {
  final String fontFamily;
  const ChangeUrduFontFamily(this.fontFamily);
  @override
  List<Object> get props => [fontFamily];
}

class ChangeAppFontScale extends SettingsEvent {
  final double appFontScale;
  const ChangeAppFontScale(this.appFontScale);
  @override
  List<Object> get props => [appFontScale];
}

// States
class SettingsState extends Equatable {
  final String themeMode;
  final double fontSize;
  final String readingFontFamily;
  final double appFontScale;
  final double urduFontSize;
  final String urduFontFamily;

  const SettingsState({
    this.themeMode = 'light',
    this.fontSize = 18.0,
    this.readingFontFamily = 'Inter',
    this.appFontScale = 1.0,
    this.urduFontSize = 24.0,
    this.urduFontFamily = 'Jameel',
  });

  SettingsState copyWith({
    String? themeMode,
    double? fontSize,
    String? readingFontFamily,
    double? appFontScale,
    double? urduFontSize,
    String? urduFontFamily,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      readingFontFamily: readingFontFamily ?? this.readingFontFamily,
      appFontScale: appFontScale ?? this.appFontScale,
      urduFontSize: urduFontSize ?? this.urduFontSize,
      urduFontFamily: urduFontFamily ?? this.urduFontFamily,
    );
  }

  @override
  List<Object> get props => [
        themeMode,
        fontSize,
        readingFontFamily,
        appFontScale,
        urduFontSize,
        urduFontFamily
      ];
}

// Bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences prefs;

  SettingsBloc({required this.prefs}) : super(const SettingsState()) {
    on<LoadSettings>((event, emit) {
      final theme = prefs.getString('theme') ?? 'light';
      final font = prefs.getDouble('font_size') ?? 18.0;
      final family = prefs.getString('reading_font_family') ?? 'Inter';
      final appScale = prefs.getDouble('app_font_scale') ?? 1.0;
      final urduFont = prefs.getDouble('urdu_font_size') ?? 24.0;
      final urduFamily =
          prefs.getString('urdu_font_family') ?? 'Jameel';
      emit(state.copyWith(
        themeMode: theme,
        fontSize: font,
        readingFontFamily: family,
        appFontScale: appScale,
        urduFontSize: urduFont,
        urduFontFamily: urduFamily,
      ));
    });

    on<ChangeTheme>((event, emit) async {
      await prefs.setString('theme', event.themeMode);
      emit(state.copyWith(themeMode: event.themeMode));
    });

    on<ChangeFontSize>((event, emit) async {
      await prefs.setDouble('font_size', event.fontSize);
      emit(state.copyWith(fontSize: event.fontSize));
    });

    on<ChangeReadingFontFamily>((event, emit) async {
      await prefs.setString('reading_font_family', event.fontFamily);
      emit(state.copyWith(readingFontFamily: event.fontFamily));
    });

    on<ChangeUrduFontSize>((event, emit) async {
      await prefs.setDouble('urdu_font_size', event.fontSize);
      emit(state.copyWith(urduFontSize: event.fontSize));
    });

    on<ChangeUrduFontFamily>((event, emit) async {
      await prefs.setString('urdu_font_family', event.fontFamily);
      emit(state.copyWith(urduFontFamily: event.fontFamily));
    });

    on<ChangeAppFontScale>((event, emit) async {
      await prefs.setDouble('app_font_scale', event.appFontScale);
      emit(state.copyWith(appFontScale: event.appFontScale));
    });
  }
}
