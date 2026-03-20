// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'YOUR ELDER BROTHER IN WINE & SPIRITS';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get createAccount => 'Create your account';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get findPerfectPairing => 'Let\'s find your perfect pairing, Bro';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordHint => 'Password';

  @override
  String get ageConfirmation =>
      'I confirm I am of legal drinking age in my state';

  @override
  String get ageVerificationRequired =>
      'Please confirm you are of legal drinking age';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signIn => 'Sign In';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign Up';

  @override
  String get verifyOtpTitle => 'Verify OTP';

  @override
  String otpSentTo(String phone) {
    return 'We sent a 6-digit code to $phone';
  }

  @override
  String get verify => 'Verify';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get changeNumber => 'Change number';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get whatShouldWeCallYou => 'What should we call you, Bro?';

  @override
  String get firstNameNeeded => 'Your first name is all we need';

  @override
  String get yourNameHint => 'Your name';

  @override
  String get continueButton => 'Continue';

  @override
  String greeting(String userName) {
    return 'Hey $userName';
  }

  @override
  String get brosPick => 'BRO\'S PICK';

  @override
  String get quickActions => 'QUICK ACTIONS';

  @override
  String get pairAction => 'Pair';

  @override
  String get scanAction => 'Scan';

  @override
  String get aromaAction => 'Aroma';

  @override
  String get learnAction => 'Learn';

  @override
  String get trendingNow => 'TRENDING NOW';

  @override
  String get broTip => 'Bro Tip';

  @override
  String get broTipContent =>
      'When pairing with spicy Indian food, reach for an off-dry Riesling or a fruity Rosé. The residual sugar tames the heat while the acidity keeps your palate refreshed. High-tannin reds will amplify the burn — avoid them!';

  @override
  String get quizFoodQuestion => 'What\'s your all-time favourite Indian food?';

  @override
  String get pickUpTo2 => 'Pick up to 2';

  @override
  String get chaatQuestion => 'You love chaat! What\'s the best part about it?';

  @override
  String get drinkQuestion => 'What\'s your go-to drink when you\'re out?';

  @override
  String get fineTunePalate => 'Fine-tune your palate, Bro';

  @override
  String get adjustSliders => 'Adjust these sliders to match your preferences';

  @override
  String get seeMyProfile => 'See My Profile';

  @override
  String get nextButton => 'Next';

  @override
  String get yourPalateProfile => 'Your Palate Profile';

  @override
  String get letsGoBro => 'Let\'s Go, Bro!';

  @override
  String get sliderDry => 'Dry';

  @override
  String get sliderSweet => 'Sweet';

  @override
  String get sliderSmooth => 'Smooth';

  @override
  String get sliderTangy => 'Tangy';

  @override
  String get sliderLight => 'Light';

  @override
  String get sliderRich => 'Rich';

  @override
  String get sliderMild => 'Mild';

  @override
  String get sliderFiery => 'Fiery';

  @override
  String stepOf(int step, int total) {
    return '$step of $total';
  }

  @override
  String get pairTitle => 'Pair';

  @override
  String get foodToDrink => 'Food → Drink';

  @override
  String get drinkToFood => 'Drink → Food';

  @override
  String get occasionTab => 'Occasion';

  @override
  String get whatAreYouEating => 'What are you eating, Bro?';

  @override
  String get pickDishForDrink => 'Pick a dish and I\'ll find the perfect drink';

  @override
  String get bestPairings => 'Best Pairings';

  @override
  String get noPairingsQuiz => 'No pairings found. Complete the quiz first!';

  @override
  String get whatAreYouDrinking => 'What are you drinking?';

  @override
  String get goesGreatWith => 'Goes great with...';

  @override
  String get whatsTheOccasion => 'What\'s the occasion?';

  @override
  String perfectFor(String occasion) {
    return 'Perfect for $occasion';
  }

  @override
  String get completeQuizSuggestions =>
      'Complete the quiz to get personalized suggestions!';

  @override
  String get scanTitle => 'Scan';

  @override
  String get tapToScan => 'Tap to scan a label';

  @override
  String get pointCamera => 'Point your camera at any wine or spirit bottle';

  @override
  String get orSearchByName => 'Or search by name';

  @override
  String get searchPlaceholder => 'Search wines, spirits, beers...';

  @override
  String get cameraRequiresDevice =>
      'Camera requires a physical device. Use search below to find your bottle.';

  @override
  String get noTextDetected =>
      'No text detected on the label. Try again or search manually.';

  @override
  String get productFound => 'Product Found!';

  @override
  String get addToJournal => 'Add to Journal';

  @override
  String get findPairingsButton => 'Find Pairings';

  @override
  String get journalTitle => 'Journal';

  @override
  String get errorLoadingJournal => 'Error loading journal';

  @override
  String get journalEmpty => 'Your journal is empty';

  @override
  String get startLoggingTastings =>
      'Start logging your tastings, Bro!\nTap the + button to create your first BroCard.';

  @override
  String get broCardTitle => 'BroCard';

  @override
  String broCardStepOf(int step) {
    return 'Step $step of 6';
  }

  @override
  String get whatAreYouTasting => 'What are you tasting?';

  @override
  String get drinkNameHint => 'Drink name';

  @override
  String get regionOptionalHint => 'Region (optional)';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get colourLabel => 'Colour';

  @override
  String get clarityLabel => 'Clarity';

  @override
  String get intensityLabel => 'Intensity';

  @override
  String get noseTitle => 'Nose';

  @override
  String get aromasSelectLabel => 'Aromas (tap to select)';

  @override
  String get palateTitle => 'Palate';

  @override
  String get sweetnessLabel => 'Sweetness';

  @override
  String get acidityLabel => 'Acidity';

  @override
  String get tanninLabel => 'Tannin';

  @override
  String get bodyLabel => 'Body';

  @override
  String get finishAndRating => 'Finish & Rating';

  @override
  String get finishLengthLabel => 'Finish Length';

  @override
  String get yourRating => 'Your Rating';

  @override
  String get wouldBuyAgain => 'Would buy again?';

  @override
  String get personalNotesHint => 'Personal notes (optional)';

  @override
  String get yourBroCard => 'Your BroCard';

  @override
  String get backButton => 'Back';

  @override
  String get saveBroCard => 'Save BroCard';

  @override
  String get aromaExplorerTitle => 'Aroma Explorer';

  @override
  String get broAromaWheel => 'Bro Aroma Wheel';

  @override
  String get tapCategoryToExplore => 'Tap a category to explore';

  @override
  String get tapToExploreAromas => 'Tap to explore individual aromas';

  @override
  String groupsAndAromas(int groups, int aromas) {
    return '$groups groups · $aromas aromas';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String xpProgress(int xp, int nextXp) {
    return '$xp / $nextXp XP';
  }

  @override
  String xpMax(int xp) {
    return '$xp XP (MAX)';
  }

  @override
  String get yourPalate => 'Your Palate';

  @override
  String get achievements => 'Achievements';

  @override
  String get tastingsLabel => 'Tastings';

  @override
  String get streakLabel => 'Streak';

  @override
  String get badgesLabel => 'Badges';

  @override
  String get scansLabel => 'Scans';

  @override
  String get pairingsLabel => 'Pairings';

  @override
  String get challengesLabel => 'Challenges';

  @override
  String get communityTitle => 'Community';

  @override
  String get theBrotherhood => 'The Brotherhood';

  @override
  String get communityDescription =>
      'Social features, tasting circles, and leaderboards arrive in Phase 2. For now, focus on building your palate profile — your community reputation starts with how many tastings you\'ve logged.';

  @override
  String get phase2Info =>
      'Phase 2 will include: Follow users, share pairings, create tasting circles, community ratings, and integration with The Cask Circle events.';

  @override
  String get navHome => 'Home';

  @override
  String get navPair => 'Pair';

  @override
  String get navScan => 'Scan';

  @override
  String get navJournal => 'Journal';

  @override
  String get navCommunity => 'Community';

  @override
  String get navProfile => 'Profile';

  @override
  String get selectLanguage => 'Language';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }
}
