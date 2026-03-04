// import 'dart:async';
// import 'package:_96_sooq/constants/app_colors.dart';
// import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
// import 'package:_96_sooq/shared/global_widgets/custom_button_widgets.dart';
// import 'package:_96_sooq/features/root/view/screens/root_view.dart';
// import 'package:_96_sooq/l10n/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pinput/pinput.dart';
// import 'package:_96_sooq/constants/app_themes.dart';

// class OtpVerificationScreen extends StatefulWidget {
//   final String mobileNumber;
//   const OtpVerificationScreen({super.key, required this.mobileNumber});
//   static const String routeName = "/otp-verification-screen";

//   @override
//   State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
// }

// class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
//   String otpCode = "";
//   bool isLoading = false;
//   // AuthServices authServices = AuthServices();
//   late Timer _resendTimer;
//   int _timerSeconds = 60;

//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//   }

//   void startTimer() {
//     _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         if (_timerSeconds > 0) {
//           _timerSeconds--;
//         } else {
//           // Stop the timer when it reaches 0
//           _resendTimer.cancel();
//         }
//       });
//     });
//   }

//   void restartTimer() {
//     // Reset the timer
//     setState(() {
//       _timerSeconds = 60;
//     });
//     _resendTimer.cancel();

//     startTimer();
//   }

//   @override
//   void dispose() {
//     _resendTimer.cancel();
//     super.dispose();
//   }

//   // Future<void> resendOtp() async {
//   //   try {
//   //     restartTimer();
//   //     await authServices.sendOtp(mobileNumber: widget.mobileNumber);
//   //   } catch (e) {
//   //     Snackbars.showFailureSnackBar(context: context, message: e.toString());
//   //   } finally {}
//   // }

//   // Future<void> _handleOtpVerfication() async {
//   //   setState(() {
//   //     isLoading = true;
//   //   });
//   //   try {
//   //     final response = await authServices.verifyOtp(
//   //       mobileNumber: widget.mobileNumber,
//   //       otpCode: otpCode,
//   //     );

//   //     if (response['responseCode'] == "200") {
//   //       SharedPreferences preferences = await SharedPreferences.getInstance();
//   //       preferences.setString('userToken', response['userToken']);
//   //       await NotificationServices().updateFCMTokenForLoggedInUser();
//   //       Snackbars.showSuccessSnackBar(
//   //           context: context, message: "OTP verified successfully");
//   //       // await preferences.setBool('isLoggedIn', true);
//   //       preferences.setString('mobileNumber', widget.mobileNumber);
//   //       // Call the API to check if the user exists
//   //       _showLoadingDialog();
//   //       final userExistenceResponse = await authServices.checkUserExists();

//   //       if (!context.mounted) return;

