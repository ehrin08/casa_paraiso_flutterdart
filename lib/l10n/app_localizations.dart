import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fil.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('fil'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Casa Paraiso'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get bookNow;

  /// No description provided for @browseServices.
  ///
  /// In en, this message translates to:
  /// **'Browse services'**
  String get browseServices;

  /// No description provided for @reserveHeadline.
  ///
  /// In en, this message translates to:
  /// **'Reserve your spot. You deserve this.'**
  String get reserveHeadline;

  /// No description provided for @reserveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A tranquil tropical spa experience, made effortless.'**
  String get reserveSubtitle;

  /// No description provided for @openEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Open every day · 1:00 PM–1:00 AM'**
  String get openEveryDay;

  /// No description provided for @featuredServices.
  ///
  /// In en, this message translates to:
  /// **'Signature experiences'**
  String get featuredServices;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @callUs.
  ///
  /// In en, this message translates to:
  /// **'Call us'**
  String get callUs;

  /// No description provided for @messageUs.
  ///
  /// In en, this message translates to:
  /// **'Message us'**
  String get messageUs;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Barangay Cuta East, Santa Teresita, Batangas, Philippines'**
  String get address;

  /// No description provided for @landmark.
  ///
  /// In en, this message translates to:
  /// **'In front of Alfamart and PLDT'**
  String get landmark;

  /// No description provided for @serviceMenu.
  ///
  /// In en, this message translates to:
  /// **'Service menu'**
  String get serviceMenu;

  /// No description provided for @serviceMenuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose one massage style, then personalize your visit.'**
  String get serviceMenuSubtitle;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @includedTreatment.
  ///
  /// In en, this message translates to:
  /// **'Included treatment'**
  String get includedTreatment;

  /// No description provided for @massageStyle.
  ///
  /// In en, this message translates to:
  /// **'Massage style'**
  String get massageStyle;

  /// No description provided for @extras.
  ///
  /// In en, this message translates to:
  /// **'Optional extras'**
  String get extras;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get dateAndTime;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get customerDetails;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumber;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @reviewBooking.
  ///
  /// In en, this message translates to:
  /// **'Review booking'**
  String get reviewBooking;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get confirmBooking;

  /// No description provided for @payAtSpa.
  ///
  /// In en, this message translates to:
  /// **'Payment is due at the spa.'**
  String get payAtSpa;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your appointment is confirmed'**
  String get bookingConfirmed;

  /// No description provided for @bookingReference.
  ///
  /// In en, this message translates to:
  /// **'Booking reference'**
  String get bookingReference;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @noBookings.
  ///
  /// In en, this message translates to:
  /// **'No appointments here yet'**
  String get noBookings;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel appointment'**
  String get cancelBooking;

  /// No description provided for @reschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get reschedule;

  /// No description provided for @keepBooking.
  ///
  /// In en, this message translates to:
  /// **'Keep appointment'**
  String get keepBooking;

  /// No description provided for @confirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel this appointment?'**
  String get confirmCancel;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @filipino.
  ///
  /// In en, this message translates to:
  /// **'Filipino'**
  String get filipino;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & local data'**
  String get privacy;

  /// No description provided for @privacySummary.
  ///
  /// In en, this message translates to:
  /// **'Your profile and appointments stay in this browser or device. They are not sent to Casa Paraiso.'**
  String get privacySummary;

  /// No description provided for @resetData.
  ///
  /// In en, this message translates to:
  /// **'Reset local data'**
  String get resetData;

  /// No description provided for @resetWarning.
  ///
  /// In en, this message translates to:
  /// **'This removes your profile, appointments, preferences, and reminder schedules from this device.'**
  String get resetWarning;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About Casa Paraiso'**
  String get about;

  /// No description provided for @replayIntro.
  ///
  /// In en, this message translates to:
  /// **'Replay introduction'**
  String get replayIntro;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Appointment reminders'**
  String get notifications;

  /// No description provided for @notificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Android reminders are scheduled 24 hours and 1 hour before. Web reminders appear while the app is open.'**
  String get notificationsDescription;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep my details on this device'**
  String get consentTitle;

  /// No description provided for @consentBody.
  ///
  /// In en, this message translates to:
  /// **'I understand that this prototype stores my profile and appointments locally for easier booking.'**
  String get consentBody;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Philippine mobile number'**
  String get invalidMobile;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @selectOption.
  ///
  /// In en, this message translates to:
  /// **'Please select an option'**
  String get selectOption;

  /// No description provided for @selectDateTime.
  ///
  /// In en, this message translates to:
  /// **'Please choose an available date and time'**
  String get selectDateTime;

  /// No description provided for @slotUnavailable.
  ///
  /// In en, this message translates to:
  /// **'That time overlaps one of your appointments'**
  String get slotUnavailable;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @dataRecovered.
  ///
  /// In en, this message translates to:
  /// **'Some damaged local data was reset safely.'**
  String get dataRecovered;

  /// No description provided for @onboardingOneTitle.
  ///
  /// In en, this message translates to:
  /// **'A calmer way to choose'**
  String get onboardingOneTitle;

  /// No description provided for @onboardingOneBody.
  ///
  /// In en, this message translates to:
  /// **'Browse Casa Paraiso\'s signature wellness experiences at your own pace.'**
  String get onboardingOneBody;

  /// No description provided for @onboardingTwoTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking that feels effortless'**
  String get onboardingTwoTitle;

  /// No description provided for @onboardingTwoBody.
  ///
  /// In en, this message translates to:
  /// **'Select your treatment, preferred time, and extras in one reassuring flow.'**
  String get onboardingTwoBody;

  /// No description provided for @onboardingThreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your plans stay close'**
  String get onboardingThreeTitle;

  /// No description provided for @onboardingThreeBody.
  ///
  /// In en, this message translates to:
  /// **'Manage appointments and reminders locally on your device or browser.'**
  String get onboardingThreeBody;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @appointmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Appointment details'**
  String get appointmentDetails;

  /// No description provided for @normalConfirmationNote.
  ///
  /// In en, this message translates to:
  /// **'Please contact the spa directly if you need assistance.'**
  String get normalConfirmationNote;

  /// No description provided for @webReminder.
  ///
  /// In en, this message translates to:
  /// **'You have an upcoming Casa Paraiso appointment.'**
  String get webReminder;

  /// No description provided for @localOnlyAvailability.
  ///
  /// In en, this message translates to:
  /// **'Times are checked against appointments saved on this device.'**
  String get localOnlyAvailability;
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
      <String>['en', 'fil'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fil':
      return AppLocalizationsFil();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
