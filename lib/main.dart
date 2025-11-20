import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:legit_cards/constants/app_notification.dart';
import 'package:legit_cards/constants/app_router.dart';
import 'package:legit_cards/constants/app_theme.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/auth/auth_view_model.dart';
import 'package:legit_cards/screens/dashboard/coins/crypto_vm.dart';
import 'package:legit_cards/screens/dashboard/gift_cards/gift_card_vm.dart';
import 'package:legit_cards/screens/dashboard/history/history_view_model.dart';
import 'package:legit_cards/screens/notification/notification_view_model.dart';
import 'package:legit_cards/screens/profile/profile_view_model.dart';
import 'package:legit_cards/screens/wallet/wallet_view_model.dart';
import 'package:legit_cards/services/firebase_messaging_service.dart';
import 'constants/k.dart';
import 'data/models/notification_model.dart';
import 'firebase_options.dart';
import 'platform_stub.dart' if (dart.library.html) 'platform_web.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configurePlatform();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Messaging
  final messagingService = FirebaseMessagingService();
  await messagingService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => GiftCardTradeVM()),
        ChangeNotifierProvider(create: (_) => HistoryViewModel()),
        ChangeNotifierProvider(create: (_) => CryptoViewModel()),
        ChangeNotifierProvider(create: (_) => WalletViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        // ChangeNotifierProvider(create: (_) => HistoryViewModel()),
        // ChangeNotifierProvider(create: (_) => HistoryViewModel()),
      ],
      child: MyApp(messagingService: messagingService),
    ),
  );
}

class MyApp extends StatefulWidget {
  final FirebaseMessagingService messagingService;

  const MyApp({super.key, required this.messagingService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // _setupNotificationListener();
    _router = AppRouter.router;
    AppNotification.setupNotificationListener(
        widget, _router.routerDelegate.navigatorKey.currentContext);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Legit Cards',
      routerConfig: _router,
      theme: AppTheme.themeDataLight,
      darkTheme: AppTheme.themeDataDark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
        );

        return child ?? const SizedBox();
      },
    );
  }
}
