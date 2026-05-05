// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTagline => 'वाइन आणि स्पिरिट्स मधला तुझा दादा';

  @override
  String get enterPhoneNumber => 'तुझा फोन नंबर टाक';

  @override
  String get createAccount => 'तुझं अकाउंट बनव';

  @override
  String get welcomeBack => 'परत आलास, स्वागत आहे';

  @override
  String get findPerfectPairing => 'दादा, चल तुझी परफेक्ट पेयरिंग शोधूया';

  @override
  String get phoneLabel => 'फोन';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get passwordHint => 'पासवर्ड';

  @override
  String get ageConfirmation =>
      'मी माझ्या राज्यात मद्यपानाची कायदेशीर वयोमर्यादा पूर्ण करतो/करते';

  @override
  String get ageVerificationRequired => 'आधी वयाची पुष्टी कर';

  @override
  String get sendOtp => 'OTP पाठव';

  @override
  String get signUp => 'साइन अप';

  @override
  String get signIn => 'साइन इन';

  @override
  String get alreadyHaveAccount => 'अकाउंट आहे? साइन इन कर';

  @override
  String get dontHaveAccount => 'अकाउंट नाही? साइन अप कर';

  @override
  String get verifyOtpTitle => 'OTP तपासा';

  @override
  String otpSentTo(String phone) {
    return '$phone वर 6 अंकी कोड पाठवला आहे';
  }

  @override
  String get verify => 'तपासा';

  @override
  String get orContinueWith => 'किंवा यासह सुरू ठेव';

  @override
  String get signInWithGoogle => 'Google ने सुरू ठेव';

  @override
  String get changeNumber => 'नंबर बदल';

  @override
  String get resendOtp => 'OTP परत पाठव';

  @override
  String resendIn(int seconds) {
    return '$seconds सेकंदात परत पाठव';
  }

  @override
  String get whatShouldWeCallYou => 'दादा, तुला काय म्हणू?';

  @override
  String get firstNameNeeded => 'फक्त तुझं पहिलं नाव सांग';

  @override
  String get yourNameHint => 'तुझं नाव';

  @override
  String get continueButton => 'पुढे';

  @override
  String greeting(String userName) {
    return 'काय रे $userName';
  }

  @override
  String get brosPick => 'दादाची पसंती';

  @override
  String get quickActions => 'झटपट';

  @override
  String get pairAction => 'पेयर';

  @override
  String get scanAction => 'स्कॅन';

  @override
  String get aromaAction => 'अरोमा';

  @override
  String get learnAction => 'शिक';

  @override
  String get trendingNow => 'सध्या ट्रेंडमध्ये';

  @override
  String get broTip => 'दादाची टीप';

  @override
  String get broTipContent =>
      'मसालेदार इंडियन जेवणासोबत ऑफ-ड्राय Riesling किंवा फ्रूटी Rosé ट्राय कर. त्यातली हलकी गोडी तिखटपणा शांत करते आणि अ‍ॅसिडिटी तुझा पॅलेट फ्रेश ठेवते. जास्त टॅनिन असलेली रेड वाइन तिखटपणा वाढवेल — त्यापासून दूर राहा!';

  @override
  String get quizFoodQuestion => 'तुझं सगळ्यात आवडतं देसी जेवण कोणतं?';

  @override
  String get pickUpTo2 => '2 पर्यंत निवड';

  @override
  String get chaatQuestion => 'चाट आवडते! त्यातलं बेस्ट काय?';

  @override
  String get drinkQuestion => 'बाहेर गेलास तर काय पितोस?';

  @override
  String get fineTunePalate => 'दादा, तुझी पसंत फाइन-ट्यून कर';

  @override
  String get adjustSliders => 'हे स्लायडर्स तुझ्या पसंतीनुसार सेट कर';

  @override
  String get seeMyProfile => 'माझी प्रोफाइल बघ';

  @override
  String get nextButton => 'पुढे';

  @override
  String get yourPalateProfile => 'तुझी पॅलेट प्रोफाइल';

  @override
  String get letsGoBro => 'चल दादा!';

  @override
  String get sliderDry => 'ड्राय';

  @override
  String get sliderSweet => 'गोड';

  @override
  String get sliderSmooth => 'स्मूथ';

  @override
  String get sliderTangy => 'आंबट';

  @override
  String get sliderLight => 'लाइट';

  @override
  String get sliderRich => 'रिच';

  @override
  String get sliderMild => 'माइल्ड';

  @override
  String get sliderFiery => 'झणझणीत';

  @override
  String stepOf(int step, int total) {
    return '$step / $total';
  }

  @override
  String get pairTitle => 'पेयर';

  @override
  String get foodToDrink => 'जेवण → ड्रिंक';

  @override
  String get drinkToFood => 'ड्रिंक → जेवण';

  @override
  String get occasionTab => 'प्रसंग';

  @override
  String get whatAreYouEating => 'दादा, काय खातोयस?';

  @override
  String get pickDishForDrink => 'डिश निवड, मी परफेक्ट ड्रिंक शोधतो';

  @override
  String get bestPairings => 'बेस्ट पेयरिंग्स';

  @override
  String get noPairingsQuiz =>
      'कोणतीही पेयरिंग सापडली नाही. आधी क्विझ पूर्ण कर!';

  @override
  String get whatAreYouDrinking => 'काय पितोयस?';

  @override
  String get goesGreatWith => 'यासोबत भारी जमतं...';

  @override
  String get whatsTheOccasion => 'प्रसंग कोणता?';

  @override
  String perfectFor(String occasion) {
    return '$occasion साठी परफेक्ट';
  }

  @override
  String get completeQuizSuggestions =>
      'तुझ्यासाठी खास सूचना हव्या असतील तर आधी क्विझ पूर्ण कर!';

  @override
  String get scanTitle => 'स्कॅन';

  @override
  String get tapToScan => 'लेबल स्कॅन करायला टॅप कर';

  @override
  String get pointCamera => 'कोणत्याही वाइन किंवा स्पिरिट बॉटलवर कॅमेरा दाखव';

  @override
  String get orSearchByName => 'किंवा नावाने शोध';

  @override
  String get searchPlaceholder => 'वाइन, स्पिरिट्स, बीयर शोधा...';

  @override
  String get cameraRequiresDevice =>
      'कॅमेऱ्यासाठी फिजिकल डिव्हाइस लागतं. खालच्या सर्चने तुझी बॉटल शोध.';

  @override
  String get noTextDetected =>
      'लेबलवर कोणताही टेक्स्ट सापडला नाही. परत ट्राय कर किंवा खाली सर्च कर.';

  @override
  String get productFound => 'प्रॉडक्ट सापडलं!';

  @override
  String get addToJournal => 'जर्नलमध्ये जोड';

  @override
  String get findPairingsButton => 'पेयरिंग शोधा';

  @override
  String get journalTitle => 'जर्नल';

  @override
  String get errorLoadingJournal => 'जर्नल लोड करताना अडचण';

  @override
  String get journalEmpty => 'तुझं जर्नल रिकामं आहे';

  @override
  String get startLoggingTastings =>
      'अजून कोणतीही टेस्टिंग लॉग केली नाहीस, दादा!\n+ बटण दाब आणि तुझं पहिलं BroCard बनव.';

  @override
  String get broCardTitle => 'BroCard';

  @override
  String broCardStepOf(int step) {
    return 'पायरी $step / 6';
  }

  @override
  String get whatAreYouTasting => 'काय टेस्ट करतोयस?';

  @override
  String get drinkNameHint => 'ड्रिंकचं नाव';

  @override
  String get regionOptionalHint => 'रीजन (ऐच्छिक)';

  @override
  String get appearanceTitle => 'दिसणं';

  @override
  String get colourLabel => 'रंग';

  @override
  String get clarityLabel => 'स्पष्टता';

  @override
  String get intensityLabel => 'तीव्रता';

  @override
  String get noseTitle => 'सुगंध';

  @override
  String get aromasSelectLabel => 'अरोमा (निवडण्यासाठी टॅप कर)';

  @override
  String get palateTitle => 'चव';

  @override
  String get sweetnessLabel => 'गोडवा';

  @override
  String get acidityLabel => 'आंबटपणा';

  @override
  String get tanninLabel => 'टॅनिन';

  @override
  String get bodyLabel => 'बॉडी';

  @override
  String get finishAndRating => 'फिनिश आणि रेटिंग';

  @override
  String get finishLengthLabel => 'फिनिशची लांबी';

  @override
  String get yourRating => 'तुझी रेटिंग';

  @override
  String get wouldBuyAgain => 'परत घेशील?';

  @override
  String get personalNotesHint => 'तुझे नोट्स (ऐच्छिक)';

  @override
  String get yourBroCard => 'तुझं BroCard';

  @override
  String get backButton => 'मागे';

  @override
  String get saveBroCard => 'BroCard सेव्ह कर';

  @override
  String get aromaExplorerTitle => 'अरोमा एक्सप्लोरर';

  @override
  String get broAromaWheel => 'दादाचं अरोमा व्हील';

  @override
  String get tapCategoryToExplore => 'कॅटेगरी एक्सप्लोर करायला टॅप कर';

  @override
  String get tapToExploreAromas => 'अरोमा एक्सप्लोर करायला टॅप कर';

  @override
  String groupsAndAromas(int groups, int aromas) {
    return '$groups ग्रुप · $aromas अरोमा';
  }

  @override
  String get profileTitle => 'प्रोफाइल';

  @override
  String levelLabel(int level) {
    return 'लेव्हल $level';
  }

  @override
  String xpProgress(int xp, int nextXp) {
    return '$xp / $nextXp XP';
  }

  @override
  String xpMax(int xp) {
    return '$xp XP (कमाल)';
  }

  @override
  String get yourPalate => 'तुझा पॅलेट';

  @override
  String get achievements => 'मानचिन्हं';

  @override
  String get tastingsLabel => 'टेस्टिंग';

  @override
  String get streakLabel => 'स्ट्रीक';

  @override
  String get badgesLabel => 'बॅज';

  @override
  String get scansLabel => 'स्कॅन';

  @override
  String get pairingsLabel => 'पेयरिंग';

  @override
  String get challengesLabel => 'चॅलेंज';

  @override
  String get communityTitle => 'कम्युनिटी';

  @override
  String get theBrotherhood => 'भाऊबंदकी';

  @override
  String get communityDescription =>
      'सोशल फीचर्स, टेस्टिंग सर्कल्स आणि लीडरबोर्ड Phase 2 मध्ये येत आहेत. सध्या तुझी पॅलेट प्रोफाइल बनवण्यावर लक्ष दे — तुझी कम्युनिटी रेप्युटेशन तू किती टेस्टिंग्स लॉग केल्यास यावर अवलंबून आहे.';

  @override
  String get phase2Info =>
      'Phase 2 मध्ये: यूजर्सना फॉलो करा, पेयरिंग शेअर करा, टेस्टिंग सर्कल्स बनवा, कम्युनिटी रेटिंग्स, आणि The Cask Circle इव्हेंट्ससोबत इंटिग्रेशन.';

  @override
  String get navHome => 'होम';

  @override
  String get navPair => 'पेयर';

  @override
  String get navScan => 'स्कॅन';

  @override
  String get navJournal => 'जर्नल';

  @override
  String get navCommunity => 'कम्युनिटी';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String get selectLanguage => 'भाषा';

  @override
  String errorGeneric(String error) {
    return 'अडचण: $error';
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
}
