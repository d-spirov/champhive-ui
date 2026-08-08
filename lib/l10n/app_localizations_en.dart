// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TeamHive';

  @override
  String get team => 'Team';

  @override
  String get hive => 'Hive';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get phone => 'Phone';

  @override
  String get logIn => 'Log In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get logOut => 'Log out';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get pleaseEnterFirstName => 'Please enter your first name';

  @override
  String get pleaseEnterLastName => 'Please enter your last name';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get loginFailed => 'Login failed. Check your credentials.';

  @override
  String get registrationFailed => 'Registration failed. Please try again.';

  @override
  String get myClubs => 'My clubs';

  @override
  String get noClubsYet => 'You\'re not a member of any club yet.';

  @override
  String get home => 'Home';

  @override
  String get teams => 'Teams';

  @override
  String get players => 'Players';

  @override
  String get events => 'Events';

  @override
  String get attendance => 'Attendance';

  @override
  String get comingSoon => 'Coming soon — UI will follow your screen designs.';

  @override
  String get retry => 'Retry';

  @override
  String get sessionExpired => 'Your session expired. Please sign in again.';
}