//   //       // Check response for user existence
//   //       if (userExistenceResponse['responseCode'] == "200") {
//   //         Navigator.pop(context); // Close the loading dialog
//   //         await preferences.setBool('isProfileCompleted', true);
//   //         await preferences.setBool('isLoggedIn', true);
//   //         context.read<BottomNavigationProvider>().changeIndex(0);
//   //         await Navigator.pushNamedAndRemoveUntil(
//   //           context,
//   //           RootScreen.routeName,
//   //           (route) => false,
//   //         );
//   //       } else if (userExistenceResponse['responseCode'] == "404") {
//   //         Navigator.pop(context); // Close the loading dialog
//   //         // showSnackBar(context, "User doesn't exist");
//   //         await preferences.setBool('isProfileCompleted', false);
//   //         await preferences.setBool('isLoggedIn', true);
//   //         // User doesn't exist; navigate to the name registration screen
//   //         await Navigator.pushNamedAndRemoveUntil(
//   //           context,
//   //           NameRegistration.routeName,
//   //           (route) => false,
//   //         );
//   //       } else {
//   //         Navigator.pop(context); // Close the loading dialog
//   //         Snackbars.showWarningSnackBar(
//   //             context: context,
//   //             message: "Something went wrong. Please try again.");
//   //       }
//   //     } else {
//   //       Snackbars.showFailureSnackBar(
//   //           context: context, message: "Failed to verify OTP");
//   //     }
//   //   } catch (e) {
//   //     Snackbars.showFailureSnackBar(context: context, message: e.toString());
//   //   }
//   //   setState(() {
//   //     isLoading = false;
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final localizations = AppLocalizations.of(context)!;
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 20),
//                 Align(
//                   alignment: AlignmentDirectional.topStart,
//                   child: BackButtonWidget(
//                     ontap: () => Navigator.of(context).pop(),
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 Text(
//                   localizations.otpVerificationTitle,
//                   style: AppThemes.f28w600,
//                 ),
//                 const SizedBox(height: 15),
//                 Text.rich(
//                   TextSpan(
//                     text: "Enter the 6-digit code sent to\n",
//                     style: AppThemes.f14w400.copyWith(color: Color(0xFF6B7280)),
//                     children: [
//                       WidgetSpan(
//                         child: Directionality(
//                           textDirection: TextDirection.ltr,
//                           child: Text(
//                             "+968 ${widget.mobileNumber}",
//                             style: AppThemes.f14w500.copyWith(color: const Color(0xFF6B7280)),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 32),
//                 Pinput(
//                   length: 6,
//                   showCursor: true,
//                   hapticFeedbackType: HapticFeedbackType.vibrate,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   cursor: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         width: 1,
//                         height: 20,
//                         color: AppColors.primaryColor,
//                       ),
//                     ],
//                   ),
//                   focusedPinTheme: PinTheme(
//                     width: 52,
//                     height: 52,
//                     decoration: BoxDecoration(
//                       color: Color(0xFFF7F8F9),
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(color: AppColors.primaryColor),
//                     ),
//                     textStyle: AppThemes.f20w600,
//                   ),
//                   defaultPinTheme: PinTheme(
//                     width: 52,
//                     height: 52,
//                     decoration: BoxDecoration(
//                       color: Color(0xFFF7F8F9),
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(color: Color(0xFFF0F0F0)),
//                     ),
//                     textStyle: AppThemes.f20w600,
//                   ),
//                   onCompleted: (value) => setState(() {
//                     otpCode = value;
//                     if (_timerSeconds > 0 && otpCode.length == 6) {
//                       FocusScope.of(context).unfocus();
//                       // _handleOtpVerfication();
//                     } else if (_timerSeconds <= 0) {
//                       // Snackbars.showWarningSnackBar(
//                       //   context: context,
//                       //   message: "Time expired! Please resend OTP.",
//                       // );
//                     }
//                   }),
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     GestureDetector(
//                       onTap: () async {
//                         // _timerSeconds < 1 ? await resendOtp() : null;
//                       },
//                       child: Text.rich(
//                         TextSpan(
//                           text: _timerSeconds > 0 ? 'Resend code in ' : '',
//                           style: AppThemes.f14w400.copyWith(color: Color(0xFF666666)),
//                           children: [
//                             if (_timerSeconds > 0)
//                               TextSpan(
//                                 text: '00:$_timerSeconds',
//                                 style: AppThemes.f14w500,
//                               ),
//                             if (_timerSeconds <= 0)
//                               TextSpan(
//                                 text: localizations.resend,
//                                 style: AppThemes.f14w600.copyWith(color: Color(0xFF316FF6)),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 32),
//                 CustomButton(
//                   text: localizations.verifyText,
//                   isLoading: isLoading,
//                   onPressed: () async {
//                     if (_timerSeconds <= 0) {
//                       // Snackbars.showWarningSnackBar(
//                       //   context: context,
//                       //   message: "Time expired! Please resend OTP.",
//                       // );
//                     } else if (otpCode.length == 6) {
//                       FocusScope.of(context).unfocus();
//                       // _handleOtpVerfication();
//                     } else {
//                       // Snackbars.showWarningSnackBar(
//                       //   context: context,
//                       //   message: "Please enter a valid OTP code",
//                       // );
//                     }
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => RootScreen()),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showLoadingDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return AlertDialog(
//           content: Row(
//             children: [
//               CircularProgressIndicator(color: AppColors.primaryColor),
//               SizedBox(width: 20),
//               Text(
//                 'Verifying user...',
//                 style: AppThemes.f14w400,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
