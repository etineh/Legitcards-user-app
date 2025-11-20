import 'package:go_router/go_router.dart';

import '../data/models/auth_model.dart';
import '../data/models/notification_model.dart';
import '../data/models/user_model.dart';
import '../data/models/wallet_model.dart';
import '../screens/auth/login_2fa_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/request_code_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/notification/notification_detail_screen.dart';
import '../screens/notification/notification_screen.dart';
import '../screens/profile/advance_screen.dart';
import '../screens/profile/bank/add_bank_screen.dart';
import '../screens/profile/bank/all_bank_accounts_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/direct_support_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/enable_2fa_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/support/support_chatList_screen.dart';
import '../screens/profile/update_pin_screen.dart';
import '../screens/wallet/withdrawal_receipt_screen.dart';
import '../screens/wallet/withdrawal_screen.dart';
import 'k.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: K.loginPath,
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
        name: K.loginPath,
        path: K.loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: K.requestCode,
        path: K.requestCode,
        builder: (context, state) => const RequestCodeScreen(),
      ),
      GoRoute(
        name: K.advanceScreen,
        path: K.advanceScreen,
        builder: (context, state) {
          final userData = state.extra as UserProfileM;
          return AdvanceScreen(user: userData);
        },
      ),
      GoRoute(
        name: K.directSupportScreen,
        path: K.directSupportScreen,
        builder: (context, state) => const DirectSupportScreen(),
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
      GoRoute(
        name: K.notificationScreen,
        path: K.notificationScreen,
        builder: (context, state) {
          final userData = state.extra as UserProfileM;
          return NotificationScreen(user: userData);
        },
      ),
      // ADD THIS NEW ROUTE FOR NOTIFICATION DETAIL
      GoRoute(
        name: K.notificationDetailScreen,
        path: K.notificationDetailScreen,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;

          // Create NotificationM from the data
          final notification = NotificationM(
            id: data['data']?['id'] ?? '',
            timer: 0,
            notification: NotificationContent(
              title: data['title'] ?? '',
              body: data['body'] ?? '',
            ),
            receiverId: data['data']?['receiver_id'] ?? '',
            reference: data['data']?['reference'] ?? '',
            createdAt: data['createdAt'] ?? '' ?? DateTime.now().toString(),
            updatedAt: DateTime.now().toString(),
          );

          return NotificationDetailScreen(notification: notification);
        },
      ),
      GoRoute(
        name: K.supportChatsScreen,
        path: K.supportChatsScreen,
        builder: (context, state) {
          final userData = state.extra as UserProfileM;
          return SupportChatListScreen(userProfile: userData);
        },
      ),
    ],
  );
}
