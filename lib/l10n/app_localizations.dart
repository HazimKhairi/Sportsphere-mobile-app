import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ms'),
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'SportSphere'**
  String get appTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About SportSphere'**
  String get about;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// No description provided for @roster.
  ///
  /// In en, this message translates to:
  /// **'Roster'**
  String get roster;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @programs.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get programs;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @languageSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred display language.'**
  String get languageSelectHint;

  /// No description provided for @availableLanguages.
  ///
  /// In en, this message translates to:
  /// **'Available languages'**
  String get availableLanguages;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @train.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get train;

  /// No description provided for @sphereAi.
  ///
  /// In en, this message translates to:
  /// **'Sphere AI'**
  String get sphereAi;

  /// No description provided for @approvals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get approvals;

  /// No description provided for @strength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get strength;

  /// No description provided for @recovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get recovery;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get upNext;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get newHere;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @checkYourInbox.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get checkYourInbox;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @reTypePassword.
  ///
  /// In en, this message translates to:
  /// **'Re-type your password'**
  String get reTypePassword;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @passwordMinChars.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordMinChars;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @signUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed. Try again.'**
  String get signUpFailed;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Try again.'**
  String get loginFailed;

  /// No description provided for @signOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed.'**
  String get signOutFailed;

  /// No description provided for @pickYourRole.
  ///
  /// In en, this message translates to:
  /// **'Pick your role'**
  String get pickYourRole;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @coach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get coach;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// No description provided for @playerDescription.
  ///
  /// In en, this message translates to:
  /// **'Training, drills, schedule, AI coach.'**
  String get playerDescription;

  /// No description provided for @staffDescription.
  ///
  /// In en, this message translates to:
  /// **'Attendance, roster, approvals.'**
  String get staffDescription;

  /// No description provided for @oneAppTwoRoles.
  ///
  /// In en, this message translates to:
  /// **'One App.\nTwo Roles.'**
  String get oneAppTwoRoles;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get paymentHistory;

  /// No description provided for @switchClub.
  ///
  /// In en, this message translates to:
  /// **'Switch club'**
  String get switchClub;

  /// No description provided for @playerCard.
  ///
  /// In en, this message translates to:
  /// **'Player Card'**
  String get playerCard;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @myVouchers.
  ///
  /// In en, this message translates to:
  /// **'My Vouchers'**
  String get myVouchers;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @appDisplayLanguage.
  ///
  /// In en, this message translates to:
  /// **'App display language'**
  String get appDisplayLanguage;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @versionInfo.
  ///
  /// In en, this message translates to:
  /// **'Version info and legal'**
  String get versionInfo;

  /// No description provided for @editPhoto.
  ///
  /// In en, this message translates to:
  /// **'Edit photo'**
  String get editPhoto;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @photoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Photo library'**
  String get photoLibrary;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @yourFullName.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get yourFullName;

  /// No description provided for @noClubSelected.
  ///
  /// In en, this message translates to:
  /// **'No club selected.'**
  String get noClubSelected;

  /// No description provided for @viewYourDigitalId.
  ///
  /// In en, this message translates to:
  /// **'View your digital ID'**
  String get viewYourDigitalId;

  /// No description provided for @viewYourTransactions.
  ///
  /// In en, this message translates to:
  /// **'View your transactions'**
  String get viewYourTransactions;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get profileUpdated;

  /// No description provided for @updateYourDetails.
  ///
  /// In en, this message translates to:
  /// **'Update your personal details'**
  String get updateYourDetails;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registrationOpens.
  ///
  /// In en, this message translates to:
  /// **'Registration opens'**
  String get registrationOpens;

  /// No description provided for @registrationCloses.
  ///
  /// In en, this message translates to:
  /// **'Registration closes'**
  String get registrationCloses;

  /// No description provided for @capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// No description provided for @openForRegistration.
  ///
  /// In en, this message translates to:
  /// **'Open for registration'**
  String get openForRegistration;

  /// No description provided for @browsePrograms.
  ///
  /// In en, this message translates to:
  /// **'Browse programs'**
  String get browsePrograms;

  /// No description provided for @noPrograms.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load programs.'**
  String get noPrograms;

  /// No description provided for @programNotFound.
  ///
  /// In en, this message translates to:
  /// **'Program not found'**
  String get programNotFound;

  /// No description provided for @coachWillAssignPrograms.
  ///
  /// In en, this message translates to:
  /// **'Your coach will assign training programs here.'**
  String get coachWillAssignPrograms;

  /// No description provided for @checkBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later or ask your coach to publish a new program.'**
  String get checkBackLater;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get starting;

  /// No description provided for @noSessionsToday.
  ///
  /// In en, this message translates to:
  /// **'No sessions on this day.'**
  String get noSessionsToday;

  /// No description provided for @scanToCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Scan to Check In'**
  String get scanToCheckIn;

  /// No description provided for @takeAttendance.
  ///
  /// In en, this message translates to:
  /// **'Take attendance'**
  String get takeAttendance;

  /// No description provided for @sessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Session not found'**
  String get sessionNotFound;

  /// No description provided for @sessionQr.
  ///
  /// In en, this message translates to:
  /// **'Session QR'**
  String get sessionQr;

  /// No description provided for @showQr.
  ///
  /// In en, this message translates to:
  /// **'Show QR'**
  String get showQr;

  /// No description provided for @findSession.
  ///
  /// In en, this message translates to:
  /// **'Find a session you want to join.'**
  String get findSession;

  /// No description provided for @alignQrCode.
  ///
  /// In en, this message translates to:
  /// **'Align the QR code inside the frame.'**
  String get alignQrCode;

  /// No description provided for @alreadyCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Already checked in to this session.'**
  String get alreadyCheckedIn;

  /// No description provided for @checkedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in. Welcome!'**
  String get checkedIn;

  /// No description provided for @checkingIn.
  ///
  /// In en, this message translates to:
  /// **'Checking you in...'**
  String get checkingIn;

  /// No description provided for @wrongQr.
  ///
  /// In en, this message translates to:
  /// **'Wrong QR for this session.'**
  String get wrongQr;

  /// No description provided for @sessionMedia.
  ///
  /// In en, this message translates to:
  /// **'Session Media'**
  String get sessionMedia;

  /// No description provided for @viewSessionMedia.
  ///
  /// In en, this message translates to:
  /// **'View Session Media'**
  String get viewSessionMedia;

  /// No description provided for @uploadMedia.
  ///
  /// In en, this message translates to:
  /// **'Upload Media'**
  String get uploadMedia;

  /// No description provided for @noMediaForSession.
  ///
  /// In en, this message translates to:
  /// **'No media for this session.'**
  String get noMediaForSession;

  /// No description provided for @noMediaYet.
  ///
  /// In en, this message translates to:
  /// **'No media yet. Add photos or videos from this session.'**
  String get noMediaYet;

  /// No description provided for @deleteMedia.
  ///
  /// In en, this message translates to:
  /// **'Delete media?'**
  String get deleteMedia;

  /// No description provided for @trainingSessionsAndEvents.
  ///
  /// In en, this message translates to:
  /// **'Training sessions and events'**
  String get trainingSessionsAndEvents;

  /// No description provided for @searchPlayers.
  ///
  /// In en, this message translates to:
  /// **'Search players...'**
  String get searchPlayers;

  /// No description provided for @noPlayers.
  ///
  /// In en, this message translates to:
  /// **'No players in roster.'**
  String get noPlayers;

  /// No description provided for @noPlayersFound.
  ///
  /// In en, this message translates to:
  /// **'No players found'**
  String get noPlayersFound;

  /// No description provided for @noPlayersInClub.
  ///
  /// In en, this message translates to:
  /// **'No players in your club yet.'**
  String get noPlayersInClub;

  /// No description provided for @viewAndManagePlayers.
  ///
  /// In en, this message translates to:
  /// **'View and manage players'**
  String get viewAndManagePlayers;

  /// No description provided for @couldNotLoadRoster.
  ///
  /// In en, this message translates to:
  /// **'Could not load roster.'**
  String get couldNotLoadRoster;

  /// No description provided for @playerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Player not found'**
  String get playerNotFound;

  /// No description provided for @couldNotLoadPlayers.
  ///
  /// In en, this message translates to:
  /// **'Could not load players.'**
  String get couldNotLoadPlayers;

  /// No description provided for @assignedPlayers.
  ///
  /// In en, this message translates to:
  /// **'Assigned Players'**
  String get assignedPlayers;

  /// No description provided for @jerseyNumber.
  ///
  /// In en, this message translates to:
  /// **'Jersey number'**
  String get jerseyNumber;

  /// No description provided for @jerseySize.
  ///
  /// In en, this message translates to:
  /// **'Jersey size'**
  String get jerseySize;

  /// No description provided for @payWithCash.
  ///
  /// In en, this message translates to:
  /// **'Pay with cash'**
  String get payWithCash;

  /// No description provided for @swipeToConfirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Swipe to confirm payment'**
  String get swipeToConfirmPayment;

  /// No description provided for @amountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount due'**
  String get amountDue;

  /// No description provided for @waitingForStaff.
  ///
  /// In en, this message translates to:
  /// **'Waiting for staff'**
  String get waitingForStaff;

  /// No description provided for @paymentApproved.
  ///
  /// In en, this message translates to:
  /// **'Payment approved.'**
  String get paymentApproved;

  /// No description provided for @paymentRejected.
  ///
  /// In en, this message translates to:
  /// **'Payment rejected.'**
  String get paymentRejected;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailed;

  /// No description provided for @paymentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Payment not found'**
  String get paymentNotFound;

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get noPaymentsYet;

  /// No description provided for @couldNotLoadPayments.
  ///
  /// In en, this message translates to:
  /// **'Could not load your payments.'**
  String get couldNotLoadPayments;

  /// No description provided for @openReceipt.
  ///
  /// In en, this message translates to:
  /// **'Open receipt'**
  String get openReceipt;

  /// No description provided for @viewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View receipt'**
  String get viewReceipt;

  /// No description provided for @handCashToStaff.
  ///
  /// In en, this message translates to:
  /// **'Hand cash to staff at the counter. Swipe below to record your payment.'**
  String get handCashToStaff;

  /// No description provided for @staffWillConfirm.
  ///
  /// In en, this message translates to:
  /// **'You will get a notification once staff confirms your payment.'**
  String get staffWillConfirm;

  /// No description provided for @pendingCashPayments.
  ///
  /// In en, this message translates to:
  /// **'Pending cash payments to review.'**
  String get pendingCashPayments;

  /// No description provided for @noPendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'No pending approvals.'**
  String get noPendingApprovals;

  /// No description provided for @failedToLoadApprovals.
  ///
  /// In en, this message translates to:
  /// **'Failed to load approvals.'**
  String get failedToLoadApprovals;

  /// No description provided for @approveFailed.
  ///
  /// In en, this message translates to:
  /// **'Approve failed. Try again.'**
  String get approveFailed;

  /// No description provided for @rejectFailed.
  ///
  /// In en, this message translates to:
  /// **'Reject failed. Try again.'**
  String get rejectFailed;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @rejectPayment.
  ///
  /// In en, this message translates to:
  /// **'Reject payment'**
  String get rejectPayment;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @couldNotOpenReceipt.
  ///
  /// In en, this message translates to:
  /// **'Could not open receipt.'**
  String get couldNotOpenReceipt;

  /// No description provided for @registrationConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your registration is confirmed. We sent a receipt to your email.'**
  String get registrationConfirmed;

  /// No description provided for @registerForProgram.
  ///
  /// In en, this message translates to:
  /// **'Register for a program to see your payment history here.'**
  String get registerForProgram;

  /// No description provided for @yourLast10Transactions.
  ///
  /// In en, this message translates to:
  /// **'Your last 10 transactions.'**
  String get yourLast10Transactions;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// No description provided for @activeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Active Workout'**
  String get activeWorkout;

  /// No description provided for @logSet.
  ///
  /// In en, this message translates to:
  /// **'Log Set'**
  String get logSet;

  /// No description provided for @logSetStartRest.
  ///
  /// In en, this message translates to:
  /// **'Log Set + Start Rest'**
  String get logSetStartRest;

  /// No description provided for @skipRest.
  ///
  /// In en, this message translates to:
  /// **'Skip rest'**
  String get skipRest;

  /// No description provided for @workoutTemplates.
  ///
  /// In en, this message translates to:
  /// **'Workout Templates'**
  String get workoutTemplates;

  /// No description provided for @trainingPlans.
  ///
  /// In en, this message translates to:
  /// **'Training Plans'**
  String get trainingPlans;

  /// No description provided for @newTrainingPlan.
  ///
  /// In en, this message translates to:
  /// **'New Training Plan'**
  String get newTrainingPlan;

  /// No description provided for @newWorkoutTemplate.
  ///
  /// In en, this message translates to:
  /// **'New Workout Template'**
  String get newWorkoutTemplate;

  /// No description provided for @noTemplates.
  ///
  /// In en, this message translates to:
  /// **'No templates yet.'**
  String get noTemplates;

  /// No description provided for @noPlans.
  ///
  /// In en, this message translates to:
  /// **'No plans yet.'**
  String get noPlans;

  /// No description provided for @noWorkouts.
  ///
  /// In en, this message translates to:
  /// **'No workouts assigned yet.'**
  String get noWorkouts;

  /// No description provided for @noActiveplan.
  ///
  /// In en, this message translates to:
  /// **'No active plan'**
  String get noActiveplan;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @restSeconds.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get restSeconds;

  /// No description provided for @estDurationMin.
  ///
  /// In en, this message translates to:
  /// **'Est. duration (min)'**
  String get estDurationMin;

  /// No description provided for @deleteTemplate.
  ///
  /// In en, this message translates to:
  /// **'Delete template?'**
  String get deleteTemplate;

  /// No description provided for @deletePlan.
  ///
  /// In en, this message translates to:
  /// **'Delete plan?'**
  String get deletePlan;

  /// No description provided for @manageWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Manage workouts & plans'**
  String get manageWorkouts;

  /// No description provided for @createFirstPlan.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first training plan.'**
  String get createFirstPlan;

  /// No description provided for @createFirstTemplate.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first workout template.'**
  String get createFirstTemplate;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add at least one exercise.'**
  String get addExercise;

  /// No description provided for @noExercisesAdded.
  ///
  /// In en, this message translates to:
  /// **'No exercises added yet.'**
  String get noExercisesAdded;

  /// No description provided for @planDetails.
  ///
  /// In en, this message translates to:
  /// **'Plan Details'**
  String get planDetails;

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan title'**
  String get planTitle;

  /// No description provided for @templateTitle.
  ///
  /// In en, this message translates to:
  /// **'Template title'**
  String get templateTitle;

  /// No description provided for @durationWeeks.
  ///
  /// In en, this message translates to:
  /// **'Duration (weeks)'**
  String get durationWeeks;

  /// No description provided for @exerciseName.
  ///
  /// In en, this message translates to:
  /// **'Exercise name'**
  String get exerciseName;

  /// No description provided for @noPlansAssigned.
  ///
  /// In en, this message translates to:
  /// **'No plans assigned yet.'**
  String get noPlansAssigned;

  /// No description provided for @couldNotLoadTemplates.
  ///
  /// In en, this message translates to:
  /// **'Could not load templates.'**
  String get couldNotLoadTemplates;

  /// No description provided for @couldNotLoadPlans.
  ///
  /// In en, this message translates to:
  /// **'Could not load plans.'**
  String get couldNotLoadPlans;

  /// No description provided for @activePlans.
  ///
  /// In en, this message translates to:
  /// **'Active Plans'**
  String get activePlans;

  /// No description provided for @startPractice.
  ///
  /// In en, this message translates to:
  /// **'Start Practice'**
  String get startPractice;

  /// No description provided for @aiPersonalised.
  ///
  /// In en, this message translates to:
  /// **'AI-personalised'**
  String get aiPersonalised;

  /// No description provided for @drillNotFound.
  ///
  /// In en, this message translates to:
  /// **'Drill not found'**
  String get drillNotFound;

  /// No description provided for @noDrillAssigned.
  ///
  /// In en, this message translates to:
  /// **'No drill assigned'**
  String get noDrillAssigned;

  /// No description provided for @noDrillsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No drills available'**
  String get noDrillsAvailable;

  /// No description provided for @coachCanPublishDrills.
  ///
  /// In en, this message translates to:
  /// **'Your coach can publish drills from the dashboard.'**
  String get coachCanPublishDrills;

  /// No description provided for @drillComplete.
  ///
  /// In en, this message translates to:
  /// **'Drill complete'**
  String get drillComplete;

  /// No description provided for @backToDrills.
  ///
  /// In en, this message translates to:
  /// **'Back to drills'**
  String get backToDrills;

  /// No description provided for @watchVideoGuide.
  ///
  /// In en, this message translates to:
  /// **'Watch Video Guide'**
  String get watchVideoGuide;

  /// No description provided for @markAsWatched.
  ///
  /// In en, this message translates to:
  /// **'Mark as watched'**
  String get markAsWatched;

  /// No description provided for @catalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get catalog;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @bodyComposition.
  ///
  /// In en, this message translates to:
  /// **'Body composition'**
  String get bodyComposition;

  /// No description provided for @trackPhysique.
  ///
  /// In en, this message translates to:
  /// **'Monitor your physique progress'**
  String get trackPhysique;

  /// No description provided for @bodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body fat'**
  String get bodyFat;

  /// No description provided for @muscle.
  ///
  /// In en, this message translates to:
  /// **'Muscle'**
  String get muscle;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @addEntry.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get addEntry;

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noEntries;

  /// No description provided for @logEntry.
  ///
  /// In en, this message translates to:
  /// **'Log another entry to start tracking changes.'**
  String get logEntry;

  /// No description provided for @tapAddEntry.
  ///
  /// In en, this message translates to:
  /// **'Tap Add entry to log your first measurement.'**
  String get tapAddEntry;

  /// No description provided for @trackWeightHeight.
  ///
  /// In en, this message translates to:
  /// **'Track weight, height, and composition over time.'**
  String get trackWeightHeight;

  /// No description provided for @couldNotLoadEntries.
  ///
  /// In en, this message translates to:
  /// **'Could not load entries.'**
  String get couldNotLoadEntries;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @dailyWellness.
  ///
  /// In en, this message translates to:
  /// **'Daily Wellness'**
  String get dailyWellness;

  /// No description provided for @saveCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Save Check-In'**
  String get saveCheckIn;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get howAreYouFeeling;

  /// No description provided for @fatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get fatigue;

  /// No description provided for @mood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// No description provided for @sleepQuality.
  ///
  /// In en, this message translates to:
  /// **'Sleep Quality'**
  String get sleepQuality;

  /// No description provided for @stress.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get stress;

  /// No description provided for @muscleSoreness.
  ///
  /// In en, this message translates to:
  /// **'Muscle Soreness'**
  String get muscleSoreness;

  /// No description provided for @wellnessScore.
  ///
  /// In en, this message translates to:
  /// **'Wellness score'**
  String get wellnessScore;

  /// No description provided for @logWellness.
  ///
  /// In en, this message translates to:
  /// **'Log your daily wellness'**
  String get logWellness;

  /// No description provided for @tapToLogWellness.
  ///
  /// In en, this message translates to:
  /// **'Tap to log wellness'**
  String get tapToLogWellness;

  /// No description provided for @loggedToday.
  ///
  /// In en, this message translates to:
  /// **'Logged today'**
  String get loggedToday;

  /// No description provided for @regenerateAdvice.
  ///
  /// In en, this message translates to:
  /// **'Regenerate advice'**
  String get regenerateAdvice;

  /// No description provided for @couldNotGenerateAdvice.
  ///
  /// In en, this message translates to:
  /// **'Could not generate advice.'**
  String get couldNotGenerateAdvice;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// No description provided for @recoveryAndNutrition.
  ///
  /// In en, this message translates to:
  /// **'Recovery & Nutrition'**
  String get recoveryAndNutrition;

  /// No description provided for @contentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Content not found.'**
  String get contentNotFound;

  /// No description provided for @askSphereAi.
  ///
  /// In en, this message translates to:
  /// **'Ask Sphere AI...'**
  String get askSphereAi;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @connectionDropped.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I lost connection. Try again.'**
  String get connectionDropped;

  /// No description provided for @couldNotAttachImage.
  ///
  /// In en, this message translates to:
  /// **'Could not attach image. Try again.'**
  String get couldNotAttachImage;

  /// No description provided for @sphereAiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'For general sporting guidance only. Not a substitute for professional advice.'**
  String get sphereAiDisclaimer;

  /// No description provided for @scoutProfile.
  ///
  /// In en, this message translates to:
  /// **'Scout Profile'**
  String get scoutProfile;

  /// No description provided for @createScoutProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Scout Profile'**
  String get createScoutProfile;

  /// No description provided for @editScoutProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Scout Profile'**
  String get editScoutProfile;

  /// No description provided for @getDiscovered.
  ///
  /// In en, this message translates to:
  /// **'Get Discovered'**
  String get getDiscovered;

  /// No description provided for @visibleToClubs.
  ///
  /// In en, this message translates to:
  /// **'Visible to clubs'**
  String get visibleToClubs;

  /// No description provided for @hiddenFromClubs.
  ///
  /// In en, this message translates to:
  /// **'Hidden from clubs'**
  String get hiddenFromClubs;

  /// No description provided for @couldNotLoadScoutProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load scout profile'**
  String get couldNotLoadScoutProfile;

  /// No description provided for @turnOnDiscoverable.
  ///
  /// In en, this message translates to:
  /// **'Turn on to be discoverable by clubs'**
  String get turnOnDiscoverable;

  /// No description provided for @highlightVideoUrl.
  ///
  /// In en, this message translates to:
  /// **'Highlight Video URL (optional)'**
  String get highlightVideoUrl;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @hoursPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Hours/week:'**
  String get hoursPerWeek;

  /// No description provided for @travelRadius.
  ///
  /// In en, this message translates to:
  /// **'Travel radius:'**
  String get travelRadius;

  /// No description provided for @availableWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Available weekdays'**
  String get availableWeekdays;

  /// No description provided for @availableWeekends.
  ///
  /// In en, this message translates to:
  /// **'Available weekends'**
  String get availableWeekends;

  /// No description provided for @noPlayerCardYet.
  ///
  /// In en, this message translates to:
  /// **'No Player Card Yet'**
  String get noPlayerCardYet;

  /// No description provided for @playerCardLive.
  ///
  /// In en, this message translates to:
  /// **'Your card is live — clubs can find you'**
  String get playerCardLive;

  /// No description provided for @getCardRated.
  ///
  /// In en, this message translates to:
  /// **'Get rated by a coach to unlock your official card'**
  String get getCardRated;

  /// No description provided for @selfRateSkills.
  ///
  /// In en, this message translates to:
  /// **'Self-Rate Skills'**
  String get selfRateSkills;

  /// No description provided for @saveCardToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save Card to Gallery'**
  String get saveCardToGallery;

  /// No description provided for @coachesRatePerformance.
  ///
  /// In en, this message translates to:
  /// **'Coaches rate your performance. Your card improves in real time.'**
  String get coachesRatePerformance;

  /// No description provided for @cardSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Card saved to gallery!'**
  String get cardSavedToGallery;

  /// No description provided for @failedToSaveCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to save card.'**
  String get failedToSaveCard;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @scheduleReminders.
  ///
  /// In en, this message translates to:
  /// **'Schedule reminders'**
  String get scheduleReminders;

  /// No description provided for @paymentUpdates.
  ///
  /// In en, this message translates to:
  /// **'Payment updates'**
  String get paymentUpdates;

  /// No description provided for @badgesAndMilestones.
  ///
  /// In en, this message translates to:
  /// **'Badges and milestone alerts'**
  String get badgesAndMilestones;

  /// No description provided for @manageAlerts.
  ///
  /// In en, this message translates to:
  /// **'Manage alerts and push settings'**
  String get manageAlerts;

  /// No description provided for @notificationsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked. Go to device Settings to enable them.'**
  String get notificationsBlocked;

  /// No description provided for @chooseWhatToNotify.
  ///
  /// In en, this message translates to:
  /// **'Choose what you want to be notified about.'**
  String get chooseWhatToNotify;

  /// No description provided for @receiveAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive all app notifications'**
  String get receiveAllNotifications;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get allCaughtUp;

  /// No description provided for @noBadgesYet.
  ///
  /// In en, this message translates to:
  /// **'No badges yet'**
  String get noBadgesYet;

  /// No description provided for @noRewardsYet.
  ///
  /// In en, this message translates to:
  /// **'No rewards yet'**
  String get noRewardsYet;

  /// No description provided for @noPointsActivity.
  ///
  /// In en, this message translates to:
  /// **'No points activity yet.'**
  String get noPointsActivity;

  /// No description provided for @couldNotLoadRewards.
  ///
  /// In en, this message translates to:
  /// **'Could not load rewards.'**
  String get couldNotLoadRewards;

  /// No description provided for @couldNotLoadPoints.
  ///
  /// In en, this message translates to:
  /// **'Could not load points.'**
  String get couldNotLoadPoints;

  /// No description provided for @couldNotLoadVouchers.
  ///
  /// In en, this message translates to:
  /// **'Could not load vouchers.'**
  String get couldNotLoadVouchers;

  /// No description provided for @spendPoints.
  ///
  /// In en, this message translates to:
  /// **'Spend points on stuff your club has stocked.'**
  String get spendPoints;

  /// No description provided for @earnBadges.
  ///
  /// In en, this message translates to:
  /// **'Earn badges as you train. The harder the tier, the rarer the unlock.'**
  String get earnBadges;

  /// No description provided for @coachCanPublishRewards.
  ///
  /// In en, this message translates to:
  /// **'Your coach can publish rewards from the dashboard.'**
  String get coachCanPublishRewards;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @badgesUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Badges unlocked'**
  String get badgesUnlocked;

  /// No description provided for @yourBalance.
  ///
  /// In en, this message translates to:
  /// **'Your balance'**
  String get yourBalance;

  /// No description provided for @totalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total earned'**
  String get totalEarned;

  /// No description provided for @trackMilestones.
  ///
  /// In en, this message translates to:
  /// **'Track your milestones'**
  String get trackMilestones;

  /// No description provided for @couldNotLoadClubInfo.
  ///
  /// In en, this message translates to:
  /// **'Could not load club info'**
  String get couldNotLoadClubInfo;

  /// No description provided for @aboutClub.
  ///
  /// In en, this message translates to:
  /// **'About the Club'**
  String get aboutClub;

  /// No description provided for @coachingStaff.
  ///
  /// In en, this message translates to:
  /// **'Coaching Staff'**
  String get coachingStaff;

  /// No description provided for @meetTheCoaches.
  ///
  /// In en, this message translates to:
  /// **'Meet the Coaches'**
  String get meetTheCoaches;

  /// No description provided for @viewClubDetails.
  ///
  /// In en, this message translates to:
  /// **'View club details'**
  String get viewClubDetails;

  /// No description provided for @sportsOffered.
  ///
  /// In en, this message translates to:
  /// **'Sports Offered'**
  String get sportsOffered;

  /// No description provided for @ageGroups.
  ///
  /// In en, this message translates to:
  /// **'Age Groups'**
  String get ageGroups;

  /// No description provided for @staffInviteOnly.
  ///
  /// In en, this message translates to:
  /// **'Staff is invite only'**
  String get staffInviteOnly;

  /// No description provided for @myClub.
  ///
  /// In en, this message translates to:
  /// **'My Club'**
  String get myClub;

  /// No description provided for @tapToManage.
  ///
  /// In en, this message translates to:
  /// **'Tap to manage'**
  String get tapToManage;

  /// No description provided for @tapToManageRoster.
  ///
  /// In en, this message translates to:
  /// **'Tap to manage roster'**
  String get tapToManageRoster;

  /// No description provided for @yourTeam.
  ///
  /// In en, this message translates to:
  /// **'Your team'**
  String get yourTeam;

  /// No description provided for @yourPerformanceHub.
  ///
  /// In en, this message translates to:
  /// **'Your performance hub.'**
  String get yourPerformanceHub;

  /// No description provided for @noActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No activity yet. Train today to start your streak.'**
  String get noActivityYet;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get app;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network hiccup. Try again.'**
  String get networkError;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @nameMinChars.
  ///
  /// In en, this message translates to:
  /// **'Min 2 characters'**
  String get nameMinChars;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get enterYourName;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go home'**
  String get goHome;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Try again later.'**
  String get tryAgainLater;

  /// No description provided for @trackMeals.
  ///
  /// In en, this message translates to:
  /// **'Track your meals and fuel your performance.'**
  String get trackMeals;

  /// No description provided for @todaysMeals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meals'**
  String get todaysMeals;

  /// No description provided for @noMealsLoggedToday.
  ///
  /// In en, this message translates to:
  /// **'No meals logged today'**
  String get noMealsLoggedToday;

  /// No description provided for @tapToLogMeal.
  ///
  /// In en, this message translates to:
  /// **'Tap + to log your first meal'**
  String get tapToLogMeal;

  /// No description provided for @logMeal.
  ///
  /// In en, this message translates to:
  /// **'Log Meal'**
  String get logMeal;

  /// No description provided for @analysePhoto.
  ///
  /// In en, this message translates to:
  /// **'Analyse'**
  String get analysePhoto;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @mealType.
  ///
  /// In en, this message translates to:
  /// **'Meal type'**
  String get mealType;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @photoAnalysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Photo analysis failed. Try again.'**
  String get photoAnalysisFailed;

  /// No description provided for @saveLog.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveLog;

  /// No description provided for @foodsDetected.
  ///
  /// In en, this message translates to:
  /// **'Foods detected'**
  String get foodsDetected;

  /// No description provided for @kcalTotal.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal total'**
  String kcalTotal(int calories);

  /// No description provided for @deleteMealLog.
  ///
  /// In en, this message translates to:
  /// **'Delete meal log'**
  String get deleteMealLog;

  /// No description provided for @deleteMealLogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this meal from today\'s log?'**
  String get deleteMealLogConfirm;

  /// No description provided for @nutritionTracker.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutritionTracker;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ms'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ms':
      return AppLocalizationsMs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
