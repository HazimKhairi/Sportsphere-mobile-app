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

  String get train;
  String get sphereAi;
  String get approvals;
  String get strength;
  String get recovery;
  String get goodMorning;
  String get goodAfternoon;
  String get goodEvening;
  String get welcomeBack;
  String get today;
  String get tomorrow;
  String get yesterday;
  String get upNext;
  String get week;
  String get upcoming;
  String get logIn;
  String get signUp;
  String get createAccount;
  String get createYourAccount;
  String get alreadyHaveAccount;
  String get newHere;
  String get forgotPassword;
  String get sendResetLink;
  String get checkYourInbox;
  String get orContinueWith;
  String get confirmPassword;
  String get reTypePassword;
  String get enterYourEmail;
  String get enterYourPassword;
  String get passwordMinChars;
  String get passwordTooShort;
  String get passwordsDoNotMatch;
  String get invalidEmail;
  String get signUpFailed;
  String get loginFailed;
  String get signOutFailed;
  String get pickYourRole;
  String get player;
  String get coach;
  String get staff;
  String get playerDescription;
  String get staffDescription;
  String get oneAppTwoRoles;
  String get getStarted;
  String get continueText;
  String get paymentHistory;
  String get switchClub;
  String get playerCard;
  String get rewards;
  String get points;
  String get myVouchers;
  String get privacyPolicy;
  String get termsOfService;
  String get appDisplayLanguage;
  String get appearance;
  String get versionInfo;
  String get editPhoto;
  String get addPhoto;
  String get takePhoto;
  String get chooseFromGallery;
  String get photoLibrary;
  String get displayName;
  String get fullName;
  String get yourFullName;
  String get noClubSelected;
  String get viewYourDigitalId;
  String get viewYourTransactions;
  String get profileUpdated;
  String get updateYourDetails;
  String get register;
  String get registrationOpens;
  String get registrationCloses;
  String get capacity;
  String get openForRegistration;
  String get browsePrograms;
  String get noPrograms;
  String get programNotFound;
  String get coachWillAssignPrograms;
  String get checkBackLater;
  String get details;
  String get starting;
  String get noSessionsToday;
  String get scanToCheckIn;
  String get takeAttendance;
  String get sessionNotFound;
  String get sessionQr;
  String get showQr;
  String get findSession;
  String get alignQrCode;
  String get alreadyCheckedIn;
  String get checkedIn;
  String get checkingIn;
  String get wrongQr;
  String get sessionMedia;
  String get viewSessionMedia;
  String get uploadMedia;
  String get noMediaForSession;
  String get noMediaYet;
  String get deleteMedia;
  String get trainingSessionsAndEvents;
  String get searchPlayers;
  String get noPlayers;
  String get noPlayersFound;
  String get noPlayersInClub;
  String get viewAndManagePlayers;
  String get couldNotLoadRoster;
  String get playerNotFound;
  String get couldNotLoadPlayers;
  String get assignedPlayers;
  String get jerseyNumber;
  String get jerseySize;
  String get payWithCash;
  String get swipeToConfirmPayment;
  String get amountDue;
  String get waitingForStaff;
  String get paymentApproved;
  String get paymentRejected;
  String get paymentFailed;
  String get paymentNotFound;
  String get noPaymentsYet;
  String get couldNotLoadPayments;
  String get openReceipt;
  String get viewReceipt;
  String get handCashToStaff;
  String get staffWillConfirm;
  String get pendingCashPayments;
  String get noPendingApprovals;
  String get failedToLoadApprovals;
  String get approveFailed;
  String get rejectFailed;
  String get approve;
  String get reject;
  String get rejectPayment;
  String get reason;
  String get couldNotOpenReceipt;
  String get registrationConfirmed;
  String get registerForProgram;
  String get yourLast10Transactions;
  String get startWorkout;
  String get activeWorkout;
  String get logSet;
  String get logSetStartRest;
  String get skipRest;
  String get workoutTemplates;
  String get trainingPlans;
  String get newTrainingPlan;
  String get newWorkoutTemplate;
  String get noTemplates;
  String get noPlans;
  String get noWorkouts;
  String get noActiveplan;
  String get exercises;
  String get sets;
  String get reps;
  String get restSeconds;
  String get estDurationMin;
  String get deleteTemplate;
  String get deletePlan;
  String get manageWorkouts;
  String get createFirstPlan;
  String get createFirstTemplate;
  String get addExercise;
  String get noExercisesAdded;
  String get planDetails;
  String get planTitle;
  String get templateTitle;
  String get durationWeeks;
  String get exerciseName;
  String get noPlansAssigned;
  String get couldNotLoadTemplates;
  String get couldNotLoadPlans;
  String get activePlans;
  String get startPractice;
  String get aiPersonalised;
  String get drillNotFound;
  String get noDrillAssigned;
  String get noDrillsAvailable;
  String get coachCanPublishDrills;
  String get drillComplete;
  String get backToDrills;
  String get watchVideoGuide;
  String get markAsWatched;
  String get catalog;
  String get categories;
  String get bodyComposition;
  String get trackPhysique;
  String get bodyFat;
  String get muscle;
  String get bmi;
  String get addEntry;
  String get noEntries;
  String get logEntry;
  String get tapAddEntry;
  String get trackWeightHeight;
  String get couldNotLoadEntries;
  String get weightKg;
  String get dailyWellness;
  String get saveCheckIn;
  String get howAreYouFeeling;
  String get fatigue;
  String get mood;
  String get sleepQuality;
  String get stress;
  String get muscleSoreness;
  String get wellnessScore;
  String get logWellness;
  String get tapToLogWellness;
  String get loggedToday;
  String get regenerateAdvice;
  String get couldNotGenerateAdvice;
  String get nutrition;
  String get recoveryAndNutrition;
  String get contentNotFound;
  String get askSphereAi;
  String get newChat;
  String get connectionDropped;
  String get couldNotAttachImage;
  String get sphereAiDisclaimer;
  String get scoutProfile;
  String get createScoutProfile;
  String get editScoutProfile;
  String get getDiscovered;
  String get visibleToClubs;
  String get hiddenFromClubs;
  String get couldNotLoadScoutProfile;
  String get turnOnDiscoverable;
  String get highlightVideoUrl;
  String get availability;
  String get hoursPerWeek;
  String get travelRadius;
  String get availableWeekdays;
  String get availableWeekends;
  String get noPlayerCardYet;
  String get playerCardLive;
  String get getCardRated;
  String get selfRateSkills;
  String get saveCardToGallery;
  String get coachesRatePerformance;
  String get cardSavedToGallery;
  String get failedToSaveCard;
  String get pushNotifications;
  String get scheduleReminders;
  String get paymentUpdates;
  String get badgesAndMilestones;
  String get manageAlerts;
  String get notificationsBlocked;
  String get chooseWhatToNotify;
  String get receiveAllNotifications;
  String get allCaughtUp;
  String get noBadgesYet;
  String get noRewardsYet;
  String get noPointsActivity;
  String get couldNotLoadRewards;
  String get couldNotLoadPoints;
  String get couldNotLoadVouchers;
  String get spendPoints;
  String get earnBadges;
  String get coachCanPublishRewards;
  String get achievements;
  String get badgesUnlocked;
  String get yourBalance;
  String get totalEarned;
  String get trackMilestones;
  String get couldNotLoadClubInfo;
  String get aboutClub;
  String get coachingStaff;
  String get meetTheCoaches;
  String get viewClubDetails;
  String get sportsOffered;
  String get ageGroups;
  String get staffInviteOnly;
  String get myClub;
  String get tapToManage;
  String get tapToManageRoster;
  String get yourTeam;
  String get yourPerformanceHub;
  String get noActivityYet;
  String get loadMore;
  String get recent;
  String get general;
  String get legal;
  String get app;
  String get somethingWentWrong;
  String get networkError;
  String get optional;
  String get required;
  String get nameMinChars;
  String get enterYourName;
  String get goBack;
  String get goHome;
  String get backToHome;
  String get tryAgainLater;
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
