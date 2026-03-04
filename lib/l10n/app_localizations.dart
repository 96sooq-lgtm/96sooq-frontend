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
