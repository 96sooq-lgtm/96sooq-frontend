import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @selectLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Your Language'**
  String get selectLanguageLabel;

  /// No description provided for @chooseyourpreferredlanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseyourpreferredlanguage;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @selectLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocationLabel;

  /// No description provided for @whatLookingForLabel.
  ///
  /// In en, this message translates to:
  /// **'What are you looking For?'**
  String get whatLookingForLabel;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @seeAllText.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAllText;

  /// No description provided for @offersTitle.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offersTitle;

  /// No description provided for @addListText.
  ///
  /// In en, this message translates to:
  /// **'Add / List'**
  String get addListText;

  /// No description provided for @dealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get dealsTitle;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @recentSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Search'**
  String get recentSearchTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @loginText.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginText;

  /// No description provided for @loginInYourAccountText.
  ///
  /// In en, this message translates to:
  /// **'Login in your account'**
  String get loginInYourAccountText;

  /// No description provided for @letsGetStartedText.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Get Started'**
  String get letsGetStartedText;

  /// No description provided for @agreeTermsConditionsText.
  ///
  /// In en, this message translates to:
  /// **'I agree to Terms and Conditions'**
  String get agreeTermsConditionsText;

  /// No description provided for @signupDescriptionText.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to get started with buying and selling locally'**
  String get signupDescriptionText;

  /// No description provided for @getStartedText.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStartedText;

  /// No description provided for @myProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfileTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @manageEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Email Address'**
  String get manageEmailTitle;

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Supports'**
  String get helpSupportTitle;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationTitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @logoutText.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutText;

  /// No description provided for @searchFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get searchFilterTitle;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @callText.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callText;

  /// No description provided for @whatsappText.
  ///
  /// In en, this message translates to:
  /// **'Whatsapp'**
  String get whatsappText;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get createAccountTitle;

  /// No description provided for @sendCodeText.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCodeText;

  /// No description provided for @otpVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerificationTitle;

  /// No description provided for @verifyText.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyText;

  /// No description provided for @didntReceivedCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t Received Code?'**
  String get didntReceivedCode;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @enterFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Full Name'**
  String get enterFullNameHint;

  /// No description provided for @enterMobileNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Mobile Number'**
  String get enterMobileNumberHint;

  /// No description provided for @signUpText.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpText;

  /// No description provided for @addCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategoryTitle;

  /// No description provided for @addSubCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Sub Category'**
  String get addSubCategoryTitle;

  /// No description provided for @addImagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Images'**
  String get addImagesTitle;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @nextText.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextText;

  /// No description provided for @conditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get conditionLabel;

  /// No description provided for @newCondition.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newCondition;

  /// No description provided for @usedCondition.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get usedCondition;

  /// No description provided for @exchangeCondition.
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get exchangeCondition;

  /// No description provided for @freeCondition.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeCondition;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @selectCityLabel.
  ///
  /// In en, this message translates to:
  /// **'Select your city'**
  String get selectCityLabel;

  /// No description provided for @selectPlaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Select your place'**
  String get selectPlaceLabel;

  /// No description provided for @submitText.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitText;

  /// No description provided for @cancelText.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelText;

  /// No description provided for @selectSubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Subscriptions'**
  String get selectSubscriptionTitle;

  /// No description provided for @boostListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Boost Your Listing'**
  String get boostListingTitle;

  /// No description provided for @boostAdTitle.
  ///
  /// In en, this message translates to:
  /// **'Boost Your Ad'**
  String get boostAdTitle;

  /// No description provided for @viewText.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewText;

  /// No description provided for @proceedToPayText.
  ///
  /// In en, this message translates to:
  /// **'Proceed to pay'**
  String get proceedToPayText;

  /// No description provided for @myDealsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Deals'**
  String get myDealsTitle;

  /// No description provided for @viewAllText.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAllText;

  /// No description provided for @quickActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Action'**
  String get quickActionTitle;

  /// No description provided for @myAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Ads'**
  String get myAdsTitle;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @recentChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Chat'**
  String get recentChatTitle;

  /// No description provided for @storesTitle.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get storesTitle;

  /// No description provided for @storeTitle.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get storeTitle;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @soldStatus.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get soldStatus;

  /// No description provided for @editText.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editText;

  /// No description provided for @promoteText.
  ///
  /// In en, this message translates to:
  /// **'Promote'**
  String get promoteText;

  /// No description provided for @selectAdFormatTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Ad Format'**
  String get selectAdFormatTitle;

  /// No description provided for @linkLabel.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get linkLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @buyingText.
  ///
  /// In en, this message translates to:
  /// **'Buying'**
  String get buyingText;

  /// No description provided for @sellingText.
  ///
  /// In en, this message translates to:
  /// **'Selling'**
  String get sellingText;

  /// No description provided for @allText.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allText;

  /// No description provided for @todayText.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayText;

  /// No description provided for @viewItemText.
  ///
  /// In en, this message translates to:
  /// **'View item'**
  String get viewItemText;

  /// No description provided for @chooseAccountTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your account type'**
  String get chooseAccountTypeTitle;

  /// No description provided for @selectRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the role that best fits your needs'**
  String get selectRoleSubtitle;

  /// No description provided for @advantagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Advantages'**
  String get advantagesTitle;

  /// No description provided for @simplePostingAdvantage.
  ///
  /// In en, this message translates to:
  /// **'Simple Posting: Share products, services, or updates effortlessly'**
  String get simplePostingAdvantage;

  /// No description provided for @directInteractionAdvantage.
  ///
  /// In en, this message translates to:
  /// **'Direct Interaction: Chat directly with sellers or service providers'**
  String get directInteractionAdvantage;

  /// No description provided for @quickEasySetupAdvantage.
  ///
  /// In en, this message translates to:
  /// **'Quick & Easy Setup: Start buying or posting in just a few steps'**
  String get quickEasySetupAdvantage;

  /// No description provided for @individualAdvantage1.
  ///
  /// In en, this message translates to:
  /// **'Chat directly with buyers for faster and easier deals.'**
  String get individualAdvantage1;

  /// No description provided for @individualAdvantage2.
  ///
  /// In en, this message translates to:
  /// **'Post products quickly without any complex setup process.'**
  String get individualAdvantage2;

  /// No description provided for @individualAdvantage3.
  ///
  /// In en, this message translates to:
  /// **'Reach nearby buyers and sell personal items easily.'**
  String get individualAdvantage3;

  /// No description provided for @businessAdvantage1.
  ///
  /// In en, this message translates to:
  /// **'Build customer trust with a professional business profile and reviews.'**
  String get businessAdvantage1;

  /// No description provided for @businessAdvantage2.
  ///
  /// In en, this message translates to:
  /// **'Showcase and manage multiple products from one profile.'**
  String get businessAdvantage2;

  /// No description provided for @businessAdvantage3.
  ///
  /// In en, this message translates to:
  /// **'Increase sales opportunities and grow your brand reach.'**
  String get businessAdvantage3;

  /// No description provided for @listYourProductTitle.
  ///
  /// In en, this message translates to:
  /// **'List Your Product'**
  String get listYourProductTitle;

  /// No description provided for @governorateLabel.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get governorateLabel;

  /// No description provided for @wilayatLabel.
  ///
  /// In en, this message translates to:
  /// **'Wilayat'**
  String get wilayatLabel;

  /// No description provided for @postText.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postText;

  /// No description provided for @postingText.
  ///
  /// In en, this message translates to:
  /// **'Posting'**
  String get postingText;

  /// No description provided for @chatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsTitle;

  /// No description provided for @noConversationsYetText.
  ///
  /// In en, this message translates to:
  /// **'No Conversations Yet'**
  String get noConversationsYetText;

  /// No description provided for @accountSettingsHeading.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettingsHeading;

  /// No description provided for @appPreferencesHeading.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferencesHeading;

  /// No description provided for @supportHeading.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportHeading;

  /// No description provided for @logoutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutDialogTitle;

  /// No description provided for @logoutDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutDialogMessage;

  /// No description provided for @useCurrentLocationText.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocationText;

  /// No description provided for @allInOmanText.
  ///
  /// In en, this message translates to:
  /// **'All in Oman'**
  String get allInOmanText;

  /// No description provided for @latestPicksTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest Picks'**
  String get latestPicksTitle;

  /// No description provided for @oopsText.
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get oopsText;

  /// No description provided for @noInternetMessage.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get noInternetMessage;

  /// No description provided for @tryAgainText.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainText;

  /// No description provided for @continueWithGoogleText.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogleText;

  /// No description provided for @continueWithAppleText.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithAppleText;

  /// No description provided for @downloadInvoiceText.
  ///
  /// In en, this message translates to:
  /// **'Download Invoice'**
  String get downloadInvoiceText;

  /// No description provided for @transactionHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistoryTitle;

  /// No description provided for @businessExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Business Expenses'**
  String get businessExpensesTitle;

  /// No description provided for @downloadInvoicesTaxRecords.
  ///
  /// In en, this message translates to:
  /// **'Download invoices for your tax records'**
  String get downloadInvoicesTaxRecords;

  /// No description provided for @individualAccountType.
  ///
  /// In en, this message translates to:
  /// **'Individual / Normal User'**
  String get individualAccountType;

  /// No description provided for @businessAccountType.
  ///
  /// In en, this message translates to:
  /// **'Business / Store'**
  String get businessAccountType;

  /// No description provided for @continueWithAccountType.
  ///
  /// In en, this message translates to:
  /// **'Continue with {accountType}'**
  String continueWithAccountType(Object accountType);

  /// No description provided for @individualShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individualShortLabel;

  /// No description provided for @businessShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get businessShortLabel;

  /// No description provided for @myStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'My Store'**
  String get myStoreTitle;

  /// No description provided for @myTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'My transactions'**
  String get myTransactionsTitle;

  /// No description provided for @noTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get noTransactionsTitle;

  /// No description provided for @storeDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Store details'**
  String get storeDetailsTitle;

  /// No description provided for @storeDetailsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Store details coming soon'**
  String get storeDetailsComingSoon;

  /// No description provided for @uploadBusinessLogoText.
  ///
  /// In en, this message translates to:
  /// **'Upload Business Logo'**
  String get uploadBusinessLogoText;

  /// No description provided for @storeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeNameLabel;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @howCanWeHelpYou.
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get howCanWeHelpYou;

  /// No description provided for @supportTeamDescription.
  ///
  /// In en, this message translates to:
  /// **'Our team is available to assist you with any questions about 96sooq.'**
  String get supportTeamDescription;

  /// No description provided for @whatsappSupport.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Support'**
  String get whatsappSupport;

  /// No description provided for @fastestResponseTime.
  ///
  /// In en, this message translates to:
  /// **'Fastest response time'**
  String get fastestResponseTime;

  /// No description provided for @chatNow.
  ///
  /// In en, this message translates to:
  /// **'Chat Now'**
  String get chatNow;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @emailUs.
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get emailUs;

  /// No description provided for @callSupport.
  ///
  /// In en, this message translates to:
  /// **'Call Support'**
  String get callSupport;

  /// No description provided for @speakWithOurTeam.
  ///
  /// In en, this message translates to:
  /// **'Speak with our team'**
  String get speakWithOurTeam;

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get callNow;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @noDealsFound.
  ///
  /// In en, this message translates to:
  /// **'No {status} deals found'**
  String noDealsFound(Object status);

  /// No description provided for @noSubcategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No subcategories found'**
  String get noSubcategoriesFound;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get statusSold;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @promotedText.
  ///
  /// In en, this message translates to:
  /// **'96 PROMOTED'**
  String get promotedText;

  /// No description provided for @subscriptionPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Plans'**
  String get subscriptionPlansTitle;

  /// No description provided for @forBusinessesTitle.
  ///
  /// In en, this message translates to:
  /// **'For Businesses'**
  String get forBusinessesTitle;

  /// No description provided for @forBusinessesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scalable solutions for Omani entrepreneurs and local store owners.'**
  String get forBusinessesSubtitle;

  /// No description provided for @chooseYourPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get chooseYourPlanTitle;

  /// No description provided for @chooseYourPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the best membership for your local selling needs in Oman.'**
  String get chooseYourPlanSubtitle;

  /// No description provided for @continueWithSelection.
  ///
  /// In en, this message translates to:
  /// **'Continue with Selection'**
  String get continueWithSelection;

  /// No description provided for @whyUpgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'WHY UPGRADE?'**
  String get whyUpgradeTitle;

  /// No description provided for @whyUpgradeDesc.
  ///
  /// In en, this message translates to:
  /// **'Best value users sell items 40% faster on average due to higher volume capacity.'**
  String get whyUpgradeDesc;

  /// No description provided for @bestValueBadge.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValueBadge;

  /// No description provided for @noSubscriptionPlans.
  ///
  /// In en, this message translates to:
  /// **'No subscription plans available right now.'**
  String get noSubscriptionPlans;

  /// No description provided for @daysListingDuration.
  ///
  /// In en, this message translates to:
  /// **'{days} days listing duration'**
  String daysListingDuration(Object days);

  /// No description provided for @daysLabel.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String daysLabel(Object days);

  /// No description provided for @priceRangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Price Range (OMR)'**
  String get priceRangeTitle;

  /// No description provided for @minPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Min Price'**
  String get minPriceLabel;

  /// No description provided for @maxPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Max Price'**
  String get maxPriceLabel;

  /// No description provided for @sellerTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller Type'**
  String get sellerTypeTitle;

  /// No description provided for @applyFiltersButton.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFiltersButton;

  /// No description provided for @ratingTitle.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingTitle;

  /// No description provided for @anyRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Any Rating'**
  String get anyRatingLabel;

  /// No description provided for @applyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyButton;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButton;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search electronics'**
  String get searchPlaceholder;

  /// No description provided for @recentSearchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearchesTitle;

  /// No description provided for @clearAllText.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAllText;

  /// No description provided for @popularSearchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular Searches'**
  String get popularSearchesTitle;

  /// No description provided for @postsTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get postsTabTitle;

  /// No description provided for @reviewsTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTabTitle;

  /// No description provided for @noListingsText.
  ///
  /// In en, this message translates to:
  /// **'No listings yet'**
  String get noListingsText;

  /// No description provided for @startAReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Start a Review'**
  String get startAReviewButton;

  /// No description provided for @noReviewsForBusiness.
  ///
  /// In en, this message translates to:
  /// **'There are no reviews for this\nbusiness as of now'**
  String get noReviewsForBusiness;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @writeAReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeAReviewTitle;

  /// No description provided for @rateBusinessPrompt.
  ///
  /// In en, this message translates to:
  /// **'How would you rate this business?'**
  String get rateBusinessPrompt;

  /// No description provided for @shareExperienceHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience (optional)'**
  String get shareExperienceHint;

  /// No description provided for @reviewSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully!'**
  String get reviewSubmittedSuccess;

  /// No description provided for @reviewSubmitFailedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit review: '**
  String get reviewSubmitFailedPrefix;

  /// No description provided for @submitReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReviewButton;

  /// No description provided for @starCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 star} other{{count} stars}}'**
  String starCount(int count);

  /// No description provided for @reviewCountText.
  ///
  /// In en, this message translates to:
  /// **'({count} {count, plural, =1{Review} other{Reviews}})'**
  String reviewCountText(int count);

  /// No description provided for @whichPromotionTitle.
  ///
  /// In en, this message translates to:
  /// **'Which promotion do you need for your product?'**
  String get whichPromotionTitle;

  /// No description provided for @promotionSelectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Select the best option to increase views, clicks, and sales.'**
  String get promotionSelectionDesc;

  /// No description provided for @daysTopLabel.
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get daysTopLabel;

  /// No description provided for @currentRateTopLabel.
  ///
  /// In en, this message translates to:
  /// **'CURRENT RATE'**
  String get currentRateTopLabel;

  /// No description provided for @perDayLabel.
  ///
  /// In en, this message translates to:
  /// **'/ PER DAY'**
  String get perDayLabel;

  /// No description provided for @forDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'/ for {days} days'**
  String forDaysLabel(Object days);

  /// No description provided for @totalPromotionDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Promotion Days'**
  String get totalPromotionDaysLabel;

  /// No description provided for @totalDaysCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{days} Days'**
  String totalDaysCountLabel(Object days);

  /// No description provided for @totalPriceTopLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTAL PRICE'**
  String get totalPriceTopLabel;

  /// No description provided for @listingSubmittedReviewText.
  ///
  /// In en, this message translates to:
  /// **'Your listing has been submitted for review!'**
  String get listingSubmittedReviewText;

  /// No description provided for @postWillBePublishedText.
  ///
  /// In en, this message translates to:
  /// **'Your post has been set for review and will be posted successfully in next 30 minutes'**
  String get postWillBePublishedText;

  /// No description provided for @checkoutFailedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Checkout failed: '**
  String get checkoutFailedPrefix;

  /// No description provided for @paymentSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get paymentSummaryTitle;

  /// No description provided for @selectedPlanTitleSection.
  ///
  /// In en, this message translates to:
  /// **'Selected Plan'**
  String get selectedPlanTitleSection;

  /// No description provided for @orderDetailsTitleSection.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetailsTitleSection;

  /// No description provided for @viewItemButton.
  ///
  /// In en, this message translates to:
  /// **'View Item'**
  String get viewItemButton;

  /// No description provided for @billedMonthlyText.
  ///
  /// In en, this message translates to:
  /// **'Billed monthly'**
  String get billedMonthlyText;

  /// No description provided for @subtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotalLabel;

  /// No description provided for @platformFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Platform Fee (2%)'**
  String get platformFeeLabel;

  /// No description provided for @totalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmountLabel;

  /// No description provided for @productListingAdOption.
  ///
  /// In en, this message translates to:
  /// **'Product Listing Ad'**
  String get productListingAdOption;

  /// No description provided for @payAndConfirmTotal.
  ///
  /// In en, this message translates to:
  /// **'Pay & Confirm {amount} {currency}'**
  String payAndConfirmTotal(Object amount, Object currency);

  /// No description provided for @noResultFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No result Found !'**
  String get noResultFoundTitle;

  /// No description provided for @noResultFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'There is no result for your search.\nCome on, try again!'**
  String get noResultFoundSubtitle;

  /// No description provided for @addAtLeast3Photos.
  ///
  /// In en, this message translates to:
  /// **'Add at least 3 photos of your ad'**
  String get addAtLeast3Photos;

  /// No description provided for @locationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Location Services Off'**
  String get locationServicesOff;

  /// No description provided for @locationServicesOffMessage.
  ///
  /// In en, this message translates to:
  /// **'To show nearby listings, please enable location services in your device settings.'**
  String get locationServicesOffMessage;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @unableToOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Unable to open link'**
  String get unableToOpenLink;

  /// No description provided for @cancelPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Payment?'**
  String get cancelPaymentTitle;

  /// No description provided for @cancelPaymentMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel?'**
  String get cancelPaymentMessage;

  /// No description provided for @noText.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noText;

  /// No description provided for @yesText.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesText;

  /// No description provided for @generatingInvoice.
  ///
  /// In en, this message translates to:
  /// **'Generating invoice...'**
  String get generatingInvoice;

  /// No description provided for @failedToGenerateInvoicePrefix.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate invoice: '**
  String get failedToGenerateInvoicePrefix;

  /// No description provided for @editListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Listing'**
  String get editListingTitle;

  /// No description provided for @listingUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Listing updated successfully!'**
  String get listingUpdatedSuccess;

  /// No description provided for @updateFailedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Update failed: '**
  String get updateFailedPrefix;

  /// No description provided for @updatingText.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updatingText;

  /// No description provided for @updateText.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateText;

  /// No description provided for @storeUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your store has been updated successfully'**
  String get storeUpdatedSuccess;

  /// No description provided for @storeCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your store has been created successfully'**
  String get storeCreatedSuccess;

  /// No description provided for @editYourStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Your Store'**
  String get editYourStoreTitle;

  /// No description provided for @createYourStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Store'**
  String get createYourStoreTitle;

  /// No description provided for @updateStoreText.
  ///
  /// In en, this message translates to:
  /// **'Update Store'**
  String get updateStoreText;

  /// No description provided for @selectGovernorateFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select governorate first'**
  String get selectGovernorateFirst;

  /// No description provided for @selectYourDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select your District'**
  String get selectYourDistrict;

  /// No description provided for @districtLabel.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get districtLabel;

  /// No description provided for @loadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Loading categories'**
  String get loadingCategories;

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No categories available right now'**
  String get noCategoriesAvailable;

  /// No description provided for @pleaseSelectCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select category first'**
  String get pleaseSelectCategoryFirst;

  /// No description provided for @loadingSubcategories.
  ///
  /// In en, this message translates to:
  /// **'Loading subcategories'**
  String get loadingSubcategories;

  /// No description provided for @noSubcategoriesForCategory.
  ///
  /// In en, this message translates to:
  /// **'No subcategories found for this category'**
  String get noSubcategoriesForCategory;

  /// No description provided for @pleaseAddSmallerImages.
  ///
  /// In en, this message translates to:
  /// **'Please add images smaller than 5 MB'**
  String get pleaseAddSmallerImages;

  /// No description provided for @atLeast3PhotosRequired.
  ///
  /// In en, this message translates to:
  /// **'At least 3 photos are required'**
  String get atLeast3PhotosRequired;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get typeAMessage;

  /// No description provided for @couldNotLoadChats.
  ///
  /// In en, this message translates to:
  /// **'Could not load chats'**
  String get couldNotLoadChats;

  /// No description provided for @retryText.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryText;

  /// No description provided for @tapToStartChatting.
  ///
  /// In en, this message translates to:
  /// **'Tap to start chatting'**
  String get tapToStartChatting;

  /// No description provided for @couldNotStartChatPrefix.
  ///
  /// In en, this message translates to:
  /// **'Could not start chat: '**
  String get couldNotStartChatPrefix;

  /// No description provided for @openLinkText.
  ///
  /// In en, this message translates to:
  /// **'Open Link'**
  String get openLinkText;

  /// No description provided for @sellerFallback.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get sellerFallback;

  /// No description provided for @storeFallback.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get storeFallback;

  /// No description provided for @userFallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userFallback;

  /// No description provided for @productFallback.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productFallback;

  /// No description provided for @noDescriptionText.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescriptionText;

  /// No description provided for @selectCategoryPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a category to view subcategories'**
  String get selectCategoryPrompt;

  /// No description provided for @failedToLoadSubcategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load subcategories'**
  String get failedToLoadSubcategories;

  /// No description provided for @failedToLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories'**
  String get failedToLoadCategories;

  /// No description provided for @failedToLoadStores.
  ///
  /// In en, this message translates to:
  /// **'Failed to load stores'**
  String get failedToLoadStores;

  /// No description provided for @failedToLoadProducts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load products'**
  String get failedToLoadProducts;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found.'**
  String get noProductsFound;

  /// No description provided for @pleaseSelectGovernorateFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select governorate first'**
  String get pleaseSelectGovernorateFirst;

  /// No description provided for @pleaseFullAllRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get pleaseFullAllRequiredFields;

  /// No description provided for @noAdsFound.
  ///
  /// In en, this message translates to:
  /// **'No ads found.'**
  String get noAdsFound;

  /// No description provided for @errorLoadingAds.
  ///
  /// In en, this message translates to:
  /// **'Error loading ads'**
  String get errorLoadingAds;

  /// No description provided for @noCitiesFound.
  ///
  /// In en, this message translates to:
  /// **'No cities found'**
  String get noCitiesFound;

  /// No description provided for @failedToLoadCities.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cities'**
  String get failedToLoadCities;

  /// No description provided for @noGovernoratesFound.
  ///
  /// In en, this message translates to:
  /// **'No governorates found'**
  String get noGovernoratesFound;

  /// No description provided for @failedToLoadGovernorates.
  ///
  /// In en, this message translates to:
  /// **'Failed to load governorates'**
  String get failedToLoadGovernorates;

  /// No description provided for @failedToLoadPlans.
  ///
  /// In en, this message translates to:
  /// **'Failed to load plans'**
  String get failedToLoadPlans;

  /// No description provided for @rejectionReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get rejectionReasonTitle;

  /// No description provided for @noReasonProvided.
  ///
  /// In en, this message translates to:
  /// **'No reason provided'**
  String get noReasonProvided;

  /// No description provided for @failedToLoadProductsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Failed to load products: '**
  String get failedToLoadProductsPrefix;

  /// No description provided for @deleteListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Listing'**
  String get deleteListingTitle;

  /// No description provided for @deleteListingMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this listing?'**
  String get deleteListingMessage;

  /// No description provided for @deleteText.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteText;

  /// No description provided for @markAsSold.
  ///
  /// In en, this message translates to:
  /// **'Mark as Sold'**
  String get markAsSold;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action is permanent and cannot be undone. All your data, listings, and history will be removed.'**
  String get deleteAccountMessage;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete My Account'**
  String get deleteAccountConfirm;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully deleted.'**
  String get accountDeletedSuccess;

  /// No description provided for @deletingAccountText.
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get deletingAccountText;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
