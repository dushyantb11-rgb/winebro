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

  @override
  String get homeGreetingMorning => 'Good morning,';

  @override
  String get homeGreetingAfternoon => 'Good afternoon,';

  @override
  String get homeGreetingEvening => 'Good evening,';

  @override
  String get homeGreetingLate => 'Up late,';

  @override
  String get homeBylineMorning => 'Slow morning. What\'s pouring?';

  @override
  String get homeBylineAfternoon => 'Afternoon. A glass with what?';

  @override
  String get homeBylineEvening => 'Your night begins here.';

  @override
  String get homeBylineLate => 'Late and lovely.';

  @override
  String get homeTonightsPourEyebrow => 'TONIGHT\'S POUR';

  @override
  String get homeWhyThisTonight => 'Why this tonight';

  @override
  String get homeEmotionEyebrow => 'TONIGHT, YOU ARE…';

  @override
  String get homeEmotionCooking => 'Cooking';

  @override
  String get homeEmotionHosting => 'Hosting';

  @override
  String get homeEmotionJustSipping => 'Just sipping';

  @override
  String get homeContinueStoryEyebrow => 'CONTINUE YOUR STORY';

  @override
  String homeMatchPercent(int percent) {
    return '$percent% match';
  }

  @override
  String get homeBroCircleEyebrow => 'BRO CIRCLE';

  @override
  String homeBroCircleSocialProof(int percent) {
    return '$percent% of bros pair this with Indian food';
  }

  @override
  String get homeBroTipHeader => 'BRO TIP OF THE DAY';

  @override
  String get actionAddToJournal => 'Add to journal';

  @override
  String get actionPair => 'Pair';

  @override
  String get actionBuyAgain => 'Buy again';

  @override
  String get pairTitleHero => 'Pair';

  @override
  String get pairBylinePrompt =>
      'What are you eating, drinking, or celebrating?';

  @override
  String get pairBylineResults => 'Bro\'s recommendations are below.';

  @override
  String get journalTitleHero => 'Your Story';

  @override
  String get journalByline => 'Every sip, remembered.';

  @override
  String get journalEmptyEyebrow => 'YOUR FIRST CHAPTER';

  @override
  String get journalEmptyHeadline => 'Start your\ntasting story.';

  @override
  String get journalEmptySubline =>
      'Every bottle becomes a BroCard.\nYour palate, in your pocket.';

  @override
  String get journalCtaScan => 'Scan a bottle';

  @override
  String get journalCtaLogManually => 'Log manually';

  @override
  String get journalNewBroCard => 'New BroCard';

  @override
  String get journalStatTastings => 'TASTINGS';

  @override
  String get journalStatWines => 'WINES';

  @override
  String get journalStatSpirits => 'SPIRITS';

  @override
  String get profileTasteDnaEyebrow => 'YOUR TASTE DNA';

  @override
  String get profilePalateLearning => 'We\'re learning your palate.';

  @override
  String profilePalateNeedsMore(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining more tastings',
      one: '1 more tasting',
    );
    return 'Log $_temp0 to unlock your taste DNA radar.';
  }

  @override
  String profilePalateProgress(int count) {
    return '$count of 3 logged';
  }

  @override
  String profilePalateBuiltFrom(int count) {
    return 'Built from $count tastings';
  }

  @override
  String get profileNextToUnlock => 'NEXT TO UNLOCK';

  @override
  String profileViewAllBadges(int total) {
    return 'View all $total →';
  }

  @override
  String get profileRecentlyEarned => 'RECENTLY EARNED';

  @override
  String get profileAllAchievements => 'All achievements';

  @override
  String get profileEarnedAllBadges =>
      'You\'ve earned them all, Bro. Legendary.';

  @override
  String profileLevelMax(int xp) {
    return '$xp XP · MAX LEVEL';
  }

  @override
  String get scanLooking => 'Looking…';

  @override
  String get scanLookingSubtitle => 'Reading label, matching to catalogue.';

  @override
  String get scanMatched => 'MATCHED';

  @override
  String get scanIdleHeadline => 'Tap the finder to scan';

  @override
  String get scanIdleSubtitle =>
      'Point your camera at any wine or spirit label.';

  @override
  String get scanOpenCamera => 'Open camera';

  @override
  String get scanTryAgain => 'Try again';

  @override
  String get scanNoMatch => 'No matching bottle in our catalogue yet.';

  @override
  String get scanNoText => 'No text detected on the label.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingBegin => 'Begin the quiz';

  @override
  String get onboardingSlide1Eyebrow => 'PALATE QUIZ';

  @override
  String get onboardingSlide1Headline => 'Find your\ntaste DNA';

  @override
  String get onboardingSlide1Byline =>
      'Six axes of flavour learn whether you lean sweet or dry, fruity or smoky, light or full-bodied.';

  @override
  String get onboardingSlide2Eyebrow => 'LABEL SCANNER';

  @override
  String get onboardingSlide2Headline => 'Scan any\nbottle';

  @override
  String get onboardingSlide2Byline =>
      'Point your camera at a label. WineBro reads, identifies, and suggests what to eat with it.';

  @override
  String get onboardingSlide3Eyebrow => 'BROCARD JOURNAL';

  @override
  String get onboardingSlide3Headline => 'Every sip,\nremembered';

  @override
  String get onboardingSlide3Byline =>
      'A beautiful tasting card for every bottle. Watch your palate evolve over time.';

  @override
  String get settingsAppearance => 'APPEARANCE';

  @override
  String get settingsAccount => 'ACCOUNT';

  @override
  String get settingsAbout => 'ABOUT';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsLanguageRow => 'Language';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutQuestion => 'Sign out?';

  @override
  String get settingsSignOutConfirm =>
      'You can sign back in any time with the same number.';

  @override
  String get settingsDelete => 'Delete account';

  @override
  String get settingsDeleteQuestion => 'Delete your account?';

  @override
  String get settingsDeleteConfirm =>
      'This wipes your tasting journal, BroCards, and palate profile. Cannot be undone.';

  @override
  String get settingsDeleteForever => 'Delete forever';

  @override
  String get settingsDeleteComingSoon => 'Account deletion coming soon.';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsTerms => 'Terms of service';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsResponsibly => 'Drink responsibly. 18+';

  @override
  String get settingsChooseLanguage => 'Choose language';

  @override
  String get voiceComingSoon => 'Voice coming in v1.1, Bro.';

  @override
  String get flashlightComingSoon => 'Flashlight in v1.1, Bro.';

  @override
  String get quickLogTitle => 'Quick log';

  @override
  String get quickLogSearchHint => 'What did you taste?';

  @override
  String get quickLogRatingPrompt => 'How was it, Bro?';

  @override
  String get quickLogFoodOptional => 'What did you eat with it? (optional)';

  @override
  String get quickLogBuyAgainPrompt => 'Would you buy this again?';

  @override
  String get quickLogSave => 'Save';

  @override
  String get quickLogProUpgrade => 'Add detailed tasting notes →';

  @override
  String get quickLogSavedSnackbar => 'Saved to your story';

  @override
  String get wishlistTitle => 'Wishlist';

  @override
  String get wishlistEmptyHint =>
      'Save bottles you want to try — they show up here.';

  @override
  String get wishlistRemove => 'Remove';

  @override
  String actionBuy(String price) {
    return 'Buy ₹$price';
  }

  @override
  String get actionSave => 'Save';

  @override
  String get actionSaved => 'Saved';

  @override
  String get actionRemind => 'Remind me';

  @override
  String get actionRemindSet => 'Reminder set';

  @override
  String get wishlistAddedSnackbar => 'Added to wishlist';

  @override
  String get wishlistRemovedSnackbar => 'Removed from wishlist';

  @override
  String get feedbackSheetTitle => 'Did Bro get it right?';

  @override
  String feedbackSheetSubtitle(String product, String dish) {
    return 'Yesterday — $product with $dish';
  }

  @override
  String get feedbackResponseYes => 'Yes';

  @override
  String get feedbackResponseMaybe => 'Sort of';

  @override
  String get feedbackResponseNo => 'Not really';

  @override
  String get feedbackResponseHelperYes =>
      'Bro learned what to suggest next time.';

  @override
  String get feedbackResponseHelperMaybe => 'Bro will calibrate this pairing.';

  @override
  String get feedbackResponseHelperNo => 'Bro will steer others away.';

  @override
  String get feedbackThanks => 'Thanks — Bro got smarter.';

  @override
  String get feedbackEntryNotFound =>
      'That pairing record is gone — nothing to rate.';

  @override
  String get homeRestockEyebrow => 'TIME TO RESTOCK';

  @override
  String get homeRestockReorder => 'Reorder';

  @override
  String get aromaCalibrationEyebrow => 'CALIBRATING YOUR NOSE';

  @override
  String aromaCalibrationPrompt(String aroma) {
    return 'Have you smelled $aroma?';
  }

  @override
  String get aromaCalibrationAssociationHint =>
      'What does it remind you of? (optional)';

  @override
  String get aromaCalibrationFamiliar => 'Yes, I know this scent';

  @override
  String get aromaCalibrationSometimes => 'Sometimes — I think so';

  @override
  String get aromaCalibrationNever => 'Never — first time';

  @override
  String get aromaCalibrationThanks =>
      'Bro just got better at reading your palate.';

  @override
  String get aromaCalibrationCta => 'Calibrate your nose · 60 seconds';

  @override
  String get brocardPhotoBottle => 'Bottle photo';

  @override
  String get brocardPhotoLabel => 'Label closeup';

  @override
  String get brocardPhotoCamera => 'Take photo';

  @override
  String get brocardPhotoGallery => 'Choose from gallery';

  @override
  String get brocardPhotoUploadFailed =>
      'Couldn\'t upload that photo. Try again?';

  @override
  String get occasionPrompt => 'Where are you tasting?';

  @override
  String get contextHome => 'Home';

  @override
  String get contextRestaurant => 'Restaurant';

  @override
  String get contextBar => 'Bar / Lounge';

  @override
  String get contextParty => 'Party';

  @override
  String get contextTravel => 'Travel';

  @override
  String get contextOther => 'Other';

  @override
  String get preQuizEyebrow => 'BEFORE WE BEGIN';

  @override
  String get preQuizHeadline => 'Tap any of these you\'ve tried.';

  @override
  String get preQuizSubhead =>
      'Bro learns faster from what you already know than from theory.';

  @override
  String get preQuizSkip => 'Skip';

  @override
  String get preQuizContinueEmpty => 'Continue without selecting';

  @override
  String preQuizContinueWithCount(int count) {
    return 'Continue with $count selected';
  }

  @override
  String get crossCategoryEyebrow => 'ONE MORE THING';

  @override
  String get crossCategoryHeadline => 'What else do you drink?';

  @override
  String get crossCategorySubhead =>
      'Bro will tailor recommendations across your full repertoire — not just wine.';

  @override
  String get crossCategorySubmit => 'Save';

  @override
  String get crossCategoryThanks => 'Saved — Bro now sees the full picture.';

  @override
  String get crossCategoryProfileTitle => 'What else do you drink?';

  @override
  String get crossCategoryProfileHint =>
      'Tell Bro your other categories — 10 seconds.';

  @override
  String get categoryWine => 'Wine';

  @override
  String get categoryWhisky => 'Whisky';

  @override
  String get categoryBeer => 'Beer';

  @override
  String get categoryCocktails => 'Cocktails';

  @override
  String get categoryGinRumVodka => 'Gin / Rum / Vodka';

  @override
  String get categoryNonAlcoholic => 'Non-alcoholic';

  @override
  String get voiceCaptureTitle => 'Speak your notes';

  @override
  String get voiceCaptureHint => 'Tap the mic and describe what you taste.';

  @override
  String get voiceCaptureListening => 'Listening — speak naturally.';

  @override
  String get voiceCaptureReview =>
      'Looking good. Tap mic to add more, or use this transcript.';

  @override
  String get voiceCapturePlaceholder =>
      'Your transcript will appear here as you speak...';

  @override
  String get voiceCaptureCancel => 'Cancel';

  @override
  String get voiceCaptureUseTranscript => 'Use this';

  @override
  String get voiceCapturePermissionError =>
      'Need microphone + speech permissions. Check Settings.';

  @override
  String get voiceCaptureTooltip => 'Speak your notes';

  @override
  String get voiceCaptureAttached => 'AUDIO ATTACHED';
}
