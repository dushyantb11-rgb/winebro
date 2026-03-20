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
}
