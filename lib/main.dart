import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:legit_cards/data/models/user_model.dart';
import 'package:legit_cards/screens/auth/auth_view_model.dart';
import 'package:legit_cards/screens/auth/login_2fa_screen.dart';
import 'package:legit_cards/screens/auth/login_screen.dart';
import 'package:legit_cards/screens/auth/otp_screen.dart';
import 'package:legit_cards/screens/auth/request_code_screen.dart';
import 'package:legit_cards/screens/auth/reset_password_screen.dart';
import 'package:legit_cards/screens/auth/signup_screen.dart';
import 'package:legit_cards/screens/dashboard/coins/crypto_vm.dart';
import 'package:legit_cards/screens/dashboard/dashboard_screen.dart';
import 'package:legit_cards/screens/dashboard/gift_cards/gift_card_vm.dart';
import 'package:legit_cards/screens/dashboard/history/history_view_model.dart';
import 'package:legit_cards/screens/profile/add_bank_screen.dart';
import 'package:legit_cards/screens/profile/all_bank_accounts_screen.dart';
import 'package:legit_cards/screens/profile/change_password_screen.dart';
import 'package:legit_cards/screens/profile/edit_profile_screen.dart';
import 'package:legit_cards/screens/profile/enable_2fa_screen.dart';
import 'package:legit_cards/screens/profile/profile_screen.dart';
import 'package:legit_cards/screens/profile/profile_view_model.dart';
import 'package:legit_cards/screens/profile/update_pin_screen.dart';
import 'package:legit_cards/screens/wallet/wallet_view_model.dart';
import 'package:legit_cards/screens/wallet/withdrawal_receipt_screen.dart';
import 'package:legit_cards/screens/wallet/withdrawal_screen.dart';
import 'constants/app_colors.dart';
import 'constants/k.dart';
import 'data/models/auth_model.dart';
import 'data/models/wallet_model.dart';
import 'firebase_options.dart';
import 'platform_stub.dart' if (dart.library.html) 'platform_web.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configurePlatform();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // runApp(const MyApp());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => GiftCardTradeVM()),
        ChangeNotifierProvider(create: (_) => HistoryViewModel()),
        ChangeNotifierProvider(create: (_) => CryptoViewModel()),
        ChangeNotifierProvider(create: (_) => WalletViewModel()),
        // ChangeNotifierProvider(create: (_) => HistoryViewModel()),
        // ChangeNotifierProvider(create: (_) => HistoryViewModel()),
        // ChangeNotifierProvider(create: (_) => HistoryViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // In your router configuration
  final GoRouter _router = GoRouter(
    initialLocation: K.dashboardScreen, // change later to home
    routes: [
      GoRoute(
        name: K.dashboardScreen,
        path: K.dashboardScreen,
        builder: (context, state) {
          final userProfile = state.extra as UserProfileM?;
          return DashboardScreen(userProfileM: userProfile);
        },
      ),
      GoRoute(
        name: K.signupPath,
        path: K.signupPath,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        name: K.profilePath,
        path: K.profilePath,
        builder: (context, state) {
          final userProfile = state.extra as UserProfileM;
          return ProfileScreen(user: userProfile);
        },
      ),
      GoRoute(
        name: K.loginPath, // ✅ Named route
        path: K.loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: K.requestCode,
        path: K.requestCode,
        builder: (context, state) => const RequestCodeScreen(),
      ),
      GoRoute(
        name: K.viewBankAccount,
        path: K.viewBankAccount,
        builder: (context, state) {
          final userData = state.extra as UserProfileM?;
          return AllBankAccountsScreen(userProfileM: userData);
        },
      ),
      GoRoute(
        name: K.withdrawScreen,
        path: K.withdrawScreen,
        builder: (context, state) {
          final userData = state.extra as UserProfileM?;
          return WithdrawalScreen(userProfileM: userData);
        },
      ),
      GoRoute(
        name: K.withdrawReceiptScreen,
        path: K.withdrawReceiptScreen,
        builder: (context, state) {
          final withdrawalRecord = state.extra as WithdrawRecordM;
          return WithdrawalReceiptScreen(withdrawalRecord: withdrawalRecord);
        },
      ),
      GoRoute(
        name: K.resetPassword,
        path: K.resetPassword,
        builder: (context, state) {
          final email = state.extra as String?;
          return ResetPasswordScreen(email: email!);
        },
      ),
      GoRoute(
        name: K.otpPath,
        path: K.otpPath,
        builder: (context, state) {
          final userData = state.extra as UserNavigationData?;
          return OtpScreen(user: userData);
        },
      ),
      GoRoute(
        name: K.updatePin,
        path: K.updatePin,
        builder: (context, state) {
          final userData = state.extra as UserProfileM?;
          return UpdatePinScreen(user: userData);
        },
      ),
      GoRoute(
        name: K.enable2Fa,
        path: K.enable2Fa,
        builder: (context, state) {
          final userData = state.extra as UserProfileM?;
          return Enable2FaScreen(user: userData);
        },
      ),
      GoRoute(
        name: K.addBankName,
        path: K.addBankName,
        builder: (context, state) {
          final userData = state.extra as UserProfileM?;
          return AddBankAccountScreen(user: userData);
        },
      ),
      GoRoute(
        name: K.login2Fa,
        path: K.login2Fa,
        builder: (context, state) {
          final userData = state.extra as SignModel?;
          return Login2FaScreen(user: userData);
        },
      ),
      GoRoute(
        name: K.editProfile,
        path: K.editProfile,
        builder: (context, state) {
          final userData = state.extra as UserProfileM?;
          return EditProfileScreen(user: userData);
        },
      ),
      GoRoute(
        name: K.changePassword,
        path: K.changePassword,
        builder: (context, state) {
          final userData = state.extra as UserProfileM?;
          return ChangePasswordScreen(user: userData);
        },
      ),
    ],
  );

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Legit Cards',
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.lightPurple, // blue_white
          onPrimary: AppColors.black, // white_black
          secondary: AppColors.white, // blue_coolBlue
          onSecondary: AppColors.defaultBlack, // default text color
          error: AppColors.errorDark,
          onError: AppColors.white,
          surface: AppColors.cardLight, // cardColor
          onSurface: AppColors.appLight, // backgroundColor
          scrim: AppColors.iconBgLight,
          shadow: AppColors.cardLight,
          outline: AppColors.greenLight,
          tertiary: AppColors.grayBackgroundLight,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.lighterPurple,
          onPrimary: AppColors.white, // Text/icons on primary
          secondary: AppColors.black,
          onSecondary: AppColors.defaultWhite,
          error: AppColors.errorDark,
          onError: AppColors.white,
          surface: AppColors.cardDark,
          onSurface: AppColors.appDark,
          scrim: AppColors.cardDark,
          shadow: AppColors.cardOption,
          outline: AppColors.greenDark,
          tertiary: AppColors.grayBackgroundDark,
        ),
      ),
      themeMode: ThemeMode.system,
      // home: const SignupScreen(),
      debugShowCheckedModeBanner: false,

      // Set the status bar style
      builder: (context, child) {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark,
          ),
        );

        return child ?? const SizedBox(); // Return the router's content
      },
    );
  }
}
