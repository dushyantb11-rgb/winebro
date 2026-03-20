import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/features/pairing/domain/dish.dart';

/// 52 real Indian dishes with accurate food properties and curated pairings.
/// Every pairing follows the WineBro interaction rules:
/// - Spicy + off-dry/fruity = CONTRAST (sweetness tames heat)
/// - Rich/fatty + high-acid = CONTRAST (acid cuts richness)
/// - Grilled protein + tannic reds = COMPLEMENT (tannin binds protein)
/// - Delicate + light-bodied = COMPLEMENT (weight matching)
/// - Sweet dessert + sweeter drink = COMPLEMENT (drink must be sweeter)
const List<Dish> kSeedDishes = [
  // ─────────────────────────────────────────────────────────────────────────
  // NORTH INDIAN (15)
  // ─────────────────────────────────────────────────────────────────────────
  Dish(
    id: 'butter-chicken',
    name: 'Butter Chicken',
    category: FoodCategory.northIndianRich,
    foodProperties: [FoodProperty.highFat, FoodProperty.creamy, FoodProperty.aromatic],
    description: 'Tender chicken in a velvety tomato-butter-cream sauce.',
    pairings: [
      DishPairing(
        productId: 'sula-sauvignon-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'The butter in Butter Chicken is crying out for something sharp to cut through. '
            'Sula\'s Sauvignon Blanc is your answer — that zippy acidity slices through the '
            'cream like a hot knife.',
        score: 88,
      ),
      DishPairing(
        productId: 'fratelli-tilt-rose',
        strategy: PairingStrategy.contrast,
        broTip:
            'A chilled rosé with its bright acidity and berry lift is like a palate reset '
            'button between every spoonful of that rich makhani gravy. Trust the Tilt.',
        score: 82,
      ),
      DishPairing(
        productId: 'bira-91-white',
        strategy: PairingStrategy.contrast,
        broTip:
            'Bira White\'s wheat-beer creaminess doesn\'t fight the butter — it\'s the '
            'coriander and orange peel that sneak in and brighten every bite. Refreshing call.',
        score: 79,
      ),
    ],
  ),

  Dish(
    id: 'dal-makhani',
    name: 'Dal Makhani',
    category: FoodCategory.northIndianRich,
    foodProperties: [FoodProperty.highFat, FoodProperty.creamy, FoodProperty.umamiRich],
    description: 'Slow-cooked black lentils finished with cream and butter.',
    pairings: [
      DishPairing(
        productId: 'soma-chenin-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Dal Makhani is pure umami-butter heaven. Soma Chenin Blanc\'s tropical fruit '
            'and crisp acidity cut right through that overnight-simmered richness. Clean finish.',
        score: 85,
      ),
      DishPairing(
        productId: 'torres-vina-sol',
        strategy: PairingStrategy.contrast,
        broTip:
            'That creamy dal needs a bright Spanish white to balance it. Viña Sol\'s '
            'Parellada grape brings floral notes and a lean acidity that keeps your palate '
            'from drowning in butter.',
        score: 80,
      ),
      DishPairing(
        productId: 'paulaner-hefeweizen',
        strategy: PairingStrategy.contrast,
        broTip:
            'German wheat beer with Indian dal sounds wild, but the carbonation scrubs '
            'your palate clean and the banana-clove notes actually complement those warm '
            'spices. Game changer.',
        score: 78,
      ),
    ],
  ),

  Dish(
    id: 'paneer-tikka-masala',
    name: 'Paneer Tikka Masala',
    category: FoodCategory.northIndianRich,
    foodProperties: [FoodProperty.highFat, FoodProperty.creamy, FoodProperty.spicyHeat, FoodProperty.aromatic],
    description: 'Charred paneer cubes in a spiced tomato-cream gravy.',
    pairings: [
      DishPairing(
        productId: 'fratelli-tilt-rose',
        strategy: PairingStrategy.contrast,
        broTip:
            'The residual sweetness in this rosé is your fire extinguisher. It tames the '
            'masala heat while the acidity handles the cream. Dual-action pairing, bro.',
        score: 84,
      ),
      DishPairing(
        productId: 'kim-crawford-sauvignon-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Kim Crawford\'s Marlborough Sauv Blanc is basically a scalpel — laser acidity '
            'that dissects through the cream and fat of tikka masala. The passionfruit '
            'notes are a bonus.',
        score: 86,
      ),
      DishPairing(
        productId: 'hoegaarden',
        strategy: PairingStrategy.contrast,
        broTip:
            'Hoegaarden\'s orange peel and coriander were born for masala spices. The '
            'wheat-beer body cushions the heat while the carbonation keeps you fresh.',
        score: 77,
      ),
    ],
  ),

  Dish(
    id: 'rogan-josh',
    name: 'Rogan Josh',
    category: FoodCategory.northIndianRich,
    foodProperties: [FoodProperty.highFat, FoodProperty.spicyHeat, FoodProperty.aromatic, FoodProperty.highProtein],
    description: 'Kashmiri slow-braised lamb in a rich red chilli and yogurt sauce.',
    pairings: [
      DishPairing(
        productId: 'grover-zampa-la-reserve',
        strategy: PairingStrategy.complement,
        broTip:
            'Lamb + a bold Bordeaux-style blend is a classic power pairing. Grover La '
            'Réserve\'s tannins lock onto the lamb protein and the dark fruit stands '
            'up to those Kashmiri chillies. Match made.',
        score: 89,
      ),
      DishPairing(
        productId: 'catena-zapata-malbec',
        strategy: PairingStrategy.complement,
        broTip:
            'Argentine Malbec and Kashmiri lamb — both are about deep, warm flavors. '
            'The plush tannins bind the protein, and the plum-and-spice profile rides '
            'alongside the rogan josh spices like a sidecar.',
        score: 87,
      ),
      DishPairing(
        productId: 'amrut-fusion',
        strategy: PairingStrategy.complement,
        broTip:
            'Amrut Fusion\'s peated-meets-unpeated complexity mirrors the layered spice '
            'in rogan josh. A splash of water opens up honey notes that soothe the chilli. '
            'Sip slow, bro.',
        score: 82,
      ),
    ],
  ),

  Dish(
    id: 'chole-bhature',
    name: 'Chole Bhature',
    category: FoodCategory.northIndianRich,
    foodProperties: [FoodProperty.highFat, FoodProperty.spicyHeat, FoodProperty.tangy],
    description: 'Spiced chickpea curry with deep-fried puffed bread.',
    pairings: [
      DishPairing(
        productId: 'bira-91-blonde',
        strategy: PairingStrategy.contrast,
        broTip:
            'Deep-fried bhature demands carbonation — it\'s non-negotiable. Bira Blonde\'s '
            'crisp lager body and light malt scrub the oil off your palate. Sunday brunch sorted.',
        score: 83,
      ),
      DishPairing(
        productId: 'sula-sauvignon-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'The tangy amchur in chole meets the citrusy acidity of Sula Sauv Blanc — '
            'they amplify each other\'s zing while the wine\'s acidity cuts through '
            'the fried bhature richness.',
        score: 80,
      ),
      DishPairing(
        productId: 'sierra-nevada-pale-ale',
        strategy: PairingStrategy.contrast,
        broTip:
            'American pale ale\'s hop bitterness is the perfect foil for greasy bhature. '
            'The citrus hops echo the amchur tang in the chole. A street-food power move.',
        score: 78,
      ),
    ],
  ),

  Dish(
    id: 'rajma-chawal',
    name: 'Rajma Chawal',
    category: FoodCategory.northIndianRich,
    foodProperties: [FoodProperty.highFat, FoodProperty.umamiRich, FoodProperty.aromatic],
    description: 'Red kidney bean curry served over steamed basmati rice.',
    pairings: [
      DishPairing(
        productId: 'louis-jadot-beaujolais-villages',
        strategy: PairingStrategy.complement,
        broTip:
            'Rajma is comfort food and Beaujolais is a comfort wine. Light tannins, '
            'bright cherry fruit, low pretension — they meet at the same cozy frequency.',
        score: 81,
      ),
      DishPairing(
        productId: 'bira-91-white',
        strategy: PairingStrategy.contrast,
        broTip:
            'Bira White\'s coriander-citrus wheat character lifts the earthy heaviness '
            'of rajma. The carbonation keeps things from getting too stodgy. '
            'Weeknight comfort upgrade.',
        score: 77,
      ),
    ],
  ),

  Dish(
    id: 'shahi-paneer',
    name: 'Shahi Paneer',
    category: FoodCategory.northIndianRich,
    foodProperties: [FoodProperty.highFat, FoodProperty.creamy, FoodProperty.aromatic],
    description: 'Paneer cubes in a cashew-cream sauce with saffron and cardamom.',
    pairings: [
      DishPairing(
        productId: 'santa-margherita-pinot-grigio',
        strategy: PairingStrategy.contrast,
        broTip:
            'Shahi Paneer\'s cashew cream is silky rich. Santa Margherita\'s Pinot Grigio '
            'brings a mineral-driven acidity that pierces through that richness. The floral '
            'notes echo the saffron. Chef\'s kiss pairing.',
        score: 85,
      ),
      DishPairing(
        productId: 'moet-chandon-imperial',
        strategy: PairingStrategy.contrast,
        broTip:
            'Champagne with paneer? Bro, hear me out — those tiny bubbles are microscopic '
            'acidity bombs that detonate the cream coating. The toast notes match the '
            'cashew-saffron richness. Royal dish, royal drink.',
        score: 88,
      ),
    ],
  ),

  Dish(
    id: 'malai-kofta',
    name: 'Malai Kofta',
    category: FoodCategory.northIndianRich,
    foodProperties: [FoodProperty.highFat, FoodProperty.creamy, FoodProperty.sweetDessert],
    description: 'Deep-fried paneer-potato dumplings in a rich cashew-tomato cream sauce.',
    pairings: [
      DishPairing(
        productId: 'cloudy-bay-sauvignon-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Malai Kofta is basically dessert disguised as a main course. Cloudy Bay\'s '
            'razor acidity and herbaceous punch cut through that double-cream, '
            'deep-fried indulgence. Essential.',
        score: 86,
      ),
      DishPairing(
        productId: 'soma-chenin-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Soma Chenin Blanc has enough tropical sweetness to complement the kofta\'s '
            'hint of sugar, but enough acidity to handle the cream. The balance you need.',
        score: 82,
      ),
    ],
  ),

  Dish(
    id: 'aloo-gobi',
    name: 'Aloo Gobi',
    category: FoodCategory.northIndianRich,
    foodProperties: [FoodProperty.aromatic, FoodProperty.lightDelicate],
    description: 'Dry-spiced potato and cauliflower with turmeric and cumin.',
    pairings: [
      DishPairing(
        productId: 'torres-vina-sol',
        strategy: PairingStrategy.complement,
        broTip:
            'Aloo Gobi is a gentle dish — don\'t overpower it. Viña Sol\'s light body '
            'and subtle floral notes match the earthy turmeric-cumin warmth perfectly. '
            'Weight matching at its best.',
        score: 80,
      ),
      DishPairing(
        productId: 'bira-91-white',
        strategy: PairingStrategy.complement,
        broTip:
            'Wheat beer\'s soft body mirrors the gentle starchiness of aloo gobi. '
            'The coriander in Bira White literally echoes the coriander in the dish. '
            'Mirror pairing, bro.',
        score: 76,
      ),
    ],
  ),

  Dish(
    id: 'kadhi-pakora',
    name: 'Kadhi Pakora',
    category: FoodCategory.northIndianRich,
    foodProperties: [FoodProperty.tangy, FoodProperty.highFat, FoodProperty.creamy],
    description: 'Yogurt-based tangy curry with deep-fried gram flour fritters.',
    pairings: [
      DishPairing(
        productId: 'sula-sauvignon-blanc',
        strategy: PairingStrategy.complement,
        broTip:
            'Kadhi is tangy from the yogurt, Sauv Blanc is tangy from the acidity — '
            'they vibe on the same wavelength. The wine\'s citrus lifts the besan '
            'heaviness of the pakoras.',
        score: 81,
      ),
      DishPairing(
        productId: 'kingfisher-ultra',
        strategy: PairingStrategy.contrast,
        broTip:
            'Sometimes you just need a clean, cold lager to handle fried pakoras in '
            'yogurt gravy. Kingfisher Ultra\'s crispness resets your palate between '
            'each tangy-oily bite.',
        score: 75,
      ),
    ],
  ),

  Dish(
    id: 'nihari',
    name: 'Nihari',
    category: FoodCategory.northIndianRich,
    foodProperties: [FoodProperty.highFat, FoodProperty.highProtein, FoodProperty.spicyHeat, FoodProperty.aromatic],
    description: 'Overnight slow-cooked bone marrow and shank stew, fiery and gelatinous.',
    pairings: [
      DishPairing(
        productId: 'penfolds-bin-389',
        strategy: PairingStrategy.complement,
        broTip:
            'Nihari is one of the richest things you\'ll ever eat — bone marrow gelatin '
            'demands a wine with structure. Bin 389\'s Cabernet-Shiraz blend has the tannin '
            'backbone to stand up to all that collagen. Power meets power.',
        score: 88,
      ),
      DishPairing(
        productId: 'lagavulin-16',
        strategy: PairingStrategy.complement,
        broTip:
            'Hear me out — Lagavulin\'s peat smoke and maritime salt next to nihari\'s '
            'bone-marrow depth creates this primal, ancient flavor experience. Both are '
            'about patience and slow extraction. Meditative stuff.',
        score: 84,
      ),
    ],
  ),

  Dish(
    id: 'keema-matar',
    name: 'Keema Matar',
    category: FoodCategory.northIndianRich,
    foodProperties: [FoodProperty.highProtein, FoodProperty.spicyHeat, FoodProperty.aromatic],
    description: 'Spiced minced lamb with green peas in a dry-ish masala.',
    pairings: [
      DishPairing(
        productId: 'krsma-cabernet-sauvignon',
        strategy: PairingStrategy.complement,
        broTip:
            'KRSMA Cab Sauv from Karnataka has the tannin structure that keema\'s lamb '
            'protein needs — tannin literally binds to protein, smoothing both the wine '
            'and the meat. Science, bro.',
        score: 85,
      ),
      DishPairing(
        productId: 'oyster-bay-pinot-noir',
        strategy: PairingStrategy.contrast,
        broTip:
            'If you want something lighter than a Cab, Pinot Noir\'s silky red fruit '
            'provides a juicy contrast to the dry spiced mince. The earthy notes match '
            'the cumin. Elegant choice.',
        score: 80,
      ),
      DishPairing(
        productId: 'paul-john-brilliance',
        strategy: PairingStrategy.complement,
        broTip:
            'Paul John\'s fruity-malty Goa single malt echoes the warm spice in keema. '
            'The honeyed sweetness tames the chilli heat through contrast. Indian whisky '
            'for Indian food — natural fit.',
        score: 78,
      ),
    ],
  ),

  Dish(
    id: 'palak-paneer',
    name: 'Palak Paneer',
    category: FoodCategory.northIndianRich,
    foodProperties: [FoodProperty.creamy, FoodProperty.highFat, FoodProperty.aromatic],
    description: 'Paneer cubes in a vibrant, spiced spinach purée.',
    pairings: [
      DishPairing(
        productId: 'sula-sauvignon-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Sauvignon Blanc\'s grassy, herbaceous character is a natural echo of the '
            'spinach, while its acidity slices through the cream and butter. Like the wine '
            'was designed for this dish.',
        score: 87,
      ),
      DishPairing(
        productId: 'cloudy-bay-sauvignon-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Cloudy Bay takes the herbaceous match up a notch — more intensity, more '
            'minerality, more cut. The green-on-green flavor bridge with the palak is '
            'incredible.',
        score: 89,
      ),
    ],
  ),

  Dish(
    id: 'baingan-bharta',
    name: 'Baingan Bharta',
    category: FoodCategory.northIndianRich,
    foodProperties: [FoodProperty.smokyCharred, FoodProperty.aromatic, FoodProperty.tangy],
    description: 'Fire-roasted mashed eggplant with onions, tomatoes, and green chillies.',
    pairings: [
      DishPairing(
        productId: 'four-seasons-barrique-shiraz',
        strategy: PairingStrategy.complement,
        broTip:
            'Smoke calls to smoke. The charred eggplant meets Shiraz\'s oak-barrel '
            'smokiness and they amplify each other into something beautiful. The peppery '
            'spice in the wine matches the green chillies.',
        score: 84,
      ),
      DishPairing(
        productId: 'krsma-sangiovese',
        strategy: PairingStrategy.complement,
        broTip:
            'Sangiovese\'s natural tomato-herb character is literally the same flavor '
            'family as bharta\'s roasted tomato-onion base. Italian grape, Indian dish, '
            'same DNA.',
        score: 82,
      ),
    ],
  ),

  Dish(
    id: 'amritsari-kulcha',
    name: 'Amritsari Kulcha',
    category: FoodCategory.northIndianRich,
    foodProperties: [FoodProperty.highFat, FoodProperty.aromatic],
    description: 'Tandoor-baked stuffed bread with spiced potato or paneer filling.',
    pairings: [
      DishPairing(
        productId: 'kingfisher-ultra',
        strategy: PairingStrategy.contrast,
        broTip:
            'Amritsari kulcha dripping with butter needs something cold, fizzy, and clean. '
            'Kingfisher Ultra is the no-brainer — the carbonation cuts the butter, '
            'the light body doesn\'t compete. Classic Amritsar combo.',
        score: 79,
      ),
      DishPairing(
        productId: 'bira-91-blonde',
        strategy: PairingStrategy.contrast,
        broTip:
            'Bira Blonde\'s crisp finish and gentle malt sweetness handles the buttery, '
            'carb-heavy kulcha without weighing you down further. Sessionable with every '
            'stuffed bite.',
        score: 77,
      ),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // SOUTH INDIAN (10)
  // ─────────────────────────────────────────────────────────────────────────
  Dish(
    id: 'masala-dosa',
    name: 'Masala Dosa',
    category: FoodCategory.southIndianSpiced,
    foodProperties: [FoodProperty.tangy, FoodProperty.aromatic, FoodProperty.lightDelicate],
    description: 'Crispy fermented rice-lentil crêpe with spiced potato filling.',
    pairings: [
      DishPairing(
        productId: 'soma-chenin-blanc',
        strategy: PairingStrategy.complement,
        broTip:
            'Dosa\'s fermented tang matches Chenin Blanc\'s natural acidity. Both are '
            'light, both are bright, both let the subtle mustard-seed tempering shine. '
            'Elegant South Indian brunch.',
        score: 83,
      ),
      DishPairing(
        productId: 'bira-91-white',
        strategy: PairingStrategy.complement,
        broTip:
            'Wheat beer\'s gentle body matches dosa\'s lightness, and the citrus-coriander '
            'notes play beautifully with the coconut chutney on the side. Weight matching '
            'done right.',
        score: 78,
      ),
    ],
  ),

  Dish(
    id: 'chettinad-chicken',
    name: 'Chettinad Chicken',
    category: FoodCategory.southIndianSpiced,
    foodProperties: [FoodProperty.spicyHeat, FoodProperty.highProtein, FoodProperty.aromatic],
    description: 'Fiery chicken curry with freshly ground Chettinad pepper-spice paste.',
    pairings: [
      DishPairing(
        productId: 'fratelli-tilt-rose',
        strategy: PairingStrategy.contrast,
        broTip:
            'Chettinad heat is serious — you need a chilled rosé with enough residual '
            'sweetness to act as a fire blanket. Tilt Rosé\'s berry fruit soothes while '
            'the acidity refreshes. Essential contrast.',
        score: 83,
      ),
      DishPairing(
        productId: 'grover-zampa-vijay-amritraj',
        strategy: PairingStrategy.complement,
        broTip:
            'Grover Vijay Amritraj\'s Cab-Shiraz blend has the weight and dark fruit '
            'to stand alongside Chettinad\'s intensity. Tannins bind the chicken protein. '
            'Both are bold — neither backs down.',
        score: 81,
      ),
      DishPairing(
        productId: 'talisker-10',
        strategy: PairingStrategy.complement,
        broTip:
            'Talisker\'s maritime pepper meets Chettinad pepper — it\'s a pepper summit. '
            'The brine and smoke add layers that don\'t exist in wine. For the adventurous.',
        score: 79,
      ),
    ],
  ),

  Dish(
    id: 'kerala-fish-curry',
    name: 'Kerala Fish Curry',
    category: FoodCategory.southIndianSpiced,
    foodProperties: [FoodProperty.tangy, FoodProperty.spicyHeat, FoodProperty.aromatic],
    description: 'Tangy, fiery fish curry with raw mango/kokum and coconut.',
    pairings: [
      DishPairing(
        productId: 'sula-sauvignon-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Kerala fish curry\'s kokum tartness and chilli heat need a wine that can '
            'match the acidity and soothe the fire. Sula Sauv Blanc\'s citrus acidity '
            'echoes the tang while the fruit tames the heat.',
        score: 85,
      ),
      DishPairing(
        productId: 'kim-crawford-sauvignon-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Kim Crawford\'s Marlborough intensity — gooseberry, passionfruit, razor '
            'acidity — is built for coconut-tamarind curry. The tropical fruit contrasts '
            'the spice; the acidity mirrors the kokum.',
        score: 87,
      ),
    ],
  ),

  Dish(
    id: 'hyderabadi-biryani',
    name: 'Hyderabadi Biryani',
    category: FoodCategory.southIndianSpiced,
    foodProperties: [FoodProperty.aromatic, FoodProperty.highProtein, FoodProperty.highFat],
    description: 'Layered dum-cooked basmati with spiced goat/chicken, saffron, and fried onions.',
    pairings: [
      DishPairing(
        productId: 'grover-zampa-la-reserve',
        strategy: PairingStrategy.complement,
        broTip:
            'Hyderabadi biryani is a celebration dish and La Réserve is a celebration wine. '
            'The Cab-Shiraz blend\'s dark fruit and oak mirror the saffron-ghee richness. '
            'Both are layered, both reward patience.',
        score: 88,
      ),
      DishPairing(
        productId: 'rampur-select',
        strategy: PairingStrategy.complement,
        broTip:
            'Rampur Select\'s tropical fruit and gentle spice are tailor-made for biryani\'s '
            'saffron and whole garam masala. The whisky\'s warmth extends the dish\'s '
            'aromatic finish. Nawabi combo.',
        score: 84,
      ),
      DishPairing(
        productId: 'ruffino-chianti-classico',
        strategy: PairingStrategy.complement,
        broTip:
            'Chianti\'s high acidity handles the ghee, while its cherry-herb profile '
            'doesn\'t compete with the delicate saffron aromatics. Medium body matches '
            'the rice\'s lightness. Smart pick.',
        score: 82,
      ),
    ],
  ),

  Dish(
    id: 'avial',
    name: 'Avial',
    category: FoodCategory.southIndianSpiced,
    foodProperties: [FoodProperty.lightDelicate, FoodProperty.aromatic],
    description: 'Mixed vegetables in a coconut-yogurt sauce tempered with curry leaves.',
    pairings: [
      DishPairing(
        productId: 'torres-vina-sol',
        strategy: PairingStrategy.complement,
        broTip:
            'Avial is gentle — coconut, yogurt, curry leaves. Viña Sol\'s light body '
            'and floral-citrus notes match that delicacy perfectly. Heavy wine would '
            'bulldoze this dish. Weight matching is key.',
        score: 81,
      ),
      DishPairing(
        productId: 'santa-margherita-pinot-grigio',
        strategy: PairingStrategy.complement,
        broTip:
            'Pinot Grigio\'s mineral-driven lightness respects avial\'s subtle coconut '
            'and curry leaf flavors. Both are about elegance, not power. Kerala sadya '
            'wine pick.',
        score: 79,
      ),
    ],
  ),

  Dish(
    id: 'rasam',
    name: 'Rasam',
    category: FoodCategory.southIndianSpiced,
    foodProperties: [FoodProperty.tangy, FoodProperty.spicyHeat, FoodProperty.lightDelicate],
    description: 'Peppery, tangy tamarind-tomato broth sipped or poured over rice.',
    pairings: [
      DishPairing(
        productId: 'soma-chenin-blanc',
        strategy: PairingStrategy.complement,
        broTip:
            'Rasam is basically a spiced consommé — light, tangy, peppery. Chenin Blanc\'s '
            'bright acidity and light body meet it at the same energy level. '
            'Don\'t overpower this delicate broth.',
        score: 79,
      ),
      DishPairing(
        productId: 'bira-91-white',
        strategy: PairingStrategy.contrast,
        broTip:
            'The wheat beer\'s soft sweetness contrasts rasam\'s sharp tamarind tang, '
            'while the carbonation amplifies the pepper tingle. Light meets light '
            'with a flavor twist.',
        score: 75,
      ),
    ],
  ),

  Dish(
    id: 'sambar',
    name: 'Sambar',
    category: FoodCategory.southIndianSpiced,
    foodProperties: [FoodProperty.tangy, FoodProperty.aromatic, FoodProperty.umamiRich],
    description: 'Lentil-based vegetable stew with tamarind and sambar powder.',
    pairings: [
      DishPairing(
        productId: 'louis-jadot-beaujolais-villages',
        strategy: PairingStrategy.complement,
        broTip:
            'Sambar\'s earthy lentil base and tangy tamarind need a wine that\'s light '
            'and fruity, not heavy. Beaujolais\'s Gamay grape delivers cherry-bright fruit '
            'with zero tannin pressure. Everyday pairing.',
        score: 78,
      ),
      DishPairing(
        productId: 'paulaner-hefeweizen',
        strategy: PairingStrategy.complement,
        broTip:
            'The banana-clove notes in hefeweizen complement sambar\'s warm spice blend, '
            'while the wheat body matches the lentil texture. South Indian comfort, '
            'German engineering.',
        score: 76,
      ),
    ],
  ),

  Dish(
    id: 'appam-with-stew',
    name: 'Appam with Stew',
    category: FoodCategory.southIndianSpiced,
    foodProperties: [FoodProperty.lightDelicate, FoodProperty.creamy, FoodProperty.aromatic],
    description: 'Lacy rice-coconut hoppers with a fragrant coconut milk vegetable or chicken stew.',
    pairings: [
      DishPairing(
        productId: 'santa-margherita-pinot-grigio',
        strategy: PairingStrategy.complement,
        broTip:
            'Appam stew is all about coconut milk delicacy. Pinot Grigio\'s light body '
            'and mineral finish complement without overwhelming. The gentle floral notes '
            'mirror the curry leaf and cardamom. Beautiful match.',
        score: 84,
      ),
      DishPairing(
        productId: 'glenmorangie-original',
        strategy: PairingStrategy.complement,
        broTip:
            'Glenmorangie\'s vanilla and citrus from ex-bourbon casks play beautifully '
            'with the coconut cream stew. The whisky\'s gentle sweetness extends the '
            'cardamom finish. Sunday supper vibes.',
        score: 78,
      ),
    ],
  ),

  Dish(
    id: 'malabar-parotta-chicken-curry',
    name: 'Malabar Parotta with Chicken Curry',
    category: FoodCategory.southIndianSpiced,
    foodProperties: [FoodProperty.highFat, FoodProperty.spicyHeat, FoodProperty.highProtein],
    description: 'Flaky, layered flatbread with a spicy coconut-based chicken curry.',
    pairings: [
      DishPairing(
        productId: 'sula-shiraz',
        strategy: PairingStrategy.complement,
        broTip:
            'Malabar chicken curry\'s coconut-chilli richness needs a wine with body and '
            'fruit. Sula Shiraz\'s peppery dark berry character stands alongside the spice '
            'while tannins handle the chicken.',
        score: 82,
      ),
      DishPairing(
        productId: 'simba-stout',
        strategy: PairingStrategy.contrast,
        broTip:
            'Stout with parotta is a vibe. Simba\'s roasted malt and chocolate notes '
            'contrast the coconut curry\'s heat, while the creamy body matches the '
            'flaky parotta\'s buttery layers.',
        score: 79,
      ),
    ],
  ),

  Dish(
    id: 'pongal',
    name: 'Pongal',
    category: FoodCategory.southIndianSpiced,
    foodProperties: [FoodProperty.lightDelicate, FoodProperty.aromatic],
    description: 'Ghee-tempered rice-lentil porridge with black pepper, cumin, and cashews.',
    pairings: [
      DishPairing(
        productId: 'torres-vina-sol',
        strategy: PairingStrategy.complement,
        broTip:
            'Pongal is subtle — pepper, cumin, ghee. Viña Sol\'s understated floral '
            'character and light body respect that subtlety. Anything bigger would '
            'stomp all over it.',
        score: 77,
      ),
      DishPairing(
        productId: 'hoegaarden',
        strategy: PairingStrategy.complement,
        broTip:
            'Hoegaarden\'s soft wheat body and gentle spice (coriander, orange peel) '
            'complement pongal\'s pepper-cumin warmth. Both are morning comfort — '
            'different cultures, same energy.',
        score: 75,
      ),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // COASTAL / SEAFOOD (8)
  // ─────────────────────────────────────────────────────────────────────────
  Dish(
    id: 'goan-fish-curry',
    name: 'Goan Fish Curry',
    category: FoodCategory.coastalSeafood,
    foodProperties: [FoodProperty.tangy, FoodProperty.spicyHeat, FoodProperty.aromatic],
    description: 'Tangy coconut-kokum fish curry — the soul of Goan kitchens.',
    pairings: [
      DishPairing(
        productId: 'sula-sauvignon-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Goan fish curry\'s kokum-tamarind tang and coconut cream need a wine that '
            'can match acidity and provide fruity contrast to the heat. Sula Sauv Blanc '
            'was literally made 30 km from Goa. Terroir destiny.',
        score: 88,
      ),
      DishPairing(
        productId: 'cloudy-bay-sauvignon-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Cloudy Bay\'s intense gooseberry-lime character echoes the kokum tang while '
            'the vibrant acidity cuts through the coconut cream. Kiwi wine, Goan curry, '
            'universal language.',
        score: 86,
      ),
      DishPairing(
        productId: 'kingfisher-ultra',
        strategy: PairingStrategy.contrast,
        broTip:
            'The classic Goan beach combo exists for a reason — cold lager, hot curry. '
            'Kingfisher\'s crispness and carbonation are your palate\'s reset button '
            'between every fiery spoonful.',
        score: 80,
      ),
    ],
  ),

  Dish(
    id: 'prawn-balchao',
    name: 'Prawn Balchão',
    category: FoodCategory.coastalSeafood,
    foodProperties: [FoodProperty.spicyHeat, FoodProperty.tangy, FoodProperty.umamiRich],
    description: 'Goan prawn pickle-curry — fiery, vinegary, and deeply savory.',
    pairings: [
      DishPairing(
        productId: 'fratelli-tilt-rose',
        strategy: PairingStrategy.contrast,
        broTip:
            'Balchão is INTENSE — vinegar, chilli, fermented prawn umami. Tilt Rosé\'s '
            'berry sweetness and chilled acidity are the perfect counterweight. '
            'Sweetness tames fire, acidity matches tang.',
        score: 83,
      ),
      DishPairing(
        productId: 'marques-de-riscal-reserva',
        strategy: PairingStrategy.complement,
        broTip:
            'Spanish Tempranillo\'s leathery, earthy complexity stands up to balchão\'s '
            'vinegar punch. The aged tannins won\'t be bullied by that chilli heat. '
            'Bold dish, bold wine.',
        score: 80,
      ),
    ],
  ),

  Dish(
    id: 'bombay-duck-fry',
    name: 'Bombay Duck Fry',
    category: FoodCategory.coastalSeafood,
    foodProperties: [FoodProperty.highFat, FoodProperty.umamiRich, FoodProperty.smokyCharred],
    description: 'Crispy fried bombil — Mumbai\'s beloved briny, funky, crunchy fish.',
    pairings: [
      DishPairing(
        productId: 'sula-sauvignon-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Bombil is deep-fried and funky. Sauv Blanc\'s citrusy acidity is like '
            'squeezing lime over the fish — it cuts the oil and brightens the umami. '
            'Mumbai street-food essential.',
        score: 84,
      ),
      DishPairing(
        productId: 'bira-91-blonde',
        strategy: PairingStrategy.contrast,
        broTip:
            'Cold blonde lager with fried fish is a law of nature. Bira Blonde\'s '
            'light malt and crisp carbonation scrub the frying oil clean. '
            'Don\'t overthink this one.',
        score: 80,
      ),
    ],
  ),

  Dish(
    id: 'mangalorean-fish-gassi',
    name: 'Mangalorean Fish Gassi',
    category: FoodCategory.coastalSeafood,
    foodProperties: [FoodProperty.spicyHeat, FoodProperty.aromatic, FoodProperty.tangy],
    description: 'Coconut-based fish curry with roasted spices and tamarind.',
    pairings: [
      DishPairing(
        productId: 'kim-crawford-sauvignon-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Gassi\'s roasted coconut-spice and tamarind tang demand a wine with matching '
            'intensity. Kim Crawford\'s concentrated passionfruit and grapefruit acidity '
            'meet the challenge head-on.',
        score: 85,
      ),
      DishPairing(
        productId: 'white-owl-spark',
        strategy: PairingStrategy.contrast,
        broTip:
            'White Owl Spark\'s citrusy wheat character and effervescence provide a '
            'palate-cleansing contrast to gassi\'s rich coconut and roasted spice. '
            'Keeps things bright.',
        score: 77,
      ),
    ],
  ),

  Dish(
    id: 'crab-masala',
    name: 'Crab Masala',
    category: FoodCategory.coastalSeafood,
    foodProperties: [FoodProperty.spicyHeat, FoodProperty.umamiRich, FoodProperty.highProtein],
    description: 'Whole crab cooked in a fiery red masala — messy, hands-on, incredible.',
    pairings: [
      DishPairing(
        productId: 'cloudy-bay-sauvignon-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Crab\'s sweet meat under all that masala fire needs a wine with enough '
            'acidity to cut through the spice and enough fruit to contrast the heat. '
            'Cloudy Bay does both. Messy food, clean wine.',
        score: 86,
      ),
      DishPairing(
        productId: 'moet-chandon-imperial',
        strategy: PairingStrategy.contrast,
        broTip:
            'Champagne and crab is a classic pairing worldwide. Moët\'s bubbles and '
            'acidity slice through the masala, while the toasty notes complement the '
            'sweet crab meat. Luxury move.',
        score: 85,
      ),
    ],
  ),

  Dish(
    id: 'meen-pollichathu',
    name: 'Meen Pollichathu (Kerala Fish in Banana Leaf)',
    category: FoodCategory.coastalSeafood,
    foodProperties: [FoodProperty.aromatic, FoodProperty.spicyHeat, FoodProperty.smokyCharred],
    description: 'Masala-marinated fish wrapped in banana leaf and pan-roasted.',
    pairings: [
      DishPairing(
        productId: 'york-arros',
        strategy: PairingStrategy.complement,
        broTip:
            'York Arros has a smoky-oaky character that mirrors the banana-leaf char. '
            'The medium body matches the fish\'s weight, and the fruit doesn\'t fight '
            'the masala. Nasik wine, Kerala dish, Indian harmony.',
        score: 82,
      ),
      DishPairing(
        productId: 'soma-chenin-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Chenin Blanc\'s bright acidity and tropical notes contrast the smoky '
            'banana-leaf char and cut through the masala\'s oil. The freshness lifts '
            'each bite.',
        score: 80,
      ),
    ],
  ),

  Dish(
    id: 'koliwada-fish-fry',
    name: 'Koliwada Fish Fry',
    category: FoodCategory.coastalSeafood,
    foodProperties: [FoodProperty.highFat, FoodProperty.spicyHeat, FoodProperty.smokyCharred],
    description: 'Mumbai Koli-style battered and deep-fried fish with red masala.',
    pairings: [
      DishPairing(
        productId: 'bira-91-blonde',
        strategy: PairingStrategy.contrast,
        broTip:
            'Koliwada fry is street food — hot, oily, spicy, crispy. You need a beer. '
            'Bira Blonde\'s clean lager crispness washes away the batter oil and cools '
            'the chilli. Mumbai harbor vibes.',
        score: 82,
      ),
      DishPairing(
        productId: 'sierra-nevada-pale-ale',
        strategy: PairingStrategy.contrast,
        broTip:
            'Hop bitterness is fried food\'s natural enemy — it cuts through batter '
            'and oil like nothing else. Sierra Nevada\'s citrus hops add a flavor '
            'dimension the dish doesn\'t have. Level up.',
        score: 79,
      ),
    ],
  ),

  Dish(
    id: 'surmai-tawa-fry',
    name: 'Surmai Tawa Fry',
    category: FoodCategory.coastalSeafood,
    foodProperties: [FoodProperty.highProtein, FoodProperty.smokyCharred, FoodProperty.spicyHeat],
    description: 'King mackerel pan-fried on a tawa with red-green masala rub.',
    pairings: [
      DishPairing(
        productId: 'sula-sauvignon-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Surmai\'s oily, meaty fish character and tawa char need citrusy acidity. '
            'Think of Sula Sauv Blanc as a liquid lime squeeze — it brightens the '
            'fish and cuts the masala oil.',
        score: 85,
      ),
      DishPairing(
        productId: 'fratelli-sette',
        strategy: PairingStrategy.complement,
        broTip:
            'Fratelli Sette\'s medium-bodied Sangiovese-Cab blend has enough structure '
            'for surmai\'s meaty texture. The Italian-grape herbal notes complement '
            'the green masala rub. Surf meets turf energy.',
        score: 78,
      ),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // TANDOORI / GRILLED (7)
  // ─────────────────────────────────────────────────────────────────────────
  Dish(
    id: 'tandoori-chicken',
    name: 'Tandoori Chicken',
    category: FoodCategory.tandooriGrilled,
    foodProperties: [FoodProperty.highProtein, FoodProperty.smokyCharred, FoodProperty.aromatic],
    description: 'Yogurt-marinated chicken cooked in a blazing tandoor — smoky, charred, juicy.',
    pairings: [
      DishPairing(
        productId: 'sula-shiraz',
        strategy: PairingStrategy.complement,
        broTip:
            'Tandoori chicken\'s smoke and char are calling for Shiraz — the grape '
            'literally tastes like black pepper and smoke. Tannins bind the chicken '
            'protein. This is the quintessential Indian wine pairing.',
        score: 90,
      ),
      DishPairing(
        productId: 'charosa-reserve-shiraz',
        strategy: PairingStrategy.complement,
        broTip:
            'Charosa Reserve Shiraz brings more oak complexity than Sula — vanilla, '
            'toast, dark fruit — all of which mirror tandoor\'s smoky char. '
            'Premium upgrade for the same pairing logic.',
        score: 88,
      ),
      DishPairing(
        productId: 'catena-zapata-malbec',
        strategy: PairingStrategy.complement,
        broTip:
            'Malbec\'s plush, smoky character and ripe tannins complement tandoori\'s '
            'char and yogurt-marinated protein. Argentine grills and Indian tandoors '
            'speak the same language — fire and smoke.',
        score: 86,
      ),
    ],
  ),

  Dish(
    id: 'seekh-kebab',
    name: 'Seekh Kebab',
    category: FoodCategory.tandooriGrilled,
    foodProperties: [FoodProperty.highProtein, FoodProperty.smokyCharred, FoodProperty.highFat, FoodProperty.aromatic],
    description: 'Minced lamb skewers with herbs and spices, charred over coals.',
    pairings: [
      DishPairing(
        productId: 'krsma-cabernet-sauvignon',
        strategy: PairingStrategy.complement,
        broTip:
            'Seekh kebab is fat, protein, char, and spice — it\'s basically designed '
            'for Cabernet Sauvignon. KRSMA\'s tannins lock onto the lamb fat, the '
            'cassis fruit matches the charred crust. Textbook complement.',
        score: 89,
      ),
      DishPairing(
        productId: 'robert-mondavi-cabernet-sauvignon',
        strategy: PairingStrategy.complement,
        broTip:
            'Robert Mondavi Cab Sauv brings Napa Valley muscle — blackcurrant, cedar, '
            'firm tannins — to lamb seekh\'s richness. Protein-tannin binding makes '
            'both taste smoother. Science at work.',
        score: 87,
      ),
      DishPairing(
        productId: 'glenfiddich-12',
        strategy: PairingStrategy.complement,
        broTip:
            'Glenfiddich 12\'s pear and oak notes are a surprisingly elegant match '
            'for charred lamb. The whisky\'s gentle sweetness contrasts the char '
            'while complementing the warm spices. Kebab night upgrade.',
        score: 80,
      ),
    ],
  ),

  Dish(
    id: 'paneer-tikka',
    name: 'Paneer Tikka',
    category: FoodCategory.tandooriGrilled,
    foodProperties: [FoodProperty.smokyCharred, FoodProperty.highFat, FoodProperty.aromatic],
    description: 'Charred paneer cubes marinated in spiced yogurt, grilled in tandoor.',
    pairings: [
      DishPairing(
        productId: 'grover-zampa-vijay-amritraj',
        strategy: PairingStrategy.complement,
        broTip:
            'Paneer tikka\'s smoky char and fat content match well with Grover\'s '
            'Cab-Shiraz dark fruit and soft tannins. The wine\'s oak smoke echoes '
            'the tandoor. India\'s most popular wine pairing for good reason.',
        score: 84,
      ),
      DishPairing(
        productId: 'big-banyan-merlot',
        strategy: PairingStrategy.complement,
        broTip:
            'Big Banyan Merlot is softer than Cab — plummy, gentle tannins — which '
            'suits paneer\'s milder protein. The smoky-fruity combo works without '
            'overpowering the cheese.',
        score: 80,
      ),
    ],
  ),

  Dish(
    id: 'fish-tikka',
    name: 'Fish Tikka',
    category: FoodCategory.tandooriGrilled,
    foodProperties: [FoodProperty.highProtein, FoodProperty.smokyCharred, FoodProperty.lightDelicate],
    description: 'Tandoor-grilled fish chunks with a light spice-yogurt marinade.',
    pairings: [
      DishPairing(
        productId: 'soma-chenin-blanc',
        strategy: PairingStrategy.complement,
        broTip:
            'Fish tikka is lighter than chicken tikka — it needs a lighter wine. '
            'Chenin Blanc\'s stone fruit and moderate acidity complement the delicate '
            'fish without drowning out the tandoor smoke.',
        score: 84,
      ),
      DishPairing(
        productId: 'cloudy-bay-sauvignon-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Cloudy Bay\'s herbal intensity and razor acidity cut through the yogurt '
            'marinade and brighten the smoky fish. It\'s like adding fresh herb chutney '
            'via your glass.',
        score: 83,
      ),
    ],
  ),

  Dish(
    id: 'galouti-kebab',
    name: 'Galouti Kebab',
    category: FoodCategory.tandooriGrilled,
    foodProperties: [FoodProperty.highFat, FoodProperty.highProtein, FoodProperty.aromatic],
    description: 'Melt-in-mouth Lucknowi lamb patties with over 150 spices and raw papaya tenderizer.',
    pairings: [
      DishPairing(
        productId: 'antinori-tignanello',
        strategy: PairingStrategy.complement,
        broTip:
            'Galouti is Awadhi royalty — it deserves an aristocratic wine. Tignanello\'s '
            'Sangiovese-Cab blend has the structure, the complexity, and the finesse to '
            'match these 150-spice patties. Both are masterpieces of subtlety.',
        score: 92,
      ),
      DishPairing(
        productId: 'chateau-leoville-barton',
        strategy: PairingStrategy.complement,
        broTip:
            'Left Bank Bordeaux with Lucknowi kebab — refined tannins meeting melt-in-mouth '
            'lamb. The cedar and graphite notes add a dimension that elevates the '
            'already complex spice blend. Nawabi pairing.',
        score: 90,
      ),
      DishPairing(
        productId: 'amrut-fusion',
        strategy: PairingStrategy.complement,
        broTip:
            'Amrut Fusion\'s Indian-Scottish barley marriage mirrors the galouti\'s own '
            'fusion of royal technique and rustic ingredients. The peaty-sweet interplay '
            'extends the kebab\'s aromatic finish.',
        score: 85,
      ),
    ],
  ),

  Dish(
    id: 'kakori-kebab',
    name: 'Kakori Kebab',
    category: FoodCategory.tandooriGrilled,
    foodProperties: [FoodProperty.highFat, FoodProperty.highProtein, FoodProperty.aromatic],
    description: 'Silky smooth lamb seekh from Lucknow — even more refined than galouti.',
    pairings: [
      DishPairing(
        productId: 'penfolds-bin-389',
        strategy: PairingStrategy.complement,
        broTip:
            'Kakori\'s silky lamb texture needs a wine with equal smoothness but enough '
            'structure to match the fat. Bin 389\'s Cab-Shiraz velvet tannins are that '
            'wine. Both are about texture over brute force.',
        score: 88,
      ),
      DishPairing(
        productId: 'rampur-select',
        strategy: PairingStrategy.complement,
        broTip:
            'Rampur Select\'s smooth, fruity character matches kakori\'s refined delicacy. '
            'No peat, no smoke to overpower — just gentle spice meeting gentle spice. '
            'Lucknow meets Rampur. Literally neighbors.',
        score: 83,
      ),
    ],
  ),

  Dish(
    id: 'chicken-malai-tikka',
    name: 'Chicken Malai Tikka',
    category: FoodCategory.tandooriGrilled,
    foodProperties: [FoodProperty.creamy, FoodProperty.highProtein, FoodProperty.smokyCharred],
    description: 'Cream-and-cheese marinated chicken grilled in tandoor — mild, buttery, smoky.',
    pairings: [
      DishPairing(
        productId: 'fratelli-sette',
        strategy: PairingStrategy.complement,
        broTip:
            'Malai tikka is milder than regular tikka — more cream, less chilli. '
            'Fratelli Sette\'s medium body and herbal-cherry notes complement the '
            'creamy smoke without any harsh tannin clash.',
        score: 82,
      ),
      DishPairing(
        productId: 'oyster-bay-pinot-noir',
        strategy: PairingStrategy.complement,
        broTip:
            'Pinot Noir\'s silky red fruit and low tannin suit the creamy, gentle '
            'character of malai tikka. Think velvet on velvet — both are smooth, '
            'both are elegant.',
        score: 84,
      ),
      DishPairing(
        productId: 'monkey-shoulder',
        strategy: PairingStrategy.complement,
        broTip:
            'Monkey Shoulder\'s vanilla-toffee smoothness from triple malt blending '
            'echoes the cream-cheese marinade. The gentle oakiness matches the tandoor '
            'char. Smooth on smooth.',
        score: 79,
      ),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // STREET FOOD (6)
  // ─────────────────────────────────────────────────────────────────────────
  Dish(
    id: 'pani-puri',
    name: 'Pani Puri',
    category: FoodCategory.streetFood,
    foodProperties: [FoodProperty.tangy, FoodProperty.spicyHeat, FoodProperty.lightDelicate],
    description: 'Hollow crispy shells filled with spiced water, tamarind, and chickpeas.',
    pairings: [
      DishPairing(
        productId: 'moet-chandon-imperial',
        strategy: PairingStrategy.complement,
        broTip:
            'Hear me out — pani puri and Champagne are the same concept. Both are about '
            'bubbles, acidity, and a burst of flavor. Moët\'s fizz mirrors the pani\'s '
            'effervescence. It\'s the pairing that shouldn\'t work but absolutely does.',
        score: 85,
      ),
      DishPairing(
        productId: 'bira-91-white',
        strategy: PairingStrategy.contrast,
        broTip:
            'Bira White\'s gentle wheat sweetness contrasts the jaljeera\'s spicy tang. '
            'The carbonation matches pani puri\'s own bubbly energy. Street-food chic.',
        score: 78,
      ),
    ],
  ),

  Dish(
    id: 'sev-puri',
    name: 'Sev Puri',
    category: FoodCategory.streetFood,
    foodProperties: [FoodProperty.tangy, FoodProperty.lightDelicate, FoodProperty.spicyHeat],
    description: 'Flat puris topped with potato, chutneys, onion, sev, and a chaos of textures.',
    pairings: [
      DishPairing(
        productId: 'soma-chenin-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Sev puri is a flavor bomb — sweet chutney, sour tamarind, spicy green '
            'chutney. Chenin Blanc\'s clean tropical fruit provides a calm center '
            'amidst the chaat chaos. Palate anchor.',
        score: 79,
      ),
      DishPairing(
        productId: 'bira-91-blonde',
        strategy: PairingStrategy.contrast,
        broTip:
            'When five flavors hit you at once, a simple cold lager is your friend. '
            'Bira Blonde resets the palate between each loaded puri. '
            'Don\'t overcomplicate chaat.',
        score: 76,
      ),
    ],
  ),

  Dish(
    id: 'vada-pav',
    name: 'Vada Pav',
    category: FoodCategory.streetFood,
    foodProperties: [FoodProperty.highFat, FoodProperty.spicyHeat, FoodProperty.tangy],
    description: 'Mumbai\'s spicy potato fritter in a bun with garlic and tamarind chutneys.',
    pairings: [
      DishPairing(
        productId: 'bira-91-blonde',
        strategy: PairingStrategy.contrast,
        broTip:
            'Vada pav is Mumbai\'s burger — fried, spicy, carb-heavy. Bira Blonde is '
            'Mumbai\'s lager. The cold carbonation cuts through the fried besan batter '
            'and the chilli. Local hero combo.',
        score: 81,
      ),
      DishPairing(
        productId: 'sierra-nevada-pale-ale',
        strategy: PairingStrategy.contrast,
        broTip:
            'Hop bitterness vs. deep-fried potato? The bitter cuts the fat, the citrus '
            'hops lift the heavy carb, and the malt body stands up to the garlic chutney. '
            'Street food elevation.',
        score: 78,
      ),
    ],
  ),

  Dish(
    id: 'pav-bhaji',
    name: 'Pav Bhaji',
    category: FoodCategory.streetFood,
    foodProperties: [FoodProperty.highFat, FoodProperty.tangy, FoodProperty.aromatic],
    description: 'Butter-loaded spiced vegetable mash served with toasted buttered buns.',
    pairings: [
      DishPairing(
        productId: 'sula-sauvignon-blanc',
        strategy: PairingStrategy.contrast,
        broTip:
            'Pav bhaji is a butter bomb — the bhaji is butter, the pav is butter. '
            'You need acid, and lots of it. Sula Sauv Blanc\'s citrus acidity is your '
            'butter-cutting weapon. Non-negotiable.',
        score: 83,
      ),
      DishPairing(
        productId: 'kingfisher-ultra',
        strategy: PairingStrategy.contrast,
        broTip:
            'Juhu Beach at night, plate of pav bhaji, cold Kingfisher. The carbonation '
            'and crispness handle the insane amount of butter. Some pairings just ARE.',
        score: 79,
      ),
      DishPairing(
        productId: 'white-owl-spark',
        strategy: PairingStrategy.contrast,
        broTip:
            'White Owl Spark\'s citrus wheat character adds brightness to pav bhaji\'s '
            'deep, buttery warmth. The effervescence scrubs butter off your palate. '
            'Craft beer upgrade from the lager default.',
        score: 77,
      ),
    ],
  ),

  Dish(
    id: 'kathi-roll',
    name: 'Kathi Roll',
    category: FoodCategory.streetFood,
    foodProperties: [FoodProperty.highProtein, FoodProperty.spicyHeat, FoodProperty.aromatic],
    description: 'Kolkata\'s egg-wrapped paratha roll stuffed with spiced grilled kebab and onions.',
    pairings: [
      DishPairing(
        productId: 'big-banyan-merlot',
        strategy: PairingStrategy.complement,
        broTip:
            'Kathi roll\'s grilled meat and egg-paratha combo wants a medium-bodied '
            'red. Big Banyan Merlot\'s soft plum fruit and gentle tannins complement '
            'the kebab protein without fighting the spice.',
        score: 80,
      ),
      DishPairing(
        productId: 'jameson-irish-whiskey',
        strategy: PairingStrategy.complement,
        broTip:
            'Jameson\'s smooth, slightly sweet Irish character pairs naturally with '
            'grilled meat. The vanilla-grain notes soften the chilli while the '
            'whiskey warmth extends the kebab\'s smoky finish. Late-night roll combo.',
        score: 77,
      ),
    ],
  ),

  Dish(
    id: 'samosa-chaat',
    name: 'Samosa Chaat',
    category: FoodCategory.streetFood,
    foodProperties: [FoodProperty.highFat, FoodProperty.tangy, FoodProperty.spicyHeat],
    description: 'Crushed samosa topped with chickpeas, chutneys, yogurt, and sev.',
    pairings: [
      DishPairing(
        productId: 'bira-91-white',
        strategy: PairingStrategy.contrast,
        broTip:
            'Samosa chaat is fried, spicy, tangy, and sweet all at once. Bira White\'s '
            'wheat creaminess and citrus notes provide a gentle contrast to all that '
            'chaat chaos. The carbonation handles the fried samosa.',
        score: 78,
      ),
      DishPairing(
        productId: 'fratelli-tilt-rose',
        strategy: PairingStrategy.contrast,
        broTip:
            'Rosé with chaat is an underrated move. Tilt\'s berry sweetness tames the '
            'green chutney heat, the acidity mirrors the tamarind tang, and the chill '
            'refreshes after each oily bite.',
        score: 80,
      ),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // DESSERTS (6)
  // ─────────────────────────────────────────────────────────────────────────
  Dish(
    id: 'gulab-jamun',
    name: 'Gulab Jamun',
    category: FoodCategory.desserts,
    foodProperties: [FoodProperty.sweetDessert, FoodProperty.highFat, FoodProperty.aromatic],
    description: 'Deep-fried milk dumplings soaked in rose-cardamom sugar syrup.',
    pairings: [
      DishPairing(
        productId: 'glenfiddich-12',
        strategy: PairingStrategy.complement,
        broTip:
            'Glenfiddich 12\'s honey and vanilla notes are sweeter than you think — '
            'they complement gulab jamun\'s sugar syrup while the oak dryness prevents '
            'a sugar overload. The pear note echoes the rose. Dessert whisky 101.',
        score: 83,
      ),
      DishPairing(
        productId: 'moet-chandon-imperial',
        strategy: PairingStrategy.contrast,
        broTip:
            'Champagne\'s bone-dry acidity and bubbles cut through gulab jamun\'s '
            'cloying sweetness like a palate scalpel. The toast notes add a savory '
            'anchor. Contrast pairing at its boldest.',
        score: 80,
      ),
    ],
  ),

  Dish(
    id: 'ras-malai',
    name: 'Ras Malai',
    category: FoodCategory.desserts,
    foodProperties: [FoodProperty.sweetDessert, FoodProperty.creamy, FoodProperty.aromatic],
    description: 'Soft paneer discs in saffron-cardamom sweetened milk.',
    pairings: [
      DishPairing(
        productId: 'glenmorangie-original',
        strategy: PairingStrategy.complement,
        broTip:
            'Glenmorangie\'s vanilla-citrus-floral profile is a natural extension of '
            'ras malai\'s saffron-cardamom milk. Both are about delicacy and sweetness. '
            'The whisky must be as sweet as the dessert — and it is.',
        score: 85,
      ),
      DishPairing(
        productId: 'paul-john-brilliance',
        strategy: PairingStrategy.complement,
        broTip:
            'Paul John Brilliance\'s tropical fruit and honey sweetness complement '
            'the saffron milk without fighting it. Goan whisky with Bengali dessert — '
            'India\'s internal pairing magic.',
        score: 81,
      ),
    ],
  ),

  Dish(
    id: 'gajar-ka-halwa',
    name: 'Gajar Ka Halwa',
    category: FoodCategory.desserts,
    foodProperties: [FoodProperty.sweetDessert, FoodProperty.highFat, FoodProperty.aromatic],
    description: 'Slow-cooked grated carrot pudding with ghee, khoya, and cardamom.',
    pairings: [
      DishPairing(
        productId: 'amrut-fusion',
        strategy: PairingStrategy.complement,
        broTip:
            'Gajar halwa\'s ghee-carrot-cardamom richness needs a whisky with matching '
            'complexity. Amrut Fusion\'s peated-unpeated blend adds smoky depth that '
            'makes the halwa taste even more decadent. Winter night perfection.',
        score: 84,
      ),
      DishPairing(
        productId: 'chimay-blue',
        strategy: PairingStrategy.complement,
        broTip:
            'Chimay Blue\'s dark fruit, spice, and residual sweetness are a mirror '
            'for gajar halwa\'s caramelized carrot and cardamom. Belgian Trappist beer '
            'and Punjabi halwa — both are about patience and richness.',
        score: 82,
      ),
    ],
  ),

  Dish(
    id: 'kulfi',
    name: 'Kulfi',
    category: FoodCategory.desserts,
    foodProperties: [FoodProperty.sweetDessert, FoodProperty.creamy],
    description: 'Dense, slow-set Indian ice cream with pistachio, saffron, or mango.',
    pairings: [
      DishPairing(
        productId: 'paul-john-brilliance',
        strategy: PairingStrategy.complement,
        broTip:
            'Paul John\'s honey-mango-tropical character complements pistachio kulfi\'s '
            'creamy nuttiness. The whisky\'s sweetness matches the dessert — remember, '
            'the drink must always be as sweet or sweeter.',
        score: 80,
      ),
      DishPairing(
        productId: 'chimay-blue',
        strategy: PairingStrategy.complement,
        broTip:
            'Chimay Blue at cellar temp with frozen kulfi creates a hot-cold, complex-simple '
            'dynamic. The Belgian ale\'s dried fruit sweetness envelops the kulfi\'s '
            'cream. Sensory contrast, flavor complement.',
        score: 78,
      ),
    ],
  ),

  Dish(
    id: 'jalebi',
    name: 'Jalebi',
    category: FoodCategory.desserts,
    foodProperties: [FoodProperty.sweetDessert, FoodProperty.highFat],
    description: 'Crispy, deep-fried batter spirals soaked in saffron sugar syrup.',
    pairings: [
      DishPairing(
        productId: 'glenfiddich-12',
        strategy: PairingStrategy.complement,
        broTip:
            'Jalebi is pure sugar and crunch. Glenfiddich 12\'s honey-vanilla sweetness '
            'complements without competing, and the malt dryness gives your palate a '
            'break from the sugar onslaught. Sip between bites.',
        score: 79,
      ),
      DishPairing(
        productId: 'moet-chandon-imperial',
        strategy: PairingStrategy.contrast,
        broTip:
            'The oldest trick in the book — acidity vs. sugar. Moët\'s razor-sharp '
            'bubbles and dry Chardonnay-Pinot base cut through jalebi\'s syrupy '
            'sweetness. Each sip resets your palate for the next crispy bite.',
        score: 81,
      ),
    ],
  ),

  Dish(
    id: 'shahi-tukda',
    name: 'Shahi Tukda',
    category: FoodCategory.desserts,
    foodProperties: [FoodProperty.sweetDessert, FoodProperty.highFat, FoodProperty.creamy, FoodProperty.aromatic],
    description: 'Fried bread soaked in sweetened rabri milk with saffron and nuts — Hyderabadi royalty.',
    pairings: [
      DishPairing(
        productId: 'rampur-select',
        strategy: PairingStrategy.complement,
        broTip:
            'Shahi Tukda is the richest Indian dessert — fried bread, cream, saffron, '
            'nuts. Rampur Select\'s tropical smoothness and caramel notes extend that '
            'richness into your glass. Both are Nawabi indulgences.',
        score: 84,
      ),
      DishPairing(
        productId: 'glenmorangie-original',
        strategy: PairingStrategy.complement,
        broTip:
            'Glenmorangie\'s vanilla and honey from bourbon-cask aging complement the '
            'rabri\'s cream and the saffron\'s floral notes. The citrus finish cuts '
            'just enough richness to keep you coming back.',
        score: 82,
      ),
      DishPairing(
        productId: 'guinness-draught',
        strategy: PairingStrategy.contrast,
        broTip:
            'Guinness with Shahi Tukda is the wild card. The roasted-barley bitterness '
            'and dry finish contrast all that cream and sugar, while the stout\'s own '
            'creaminess matches the rabri texture. Trust the contrast.',
        score: 76,
      ),
    ],
  ),
];

