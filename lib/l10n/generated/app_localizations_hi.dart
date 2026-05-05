// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTagline => 'वाइन और स्पिरिट्स में तुम्हारा बड़ा भाई';

  @override
  String get enterPhoneNumber => 'अपना फ़ोन नंबर डालो';

  @override
  String get createAccount => 'अपना अकाउंट बनाओ';

  @override
  String get welcomeBack => 'वापसी मुबारक';

  @override
  String get findPerfectPairing =>
      'भाई, चलो तुम्हारी परफ़ेक्ट पेयरिंग ढूँढते हैं';

  @override
  String get phoneLabel => 'फ़ोन';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get passwordHint => 'पासवर्ड';

  @override
  String get ageConfirmation =>
      'मेरी उम्र मेरे राज्य में शराब पीने की कानूनी सीमा पूरी करती है';

  @override
  String get ageVerificationRequired => 'पहले अपनी उम्र की पुष्टि करो';

  @override
  String get sendOtp => 'OTP भेजो';

  @override
  String get signUp => 'साइन अप';

  @override
  String get signIn => 'साइन इन';

  @override
  String get alreadyHaveAccount => 'अकाउंट है? साइन इन करो';

  @override
  String get dontHaveAccount => 'अकाउंट नहीं है? साइन अप करो';

  @override
  String get verifyOtpTitle => 'OTP वेरिफ़ाई करो';

  @override
  String otpSentTo(String phone) {
    return '$phone पर 6 अंकों का कोड भेजा गया है';
  }

  @override
  String get verify => 'वेरिफ़ाई करो';

  @override
  String get orContinueWith => 'या इससे जारी रखो';

  @override
  String get signInWithGoogle => 'Google से जारी रखो';

  @override
  String get changeNumber => 'नंबर बदलो';

  @override
  String get resendOtp => 'OTP दोबारा भेजो';

  @override
  String resendIn(int seconds) {
    return '$seconds सेकंड में दोबारा भेजो';
  }

  @override
  String get whatShouldWeCallYou => 'भाई, तुम्हें क्या बुलाएँ?';

  @override
  String get firstNameNeeded => 'बस तुम्हारा पहला नाम बता दो';

  @override
  String get yourNameHint => 'तुम्हारा नाम';

  @override
  String get continueButton => 'आगे बढ़ो';

  @override
  String greeting(String userName) {
    return 'अरे $userName';
  }

  @override
  String get brosPick => 'भाई की पसंद';

  @override
  String get quickActions => 'झटपट';

  @override
  String get pairAction => 'पेयर';

  @override
  String get scanAction => 'स्कैन';

  @override
  String get aromaAction => 'अरोमा';

  @override
  String get learnAction => 'सीखो';

  @override
  String get trendingNow => 'अभी ट्रेंड में';

  @override
  String get broTip => 'भाई की सलाह';

  @override
  String get broTipContent =>
      'मसालेदार इंडियन खाने के साथ ऑफ़-ड्राय Riesling या फ़्रूटी Rosé ट्राई करो। इनकी हल्की मिठास तीखापन को शांत करती है और एसिडिटी तुम्हारे पैलेट को तरोताज़ा रखती है। ज़्यादा टैनिन वाली रेड वाइन तीखापन बढ़ा देगी — इनसे बचो!';

  @override
  String get quizFoodQuestion => 'तुम्हारा सबसे पसंदीदा देसी खाना?';

  @override
  String get pickUpTo2 => '2 तक चुनो';

  @override
  String get chaatQuestion => 'चाट पसंद है! उसमें बेस्ट क्या लगता है?';

  @override
  String get drinkQuestion => 'बाहर जाओ तो पीते क्या हो?';

  @override
  String get fineTunePalate => 'भाई, अपनी पसंद फ़ाइन-ट्यून करो';

  @override
  String get adjustSliders => 'ये स्लाइडर्स अपनी पसंद के हिसाब से सेट करो';

  @override
  String get seeMyProfile => 'मेरी प्रोफ़ाइल देखो';

  @override
  String get nextButton => 'आगे';

  @override
  String get yourPalateProfile => 'तुम्हारी पैलेट प्रोफ़ाइल';

  @override
  String get letsGoBro => 'चलो भाई!';

  @override
  String get sliderDry => 'ड्राय';

  @override
  String get sliderSweet => 'मीठा';

  @override
  String get sliderSmooth => 'स्मूथ';

  @override
  String get sliderTangy => 'खट्टा';

  @override
  String get sliderLight => 'लाइट';

  @override
  String get sliderRich => 'रिच';

  @override
  String get sliderMild => 'माइल्ड';

  @override
  String get sliderFiery => 'तीखा';

  @override
  String stepOf(int step, int total) {
    return '$step / $total';
  }

  @override
  String get pairTitle => 'पेयर';

  @override
  String get foodToDrink => 'खाना → ड्रिंक';

  @override
  String get drinkToFood => 'ड्रिंक → खाना';

  @override
  String get occasionTab => 'मौका';

  @override
  String get whatAreYouEating => 'भाई, क्या खा रहे हो?';

  @override
  String get pickDishForDrink => 'डिश चुनो, मैं परफ़ेक्ट ड्रिंक ढूँढता हूँ';

  @override
  String get bestPairings => 'बेस्ट पेयरिंग्स';

  @override
  String get noPairingsQuiz => 'कोई पेयरिंग नहीं मिली। पहले क्विज़ पूरा करो!';

  @override
  String get whatAreYouDrinking => 'क्या पी रहे हो?';

  @override
  String get goesGreatWith => 'इसके साथ बढ़िया जमेगा...';

  @override
  String get whatsTheOccasion => 'मौका क्या है?';

  @override
  String perfectFor(String occasion) {
    return '$occasion के लिए परफ़ेक्ट';
  }

  @override
  String get completeQuizSuggestions =>
      'पर्सनलाइज़्ड सजेशन के लिए पहले क्विज़ पूरा करो!';

  @override
  String get scanTitle => 'स्कैन';

  @override
  String get tapToScan => 'लेबल स्कैन करने के लिए टैप करो';

  @override
  String get pointCamera =>
      'किसी भी वाइन या स्पिरिट की बोतल पर कैमरा पॉइंट करो';

  @override
  String get orSearchByName => 'या नाम से खोजो';

  @override
  String get searchPlaceholder => 'वाइन, स्पिरिट्स, बीयर खोजो...';

  @override
  String get cameraRequiresDevice =>
      'कैमरे के लिए फ़िज़िकल डिवाइस चाहिए। नीचे सर्च से अपनी बोतल ढूँढो।';

  @override
  String get noTextDetected =>
      'लेबल पर कोई टेक्स्ट नहीं मिला। दोबारा ट्राई करो या नीचे सर्च करो।';

  @override
  String get productFound => 'प्रॉडक्ट मिल गया!';

  @override
  String get addToJournal => 'जर्नल में जोड़ो';

  @override
  String get findPairingsButton => 'पेयरिंग ढूँढो';

  @override
  String get journalTitle => 'जर्नल';

  @override
  String get errorLoadingJournal => 'जर्नल लोड करने में दिक्कत';

  @override
  String get journalEmpty => 'तुम्हारा जर्नल खाली है';

  @override
  String get startLoggingTastings =>
      'अभी तक कोई टेस्टिंग लॉग नहीं की, भाई!\n+ बटन दबाओ और अपना पहला BroCard बनाओ।';

  @override
  String get broCardTitle => 'BroCard';

  @override
  String broCardStepOf(int step) {
    return 'चरण $step / 6';
  }

  @override
  String get whatAreYouTasting => 'क्या टेस्ट कर रहे हो?';

  @override
  String get drinkNameHint => 'ड्रिंक का नाम';

  @override
  String get regionOptionalHint => 'रीजन (ऐच्छिक)';

  @override
  String get appearanceTitle => 'दिखावट';

  @override
  String get colourLabel => 'रंग';

  @override
  String get clarityLabel => 'साफ़ी';

  @override
  String get intensityLabel => 'तीव्रता';

  @override
  String get noseTitle => 'ख़ुशबू';

  @override
  String get aromasSelectLabel => 'अरोमा (चुनने के लिए टैप करो)';

  @override
  String get palateTitle => 'स्वाद';

  @override
  String get sweetnessLabel => 'मिठास';

  @override
  String get acidityLabel => 'खटास';

  @override
  String get tanninLabel => 'टैनिन';

  @override
  String get bodyLabel => 'बॉडी';

  @override
  String get finishAndRating => 'फ़िनिश और रेटिंग';

  @override
  String get finishLengthLabel => 'फ़िनिश की लंबाई';

  @override
  String get yourRating => 'तुम्हारी रेटिंग';

  @override
  String get wouldBuyAgain => 'दोबारा ख़रीदोगे?';

  @override
  String get personalNotesHint => 'अपने नोट्स (ऐच्छिक)';

  @override
  String get yourBroCard => 'तुम्हारा BroCard';

  @override
  String get backButton => 'पीछे';

  @override
  String get saveBroCard => 'BroCard सेव करो';

  @override
  String get aromaExplorerTitle => 'अरोमा एक्सप्लोरर';

  @override
  String get broAromaWheel => 'भाई का अरोमा व्हील';

  @override
  String get tapCategoryToExplore => 'कैटेगरी पर टैप करो';

  @override
  String get tapToExploreAromas => 'अरोमा एक्सप्लोर करने के लिए टैप करो';

  @override
  String groupsAndAromas(int groups, int aromas) {
    return '$groups ग्रुप · $aromas अरोमा';
  }

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String levelLabel(int level) {
    return 'लेवल $level';
  }

  @override
  String xpProgress(int xp, int nextXp) {
    return '$xp / $nextXp XP';
  }

  @override
  String xpMax(int xp) {
    return '$xp XP (अधिकतम)';
  }

  @override
  String get yourPalate => 'तुम्हारा पैलेट';

  @override
  String get achievements => 'उपलब्धियाँ';

  @override
  String get tastingsLabel => 'टेस्टिंग';

  @override
  String get streakLabel => 'स्ट्रीक';

  @override
  String get badgesLabel => 'बैज';

  @override
  String get scansLabel => 'स्कैन';

  @override
  String get pairingsLabel => 'पेयरिंग';

  @override
  String get challengesLabel => 'चैलेंज';

  @override
  String get communityTitle => 'कम्युनिटी';

  @override
  String get theBrotherhood => 'भाईचारा';

  @override
  String get communityDescription =>
      'सोशल फ़ीचर्स, टेस्टिंग सर्कल्स और लीडरबोर्ड Phase 2 में आ रहे हैं। फ़िलहाल अपनी पैलेट प्रोफ़ाइल बनाने पर ध्यान दो — तुम्हारी कम्युनिटी रेप्यूटेशन इस बात पर निर्भर करेगी कि तुमने कितनी टेस्टिंग्स लॉग की हैं।';

  @override
  String get phase2Info =>
      'Phase 2 में: यूज़र्स को फ़ॉलो करो, पेयरिंग शेयर करो, टेस्टिंग सर्कल्स बनाओ, कम्युनिटी रेटिंग्स, और The Cask Circle इवेंट्स के साथ इंटीग्रेशन।';

  @override
  String get navHome => 'होम';

  @override
  String get navPair => 'पेयर';

  @override
  String get navScan => 'स्कैन';

  @override
  String get navJournal => 'जर्नल';

  @override
  String get navCommunity => 'कम्युनिटी';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get selectLanguage => 'भाषा';

  @override
  String errorGeneric(String error) {
    return 'गड़बड़: $error';
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
}
