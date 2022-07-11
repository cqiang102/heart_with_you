// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `zh`
  String get _locale {
    return Intl.message(
      'zh',
      name: '_locale',
      desc: '',
      args: [],
    );
  }

  /// `心系于你`
  String get taskTitle {
    return Intl.message(
      '心系于你',
      name: 'taskTitle',
      desc: '',
      args: [],
    );
  }

  /// `心系于你`
  String get titleBarTitle {
    return Intl.message(
      '心系于你',
      name: 'titleBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `你一共点击了这么多次按钮：`
  String get clickTop {
    return Intl.message(
      '你一共点击了这么多次按钮：',
      name: 'clickTop',
      desc: '',
      args: [],
    );
  }

  /// `增加`
  String get inc {
    return Intl.message(
      '增加',
      name: 'inc',
      desc: '',
      args: [],
    );
  }

  /// `{howMany, plural, one{你有一条消息} other{You have {howMany} messages}}`
  String pageHomeSamplePlural(num howMany) {
    return Intl.plural(
      howMany,
      one: '你有一条消息',
      other: 'You have $howMany messages',
      name: 'pageHomeSamplePlural',
      desc: '',
      args: [howMany],
    );
  }

  /// `点赞`
  String get star {
    return Intl.message(
      '点赞',
      name: 'star',
      desc: '',
      args: [],
    );
  }

  /// `现在`
  String get now {
    return Intl.message(
      '现在',
      name: 'now',
      desc: '',
      args: [],
    );
  }

  /// `未来`
  String get future {
    return Intl.message(
      '未来',
      name: 'future',
      desc: '',
      args: [],
    );
  }

  /// `过去`
  String get history {
    return Intl.message(
      '过去',
      name: 'history',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
