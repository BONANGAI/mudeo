import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mudeo/main_common.dart';
import 'package:mudeo/redux/app/app_middleware.dart';
import 'package:mudeo/redux/app/app_reducer.dart';
import 'package:mudeo/redux/app/app_state.dart';
import 'package:mudeo/redux/artist/artist_middleware.dart';
import 'package:mudeo/redux/auth/auth_middleware.dart';
import 'package:mudeo/redux/song/song_middleware.dart';
import 'package:mudeo/utils/sentry.dart';
import 'package:redux/redux.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:sentry/sentry.dart';

void main() async {
  //InAppPurchaseConnection.enablePendingPurchases();
  WidgetsFlutterBinding.ensureInitialized();
  //Screen.keepOn(true);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final SentryClient _sentry = null;
  /*
  final SentryClient _sentry = Config.SENTRY_DNS.isEmpty
      ? null
      : SentryClient(
      dsn: Config.SENTRY_DNS,
      environmentAttributes: await getSentryEvent());
  */

  final flavor = html.window.document.documentElement.dataset['flavor'];
  bool isDance = (flavor == 'dance');

  print('### IS DANCE: $isDance ###');

  final store = Store<AppState>(appReducer,
      initialState: AppState(isDance: isDance),
      middleware: []
        ..addAll(createStoreAuthMiddleware())
        ..addAll(createStoreSongsMiddleware())
        ..addAll(createStoreArtistsMiddleware())
        ..addAll(createStorePersistenceMiddleware())
        ..addAll([
          LoggingMiddleware<dynamic>.printer(),
        ]));

  if (_sentry == null) {
    runZonedGuarded<Future<void>>(() async {
      runApp(MudeoApp(store: store));
    }, (Object exception, StackTrace stackTrace) async {
      if (kDebugMode) {
        print('ERROR: $exception\nSTACK: $stackTrace');
      }
    });
  } else {
    runZonedGuarded<Future<void>>(() async {
      runApp(MudeoApp(store: store));
    }, (Object exception, StackTrace stackTrace) async {
      if (kDebugMode) {
        print('$exception\n$stackTrace');
      } else {
        final event = await getSentryEvent(
          state: store.state,
          exception: exception,
          stackTrace: stackTrace,
        );
        _sentry.capture(event: event);
      }
    });
  }
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
}
