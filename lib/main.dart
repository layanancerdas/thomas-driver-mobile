import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tomas_driver/helpers/deeplinks.dart';
import 'package:tomas_driver/helpers/push_notification_service.dart';
import 'package:tomas_driver/localization/app_translations_delegate.dart';
import 'package:tomas_driver/localization/application.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/redux/store.dart';
import 'package:tomas_driver/routes.dart';
import 'package:tomas_driver/screens/home/home.dart';
import 'package:tomas_driver/screens/lifecycle_manager/lifecycle_manager.dart';
// ignore: unused_import
import 'package:tomas_driver/screens/sign/sign.dart';
import 'package:tomas_driver/screens/webview/webview.dart';
import 'package:tomas_driver/widgets/qr_scan.dart';
import 'package:uni_links/uni_links.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Store<AppState> _store = await createStore();
  await Firebase.initializeApp();
  runApp(MainApp(_store));
}

class MainApp extends StatefulWidget {
  final Store<AppState> store;

  MainApp(this.store);
  @override
  _MainAppState createState() => _MainAppState();

  static _MainAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MainAppState>();
}

class _MainAppState extends State<MainApp> {
  // final PushNotificationService pushNotificationService =
  //     PushNotificationService();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription _linkSubscription;

  SharedPreferences prefs;
  AppTranslationsDelegate _newLocaleDelegate;
  bool isLogin = false;

  Future initMain() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString('jwtToken');
    if (jwtToken != null) {
      print(jwtToken);
      bool hasExpired = JwtDecoder.isExpired(jwtToken);
      if (hasExpired) {
        prefs.clear();
        setState(() {
          isLogin = false;
        });
      } else {
        setState(() {
          isLogin = true;
        });
      }
    } else {
      setState(() {
        isLogin = false;
      });
    }
  }

  Future<void> onLocaleChange(Locale locale) async {
    setState(() {
      _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
    });
  }

  Future<void> initLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String language = prefs.getString('language') ?? 'en';
    Intl.defaultLocale = prefs.getString('language') == 'id' ? 'id' : 'en_US';
    setState(() {
      _newLocaleDelegate =
          AppTranslationsDelegate(newLocale: Locale(language, ''));
    });
  }

  Future<void> initPlatformState() async {
    //   // Attach a listener to the Uri links stream
    //   // final initialLink = await getInitialLink();
    //   // print(initialLink);
    //   // final initialUri = await getInitialUri();

    //   // if (initialUri != null) {
    //   //   Deeplinks.parseRoute(initialUri, navigatorKey, isLogin);
    //   // }

    //   // getLinksStream().listen((event) {
    //   //   print(event);
    //   // }, onError: (Object err) {
    //   //   print('Got error $err');
    //   // });

    //   print("active unilink");

    _linkSubscription = getUriLinksStream().listen((Uri uri) {
      // if (!mounted) return;
      // setState(() {
      Deeplinks.parseRoute(uri, navigatorKey, isLogin);
      // });
    }, onError: (Object err) {
      print('Got error $err');
    });
  }

  @override
  void initState() {
    // initPlatformState();
    initMain();
    _newLocaleDelegate = AppTranslationsDelegate(newLocale: Locale('id', ''));
    initLocale();
    application.onLocaleChanged = onLocaleChange;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPlatformState();
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: StoreProvider<AppState>(
          store: widget.store,
          child: LifecycleManager(
              navigatorKey: navigatorKey,
              child: MaterialApp(
                navigatorKey: navigatorKey,
                title: 'Tomas Driver',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                    scaffoldBackgroundColor: Colors.white,
                    brightness: Brightness.light,
                    primarySwatch: Colors.blue,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    appBarTheme: AppBarTheme(
                        elevation: 0,
                        color: Colors.white,
                        brightness: Brightness.light),
                    dialogBackgroundColor: Colors.white24,
                    bottomSheetTheme:
                        BottomSheetThemeData(backgroundColor: Colors.black26)),
                localizationsDelegates: [
                  _newLocaleDelegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: <Locale>[
                  const Locale('en', ''),
                  const Locale('id', ''),
                ],
                home: !isLogin ? Sign() : Home(),
                // home: LifecycleManager(Home()),
                routes: routes,
              ))),
    );
  }
}
