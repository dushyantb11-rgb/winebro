// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appTagline => 'વાઇન અને સ્પિરિટ્સમાં તારો મોટો ભાઈ';

  @override
  String get enterPhoneNumber => 'તારો ફોન નંબર નાખ';

  @override
  String get createAccount => 'તારું એકાઉન્ટ બનાવ';

  @override
  String get welcomeBack => 'પાછો આવ્યો, સ્વાગત છે';

  @override
  String get findPerfectPairing => 'ભાઈ, ચાલ તારી પરફેક્ટ પેરિંગ શોધીએ';

  @override
  String get phoneLabel => 'ફોન';

  @override
  String get emailLabel => 'ઈમેઇલ';

  @override
  String get passwordHint => 'પાસવર્ડ';

  @override
  String get ageConfirmation =>
      'મારી ઉંમર મારા રાજ્યમાં દારૂ પીવાની કાયદેસરની ઉંમર પૂરી કરે છે';

  @override
  String get ageVerificationRequired => 'પહેલાં ઉંમરની ખાતરી કર';

  @override
  String get sendOtp => 'OTP મોકલ';

  @override
  String get signUp => 'સાઇન અપ';

  @override
  String get signIn => 'સાઇન ઇન';

  @override
  String get alreadyHaveAccount => 'એકાઉન્ટ છે? સાઇન ઇન કર';

  @override
  String get dontHaveAccount => 'એકાઉન્ટ નથી? સાઇન અપ કર';

  @override
  String get verifyOtpTitle => 'OTP ચકાસો';

  @override
  String otpSentTo(String phone) {
    return '$phone પર 6 આંકડાનો કોડ મોકલ્યો છે';
  }

  @override
  String get verify => 'ચકાસો';

  @override
  String get orContinueWith => 'અથવા આની સાથે ચાલુ રાખ';

  @override
  String get signInWithGoogle => 'Google સાથે ચાલુ રાખ';

  @override
  String get changeNumber => 'નંબર બદલ';

  @override
  String get resendOtp => 'OTP ફરીથી મોકલ';

  @override
  String resendIn(int seconds) {
    return '$seconds સેકન્ડમાં ફરીથી મોકલ';
  }

  @override
  String get whatShouldWeCallYou => 'ભાઈ, તને શું કહીએ?';

  @override
  String get firstNameNeeded => 'બસ તારું પહેલું નામ કહે';

  @override
  String get yourNameHint => 'તારું નામ';

  @override
  String get continueButton => 'આગળ';

  @override
  String greeting(String userName) {
    return 'કેમ છે $userName';
  }

  @override
  String get brosPick => 'ભાઈની પસંદ';

  @override
  String get quickActions => 'ઝટપટ';

  @override
  String get pairAction => 'પેર';

  @override
  String get scanAction => 'સ્કેન';

  @override
  String get aromaAction => 'અરોમા';

  @override
  String get learnAction => 'શીખ';

  @override
  String get trendingNow => 'હમણાં ટ્રેન્ડમાં';

  @override
  String get broTip => 'ભાઈની ટિપ';

  @override
  String get broTipContent =>
      'મસાલેદાર ઇન્ડિયન ખાણા સાથે ઑફ-ડ્રાય Riesling કે ફ્રૂટી Rosé ટ્રાય કર. એની હળવી મીઠાશ તીખાશને શાંત કરે છે અને એસિડિટી તારું પૅલેટ તાજું રાખે છે. વધુ ટૅનિન વાળી રેડ વાઇન તીખાશ વધારશે — એનાથી દૂર રહે!';

  @override
  String get quizFoodQuestion => 'તારું સૌથી ફેવરિટ દેસી ખાણું કયું?';

  @override
  String get pickUpTo2 => '2 સુધી પસંદ કર';

  @override
  String get chaatQuestion => 'ચાટ ભાવે છે! એમાં બેસ્ટ શું લાગે?';

  @override
  String get drinkQuestion => 'બહાર જાય ત્યારે શું પીવે છે?';

  @override
  String get fineTunePalate => 'ભાઈ, તારી પસંદ ફાઇન-ટ્યુન કર';

  @override
  String get adjustSliders => 'આ સ્લાઇડર્સ તારી પસંદ મુજબ સેટ કર';

  @override
  String get seeMyProfile => 'મારી પ્રોફાઈલ જો';

  @override
  String get nextButton => 'આગળ';

  @override
  String get yourPalateProfile => 'તારી પૅલેટ પ્રોફાઈલ';

  @override
  String get letsGoBro => 'ચાલ ભાઈ!';

  @override
  String get sliderDry => 'ડ્રાય';

  @override
  String get sliderSweet => 'મીઠું';

  @override
  String get sliderSmooth => 'સ્મૂથ';

  @override
  String get sliderTangy => 'ખાટું';

  @override
  String get sliderLight => 'લાઈટ';

  @override
  String get sliderRich => 'રિચ';

  @override
  String get sliderMild => 'માઈલ્ડ';

  @override
  String get sliderFiery => 'તીખું';

  @override
  String stepOf(int step, int total) {
    return '$step / $total';
  }

  @override
  String get pairTitle => 'પેર';

  @override
  String get foodToDrink => 'ખાણું → ડ્રિંક';

  @override
  String get drinkToFood => 'ડ્રિંક → ખાણું';

  @override
  String get occasionTab => 'પ્રસંગ';

  @override
  String get whatAreYouEating => 'ભાઈ, શું ખાય છે?';

  @override
  String get pickDishForDrink => 'ડિશ પસંદ કર, હું પરફેક્ટ ડ્રિંક શોધું';

  @override
  String get bestPairings => 'બેસ્ટ પેરિંગ્સ';

  @override
  String get noPairingsQuiz => 'કોઈ પેરિંગ ન મળી. પહેલાં ક્વિઝ પૂરી કર!';

  @override
  String get whatAreYouDrinking => 'શું પીવે છે?';

  @override
  String get goesGreatWith => 'આની સાથે મજા આવશે...';

  @override
  String get whatsTheOccasion => 'પ્રસંગ કયો છે?';

  @override
  String perfectFor(String occasion) {
    return '$occasion માટે પરફેક્ટ';
  }

  @override
  String get completeQuizSuggestions =>
      'તારા માટે ખાસ સૂચનો જોઈતાં હોય તો પહેલાં ક્વિઝ પૂરી કર!';

  @override
  String get scanTitle => 'સ્કેન';

  @override
  String get tapToScan => 'લેબલ સ્કેન કરવા ટૅપ કર';

  @override
  String get pointCamera => 'કોઈપણ વાઇન કે સ્પિરિટ બોટલ પર કૅમેરો રાખ';

  @override
  String get orSearchByName => 'અથવા નામથી શોધ';

  @override
  String get searchPlaceholder => 'વાઇન, સ્પિરિટ્સ, બીયર શોધો...';

  @override
  String get cameraRequiresDevice =>
      'કૅમેરા માટે ફિઝિકલ ડિવાઇસ જોઈએ. નીચે સર્ચ કરીને તારી બોટલ શોધ.';

  @override
  String get noTextDetected =>
      'લેબલ પર કોઈ ટેક્સ્ટ ન મળ્યો. ફરીથી ટ્રાય કર અથવા નીચે સર્ચ કર.';

  @override
  String get productFound => 'પ્રોડક્ટ મળી ગઈ!';

  @override
  String get addToJournal => 'જર્નલમાં ઉમેર';

  @override
  String get findPairingsButton => 'પેરિંગ શોધ';

  @override
  String get journalTitle => 'જર્નલ';

  @override
  String get errorLoadingJournal => 'જર્નલ લોડ કરવામાં તકલીફ';

  @override
  String get journalEmpty => 'તારું જર્નલ ખાલી છે';

  @override
  String get startLoggingTastings =>
      'હજુ સુધી કોઈ ટેસ્ટિંગ લોગ નથી કરી, ભાઈ!\n+ બટન દબાવ અને તારું પહેલું BroCard બનાવ.';

  @override
  String get broCardTitle => 'BroCard';

  @override
  String broCardStepOf(int step) {
    return 'પગલું $step / 6';
  }

  @override
  String get whatAreYouTasting => 'શું ટેસ્ટ કરે છે?';

  @override
  String get drinkNameHint => 'ડ્રિંકનું નામ';

  @override
  String get regionOptionalHint => 'રિજન (વૈકલ્પિક)';

  @override
  String get appearanceTitle => 'દેખાવ';

  @override
  String get colourLabel => 'રંગ';

  @override
  String get clarityLabel => 'ચોખ્ખાઈ';

  @override
  String get intensityLabel => 'તીવ્રતા';

  @override
  String get noseTitle => 'સુગંધ';

  @override
  String get aromasSelectLabel => 'અરોમા (પસંદ કરવા ટૅપ કર)';

  @override
  String get palateTitle => 'સ્વાદ';

  @override
  String get sweetnessLabel => 'મીઠાશ';

  @override
  String get acidityLabel => 'ખટાશ';

  @override
  String get tanninLabel => 'ટૅનિન';

  @override
  String get bodyLabel => 'બૉડી';

  @override
  String get finishAndRating => 'ફિનિશ અને રેટિંગ';

  @override
  String get finishLengthLabel => 'ફિનિશની લંબાઈ';

  @override
  String get yourRating => 'તારી રેટિંગ';

  @override
  String get wouldBuyAgain => 'ફરીથી ખરીદીશ?';

  @override
  String get personalNotesHint => 'તારી નોંધ (વૈકલ્પિક)';

  @override
  String get yourBroCard => 'તારું BroCard';

  @override
  String get backButton => 'પાછળ';

  @override
  String get saveBroCard => 'BroCard સેવ કર';

  @override
  String get aromaExplorerTitle => 'અરોમા એક્સપ્લોરર';

  @override
  String get broAromaWheel => 'ભાઈનું અરોમા વ્હીલ';

  @override
  String get tapCategoryToExplore => 'કૅટેગરી એક્સપ્લોર કરવા ટૅપ કર';

  @override
  String get tapToExploreAromas => 'અરોમા એક્સપ્લોર કરવા ટૅપ કર';

  @override
  String groupsAndAromas(int groups, int aromas) {
    return '$groups ગ્રુપ · $aromas અરોમા';
  }

  @override
  String get profileTitle => 'પ્રોફાઈલ';

  @override
  String levelLabel(int level) {
    return 'લેવલ $level';
  }

  @override
  String xpProgress(int xp, int nextXp) {
    return '$xp / $nextXp XP';
  }

  @override
  String xpMax(int xp) {
    return '$xp XP (મહત્તમ)';
  }

  @override
  String get yourPalate => 'તારું પૅલેટ';

  @override
  String get achievements => 'સિદ્ધિઓ';

  @override
  String get tastingsLabel => 'ટેસ્ટિંગ';

  @override
  String get streakLabel => 'સ્ટ્રીક';

  @override
  String get badgesLabel => 'બૅજ';

  @override
  String get scansLabel => 'સ્કેન';

  @override
  String get pairingsLabel => 'પેરિંગ';

  @override
  String get challengesLabel => 'ચૅલેન્જ';

  @override
  String get communityTitle => 'કમ્યુનિટી';

  @override
  String get theBrotherhood => 'ભાઈચારો';

  @override
  String get communityDescription =>
      'સોશિયલ ફીચર્સ, ટેસ્ટિંગ સર્કલ્સ અને લીડરબોર્ડ Phase 2 માં આવશે. હમણાં તારી પૅલેટ પ્રોફાઈલ બનાવવા પર ધ્યાન આપ — તારી કમ્યુનિટી રેપ્યુટેશન તેં કેટલી ટેસ્ટિંગ્સ લોગ કરી છે એના પર નક્કી થશે.';

  @override
  String get phase2Info =>
      'Phase 2 માં: યુઝર્સને ફૉલો કરો, પેરિંગ શૅર કરો, ટેસ્ટિંગ સર્કલ્સ બનાવો, કમ્યુનિટી રેટિંગ્સ, અને The Cask Circle ઇવેન્ટ્સ સાથે ઈન્ટિગ્રેશન.';

  @override
  String get navHome => 'હોમ';

  @override
  String get navPair => 'પેર';

  @override
  String get navScan => 'સ્કેન';

  @override
  String get navJournal => 'જર્નલ';

  @override
  String get navCommunity => 'કમ્યુનિટી';

  @override
  String get navProfile => 'પ્રોફાઈલ';

  @override
  String get selectLanguage => 'ભાષા';

  @override
  String errorGeneric(String error) {
    return 'ભૂલ: $error';
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

  @override
  String get friendsTitle => 'Friends';

  @override
  String get friendsProfileTitle => 'Friends';

  @override
  String get friendsProfileEmpty => 'Find Bros you know on WineBro.';

  @override
  String friendsProfileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bros',
      one: 'Bro',
    );
    return 'Following $count $_temp0';
  }

  @override
  String get friendsDiscoverTitle => 'Find friends from contacts';

  @override
  String get friendsDiscoverHint =>
      'Match phone numbers — never uploads your contacts.';

  @override
  String get friendsDiscoveryError =>
      'Couldn\'t read contacts. Check permissions.';

  @override
  String friendsDiscoveredHeader(int count) {
    return 'FOUND ($count)';
  }

  @override
  String get friendsNoneOnApp => 'None of your contacts are on WineBro yet.';

  @override
  String friendsFollowingHeader(int count) {
    return 'FOLLOWING ($count)';
  }

  @override
  String get friendsEmpty => 'Tap above to find Bros you already know.';

  @override
  String get friendsFollow => 'Follow';

  @override
  String get friendsFollowing => 'FOLLOWING';

  @override
  String get friendsUnfollow => 'Unfollow';

  @override
  String friendsAsContact(String contactName) {
    return 'Saved as $contactName';
  }

  @override
  String get settingsPrivacy => 'PRIVACY';

  @override
  String get settingsVisibilityTitle => 'Profile visibility';

  @override
  String get settingsVisibilityPublic => 'Public';

  @override
  String get settingsVisibilityFriends => 'Friends';

  @override
  String get settingsVisibilityPrivate => 'Private';

  @override
  String get settingsVisibilityPublicHint =>
      'Anyone can see your name and recent BroCards.';

  @override
  String get settingsVisibilityFriendsHint =>
      'Only people you follow can see your BroCards.';

  @override
  String get settingsVisibilityPrivateHint =>
      'Only you can see your journal — community signals stay anonymous.';

  @override
  String get wrapUpProfileTitle => 'Your year in tastings';

  @override
  String get wrapUpProfileHint => 'Bro put together your wrap-up.';

  @override
  String get wrapUpYearSuffix => 'WRAP-UP';

  @override
  String get wrapUpNext => 'Next';

  @override
  String get wrapUpDone => 'Done';

  @override
  String get wrapUpYourYearEyebrow => 'YOUR YEAR';

  @override
  String get wrapUpTastingsLabel => 'tastings logged';

  @override
  String wrapUpYourYearBody(int count) {
    return '$count different bottles. Each one a story.';
  }

  @override
  String get wrapUpMostPouredEyebrow => 'MOST POURED';

  @override
  String get wrapUpMostPouredBody =>
      'Your year had a clear hero. Bro saw it coming.';

  @override
  String get wrapUpFavoriteRegionEyebrow => 'FAVORITE REGION';

  @override
  String get wrapUpFavoriteRegionBody => 'Your palate kept coming back here.';

  @override
  String get wrapUpTopPairingEyebrow => 'WITH FOOD';

  @override
  String get wrapUpTopPairingBody =>
      'The pairing your year kept circling back to.';

  @override
  String get wrapUpStreakEyebrow => 'ON A ROLL';

  @override
  String get wrapUpStreakLabel => 'consecutive days';

  @override
  String wrapUpStreakBody(int count) {
    return '$count bottles you rated 4 stars or higher.';
  }

  @override
  String wrapUpEmptyTitle(int year) {
    return 'Your $year starts here.';
  }

  @override
  String get wrapUpEmptyBody =>
      'Log a tasting and Bro will start putting together your year.';

  @override
  String get wrapUpEmptyCta => 'Open journal';

  @override
  String get ageGateLeading =>
      'I\'m 21 or older. I\'ll drink responsibly. I agree to WineBro\'s ';

  @override
  String get ageGatePrivacy => 'Privacy Policy';

  @override
  String get ageGateAnd => ' and ';

  @override
  String get ageGateTerms => 'Terms of Service';

  @override
  String get ageGateTrailing => '.';

  @override
  String get ageGateRequired =>
      'Please confirm you are 21+ and accept the policies to continue.';
}
