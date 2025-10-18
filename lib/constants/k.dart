import 'dart:io';

class K {
  static String baseUrl = "https://legitcards.ng";
// static String baseUrl = "http://192.168.0.171:8080";

  static const dashboardScreen = "/";
  static const welcomeScreenPath = "/welcome";
  static const signupPath = "/signup";
  static const loginPath = "/login";
  static const otpPath = "/otp-screen";
  static const profilePath = "/profile";
  static const notificationPath = "/notification";
  static const editProfile = "/edit-profile";
  static const resetPassword = "/reset-password";
  static const changePassword = "/change-password";
  static const requestCode = "/request-code";
  static const updatePin = "/update-pin";
  static const enable2Fa = "/two-fa";
  static const login2Fa = "/login2fa";
  static const addBankName = "/add-bank";
  static const viewBankAccount = "/view-bank-account";
  static const withdrawScreen = "/withdraw";
  static const withdrawReceiptScreen = "/withdraw-receipt";
  // static const login2Fa = "/login2fa";
  // static const login2Fa = "/login2fa";

  static const sellNow = "Sell Now";
  static const cancelTransaction = "Cancel Transaction";
  static const optInfo =
      "Please check your spam folder if not received in your inbox";

  // usdt networks
  static const usdtBep20 = "0x31CbBbb58bCa0E091B99Ae9427E777819ff790D8";
  static const usdtTrc20 = "TYuHyss71JMVfvuv1v7d5tohqaNfimkmgd";
  static const usdtErc20 = "0x31CbBbb58bCa0E091B99Ae9427E777819ff790D8";

  // eth network
  static const ethEthNet = "0x31CbBbb58bCa0E091B99Ae9427E777819ff790D8";

  // btc network
  static const btcBtcNet = "1LCsWQFKv5NUxkNi5hHFKFEWEz8oeGzE9Y";

  static const BTC = "BTC";
  static const USDT = "USDT";
  static const ETH = "ETH";

  static const CARD = "CARD";
  static const COIN = "CRYPTO";

  static bool isAndroid() {
    return Platform.isAndroid;
  }

  static bool isIOS() {
    return Platform.isIOS;
  }
}
