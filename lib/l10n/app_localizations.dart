import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bs.dart';
import 'app_localizations_en.dart';
import 'app_localizations_it.dart';
import 'app_localizations_mk.dart';
import 'app_localizations_sr.dart';
import 'app_localizations_tr.dart';

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
    Locale('bs'),
    Locale('en'),
    Locale('it'),
    Locale('mk'),
    Locale('sr'),
    Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ChampHive'**
  String get appTitle;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @hive.
  ///
  /// In en, this message translates to:
  /// **'Hive'**
  String get hive;

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

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseEnterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get pleaseEnterFirstName;

  /// No description provided for @pleaseEnterLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get pleaseEnterLastName;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Check your credentials.'**
  String get loginFailed;

  /// No description provided for @faceIdSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID to sign in'**
  String get faceIdSignInPrompt;

  /// No description provided for @signInWithFaceId.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Face ID'**
  String get signInWithFaceId;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registrationFailed;

  /// No description provided for @myClubs.
  ///
  /// In en, this message translates to:
  /// **'My clubs'**
  String get myClubs;

  /// No description provided for @noClubsYet.
  ///
  /// In en, this message translates to:
  /// **'You\'re not a member of any club yet.'**
  String get noClubsYet;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @teams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get teams;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About ChampHive'**
  String get aboutApp;

  /// No description provided for @moreManagement.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get moreManagement;

  /// No description provided for @moreAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get moreAccount;

  /// No description provided for @moreSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get moreSupport;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

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

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @comingSoonNamed.
  ///
  /// In en, this message translates to:
  /// **'{label} coming soon'**
  String comingSoonNamed(String label);

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get sessionExpired;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @selectClub.
  ///
  /// In en, this message translates to:
  /// **'Select a club'**
  String get selectClub;

  /// No description provided for @selectClubFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a club first'**
  String get selectClubFirst;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noData;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @optionalNote.
  ///
  /// In en, this message translates to:
  /// **'Optional note'**
  String get optionalNote;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @scope.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get scope;

  /// No description provided for @when.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get when;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @importMethod.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importMethod;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @session.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// No description provided for @club.
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get club;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezone;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @registrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration #'**
  String get registrationNumber;

  /// No description provided for @shirtNumber.
  ///
  /// In en, this message translates to:
  /// **'Shirt number'**
  String get shirtNumber;

  /// No description provided for @shirtNumberValue.
  ///
  /// In en, this message translates to:
  /// **'Shirt #{number}'**
  String shirtNumberValue(String number);

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageMacedonian.
  ///
  /// In en, this message translates to:
  /// **'Macedonian'**
  String get languageMacedonian;

  /// No description provided for @languageSerbian.
  ///
  /// In en, this message translates to:
  /// **'Serbian'**
  String get languageSerbian;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// No description provided for @languageBosnian.
  ///
  /// In en, this message translates to:
  /// **'Bosnian'**
  String get languageBosnian;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get languageTurkish;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get languageSystem;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessage;

  /// No description provided for @newSchedule.
  ///
  /// In en, this message translates to:
  /// **'New schedule'**
  String get newSchedule;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get recordPayment;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @outstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @myFees.
  ///
  /// In en, this message translates to:
  /// **'My fees'**
  String get myFees;

  /// No description provided for @membership.
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get membership;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @exploreDemo.
  ///
  /// In en, this message translates to:
  /// **'Explore demo UI'**
  String get exploreDemo;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your team. One place.'**
  String get tagline;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @signInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with email'**
  String get signInWithEmail;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// No description provided for @newToChampHive.
  ///
  /// In en, this message translates to:
  /// **'New to ChampHive? '**
  String get newToChampHive;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account!'**
  String get createAccount;

  /// No description provided for @accountsViaInviteNote.
  ///
  /// In en, this message translates to:
  /// **'Accounts are normally created via invite. Sign-up may be ops-only on this API.'**
  String get accountsViaInviteNote;

  /// No description provided for @coachFallback.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get coachFallback;

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

  /// No description provided for @yourTeams.
  ///
  /// In en, this message translates to:
  /// **'Your teams'**
  String get yourTeams;

  /// No description provided for @yourClubs.
  ///
  /// In en, this message translates to:
  /// **'Your clubs'**
  String get yourClubs;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @nextMatch.
  ///
  /// In en, this message translates to:
  /// **'Next match'**
  String get nextMatch;

  /// No description provided for @tbd.
  ///
  /// In en, this message translates to:
  /// **'TBD'**
  String get tbd;

  /// No description provided for @nothingOnScheduleToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing on the schedule today. Open Calendar to browse.'**
  String get nothingOnScheduleToday;

  /// No description provided for @nothingTodayNextUp.
  ///
  /// In en, this message translates to:
  /// **'Nothing today — next up'**
  String get nothingTodayNextUp;

  /// No description provided for @couldNotLoadClubs.
  ///
  /// In en, this message translates to:
  /// **'Could not load clubs'**
  String get couldNotLoadClubs;

  /// No description provided for @couldNotLoadSchedule.
  ///
  /// In en, this message translates to:
  /// **'Could not load schedule'**
  String get couldNotLoadSchedule;

  /// No description provided for @couldNotLoadEvents.
  ///
  /// In en, this message translates to:
  /// **'Could not load events'**
  String get couldNotLoadEvents;

  /// No description provided for @couldNotLoadTeams.
  ///
  /// In en, this message translates to:
  /// **'Could not load teams'**
  String get couldNotLoadTeams;

  /// No description provided for @couldNotLoadMembers.
  ///
  /// In en, this message translates to:
  /// **'Could not load members'**
  String get couldNotLoadMembers;

  /// No description provided for @couldNotLoadMember.
  ///
  /// In en, this message translates to:
  /// **'Could not load member'**
  String get couldNotLoadMember;

  /// No description provided for @couldNotLoadRoster.
  ///
  /// In en, this message translates to:
  /// **'Could not load roster'**
  String get couldNotLoadRoster;

  /// No description provided for @couldNotLoadSession.
  ///
  /// In en, this message translates to:
  /// **'Could not load session'**
  String get couldNotLoadSession;

  /// No description provided for @couldNotLoadReport.
  ///
  /// In en, this message translates to:
  /// **'Could not load report'**
  String get couldNotLoadReport;

  /// No description provided for @couldNotLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Could not load history'**
  String get couldNotLoadHistory;

  /// No description provided for @couldNotLoadConversations.
  ///
  /// In en, this message translates to:
  /// **'Could not load conversations'**
  String get couldNotLoadConversations;

  /// No description provided for @couldNotLoadChat.
  ///
  /// In en, this message translates to:
  /// **'Could not load chat'**
  String get couldNotLoadChat;

  /// No description provided for @couldNotLoadPeople.
  ///
  /// In en, this message translates to:
  /// **'Could not load people'**
  String get couldNotLoadPeople;

  /// No description provided for @couldNotLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Could not load notifications'**
  String get couldNotLoadNotifications;

  /// No description provided for @couldNotLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Could not load more'**
  String get couldNotLoadMore;

  /// No description provided for @couldNotLoadObligations.
  ///
  /// In en, this message translates to:
  /// **'Could not load obligations'**
  String get couldNotLoadObligations;

  /// No description provided for @couldNotLoadPayments.
  ///
  /// In en, this message translates to:
  /// **'Could not load payments'**
  String get couldNotLoadPayments;

  /// No description provided for @couldNotLoadFees.
  ///
  /// In en, this message translates to:
  /// **'Could not load your fees'**
  String get couldNotLoadFees;

  /// No description provided for @couldNotLoadClub.
  ///
  /// In en, this message translates to:
  /// **'Could not load club'**
  String get couldNotLoadClub;

  /// No description provided for @couldNotLoadMembershipStats.
  ///
  /// In en, this message translates to:
  /// **'Could not load membership stats'**
  String get couldNotLoadMembershipStats;

  /// No description provided for @couldNotLoadRevenueStats.
  ///
  /// In en, this message translates to:
  /// **'Could not load revenue stats'**
  String get couldNotLoadRevenueStats;

  /// No description provided for @couldNotCreateSchedule.
  ///
  /// In en, this message translates to:
  /// **'Could not create schedule'**
  String get couldNotCreateSchedule;

  /// No description provided for @couldNotSaveStatus.
  ///
  /// In en, this message translates to:
  /// **'Could not save status'**
  String get couldNotSaveStatus;

  /// No description provided for @couldNotSaveAttendance.
  ///
  /// In en, this message translates to:
  /// **'Could not save attendance'**
  String get couldNotSaveAttendance;

  /// No description provided for @couldNotSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not send message'**
  String get couldNotSendMessage;

  /// No description provided for @couldNotOpenConversation.
  ///
  /// In en, this message translates to:
  /// **'Could not open conversation'**
  String get couldNotOpenConversation;

  /// No description provided for @couldNotMarkAsRead.
  ///
  /// In en, this message translates to:
  /// **'Could not mark as read'**
  String get couldNotMarkAsRead;

  /// No description provided for @couldNotRecordPayment.
  ///
  /// In en, this message translates to:
  /// **'Could not record payment'**
  String get couldNotRecordPayment;

  /// No description provided for @signInToCreateSchedule.
  ///
  /// In en, this message translates to:
  /// **'Sign in to create schedule items'**
  String get signInToCreateSchedule;

  /// No description provided for @cannotCreateEventInPast.
  ///
  /// In en, this message translates to:
  /// **'You can\'t create an event in the past.'**
  String get cannotCreateEventInPast;

  /// No description provided for @signInToOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Sign in to open live chat'**
  String get signInToOpenChat;

  /// No description provided for @signInToSeeNotifications.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your notification feed.'**
  String get signInToSeeNotifications;

  /// No description provided for @signInToManagePayments.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage club payments.'**
  String get signInToManagePayments;

  /// No description provided for @signInToSeeFees.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your fees.'**
  String get signInToSeeFees;

  /// No description provided for @signInToSeeStats.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see club membership and revenue analytics.'**
  String get signInToSeeStats;

  /// No description provided for @signInToLoadTeams.
  ///
  /// In en, this message translates to:
  /// **'Sign in to load club teams from the API.'**
  String get signInToLoadTeams;

  /// No description provided for @selectClubToViewTeams.
  ///
  /// In en, this message translates to:
  /// **'Select a club to view teams.'**
  String get selectClubToViewTeams;

  /// No description provided for @selectClubToViewMembers.
  ///
  /// In en, this message translates to:
  /// **'Select a club to view members.'**
  String get selectClubToViewMembers;

  /// No description provided for @selectClubToViewCharges.
  ///
  /// In en, this message translates to:
  /// **'Select a club to view charges.'**
  String get selectClubToViewCharges;

  /// No description provided for @selectClubToViewPayments.
  ///
  /// In en, this message translates to:
  /// **'Select a club to view payments.'**
  String get selectClubToViewPayments;

  /// No description provided for @selectClubToViewMembershipStats.
  ///
  /// In en, this message translates to:
  /// **'Select a club to view membership stats.'**
  String get selectClubToViewMembershipStats;

  /// No description provided for @selectClubToViewRevenueStats.
  ///
  /// In en, this message translates to:
  /// **'Select a club to view revenue stats.'**
  String get selectClubToViewRevenueStats;

  /// No description provided for @noClubSelected.
  ///
  /// In en, this message translates to:
  /// **'No club selected.'**
  String get noClubSelected;

  /// No description provided for @noEventsOnThisDay.
  ///
  /// In en, this message translates to:
  /// **'No events on this day.'**
  String get noEventsOnThisDay;

  /// No description provided for @demoSchedule.
  ///
  /// In en, this message translates to:
  /// **'Demo schedule'**
  String get demoSchedule;

  /// No description provided for @noTeamsYet.
  ///
  /// In en, this message translates to:
  /// **'No teams in this club yet.'**
  String get noTeamsYet;

  /// No description provided for @tapToOpenRoster.
  ///
  /// In en, this message translates to:
  /// **'Tap to open roster'**
  String get tapToOpenRoster;

  /// No description provided for @noMembersFound.
  ///
  /// In en, this message translates to:
  /// **'No members found for this club.'**
  String get noMembersFound;

  /// No description provided for @searchMembers.
  ///
  /// In en, this message translates to:
  /// **'Search members'**
  String get searchMembers;

  /// No description provided for @searchMessages.
  ///
  /// In en, this message translates to:
  /// **'Search messages'**
  String get searchMessages;

  /// No description provided for @searchPeople.
  ///
  /// In en, this message translates to:
  /// **'Search people'**
  String get searchPeople;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations.'**
  String get noConversations;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet.'**
  String get noConversationsYet;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get noMessagesYet;

  /// No description provided for @messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get messageDeleted;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches.'**
  String get noMatches;

  /// No description provided for @noAdultsToMessage.
  ///
  /// In en, this message translates to:
  /// **'No adults to message yet.\nPeople appear here from club staff and your team chats.'**
  String get noAdultsToMessage;

  /// No description provided for @sayHello.
  ///
  /// In en, this message translates to:
  /// **'Say hello'**
  String get sayHello;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageHint;

  /// No description provided for @readOnly.
  ///
  /// In en, this message translates to:
  /// **'Read only'**
  String get readOnly;

  /// No description provided for @systemMessage.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemMessage;

  /// No description provided for @cannotSendInChannel.
  ///
  /// In en, this message translates to:
  /// **'You cannot send in this channel'**
  String get cannotSendInChannel;

  /// No description provided for @couldNotLoadOlder.
  ///
  /// In en, this message translates to:
  /// **'Could not load older'**
  String get couldNotLoadOlder;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotificationsYet;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @nothingOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Nothing outstanding.'**
  String get nothingOutstanding;

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments recorded yet.'**
  String get noPaymentsYet;

  /// No description provided for @noOpenFamilyFees.
  ///
  /// In en, this message translates to:
  /// **'No open family fees.'**
  String get noOpenFamilyFees;

  /// No description provided for @noFeeHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No fee history yet.'**
  String get noFeeHistoryYet;

  /// No description provided for @openCharges.
  ///
  /// In en, this message translates to:
  /// **'Open charges'**
  String get openCharges;

  /// No description provided for @youOwe.
  ///
  /// In en, this message translates to:
  /// **'You owe'**
  String get youOwe;

  /// No description provided for @paymentReference.
  ///
  /// In en, this message translates to:
  /// **'Payment reference'**
  String get paymentReference;

  /// No description provided for @mixedCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Mixed currencies'**
  String get mixedCurrencies;

  /// No description provided for @noFamilyMembersLinked.
  ///
  /// In en, this message translates to:
  /// **'No family members linked'**
  String get noFamilyMembersLinked;

  /// No description provided for @copiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Copied {label}'**
  String copiedLabel(String label);

  /// No description provided for @memberId.
  ///
  /// In en, this message translates to:
  /// **'Member id'**
  String get memberId;

  /// No description provided for @pasteMemberIdHint.
  ///
  /// In en, this message translates to:
  /// **'No open charges — paste member id'**
  String get pasteMemberIdHint;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @savePayment.
  ///
  /// In en, this message translates to:
  /// **'Save payment'**
  String get savePayment;

  /// No description provided for @pickAMember.
  ///
  /// In en, this message translates to:
  /// **'Pick a member'**
  String get pickAMember;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @openListedSummary.
  ///
  /// In en, this message translates to:
  /// **'{open} open · {total} listed'**
  String openListedSummary(int open, int total);

  /// No description provided for @membersCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} member(s)'**
  String membersCountLabel(int count);

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @pickATeam.
  ///
  /// In en, this message translates to:
  /// **'Pick a team'**
  String get pickATeam;

  /// No description provided for @createdNamed.
  ///
  /// In en, this message translates to:
  /// **'Created “{title}”'**
  String createdNamed(String title);

  /// No description provided for @purposeOptional.
  ///
  /// In en, this message translates to:
  /// **'Purpose (optional)'**
  String get purposeOptional;

  /// No description provided for @locationOptional.
  ///
  /// In en, this message translates to:
  /// **'Location (optional)'**
  String get locationOptional;

  /// No description provided for @titleHintTraining.
  ///
  /// In en, this message translates to:
  /// **'e.g. U14 training'**
  String get titleHintTraining;

  /// No description provided for @titleHintTesting.
  ///
  /// In en, this message translates to:
  /// **'e.g. U14 physical testing'**
  String get titleHintTesting;

  /// No description provided for @wholeClub.
  ///
  /// In en, this message translates to:
  /// **'Whole club'**
  String get wholeClub;

  /// No description provided for @noTeamsCreateOrClub.
  ///
  /// In en, this message translates to:
  /// **'No teams in this club. Create a team first, or use Whole club.'**
  String get noTeamsCreateOrClub;

  /// No description provided for @duration45.
  ///
  /// In en, this message translates to:
  /// **'45 min'**
  String get duration45;

  /// No description provided for @duration60.
  ///
  /// In en, this message translates to:
  /// **'60 min'**
  String get duration60;

  /// No description provided for @duration75.
  ///
  /// In en, this message translates to:
  /// **'75 min'**
  String get duration75;

  /// No description provided for @duration90.
  ///
  /// In en, this message translates to:
  /// **'90 min'**
  String get duration90;

  /// No description provided for @duration2h.
  ///
  /// In en, this message translates to:
  /// **'2 hours'**
  String get duration2h;

  /// No description provided for @duration3h.
  ///
  /// In en, this message translates to:
  /// **'3 hours'**
  String get duration3h;

  /// No description provided for @oneOff.
  ///
  /// In en, this message translates to:
  /// **'One-off'**
  String get oneOff;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @numberOfOccurrences.
  ///
  /// In en, this message translates to:
  /// **'Number of occurrences'**
  String get numberOfOccurrences;

  /// No description provided for @requestRsvp.
  ///
  /// In en, this message translates to:
  /// **'Request RSVP'**
  String get requestRsvp;

  /// No description provided for @requestRsvpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Families can confirm attendance beforehand'**
  String get requestRsvpSubtitle;

  /// No description provided for @eventTypeTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get eventTypeTraining;

  /// No description provided for @eventTypeMatch.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get eventTypeMatch;

  /// No description provided for @eventTypeClubEvent.
  ///
  /// In en, this message translates to:
  /// **'Club event'**
  String get eventTypeClubEvent;

  /// No description provided for @eventTypeTournament.
  ///
  /// In en, this message translates to:
  /// **'Tournament'**
  String get eventTypeTournament;

  /// No description provided for @eventTypeTesting.
  ///
  /// In en, this message translates to:
  /// **'Testing'**
  String get eventTypeTesting;

  /// No description provided for @eventTypeEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get eventTypeEvent;

  /// No description provided for @statusPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get statusPresent;

  /// No description provided for @statusAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get statusAbsent;

  /// No description provided for @statusLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get statusLate;

  /// No description provided for @statusExcused.
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get statusExcused;

  /// No description provided for @statusUnmarked.
  ///
  /// In en, this message translates to:
  /// **'Unmarked'**
  String get statusUnmarked;

  /// No description provided for @takeAttendance.
  ///
  /// In en, this message translates to:
  /// **'Take attendance'**
  String get takeAttendance;

  /// No description provided for @roster.
  ///
  /// In en, this message translates to:
  /// **'Roster'**
  String get roster;

  /// No description provided for @rosterCount.
  ///
  /// In en, this message translates to:
  /// **'Roster ({count})'**
  String rosterCount(int count);

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @reloadRoster.
  ///
  /// In en, this message translates to:
  /// **'Reload roster'**
  String get reloadRoster;

  /// No description provided for @saveRemaining.
  ///
  /// In en, this message translates to:
  /// **'Save remaining'**
  String get saveRemaining;

  /// No description provided for @skipNote.
  ///
  /// In en, this message translates to:
  /// **'Skip note'**
  String get skipNote;

  /// No description provided for @tapMemberToMark.
  ///
  /// In en, this message translates to:
  /// **'Tap a member to mark — status saves to the server immediately'**
  String get tapMemberToMark;

  /// No description provided for @noMembersOnRoster.
  ///
  /// In en, this message translates to:
  /// **'No members on the roster for {scope}.'**
  String noMembersOnRoster(String scope);

  /// No description provided for @thisSession.
  ///
  /// In en, this message translates to:
  /// **'this session'**
  String get thisSession;

  /// No description provided for @attendanceLocked.
  ///
  /// In en, this message translates to:
  /// **'Attendance is locked for this session.'**
  String get attendanceLocked;

  /// No description provided for @sessionCanceled.
  ///
  /// In en, this message translates to:
  /// **'This session was canceled.'**
  String get sessionCanceled;

  /// No description provided for @unmarkedCannotBeSaved.
  ///
  /// In en, this message translates to:
  /// **'Unmarked cannot be saved — pick a status first.'**
  String get unmarkedCannotBeSaved;

  /// No description provided for @allMarksAlreadySaved.
  ///
  /// In en, this message translates to:
  /// **'All marks are already saved.'**
  String get allMarksAlreadySaved;

  /// No description provided for @rsvpStatus.
  ///
  /// In en, this message translates to:
  /// **'RSVP: {status}'**
  String rsvpStatus(String status);

  /// No description provided for @markNamed.
  ///
  /// In en, this message translates to:
  /// **'Mark {name}'**
  String markNamed(String name);

  /// No description provided for @optionalNoteSynced.
  ///
  /// In en, this message translates to:
  /// **'Optional note (synced with the mark)'**
  String get optionalNoteSynced;

  /// No description provided for @attendanceReport.
  ///
  /// In en, this message translates to:
  /// **'Attendance report'**
  String get attendanceReport;

  /// No description provided for @openWindow.
  ///
  /// In en, this message translates to:
  /// **'Open window'**
  String get openWindow;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @noSessionsInWindow.
  ///
  /// In en, this message translates to:
  /// **'No sessions in the attendance window right now.'**
  String get noSessionsInWindow;

  /// No description provided for @noPastSessions.
  ///
  /// In en, this message translates to:
  /// **'No past sessions yet.'**
  String get noPastSessions;

  /// No description provided for @attendanceSynced.
  ///
  /// In en, this message translates to:
  /// **'Attendance synced'**
  String get attendanceSynced;

  /// No description provided for @attendancePartiallySynced.
  ///
  /// In en, this message translates to:
  /// **'Attendance partially synced'**
  String get attendancePartiallySynced;

  /// No description provided for @marksSentToPlatform.
  ///
  /// In en, this message translates to:
  /// **'Marks were sent to the club platform.'**
  String get marksSentToPlatform;

  /// No description provided for @marksAppliedRejected.
  ///
  /// In en, this message translates to:
  /// **'{applied} applied · {rejected} rejected'**
  String marksAppliedRejected(int applied, int rejected);

  /// No description provided for @superseded.
  ///
  /// In en, this message translates to:
  /// **'superseded'**
  String get superseded;

  /// No description provided for @backToSession.
  ///
  /// In en, this message translates to:
  /// **'Back to session'**
  String get backToSession;

  /// No description provided for @viewReport.
  ///
  /// In en, this message translates to:
  /// **'View report'**
  String get viewReport;

  /// No description provided for @attendanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Attendance history'**
  String get attendanceHistory;

  /// No description provided for @trainingLocation.
  ///
  /// In en, this message translates to:
  /// **'Training location'**
  String get trainingLocation;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @season.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get season;

  /// No description provided for @noMembersOnTeamRoster.
  ///
  /// In en, this message translates to:
  /// **'No members on this team roster.'**
  String get noMembersOnTeamRoster;

  /// No description provided for @noUpcomingSessionsForTeam.
  ///
  /// In en, this message translates to:
  /// **'No upcoming sessions for this team.'**
  String get noUpcomingSessionsForTeam;

  /// No description provided for @teamChat.
  ///
  /// In en, this message translates to:
  /// **'Team chat'**
  String get teamChat;

  /// No description provided for @couldNotOpenTeamChat.
  ///
  /// In en, this message translates to:
  /// **'This team\'s chat is not available yet.'**
  String get couldNotOpenTeamChat;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get addEvent;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get addMember;

  /// No description provided for @couldNotAddMember.
  ///
  /// In en, this message translates to:
  /// **'Could not add member'**
  String get couldNotAddMember;

  /// No description provided for @memberAddedNamed.
  ///
  /// In en, this message translates to:
  /// **'Added {name}'**
  String memberAddedNamed(String name);

  /// No description provided for @dateOfBirthRequired.
  ///
  /// In en, this message translates to:
  /// **'Date of birth is required'**
  String get dateOfBirthRequired;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderUnspecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get genderUnspecified;

  /// No description provided for @duplicateMemberSuspected.
  ///
  /// In en, this message translates to:
  /// **'A similar member already exists. Add this person anyway?'**
  String get duplicateMemberSuspected;

  /// No description provided for @addAnyway.
  ///
  /// In en, this message translates to:
  /// **'Add anyway'**
  String get addAnyway;

  /// No description provided for @nextUp.
  ///
  /// In en, this message translates to:
  /// **'Next up'**
  String get nextUp;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @viewAllMembers.
  ///
  /// In en, this message translates to:
  /// **'View all members'**
  String get viewAllMembers;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @ageGroup.
  ///
  /// In en, this message translates to:
  /// **'Age group'**
  String get ageGroup;

  /// No description provided for @playersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} players'**
  String playersCount(int count);

  /// No description provided for @seasonNamed.
  ///
  /// In en, this message translates to:
  /// **'Season {label}'**
  String seasonNamed(String label);

  /// No description provided for @goingAwaiting.
  ///
  /// In en, this message translates to:
  /// **'{going} going • {awaiting} awaiting'**
  String goingAwaiting(int going, int awaiting);

  /// No description provided for @noSessionToTakeAttendance.
  ///
  /// In en, this message translates to:
  /// **'No upcoming session to take attendance for.'**
  String get noSessionToTakeAttendance;

  /// No description provided for @playerProfile.
  ///
  /// In en, this message translates to:
  /// **'Player Profile'**
  String get playerProfile;

  /// No description provided for @noProfileDetailsYet.
  ///
  /// In en, this message translates to:
  /// **'No profile details yet.'**
  String get noProfileDetailsYet;

  /// No description provided for @notAssignedToTeam.
  ///
  /// In en, this message translates to:
  /// **'Not assigned to a team.'**
  String get notAssignedToTeam;

  /// No description provided for @noNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No notes yet.'**
  String get noNotesYet;

  /// No description provided for @demoNotes.
  ///
  /// In en, this message translates to:
  /// **'Demo notes'**
  String get demoNotes;

  /// No description provided for @canceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get canceled;

  /// No description provided for @loadingAttendanceStatus.
  ///
  /// In en, this message translates to:
  /// **'Loading attendance status…'**
  String get loadingAttendanceStatus;

  /// No description provided for @loadRosterAndMark.
  ///
  /// In en, this message translates to:
  /// **'Load roster and mark members'**
  String get loadRosterAndMark;

  /// No description provided for @viewLockedReport.
  ///
  /// In en, this message translates to:
  /// **'View the report for this locked session'**
  String get viewLockedReport;

  /// No description provided for @rosterWithStatuses.
  ///
  /// In en, this message translates to:
  /// **'Roster with present / late / absent / excused'**
  String get rosterWithStatuses;

  /// No description provided for @pastAndOpenSessions.
  ///
  /// In en, this message translates to:
  /// **'Past and open sessions for attendance'**
  String get pastAndOpenSessions;

  /// No description provided for @refreshAttendanceStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh attendance status'**
  String get refreshAttendanceStatus;

  /// No description provided for @marksAcceptedUntil.
  ///
  /// In en, this message translates to:
  /// **'Marks accepted until {date} · {time}'**
  String marksAcceptedUntil(String date, String time);

  /// No description provided for @clubStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} stats'**
  String clubStatsTitle(String name);

  /// No description provided for @noMembershipData.
  ///
  /// In en, this message translates to:
  /// **'No membership data.'**
  String get noMembershipData;

  /// No description provided for @noRevenueData.
  ///
  /// In en, this message translates to:
  /// **'No revenue data.'**
  String get noRevenueData;

  /// No description provided for @noTrendDataYet.
  ///
  /// In en, this message translates to:
  /// **'No trend data yet.'**
  String get noTrendDataYet;

  /// No description provided for @noRevenueTrendYet.
  ///
  /// In en, this message translates to:
  /// **'No revenue trend yet.'**
  String get noRevenueTrendYet;

  /// No description provided for @asOfDate.
  ///
  /// In en, this message translates to:
  /// **'As of {date}'**
  String asOfDate(String date);

  /// No description provided for @asOfDateCurrency.
  ///
  /// In en, this message translates to:
  /// **'As of {date} · {currency}'**
  String asOfDateCurrency(String date, String currency);

  /// No description provided for @activeNow.
  ///
  /// In en, this message translates to:
  /// **'Active now'**
  String get activeNow;

  /// No description provided for @onTheBooks.
  ///
  /// In en, this message translates to:
  /// **'On the books'**
  String get onTheBooks;

  /// No description provided for @joined12Mo.
  ///
  /// In en, this message translates to:
  /// **'Joined (12 mo)'**
  String get joined12Mo;

  /// No description provided for @left12Mo.
  ///
  /// In en, this message translates to:
  /// **'Left (12 mo)'**
  String get left12Mo;

  /// No description provided for @unenrolledNoTeam.
  ///
  /// In en, this message translates to:
  /// **'Unenrolled (no team)'**
  String get unenrolledNoTeam;

  /// No description provided for @collected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collected;

  /// No description provided for @expected.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get expected;

  /// No description provided for @collectionRate.
  ///
  /// In en, this message translates to:
  /// **'Collection rate'**
  String get collectionRate;

  /// No description provided for @membersBilled.
  ///
  /// In en, this message translates to:
  /// **'Members billed'**
  String get membersBilled;

  /// No description provided for @inDebt.
  ///
  /// In en, this message translates to:
  /// **'In debt'**
  String get inDebt;

  /// No description provided for @waived.
  ///
  /// In en, this message translates to:
  /// **'Waived'**
  String get waived;

  /// No description provided for @monthlyEnrollment.
  ///
  /// In en, this message translates to:
  /// **'Monthly enrollment'**
  String get monthlyEnrollment;

  /// No description provided for @agingOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Aging (outstanding)'**
  String get agingOutstanding;

  /// No description provided for @monthlyTrend.
  ///
  /// In en, this message translates to:
  /// **'Monthly trend'**
  String get monthlyTrend;

  /// No description provided for @byTeam.
  ///
  /// In en, this message translates to:
  /// **'By team'**
  String get byTeam;

  /// No description provided for @bySection.
  ///
  /// In en, this message translates to:
  /// **'By section'**
  String get bySection;

  /// No description provided for @notDue.
  ///
  /// In en, this message translates to:
  /// **'Not due'**
  String get notDue;

  /// No description provided for @days1To30.
  ///
  /// In en, this message translates to:
  /// **'1–30 days'**
  String get days1To30;

  /// No description provided for @days31To60.
  ///
  /// In en, this message translates to:
  /// **'31–60 days'**
  String get days31To60;

  /// No description provided for @days61To90.
  ///
  /// In en, this message translates to:
  /// **'61–90 days'**
  String get days61To90;

  /// No description provided for @days90Plus.
  ///
  /// In en, this message translates to:
  /// **'90+ days'**
  String get days90Plus;

  /// No description provided for @activeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String activeCount(int count);

  /// No description provided for @joinedLeftDelta.
  ///
  /// In en, this message translates to:
  /// **'+{joined} / −{left}'**
  String joinedLeftDelta(int joined, int left);

  /// No description provided for @owedAmount.
  ///
  /// In en, this message translates to:
  /// **'owed {amount}'**
  String owedAmount(String amount);

  /// No description provided for @membersOwed.
  ///
  /// In en, this message translates to:
  /// **'{count} members · owed {amount}'**
  String membersOwed(int count, String amount);

  /// No description provided for @yourRoles.
  ///
  /// In en, this message translates to:
  /// **'Your roles'**
  String get yourRoles;

  /// No description provided for @useThisClub.
  ///
  /// In en, this message translates to:
  /// **'Use this club'**
  String get useThisClub;

  /// No description provided for @clubSelected.
  ///
  /// In en, this message translates to:
  /// **'{name} selected'**
  String clubSelected(String name);

  /// No description provided for @namesRequired.
  ///
  /// In en, this message translates to:
  /// **'First and last name are required'**
  String get namesRequired;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get saveFailed;

  /// No description provided for @enterCurrentAndNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter current and new password'**
  String get enterCurrentAndNewPassword;

  /// No description provided for @newPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get newPasswordsDoNotMatch;

  /// No description provided for @newPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 8 characters'**
  String get newPasswordMinLength;

  /// No description provided for @passwordChangedSessionsSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Other sessions were signed out.'**
  String get passwordChangedSessionsSignedOut;

  /// No description provided for @couldNotChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Could not change password'**
  String get couldNotChangePassword;

  /// No description provided for @clubsAndRoles.
  ///
  /// In en, this message translates to:
  /// **'Clubs & roles'**
  String get clubsAndRoles;

  /// No description provided for @noRoleGrants.
  ///
  /// In en, this message translates to:
  /// **'No role grants on this account.'**
  String get noRoleGrants;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @passwordRequirementsHint.
  ///
  /// In en, this message translates to:
  /// **'≥8 chars with upper, lower, digit'**
  String get passwordRequirementsHint;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get emailVerified;

  /// No description provided for @verificationPending.
  ///
  /// In en, this message translates to:
  /// **'Verification pending'**
  String get verificationPending;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get emailNotVerified;

  /// No description provided for @platformRoot.
  ///
  /// In en, this message translates to:
  /// **'Platform root'**
  String get platformRoot;

  /// No description provided for @joinedMonthYear.
  ///
  /// In en, this message translates to:
  /// **'Joined {when}'**
  String joinedMonthYear(String when);

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'overdue'**
  String get overdue;

  /// No description provided for @voided.
  ///
  /// In en, this message translates to:
  /// **'voided'**
  String get voided;

  /// No description provided for @voidLabel.
  ///
  /// In en, this message translates to:
  /// **'void'**
  String get voidLabel;

  /// No description provided for @relationshipSelf.
  ///
  /// In en, this message translates to:
  /// **'self'**
  String get relationshipSelf;

  /// No description provided for @relationshipGuardian.
  ///
  /// In en, this message translates to:
  /// **'guardian'**
  String get relationshipGuardian;

  /// No description provided for @attendanceCanceledClosed.
  ///
  /// In en, this message translates to:
  /// **'Canceled — attendance closed'**
  String get attendanceCanceledClosed;

  /// No description provided for @attendanceOpen.
  ///
  /// In en, this message translates to:
  /// **'Attendance open'**
  String get attendanceOpen;

  /// No description provided for @attendanceLockedShort.
  ///
  /// In en, this message translates to:
  /// **'Attendance locked'**
  String get attendanceLockedShort;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @pendingConsents.
  ///
  /// In en, this message translates to:
  /// **'Pending consents'**
  String get pendingConsents;

  /// No description provided for @noPendingConsents.
  ///
  /// In en, this message translates to:
  /// **'No consents waiting for you.'**
  String get noPendingConsents;

  /// No description provided for @familyMembers.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get familyMembers;

  /// No description provided for @noFamilyMembers.
  ///
  /// In en, this message translates to:
  /// **'No family members linked to this account.'**
  String get noFamilyMembers;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences'**
  String get notificationPreferences;

  /// No description provided for @noNotificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'No email notification preferences available.'**
  String get noNotificationPreferences;

  /// No description provided for @prefsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load preferences'**
  String get prefsLoadFailed;

  /// No description provided for @familyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load family'**
  String get familyLoadFailed;

  /// No description provided for @consentsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load consents'**
  String get consentsLoadFailed;

  /// No description provided for @grantConsent.
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get grantConsent;

  /// No description provided for @consentGrantedSnack.
  ///
  /// In en, this message translates to:
  /// **'Consent granted'**
  String get consentGrantedSnack;

  /// No description provided for @consentGrantFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not grant consent'**
  String get consentGrantFailed;

  /// No description provided for @consentVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String consentVersion(int version);

  /// No description provided for @consentReasonNeverGranted.
  ///
  /// In en, this message translates to:
  /// **'Not granted yet'**
  String get consentReasonNeverGranted;

  /// No description provided for @consentReasonWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Previously withdrawn'**
  String get consentReasonWithdrawn;

  /// No description provided for @consentReasonNewVersion.
  ///
  /// In en, this message translates to:
  /// **'New version available'**
  String get consentReasonNewVersion;

  /// No description provided for @consentReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Action needed'**
  String get consentReasonOther;

  /// No description provided for @reviewAndGrantConsent.
  ///
  /// In en, this message translates to:
  /// **'Review & grant'**
  String get reviewAndGrantConsent;

  /// No description provided for @consentForMember.
  ///
  /// In en, this message translates to:
  /// **'Consent for {name}'**
  String consentForMember(String name);

  /// No description provided for @enrolled.
  ///
  /// In en, this message translates to:
  /// **'Enrolled'**
  String get enrolled;

  /// No description provided for @notEnrolled.
  ///
  /// In en, this message translates to:
  /// **'Not enrolled'**
  String get notEnrolled;

  /// No description provided for @consentOk.
  ///
  /// In en, this message translates to:
  /// **'Consent OK'**
  String get consentOk;

  /// No description provided for @consentMissing.
  ///
  /// In en, this message translates to:
  /// **'Consent missing'**
  String get consentMissing;

  /// No description provided for @channelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get channelEmail;

  /// No description provided for @channelOther.
  ///
  /// In en, this message translates to:
  /// **'{channel}'**
  String channelOther(String channel);

  /// No description provided for @preferenceDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get preferenceDefault;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @changeYourPhoto.
  ///
  /// In en, this message translates to:
  /// **'Change your photo'**
  String get changeYourPhoto;

  /// No description provided for @changeChildPhoto.
  ///
  /// In en, this message translates to:
  /// **'Change {name}\'s photo'**
  String changeChildPhoto(String name);

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from library'**
  String get chooseFromLibrary;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @photoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Photo updated'**
  String get photoUpdated;

  /// No description provided for @photoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Photo removed'**
  String get photoRemoved;

  /// No description provided for @photoUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update photo'**
  String get photoUpdateFailed;

  /// No description provided for @photoNeedLinkedMember.
  ///
  /// In en, this message translates to:
  /// **'This login isn\'t linked to a member record. Change a family member\'s photo below, or open their profile.'**
  String get photoNeedLinkedMember;

  /// No description provided for @photoSelectClubFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a club first, then try again.'**
  String get photoSelectClubFirst;

  /// No description provided for @photoNoPermission.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to change this photo.'**
  String get photoNoPermission;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @yourDocuments.
  ///
  /// In en, this message translates to:
  /// **'Your documents'**
  String get yourDocuments;

  /// No description provided for @clubDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'{club} documents'**
  String clubDocumentsTitle(String club);

  /// No description provided for @complianceOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get complianceOverview;

  /// No description provided for @reviewQueue.
  ///
  /// In en, this message translates to:
  /// **'To review'**
  String get reviewQueue;

  /// No description provided for @noDocumentsPending.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting for review.'**
  String get noDocumentsPending;

  /// No description provided for @noComplianceMembers.
  ///
  /// In en, this message translates to:
  /// **'Everyone is in order.'**
  String get noComplianceMembers;

  /// No description provided for @complianceValid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get complianceValid;

  /// No description provided for @complianceExpiring.
  ///
  /// In en, this message translates to:
  /// **'Expiring'**
  String get complianceExpiring;

  /// No description provided for @complianceMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get complianceMissing;

  /// No description provided for @complianceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get complianceUnknown;

  /// No description provided for @requirementRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requirementRequired;

  /// No description provided for @requirementOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get requirementOptional;

  /// No description provided for @uploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get uploadDocument;

  /// No description provided for @choosePdf.
  ///
  /// In en, this message translates to:
  /// **'Choose PDF or file'**
  String get choosePdf;

  /// No description provided for @issuedOn.
  ///
  /// In en, this message translates to:
  /// **'Issue date'**
  String get issuedOn;

  /// No description provided for @issuedOnHint.
  ///
  /// In en, this message translates to:
  /// **'If the certificate has a printed date, add it so expiry is counted from that day.'**
  String get issuedOnHint;

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get expiresOn;

  /// No description provided for @expiresOnDate.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String expiresOnDate(String date);

  /// No description provided for @documentPending.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get documentPending;

  /// No description provided for @documentVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get documentVerified;

  /// No description provided for @documentRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get documentRejected;

  /// No description provided for @documentAwaitingUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload started'**
  String get documentAwaitingUpload;

  /// No description provided for @viewDocument.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewDocument;

  /// No description provided for @deleteDocument.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteDocument;

  /// No description provided for @verifyDocument.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyDocument;

  /// No description provided for @rejectDocument.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectDocument;

  /// No description provided for @rejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for the family'**
  String get rejectionReason;

  /// No description provided for @askFamily.
  ///
  /// In en, this message translates to:
  /// **'Ask family'**
  String get askFamily;

  /// No description provided for @familyAsked.
  ///
  /// In en, this message translates to:
  /// **'Asked {count} family account(s)'**
  String familyAsked(int count);

  /// No description provided for @familyAlreadyAsked.
  ///
  /// In en, this message translates to:
  /// **'Already asked today'**
  String get familyAlreadyAsked;

  /// No description provided for @documentUploaded.
  ///
  /// In en, this message translates to:
  /// **'Document uploaded — waiting for review'**
  String get documentUploaded;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload document'**
  String get uploadFailed;

  /// No description provided for @couldNotLoadCompliance.
  ///
  /// In en, this message translates to:
  /// **'Could not load documents'**
  String get couldNotLoadCompliance;

  /// No description provided for @signInToSeeDocuments.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage documents'**
  String get signInToSeeDocuments;

  /// No description provided for @contentViewAudited.
  ///
  /// In en, this message translates to:
  /// **'Opening this file is logged'**
  String get contentViewAudited;

  /// No description provided for @noRequirements.
  ///
  /// In en, this message translates to:
  /// **'No document requirements for this member.'**
  String get noRequirements;

  /// No description provided for @confirmDeleteDocument.
  ///
  /// In en, this message translates to:
  /// **'Remove this document?'**
  String get confirmDeleteDocument;

  /// No description provided for @rejectReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please explain why it was rejected'**
  String get rejectReasonRequired;

  /// No description provided for @documentVerifiedSnack.
  ///
  /// In en, this message translates to:
  /// **'Document verified'**
  String get documentVerifiedSnack;

  /// No description provided for @documentRejectedSnack.
  ///
  /// In en, this message translates to:
  /// **'Document rejected'**
  String get documentRejectedSnack;

  /// No description provided for @documentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Document removed'**
  String get documentDeleted;

  /// No description provided for @documentTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File must be 15 MB or smaller'**
  String get documentTooLarge;

  /// No description provided for @couldNotOpenDocument.
  ///
  /// In en, this message translates to:
  /// **'Could not open the file'**
  String get couldNotOpenDocument;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Manage. Inspire. Win together.'**
  String get aboutTagline;

  /// No description provided for @aboutIntro.
  ///
  /// In en, this message translates to:
  /// **'ChampHive is the all-in-one platform for sports clubs, coaches and parents. We help teams stay organized, communicate better and develop every athlete.'**
  String get aboutIntro;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutMissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get aboutMissionTitle;

  /// No description provided for @aboutMissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Empowering sports teams to achieve their full potential.'**
  String get aboutMissionSubtitle;

  /// No description provided for @aboutMissionBody.
  ///
  /// In en, this message translates to:
  /// **'Every club deserves tools that match the energy on the pitch.\n\nChampHive exists to take admin off coaches\' and parents\' plates, so more time goes to training, development and the people who make a team. We build for real club life — busy evenings, mixed-age groups, and volunteers who care.'**
  String get aboutMissionBody;

  /// No description provided for @aboutTeamsTitle.
  ///
  /// In en, this message translates to:
  /// **'Built for Teams'**
  String get aboutTeamsTitle;

  /// No description provided for @aboutTeamsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Designed with coaches, players and parents in mind.'**
  String get aboutTeamsSubtitle;

  /// No description provided for @aboutTeamsBody.
  ///
  /// In en, this message translates to:
  /// **'Coaches, players, parents and club staff all need a clear view of the same season — not three different apps.\n\nChampHive is built around those roles. Training, attendance, messages, payments and documents stay in one place, with the right access for each person.'**
  String get aboutTeamsBody;

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Data Matters'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'We take privacy and data security seriously.'**
  String get aboutPrivacySubtitle;

  /// No description provided for @aboutPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Club data is a trust, not a product.\n\nPhotos, documents and personal details stay scoped to your club and your role. We take privacy and security seriously as ChampHive grows, and we only collect what the club needs to run.'**
  String get aboutPrivacyBody;

  /// No description provided for @aboutMadeWith.
  ///
  /// In en, this message translates to:
  /// **'Made with'**
  String get aboutMadeWith;

  /// No description provided for @aboutMadeBy.
  ///
  /// In en, this message translates to:
  /// **'by Codeantech'**
  String get aboutMadeBy;

  /// No description provided for @aboutCodeantechBlurb.
  ///
  /// In en, this message translates to:
  /// **'Codeantech builds digital solutions that help businesses and communities grow through technology.'**
  String get aboutCodeantechBlurb;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'© {year} Codeantech. All rights reserved.'**
  String aboutCopyright(String year);

  /// No description provided for @aboutCouldNotOpenWebsite.
  ///
  /// In en, this message translates to:
  /// **'Could not open the website'**
  String get aboutCouldNotOpenWebsite;

  /// No description provided for @sessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Session details'**
  String get sessionDetails;

  /// No description provided for @sessionDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Title, time, location and other fields from the API'**
  String get sessionDetailsSubtitle;

  /// No description provided for @sessionDetailsIntro.
  ///
  /// In en, this message translates to:
  /// **'These are the details saved for this session.'**
  String get sessionDetailsIntro;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// No description provided for @coaches.
  ///
  /// In en, this message translates to:
  /// **'Coaches'**
  String get coaches;

  /// No description provided for @trainingPlan.
  ///
  /// In en, this message translates to:
  /// **'Training plan'**
  String get trainingPlan;

  /// No description provided for @section.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get section;

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusScheduled;

  /// No description provided for @statusMoved.
  ///
  /// In en, this message translates to:
  /// **'Moved'**
  String get statusMoved;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @rsvpYes.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get rsvpYes;

  /// No description provided for @rsvpNo.
  ///
  /// In en, this message translates to:
  /// **'Not requested'**
  String get rsvpNo;

  /// No description provided for @originallyScheduled.
  ///
  /// In en, this message translates to:
  /// **'Originally'**
  String get originallyScheduled;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @pickTrainingPlan.
  ///
  /// In en, this message translates to:
  /// **'Training plan (optional)'**
  String get pickTrainingPlan;

  /// No description provided for @noTrainingPlan.
  ///
  /// In en, this message translates to:
  /// **'No training plan'**
  String get noTrainingPlan;

  /// No description provided for @noTrainingPlansYet.
  ///
  /// In en, this message translates to:
  /// **'No training plans in this club yet.'**
  String get noTrainingPlansYet;

  /// No description provided for @couldNotLoadTrainingPlan.
  ///
  /// In en, this message translates to:
  /// **'Could not load the training plan'**
  String get couldNotLoadTrainingPlan;

  /// No description provided for @trainingPlanExercises.
  ///
  /// In en, this message translates to:
  /// **'Drills'**
  String get trainingPlanExercises;

  /// No description provided for @trainingPlanDurationSummary.
  ///
  /// In en, this message translates to:
  /// **'{session} session · {drills} of drills'**
  String trainingPlanDurationSummary(String session, String drills);

  /// No description provided for @repetitionsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} reps'**
  String repetitionsValue(String count);

  /// No description provided for @watchVideo.
  ///
  /// In en, this message translates to:
  /// **'Watch video'**
  String get watchVideo;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @noCoachesYet.
  ///
  /// In en, this message translates to:
  /// **'No coaches assigned yet'**
  String get noCoachesYet;

  /// No description provided for @noTrainingPlanAttached.
  ///
  /// In en, this message translates to:
  /// **'No training plan is attached to this session'**
  String get noTrainingPlanAttached;

  /// No description provided for @noExercisesInPlan.
  ///
  /// In en, this message translates to:
  /// **'This plan has no drills yet'**
  String get noExercisesInPlan;

  /// No description provided for @rsvpNotRequestedLabel.
  ///
  /// In en, this message translates to:
  /// **'RSVP not requested'**
  String get rsvpNotRequestedLabel;

  /// No description provided for @sport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get sport;

  /// No description provided for @pickTestSet.
  ///
  /// In en, this message translates to:
  /// **'Test set'**
  String get pickTestSet;

  /// No description provided for @noTestSetsYet.
  ///
  /// In en, this message translates to:
  /// **'No test sets in this club yet. Create one to schedule a testing day.'**
  String get noTestSetsYet;

  /// No description provided for @couldNotLoadTestSets.
  ///
  /// In en, this message translates to:
  /// **'Could not load test sets'**
  String get couldNotLoadTestSets;

  /// No description provided for @createTestSet.
  ///
  /// In en, this message translates to:
  /// **'Create test set'**
  String get createTestSet;

  /// No description provided for @testSetName.
  ///
  /// In en, this message translates to:
  /// **'Test set name'**
  String get testSetName;

  /// No description provided for @testSetNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name the test set'**
  String get testSetNameRequired;

  /// No description provided for @pickMetrics.
  ///
  /// In en, this message translates to:
  /// **'Stations (metrics)'**
  String get pickMetrics;

  /// No description provided for @pickAtLeastOneMetric.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one metric'**
  String get pickAtLeastOneMetric;

  /// No description provided for @testSetRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick a test set. A testing day has to say which metrics it runs.'**
  String get testSetRequired;

  /// No description provided for @testSet.
  ///
  /// In en, this message translates to:
  /// **'Test set'**
  String get testSet;

  /// No description provided for @couldNotLoadTestingDay.
  ///
  /// In en, this message translates to:
  /// **'Could not load this testing day'**
  String get couldNotLoadTestingDay;

  /// No description provided for @couldNotCreateTestSet.
  ///
  /// In en, this message translates to:
  /// **'Could not create the test set'**
  String get couldNotCreateTestSet;

  /// No description provided for @pickASport.
  ///
  /// In en, this message translates to:
  /// **'Pick a sport'**
  String get pickASport;

  /// No description provided for @noSportsForTestSets.
  ///
  /// In en, this message translates to:
  /// **'This club has no sports yet. Add a section first.'**
  String get noSportsForTestSets;

  /// No description provided for @noMetricsForSport.
  ///
  /// In en, this message translates to:
  /// **'No collectable metrics for this sport.'**
  String get noMetricsForSport;

  /// No description provided for @stationCount.
  ///
  /// In en, this message translates to:
  /// **'{count} stations'**
  String stationCount(int count);

  /// No description provided for @noStationsInTestSet.
  ///
  /// In en, this message translates to:
  /// **'This test set has no stations yet'**
  String get noStationsInTestSet;

  /// No description provided for @retiredStation.
  ///
  /// In en, this message translates to:
  /// **'Retired'**
  String get retiredStation;

  /// No description provided for @recordResults.
  ///
  /// In en, this message translates to:
  /// **'Record results'**
  String get recordResults;

  /// No description provided for @recordResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter numbers for each station'**
  String get recordResultsSubtitle;

  /// No description provided for @recordStation.
  ///
  /// In en, this message translates to:
  /// **'Record station'**
  String get recordStation;

  /// No description provided for @saveResults.
  ///
  /// In en, this message translates to:
  /// **'Save results'**
  String get saveResults;

  /// No description provided for @resultsSaved.
  ///
  /// In en, this message translates to:
  /// **'Results saved'**
  String get resultsSaved;

  /// No description provided for @someResultsFailed.
  ///
  /// In en, this message translates to:
  /// **'{failed} of {total} could not be saved'**
  String someResultsFailed(int failed, int total);

  /// No description provided for @recordedOf.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} recorded'**
  String recordedOf(int done, int total);

  /// No description provided for @noPlayersOnTestingDay.
  ///
  /// In en, this message translates to:
  /// **'No squad on this testing day.'**
  String get noPlayersOnTestingDay;

  /// No description provided for @stationRetiredCannotRecord.
  ///
  /// In en, this message translates to:
  /// **'This station is retired and cannot take new values.'**
  String get stationRetiredCannotRecord;

  /// No description provided for @madeLabel.
  ///
  /// In en, this message translates to:
  /// **'Made'**
  String get madeLabel;

  /// No description provided for @attemptedLabel.
  ///
  /// In en, this message translates to:
  /// **'Attempted'**
  String get attemptedLabel;

  /// No description provided for @releaseResults.
  ///
  /// In en, this message translates to:
  /// **'Release results'**
  String get releaseResults;

  /// No description provided for @resultsReleased.
  ///
  /// In en, this message translates to:
  /// **'Results released to player history'**
  String get resultsReleased;

  /// No description provided for @couldNotRecordResults.
  ///
  /// In en, this message translates to:
  /// **'Could not save results'**
  String get couldNotRecordResults;

  /// No description provided for @noValuesToSave.
  ///
  /// In en, this message translates to:
  /// **'Enter at least one value before saving.'**
  String get noValuesToSave;

  /// No description provided for @teamRequiredForRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording needs a team-scoped testing day.'**
  String get teamRequiredForRecording;

  /// No description provided for @tapStationToRecord.
  ///
  /// In en, this message translates to:
  /// **'Tap a station to enter numbers for the squad.'**
  String get tapStationToRecord;

  /// No description provided for @noDraftsToRelease.
  ///
  /// In en, this message translates to:
  /// **'Nothing to release yet. Save station results first.'**
  String get noDraftsToRelease;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @noPerformanceYet.
  ///
  /// In en, this message translates to:
  /// **'No released measurements yet. Record a testing day, then Release results.'**
  String get noPerformanceYet;

  /// No description provided for @previousResult.
  ///
  /// In en, this message translates to:
  /// **'was {value}'**
  String previousResult(String value);

  /// No description provided for @resultsThisSession.
  ///
  /// In en, this message translates to:
  /// **'Numbers this session'**
  String get resultsThisSession;

  /// No description provided for @releaseResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Saving a station stores the numbers here as drafts. Release publishes them to each player\'s Performance tab.'**
  String get releaseResultsHint;

  /// No description provided for @couldNotLoadPerformance.
  ///
  /// In en, this message translates to:
  /// **'Could not load performance'**
  String get couldNotLoadPerformance;

  /// No description provided for @resultsReleasedCount.
  ///
  /// In en, this message translates to:
  /// **'Published {count} sittings to player profiles'**
  String resultsReleasedCount(int count);

  /// No description provided for @clubPermissions.
  ///
  /// In en, this message translates to:
  /// **'Staff permissions'**
  String get clubPermissions;

  /// No description provided for @coachCreatesMembers.
  ///
  /// In en, this message translates to:
  /// **'Coaches can add members'**
  String get coachCreatesMembers;

  /// No description provided for @coachCreatesMembersHint.
  ///
  /// In en, this message translates to:
  /// **'Lets coaches register new players and put them on their teams.'**
  String get coachCreatesMembersHint;

  /// No description provided for @coachSeesPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Coaches can see payment status'**
  String get coachSeesPaymentStatus;

  /// No description provided for @coachSeesPaymentStatusHint.
  ///
  /// In en, this message translates to:
  /// **'Lets coaches see whether a member\'s fees are paid.'**
  String get coachSeesPaymentStatusHint;

  /// No description provided for @trainingPlanCoachScope.
  ///
  /// In en, this message translates to:
  /// **'Coaches can manage training plans'**
  String get trainingPlanCoachScope;

  /// No description provided for @trainingPlanCoachScopeHint.
  ///
  /// In en, this message translates to:
  /// **'Lets coaches create and edit training plans for their teams.'**
  String get trainingPlanCoachScopeHint;

  /// No description provided for @coachCannotAddMembers.
  ///
  /// In en, this message translates to:
  /// **'This club does not allow coaches to add members. A club admin can enable this under Club → Staff permissions.'**
  String get coachCannotAddMembers;

  /// No description provided for @couldNotLoadClubPermissions.
  ///
  /// In en, this message translates to:
  /// **'Could not load staff permissions'**
  String get couldNotLoadClubPermissions;

  /// No description provided for @couldNotSaveClubPermissions.
  ///
  /// In en, this message translates to:
  /// **'Could not save staff permissions'**
  String get couldNotSaveClubPermissions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'bs',
    'en',
    'it',
    'mk',
    'sr',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'sr':
      {
        switch (locale.scriptCode) {
          case 'Latn':
            return AppLocalizationsSrLatn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bs':
      return AppLocalizationsBs();
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
    case 'mk':
      return AppLocalizationsMk();
    case 'sr':
      return AppLocalizationsSr();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
