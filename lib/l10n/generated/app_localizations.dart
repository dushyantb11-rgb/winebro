import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('gu'),
    Locale('hi'),
    Locale('mr'),
  ];

  /// Splash screen tagline below brand logo
  ///
  /// In en, this message translates to:
  /// **'YOUR ELDER BROTHER IN WINE & SPIRITS'**
  String get appTagline;

  /// Login heading in phone mode
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// Login heading in email sign-up mode
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createAccount;

  /// Login heading in email sign-in mode
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// Login subtitle
  ///
  /// In en, this message translates to:
  /// **'Let\'s find your perfect pairing, Bro'**
  String get findPerfectPairing;

  /// Phone toggle button label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// Email toggle button label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Password field hint text
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// Age verification checkbox text
  ///
  /// In en, this message translates to:
  /// **'I confirm I am of legal drinking age in my state'**
  String get ageConfirmation;

  /// Snackbar when age not confirmed
  ///
  /// In en, this message translates to:
  /// **'Please confirm you are of legal drinking age'**
  String get ageVerificationRequired;

  /// Phone login button
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// Email sign-up button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Email sign-in button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Toggle to sign-in mode
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAccount;

  /// Toggle to sign-up mode
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccount;

  /// OTP screen heading
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtpTitle;

  /// OTP screen subtitle
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {phone}'**
  String otpSentTo(String phone);

  /// OTP verify button
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// Divider text before social login
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// Google sign-in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInWithGoogle;

  /// Go back from OTP screen
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get changeNumber;

  /// Resend OTP button
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// Resend countdown timer
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// Name screen heading
  ///
  /// In en, this message translates to:
  /// **'What should we call you, Bro?'**
  String get whatShouldWeCallYou;

  /// Name screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Your first name is all we need'**
  String get firstNameNeeded;

  /// Name input placeholder
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourNameHint;

  /// Name screen button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Home screen greeting
  ///
  /// In en, this message translates to:
  /// **'Hey {userName}'**
  String greeting(String userName);

  /// Bro's pick of the day badge
  ///
  /// In en, this message translates to:
  /// **'BRO\'S PICK'**
  String get brosPick;

  /// Home quick actions section header
  ///
  /// In en, this message translates to:
  /// **'QUICK ACTIONS'**
  String get quickActions;

  /// Quick action button
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get pairAction;

  /// Quick action button
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanAction;

  /// Quick action button
  ///
  /// In en, this message translates to:
  /// **'Aroma'**
  String get aromaAction;

  /// Quick action button
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnAction;

  /// Home trending section header
  ///
  /// In en, this message translates to:
  /// **'TRENDING NOW'**
  String get trendingNow;

  /// Home tip box heading
  ///
  /// In en, this message translates to:
  /// **'Bro Tip'**
  String get broTip;

  /// Home tip text about wine pairing
  ///
  /// In en, this message translates to:
  /// **'When pairing with spicy Indian food, reach for an off-dry Riesling or a fruity Rosé. The residual sugar tames the heat while the acidity keeps your palate refreshed. High-tannin reds will amplify the burn — avoid them!'**
  String get broTipContent;

  /// Quiz step 1 heading
  ///
  /// In en, this message translates to:
  /// **'What\'s your all-time favourite Indian food?'**
  String get quizFoodQuestion;

  /// Quiz step 1 subtitle
  ///
  /// In en, this message translates to:
  /// **'Pick up to 2'**
  String get pickUpTo2;

  /// Quiz step 2 heading
  ///
  /// In en, this message translates to:
  /// **'You love chaat! What\'s the best part about it?'**
  String get chaatQuestion;

  /// Quiz step 3 heading
  ///
  /// In en, this message translates to:
  /// **'What\'s your go-to drink when you\'re out?'**
  String get drinkQuestion;

  /// Quiz slider step heading
  ///
  /// In en, this message translates to:
  /// **'Fine-tune your palate, Bro'**
  String get fineTunePalate;

  /// Quiz slider step subtitle
  ///
  /// In en, this message translates to:
  /// **'Adjust these sliders to match your preferences'**
  String get adjustSliders;

  /// Quiz final step button
  ///
  /// In en, this message translates to:
  /// **'See My Profile'**
  String get seeMyProfile;

  /// Quiz next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// Quiz result heading
  ///
  /// In en, this message translates to:
  /// **'Your Palate Profile'**
  String get yourPalateProfile;

  /// Quiz result CTA button
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go, Bro!'**
  String get letsGoBro;

  /// Fruit slider low label
  ///
  /// In en, this message translates to:
  /// **'Dry'**
  String get sliderDry;

  /// Fruit slider high label
  ///
  /// In en, this message translates to:
  /// **'Sweet'**
  String get sliderSweet;

  /// Acidity slider low label
  ///
  /// In en, this message translates to:
  /// **'Smooth'**
  String get sliderSmooth;

  /// Acidity slider high label
  ///
  /// In en, this message translates to:
  /// **'Tangy'**
  String get sliderTangy;

  /// Body slider low label
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get sliderLight;

  /// Body slider high label
  ///
  /// In en, this message translates to:
  /// **'Rich'**
  String get sliderRich;

  /// Tannin slider low label
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get sliderMild;

  /// Tannin slider high label
  ///
  /// In en, this message translates to:
  /// **'Fiery'**
  String get sliderFiery;

  /// Progress indicator
  ///
  /// In en, this message translates to:
  /// **'{step} of {total}'**
  String stepOf(int step, int total);

  /// Pair screen app bar title
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get pairTitle;

  /// Pair tab 1
  ///
  /// In en, this message translates to:
  /// **'Food → Drink'**
  String get foodToDrink;

  /// Pair tab 2
  ///
  /// In en, this message translates to:
  /// **'Drink → Food'**
  String get drinkToFood;

  /// Pair tab 3
  ///
  /// In en, this message translates to:
  /// **'Occasion'**
  String get occasionTab;

  /// Food-to-drink heading
  ///
  /// In en, this message translates to:
  /// **'What are you eating, Bro?'**
  String get whatAreYouEating;

  /// Food-to-drink subtitle
  ///
  /// In en, this message translates to:
  /// **'Pick a dish and I\'ll find the perfect drink'**
  String get pickDishForDrink;

  /// Pairing results heading
  ///
  /// In en, this message translates to:
  /// **'Best Pairings'**
  String get bestPairings;

  /// Empty pairing state
  ///
  /// In en, this message translates to:
  /// **'No pairings found. Complete the quiz first!'**
  String get noPairingsQuiz;

  /// Drink-to-food heading
  ///
  /// In en, this message translates to:
  /// **'What are you drinking?'**
  String get whatAreYouDrinking;

  /// Drink-to-food results heading
  ///
  /// In en, this message translates to:
  /// **'Goes great with...'**
  String get goesGreatWith;

  /// Occasion tab heading
  ///
  /// In en, this message translates to:
  /// **'What\'s the occasion?'**
  String get whatsTheOccasion;

  /// Occasion results heading
  ///
  /// In en, this message translates to:
  /// **'Perfect for {occasion}'**
  String perfectFor(String occasion);

  /// Empty occasion state
  ///
  /// In en, this message translates to:
  /// **'Complete the quiz to get personalized suggestions!'**
  String get completeQuizSuggestions;

  /// Scanner app bar title
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanTitle;

  /// Scanner CTA text
  ///
  /// In en, this message translates to:
  /// **'Tap to scan a label'**
  String get tapToScan;

  /// Scanner instruction
  ///
  /// In en, this message translates to:
  /// **'Point your camera at any wine or spirit bottle'**
  String get pointCamera;

  /// Search fallback label
  ///
  /// In en, this message translates to:
  /// **'Or search by name'**
  String get orSearchByName;

  /// Search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search wines, spirits, beers...'**
  String get searchPlaceholder;

  /// Camera unavailable snackbar
  ///
  /// In en, this message translates to:
  /// **'Camera requires a physical device. Use search below to find your bottle.'**
  String get cameraRequiresDevice;

  /// Scanner OCR found no text
  ///
  /// In en, this message translates to:
  /// **'No text detected on the label. Try again or search manually.'**
  String get noTextDetected;

  /// Scan match badge
  ///
  /// In en, this message translates to:
  /// **'Product Found!'**
  String get productFound;

  /// Scan result action
  ///
  /// In en, this message translates to:
  /// **'Add to Journal'**
  String get addToJournal;

  /// Scan result action
  ///
  /// In en, this message translates to:
  /// **'Find Pairings'**
  String get findPairingsButton;

  /// Journal app bar title
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalTitle;

  /// Journal error state
  ///
  /// In en, this message translates to:
  /// **'Error loading journal'**
  String get errorLoadingJournal;

  /// Journal empty heading
  ///
  /// In en, this message translates to:
  /// **'Your journal is empty'**
  String get journalEmpty;

  /// Journal empty subtitle
  ///
  /// In en, this message translates to:
  /// **'Start logging your tastings, Bro!\nTap the + button to create your first BroCard.'**
  String get startLoggingTastings;

  /// BroCard sheet heading
  ///
  /// In en, this message translates to:
  /// **'BroCard'**
  String get broCardTitle;

  /// BroCard step indicator
  ///
  /// In en, this message translates to:
  /// **'Step {step} of 6'**
  String broCardStepOf(int step);

  /// BroCard step 1 heading
  ///
  /// In en, this message translates to:
  /// **'What are you tasting?'**
  String get whatAreYouTasting;

  /// BroCard name input hint
  ///
  /// In en, this message translates to:
  /// **'Drink name'**
  String get drinkNameHint;

  /// BroCard region input hint
  ///
  /// In en, this message translates to:
  /// **'Region (optional)'**
  String get regionOptionalHint;

  /// BroCard step 2 heading
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// BroCard appearance field
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get colourLabel;

  /// BroCard appearance field
  ///
  /// In en, this message translates to:
  /// **'Clarity'**
  String get clarityLabel;

  /// BroCard nose/appearance field
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensityLabel;

  /// BroCard step 3 heading
  ///
  /// In en, this message translates to:
  /// **'Nose'**
  String get noseTitle;

  /// BroCard nose aromas instruction
  ///
  /// In en, this message translates to:
  /// **'Aromas (tap to select)'**
  String get aromasSelectLabel;

  /// BroCard step 4 heading
  ///
  /// In en, this message translates to:
  /// **'Palate'**
  String get palateTitle;

  /// BroCard palate field
  ///
  /// In en, this message translates to:
  /// **'Sweetness'**
  String get sweetnessLabel;

  /// BroCard palate field
  ///
  /// In en, this message translates to:
  /// **'Acidity'**
  String get acidityLabel;

  /// BroCard palate field
  ///
  /// In en, this message translates to:
  /// **'Tannin'**
  String get tanninLabel;

  /// BroCard palate field
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get bodyLabel;

  /// BroCard step 5 heading
  ///
  /// In en, this message translates to:
  /// **'Finish & Rating'**
  String get finishAndRating;

  /// BroCard finish field
  ///
  /// In en, this message translates to:
  /// **'Finish Length'**
  String get finishLengthLabel;

  /// BroCard rating label
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get yourRating;

  /// BroCard toggle label
  ///
  /// In en, this message translates to:
  /// **'Would buy again?'**
  String get wouldBuyAgain;

  /// BroCard notes placeholder
  ///
  /// In en, this message translates to:
  /// **'Personal notes (optional)'**
  String get personalNotesHint;

  /// BroCard summary heading
  ///
  /// In en, this message translates to:
  /// **'Your BroCard'**
  String get yourBroCard;

  /// BroCard back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// BroCard save button
  ///
  /// In en, this message translates to:
  /// **'Save BroCard'**
  String get saveBroCard;

  /// Aroma wheel app bar title
  ///
  /// In en, this message translates to:
  /// **'Aroma Explorer'**
  String get aromaExplorerTitle;

  /// Aroma wheel main heading
  ///
  /// In en, this message translates to:
  /// **'Bro Aroma Wheel'**
  String get broAromaWheel;

  /// Aroma wheel instruction
  ///
  /// In en, this message translates to:
  /// **'Tap a category to explore'**
  String get tapCategoryToExplore;

  /// Aroma subcategory instruction
  ///
  /// In en, this message translates to:
  /// **'Tap to explore individual aromas'**
  String get tapToExploreAromas;

  /// Aroma category stats
  ///
  /// In en, this message translates to:
  /// **'{groups} groups · {aromas} aromas'**
  String groupsAndAromas(int groups, int aromas);

  /// Profile app bar title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Profile level indicator
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelLabel(int level);

  /// XP progress text
  ///
  /// In en, this message translates to:
  /// **'{xp} / {nextXp} XP'**
  String xpProgress(int xp, int nextXp);

  /// Max level XP text
  ///
  /// In en, this message translates to:
  /// **'{xp} XP (MAX)'**
  String xpMax(int xp);

  /// Profile palate section heading
  ///
  /// In en, this message translates to:
  /// **'Your Palate'**
  String get yourPalate;

  /// Profile badges section heading
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Profile stat label
  ///
  /// In en, this message translates to:
  /// **'Tastings'**
  String get tastingsLabel;

  /// Profile stat label
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakLabel;

  /// Profile stat label
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badgesLabel;

  /// Profile stat label
  ///
  /// In en, this message translates to:
  /// **'Scans'**
  String get scansLabel;

  /// Profile stat label
  ///
  /// In en, this message translates to:
  /// **'Pairings'**
  String get pairingsLabel;

  /// Profile stat label
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challengesLabel;

  /// Community app bar title
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get communityTitle;

  /// Community main heading
  ///
  /// In en, this message translates to:
  /// **'The Brotherhood'**
  String get theBrotherhood;

  /// Community placeholder text
  ///
  /// In en, this message translates to:
  /// **'Social features, tasting circles, and leaderboards arrive in Phase 2. For now, focus on building your palate profile — your community reputation starts with how many tastings you\'ve logged.'**
  String get communityDescription;

  /// Community Phase 2 info box
  ///
  /// In en, this message translates to:
  /// **'Phase 2 will include: Follow users, share pairings, create tasting circles, community ratings, and integration with The Cask Circle events.'**
  String get phase2Info;

  /// Bottom nav home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav pair tab
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get navPair;

  /// Bottom nav scan tab
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// Bottom nav journal tab
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get navJournal;

  /// Bottom nav community tab
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navCommunity;

  /// Bottom nav profile tab
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Language picker label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get selectLanguage;

  /// Generic error display
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);

  /// Time-aware greeting before name (5am-12pm)
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get homeGreetingMorning;

  /// Time-aware greeting (12pm-5pm)
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get homeGreetingAfternoon;

  /// Time-aware greeting (5pm-10pm)
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get homeGreetingEvening;

  /// Time-aware greeting (10pm-5am)
  ///
  /// In en, this message translates to:
  /// **'Up late,'**
  String get homeGreetingLate;

  /// Italic byline, morning
  ///
  /// In en, this message translates to:
  /// **'Slow morning. What\'s pouring?'**
  String get homeBylineMorning;

  /// Italic byline, afternoon
  ///
  /// In en, this message translates to:
  /// **'Afternoon. A glass with what?'**
  String get homeBylineAfternoon;

  /// Italic byline, evening
  ///
  /// In en, this message translates to:
  /// **'Your night begins here.'**
  String get homeBylineEvening;

  /// Italic byline, late night
  ///
  /// In en, this message translates to:
  /// **'Late and lovely.'**
  String get homeBylineLate;

  /// Hero card eyebrow
  ///
  /// In en, this message translates to:
  /// **'TONIGHT\'S POUR'**
  String get homeTonightsPourEyebrow;

  /// Pill CTA on Tonight's Pour
  ///
  /// In en, this message translates to:
  /// **'Why this tonight'**
  String get homeWhyThisTonight;

  /// Eyebrow above 3 emotion tiles
  ///
  /// In en, this message translates to:
  /// **'TONIGHT, YOU ARE…'**
  String get homeEmotionEyebrow;

  /// Emotion tile
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get homeEmotionCooking;

  /// Emotion tile
  ///
  /// In en, this message translates to:
  /// **'Hosting'**
  String get homeEmotionHosting;

  /// Emotion tile
  ///
  /// In en, this message translates to:
  /// **'Just sipping'**
  String get homeEmotionJustSipping;

  /// Continue Your Story eyebrow
  ///
  /// In en, this message translates to:
  /// **'CONTINUE YOUR STORY'**
  String get homeContinueStoryEyebrow;

  /// Match percentage badge
  ///
  /// In en, this message translates to:
  /// **'{percent}% match'**
  String homeMatchPercent(int percent);

  /// Bro Circle strip eyebrow
  ///
  /// In en, this message translates to:
  /// **'BRO CIRCLE'**
  String get homeBroCircleEyebrow;

  /// Social proof one-liner on product detail
  ///
  /// In en, this message translates to:
  /// **'{percent}% of bros pair this with Indian food'**
  String homeBroCircleSocialProof(int percent);

  /// Bro Tip card eyebrow
  ///
  /// In en, this message translates to:
  /// **'BRO TIP OF THE DAY'**
  String get homeBroTipHeader;

  /// Button: add to journal
  ///
  /// In en, this message translates to:
  /// **'Add to journal'**
  String get actionAddToJournal;

  /// Button/label: pair
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get actionPair;

  /// BroCard repurchase indicator
  ///
  /// In en, this message translates to:
  /// **'Buy again'**
  String get actionBuyAgain;

  /// Pair screen large title
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get pairTitleHero;

  /// Italic byline before selection
  ///
  /// In en, this message translates to:
  /// **'What are you eating, drinking, or celebrating?'**
  String get pairBylinePrompt;

  /// Italic byline after selection
  ///
  /// In en, this message translates to:
  /// **'Bro\'s recommendations are below.'**
  String get pairBylineResults;

  /// Journal large title
  ///
  /// In en, this message translates to:
  /// **'Your Story'**
  String get journalTitleHero;

  /// Italic byline
  ///
  /// In en, this message translates to:
  /// **'Every sip, remembered.'**
  String get journalByline;

  /// Empty-state eyebrow
  ///
  /// In en, this message translates to:
  /// **'YOUR FIRST CHAPTER'**
  String get journalEmptyEyebrow;

  /// Empty-state headline
  ///
  /// In en, this message translates to:
  /// **'Start your\ntasting story.'**
  String get journalEmptyHeadline;

  /// Empty-state subtitle
  ///
  /// In en, this message translates to:
  /// **'Every bottle becomes a BroCard.\nYour palate, in your pocket.'**
  String get journalEmptySubline;

  /// Empty-state primary CTA
  ///
  /// In en, this message translates to:
  /// **'Scan a bottle'**
  String get journalCtaScan;

  /// Empty-state secondary CTA
  ///
  /// In en, this message translates to:
  /// **'Log manually'**
  String get journalCtaLogManually;

  /// FAB label
  ///
  /// In en, this message translates to:
  /// **'New BroCard'**
  String get journalNewBroCard;

  /// Hero stat eyebrow
  ///
  /// In en, this message translates to:
  /// **'TASTINGS'**
  String get journalStatTastings;

  /// Hero stat eyebrow
  ///
  /// In en, this message translates to:
  /// **'WINES'**
  String get journalStatWines;

  /// Hero stat eyebrow
  ///
  /// In en, this message translates to:
  /// **'SPIRITS'**
  String get journalStatSpirits;

  /// Eyebrow above palate radar
  ///
  /// In en, this message translates to:
  /// **'YOUR TASTE DNA'**
  String get profileTasteDnaEyebrow;

  /// Headline before 3 tastings logged
  ///
  /// In en, this message translates to:
  /// **'We\'re learning your palate.'**
  String get profilePalateLearning;

  /// Subtitle in palate-gated state
  ///
  /// In en, this message translates to:
  /// **'Log {remaining, plural, =1{1 more tasting} other{{remaining} more tastings}} to unlock your taste DNA radar.'**
  String profilePalateNeedsMore(int remaining);

  /// Progress label
  ///
  /// In en, this message translates to:
  /// **'{count} of 3 logged'**
  String profilePalateProgress(int count);

  /// Headline with full radar
  ///
  /// In en, this message translates to:
  /// **'Built from {count} tastings'**
  String profilePalateBuiltFrom(int count);

  /// Eyebrow above next-2 badges
  ///
  /// In en, this message translates to:
  /// **'NEXT TO UNLOCK'**
  String get profileNextToUnlock;

  /// Link to full badge sheet
  ///
  /// In en, this message translates to:
  /// **'View all {total} →'**
  String profileViewAllBadges(int total);

  /// Eyebrow above recent badges
  ///
  /// In en, this message translates to:
  /// **'RECENTLY EARNED'**
  String get profileRecentlyEarned;

  /// Title of full-badge sheet
  ///
  /// In en, this message translates to:
  /// **'All achievements'**
  String get profileAllAchievements;

  /// Empty state when no badges remain
  ///
  /// In en, this message translates to:
  /// **'You\'ve earned them all, Bro. Legendary.'**
  String get profileEarnedAllBadges;

  /// XP label at max level
  ///
  /// In en, this message translates to:
  /// **'{xp} XP · MAX LEVEL'**
  String profileLevelMax(int xp);

  /// Magnetic sheet label while OCR runs
  ///
  /// In en, this message translates to:
  /// **'Looking…'**
  String get scanLooking;

  /// Italic subtitle while scanning
  ///
  /// In en, this message translates to:
  /// **'Reading label, matching to catalogue.'**
  String get scanLookingSubtitle;

  /// Green chip after bottle match
  ///
  /// In en, this message translates to:
  /// **'MATCHED'**
  String get scanMatched;

  /// Magnetic sheet idle headline
  ///
  /// In en, this message translates to:
  /// **'Tap the finder to scan'**
  String get scanIdleHeadline;

  /// Idle italic subtitle
  ///
  /// In en, this message translates to:
  /// **'Point your camera at any wine or spirit label.'**
  String get scanIdleSubtitle;

  /// Idle CTA
  ///
  /// In en, this message translates to:
  /// **'Open camera'**
  String get scanOpenCamera;

  /// Error CTA
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get scanTryAgain;

  /// No-match error message
  ///
  /// In en, this message translates to:
  /// **'No matching bottle in our catalogue yet.'**
  String get scanNoMatch;

  /// OCR-empty error message
  ///
  /// In en, this message translates to:
  /// **'No text detected on the label.'**
  String get scanNoText;

  /// Skip onboarding
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Next slide button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Final onboarding CTA
  ///
  /// In en, this message translates to:
  /// **'Begin the quiz'**
  String get onboardingBegin;

  /// Onboarding slide 1 eyebrow
  ///
  /// In en, this message translates to:
  /// **'PALATE QUIZ'**
  String get onboardingSlide1Eyebrow;

  /// Onboarding slide 1 hero copy
  ///
  /// In en, this message translates to:
  /// **'Find your\ntaste DNA'**
  String get onboardingSlide1Headline;

  /// Onboarding slide 1 byline
  ///
  /// In en, this message translates to:
  /// **'Six axes of flavour learn whether you lean sweet or dry, fruity or smoky, light or full-bodied.'**
  String get onboardingSlide1Byline;

  /// Onboarding slide 2 eyebrow
  ///
  /// In en, this message translates to:
  /// **'LABEL SCANNER'**
  String get onboardingSlide2Eyebrow;

  /// Onboarding slide 2 hero copy
  ///
  /// In en, this message translates to:
  /// **'Scan any\nbottle'**
  String get onboardingSlide2Headline;

  /// Onboarding slide 2 byline
  ///
  /// In en, this message translates to:
  /// **'Point your camera at a label. WineBro reads, identifies, and suggests what to eat with it.'**
  String get onboardingSlide2Byline;

  /// Onboarding slide 3 eyebrow
  ///
  /// In en, this message translates to:
  /// **'BROCARD JOURNAL'**
  String get onboardingSlide3Eyebrow;

  /// Onboarding slide 3 hero copy
  ///
  /// In en, this message translates to:
  /// **'Every sip,\nremembered'**
  String get onboardingSlide3Headline;

  /// Onboarding slide 3 byline
  ///
  /// In en, this message translates to:
  /// **'A beautiful tasting card for every bottle. Watch your palate evolve over time.'**
  String get onboardingSlide3Byline;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get settingsAppearance;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get settingsAccount;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get settingsAbout;

  /// Theme toggle row
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Language picker row
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageRow;

  /// Sign out row
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// Sign out confirm dialog title
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get settingsSignOutQuestion;

  /// Sign out dialog body
  ///
  /// In en, this message translates to:
  /// **'You can sign back in any time with the same number.'**
  String get settingsSignOutConfirm;

  /// Delete account row
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDelete;

  /// Delete confirm dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get settingsDeleteQuestion;

  /// Delete dialog body
  ///
  /// In en, this message translates to:
  /// **'This wipes your tasting journal, BroCards, and palate profile. Cannot be undone.'**
  String get settingsDeleteConfirm;

  /// Delete confirm CTA
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get settingsDeleteForever;

  /// Snackbar — feature stub
  ///
  /// In en, this message translates to:
  /// **'Account deletion coming soon.'**
  String get settingsDeleteComingSoon;

  /// Generic cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// Privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// Terms link
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get settingsTerms;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// Settings footer
  ///
  /// In en, this message translates to:
  /// **'Drink responsibly. 18+'**
  String get settingsResponsibly;

  /// Language picker sheet title
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get settingsChooseLanguage;

  /// Voice button stub snackbar
  ///
  /// In en, this message translates to:
  /// **'Voice coming in v1.1, Bro.'**
  String get voiceComingSoon;

  /// Flashlight button stub snackbar
  ///
  /// In en, this message translates to:
  /// **'Flashlight in v1.1, Bro.'**
  String get flashlightComingSoon;

  /// Quick-log sheet title
  ///
  /// In en, this message translates to:
  /// **'Quick log'**
  String get quickLogTitle;

  /// Quick-log product search hint
  ///
  /// In en, this message translates to:
  /// **'What did you taste?'**
  String get quickLogSearchHint;

  /// Star rating prompt
  ///
  /// In en, this message translates to:
  /// **'How was it, Bro?'**
  String get quickLogRatingPrompt;

  /// Optional food pairing prompt
  ///
  /// In en, this message translates to:
  /// **'What did you eat with it? (optional)'**
  String get quickLogFoodOptional;

  /// Buy-again toggle prompt
  ///
  /// In en, this message translates to:
  /// **'Would you buy this again?'**
  String get quickLogBuyAgainPrompt;

  /// Quick-log save CTA
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get quickLogSave;

  /// Upgrade to Pro 6-step CTA
  ///
  /// In en, this message translates to:
  /// **'Add detailed tasting notes →'**
  String get quickLogProUpgrade;

  /// Snackbar after Quick-log save
  ///
  /// In en, this message translates to:
  /// **'Saved to your story'**
  String get quickLogSavedSnackbar;

  /// Wishlist screen + Home tile title
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlistTitle;

  /// Empty wishlist hint
  ///
  /// In en, this message translates to:
  /// **'Save bottles you want to try — they show up here.'**
  String get wishlistEmptyHint;

  /// Remove from wishlist button
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get wishlistRemove;

  /// Buy button on Pair results / detail
  ///
  /// In en, this message translates to:
  /// **'Buy ₹{price}'**
  String actionBuy(String price);

  /// Save to wishlist button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Saved state of save button
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get actionSaved;

  /// Set calendar reminder button
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get actionRemind;

  /// Snackbar after calendar reminder set
  ///
  /// In en, this message translates to:
  /// **'Reminder set'**
  String get actionRemindSet;

  /// Snackbar after Save
  ///
  /// In en, this message translates to:
  /// **'Added to wishlist'**
  String get wishlistAddedSnackbar;

  /// Snackbar after Remove
  ///
  /// In en, this message translates to:
  /// **'Removed from wishlist'**
  String get wishlistRemovedSnackbar;

  /// Pairing feedback sheet title
  ///
  /// In en, this message translates to:
  /// **'Did Bro get it right?'**
  String get feedbackSheetTitle;

  /// Sub-headline showing what was tasted
  ///
  /// In en, this message translates to:
  /// **'Yesterday — {product} with {dish}'**
  String feedbackSheetSubtitle(String product, String dish);

  /// Pairing worked
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get feedbackResponseYes;

  /// Pairing partially worked
  ///
  /// In en, this message translates to:
  /// **'Sort of'**
  String get feedbackResponseMaybe;

  /// Pairing didn't work
  ///
  /// In en, this message translates to:
  /// **'Not really'**
  String get feedbackResponseNo;

  /// Yes button helper
  ///
  /// In en, this message translates to:
  /// **'Bro learned what to suggest next time.'**
  String get feedbackResponseHelperYes;

  /// Maybe button helper
  ///
  /// In en, this message translates to:
  /// **'Bro will calibrate this pairing.'**
  String get feedbackResponseHelperMaybe;

  /// No button helper
  ///
  /// In en, this message translates to:
  /// **'Bro will steer others away.'**
  String get feedbackResponseHelperNo;

  /// Snackbar after feedback recorded
  ///
  /// In en, this message translates to:
  /// **'Thanks — Bro got smarter.'**
  String get feedbackThanks;

  /// Shown if entry was deleted before feedback collection
  ///
  /// In en, this message translates to:
  /// **'That pairing record is gone — nothing to rate.'**
  String get feedbackEntryNotFound;

  /// Eyebrow on the Home Restock card
  ///
  /// In en, this message translates to:
  /// **'TIME TO RESTOCK'**
  String get homeRestockEyebrow;

  /// CTA on the Home Restock card
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get homeRestockReorder;
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
      <String>['en', 'gu', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
