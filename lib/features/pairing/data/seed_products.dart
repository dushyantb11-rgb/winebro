import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/features/pairing/domain/product.dart';

/// Seed catalogue of real wines, whiskies, and beers available in India.
///
/// Every name, region, grape variety, ABV, and tasting note is factually
/// accurate. Flavour-axis scores are calibrated to each product's real
/// sensory profile.
const kSeedProducts = <Product>[
  // ───────────────────────────────────────────────────────────────────────
  //  INDIAN WINES (15)
  // ───────────────────────────────────────────────────────────────────────

  Product(
    id: 'sula-sauvignon-blanc',
    name: 'Sula Vineyards Sauvignon Blanc',
    category: DrinkCategory.whiteWine,
    subcategory: 'Sauvignon Blanc',
    region: 'Nashik, Maharashtra',
    price: 750,
    fruit: 6,
    acidity: 7,
    body: 3,
    tannin: 1,
    freshness: 8,
    complexity: 4,
    archetypeTags: [PalateArchetype.crispPurist],
    tastingNotes:
        'Crisp and refreshing with gooseberry, green apple, and a hint of '
        'cut grass. Clean citrus finish with bright acidity typical of '
        'Nashik terroir.',
    aromas: ['gooseberry', 'green apple', 'cut grass', 'lime zest'],
    abv: 12.5,
    grapeVariety: 'Sauvignon Blanc',
    origin:
        'From Sula Vineyards in Nashik, the pioneer of Indian winemaking '
        'founded by Rajeev Samant in 1999.',
  ),

  Product(
    id: 'sula-shiraz',
    name: 'Sula Vineyards Shiraz',
    category: DrinkCategory.redWine,
    subcategory: 'Shiraz',
    region: 'Nashik, Maharashtra',
    price: 800,
    fruit: 7,
    acidity: 5,
    body: 6,
    tannin: 6,
    freshness: 4,
    complexity: 5,
    archetypeTags: [PalateArchetype.fruitForward],
    tastingNotes:
        'Medium-bodied with ripe blackberry, plum, and a touch of black '
        'pepper. Soft tannins with a spicy, warm finish. Approachable and '
        'fruit-driven.',
    aromas: ['blackberry', 'plum', 'black pepper', 'vanilla'],
    abv: 13.0,
    grapeVariety: 'Shiraz',
    origin:
        'Sula\'s flagship red from their Nashik estate, one of the most '
        'widely consumed Indian red wines.',
  ),

  Product(
    id: 'grover-zampa-la-reserve',
    name: 'Grover Zampa La Réserve',
    category: DrinkCategory.redWine,
    subcategory: 'Cabernet Sauvignon-Shiraz Blend',
    region: 'Nandi Hills, Karnataka',
    price: 1200,
    fruit: 6,
    acidity: 5,
    body: 7,
    tannin: 7,
    freshness: 3,
    complexity: 7,
    archetypeTags: [PalateArchetype.boldExplorer],
    tastingNotes:
        'Full-bodied Bordeaux-style blend with blackcurrant, cedar, and '
        'tobacco. Structured tannins with a long, oaky finish. Crafted with '
        'guidance from French oenologist Michel Rolland.',
    aromas: ['blackcurrant', 'cedar', 'tobacco', 'dark chocolate'],
    abv: 13.5,
    grapeVariety: 'Cabernet Sauvignon, Shiraz',
    origin:
        'Grover Zampa\'s premium blend from Nandi Hills vineyards near '
        'Bangalore, developed with consultant Michel Rolland.',
  ),

  Product(
    id: 'grover-zampa-vijay-amritraj',
    name: 'Grover Zampa Vijay Amritraj Reserve Collection',
    category: DrinkCategory.redWine,
    subcategory: 'Cabernet Sauvignon-Shiraz Blend',
    region: 'Nandi Hills, Karnataka',
    price: 1500,
    fruit: 6,
    acidity: 5,
    body: 8,
    tannin: 7,
    freshness: 3,
    complexity: 8,
    archetypeTags: [PalateArchetype.boldExplorer],
    tastingNotes:
        'Rich and powerful with layers of cassis, dark plum, espresso, and '
        'mocha. Firm tannins balanced by ripe fruit concentration. Extended '
        'oak ageing adds vanilla and spice complexity.',
    aromas: ['cassis', 'dark plum', 'espresso', 'mocha', 'vanilla'],
    abv: 14.0,
    grapeVariety: 'Cabernet Sauvignon, Shiraz',
    origin:
        'A premium reserve collaboration between Grover Zampa and tennis '
        'legend Vijay Amritraj, sourced from the best Nandi Hills barrels.',
  ),

  Product(
    id: 'fratelli-sette',
    name: 'Fratelli Sette',
    category: DrinkCategory.redWine,
    subcategory: 'Sangiovese-Cabernet Sauvignon Blend',
    region: 'Akluj, Maharashtra',
    price: 1800,
    fruit: 6,
    acidity: 6,
    body: 8,
    tannin: 7,
    freshness: 3,
    complexity: 8,
    archetypeTags: [PalateArchetype.boldExplorer],
    tastingNotes:
        'A Super Tuscan-style blend with dark cherry, leather, and dried '
        'herbs. Well-integrated oak gives notes of vanilla and toast. Firm '
        'structure with excellent ageing potential.',
    aromas: ['dark cherry', 'leather', 'dried herbs', 'toast', 'vanilla'],
    abv: 14.0,
    grapeVariety: 'Sangiovese, Cabernet Sauvignon',
    origin:
        'Fratelli\'s flagship wine from Akluj, crafted by Italian winemaker '
        'Piero Masi, blending Italian and Indian terroir.',
  ),

  Product(
    id: 'fratelli-tilt-rose',
    name: 'Fratelli TILT Rosé',
    category: DrinkCategory.roseWine,
    subcategory: 'Rosé',
    region: 'Akluj, Maharashtra',
    price: 700,
    fruit: 7,
    acidity: 6,
    body: 3,
    tannin: 1,
    freshness: 8,
    complexity: 3,
    archetypeTags: [PalateArchetype.crispPurist, PalateArchetype.fruitForward],
    tastingNotes:
        'Light and vibrant rosé with fresh strawberry, watermelon, and a '
        'hint of rose petal. Dry finish with lively acidity. Perfect for '
        'warm weather sipping.',
    aromas: ['strawberry', 'watermelon', 'rose petal', 'citrus'],
    abv: 12.0,
    grapeVariety: 'Sangiovese',
    origin:
        'A fresh, easy-drinking rosé from Fratelli\'s Akluj estate, '
        'targeting India\'s growing rosé market.',
  ),

  Product(
    id: 'krsma-sangiovese',
    name: 'KRSMA Sangiovese',
    category: DrinkCategory.redWine,
    subcategory: 'Sangiovese',
    region: 'Hampi Hills, Karnataka',
    price: 2200,
    fruit: 6,
    acidity: 7,
    body: 6,
    tannin: 6,
    freshness: 4,
    complexity: 7,
    archetypeTags: [PalateArchetype.boldExplorer],
    tastingNotes:
        'Elegant Sangiovese with sour cherry, dried cranberry, and earthy '
        'undertones. Medium-plus body with bright acidity and fine-grained '
        'tannins. Notes of dried oregano and leather on the finish.',
    aromas: ['sour cherry', 'cranberry', 'oregano', 'leather', 'earth'],
    abv: 13.5,
    grapeVariety: 'Sangiovese',
    origin:
        'KRSMA Estates in the Hampi Hills grows Sangiovese at 2,000 feet '
        'elevation, producing one of India\'s finest Italian varietals.',
  ),

  Product(
    id: 'krsma-cabernet-sauvignon',
    name: 'KRSMA Cabernet Sauvignon',
    category: DrinkCategory.redWine,
    subcategory: 'Cabernet Sauvignon',
    region: 'Hampi Hills, Karnataka',
    price: 2500,
    fruit: 6,
    acidity: 5,
    body: 8,
    tannin: 8,
    freshness: 3,
    complexity: 8,
    archetypeTags: [PalateArchetype.boldExplorer],
    tastingNotes:
        'Intense and structured with blackcurrant, graphite, and cigar box. '
        'Powerful tannins with a long, mineral-driven finish. French oak '
        'ageing contributes cedar and spice.',
    aromas: ['blackcurrant', 'graphite', 'cigar box', 'cedar', 'mint'],
    abv: 14.0,
    grapeVariety: 'Cabernet Sauvignon',
    origin:
        'KRSMA\'s flagship Cabernet from granite-rich soils of the Hampi '
        'Hills, recognised internationally at Decanter awards.',
  ),

  Product(
    id: 'charosa-reserve-shiraz',
    name: 'Charosa Vineyards Reserve Shiraz',
    category: DrinkCategory.redWine,
    subcategory: 'Shiraz',
    region: 'Nashik, Maharashtra',
    price: 1600,
    fruit: 7,
    acidity: 5,
    body: 7,
    tannin: 6,
    freshness: 3,
    complexity: 7,
    archetypeTags: [PalateArchetype.boldExplorer, PalateArchetype.fruitForward],
    tastingNotes:
        'Rich and concentrated with ripe blueberry, dark plum, and cracked '
        'pepper. Oak maturation adds smoky vanilla and a hint of clove. '
        'Velvety tannins lead to a long, warm finish.',
    aromas: ['blueberry', 'dark plum', 'cracked pepper', 'clove', 'smoke'],
    abv: 14.0,
    grapeVariety: 'Shiraz',
    origin:
        'Charosa Vineyards in Nashik produce small-batch reserve wines with '
        'grapes from high-altitude plots in the Western Ghats.',
  ),

  Product(
    id: 'york-arros',
    name: 'York Arros',
    category: DrinkCategory.redWine,
    subcategory: 'Tempranillo-Shiraz Blend',
    region: 'Nashik, Maharashtra',
    price: 1400,
    fruit: 6,
    acidity: 5,
    body: 7,
    tannin: 6,
    freshness: 4,
    complexity: 6,
    archetypeTags: [PalateArchetype.balancedSipper],
    tastingNotes:
        'A well-structured blend with red cherry, raspberry, and subtle '
        'earthy notes. Medium tannins and gentle oak influence. Smooth and '
        'balanced with a hint of spice on the finish.',
    aromas: ['red cherry', 'raspberry', 'earth', 'oak spice'],
    abv: 13.5,
    grapeVariety: 'Tempranillo, Shiraz',
    origin:
        'York Winery\'s premium red from Nashik, blending Spanish '
        'Tempranillo with Shiraz for a uniquely Indian expression.',
  ),

  Product(
    id: 'big-banyan-merlot',
    name: 'Big Banyan Merlot',
    category: DrinkCategory.redWine,
    subcategory: 'Merlot',
    region: 'Karnataka',
    price: 650,
    fruit: 7,
    acidity: 4,
    body: 5,
    tannin: 4,
    freshness: 5,
    complexity: 4,
    archetypeTags: [PalateArchetype.fruitForward, PalateArchetype.balancedSipper],
    tastingNotes:
        'Soft and approachable with ripe plum, cherry, and a touch of '
        'chocolate. Gentle tannins and a smooth, medium-length finish. '
        'An easy-drinking everyday red.',
    aromas: ['plum', 'cherry', 'chocolate', 'herbs'],
    abv: 13.0,
    grapeVariety: 'Merlot',
    origin:
        'Big Banyan wines are produced from Karnataka-grown grapes, '
        'aimed at the everyday Indian wine drinker.',
  ),

  Product(
    id: 'soma-chenin-blanc',
    name: 'Soma Vine Village Chenin Blanc',
    category: DrinkCategory.whiteWine,
    subcategory: 'Chenin Blanc',
    region: 'Nashik, Maharashtra',
    price: 600,
    fruit: 7,
    acidity: 6,
    body: 3,
    tannin: 1,
    freshness: 7,
    complexity: 4,
    archetypeTags: [PalateArchetype.crispPurist, PalateArchetype.fruitForward],
    tastingNotes:
        'Bright and tropical with guava, pineapple, and honeydew melon. '
        'Balanced acidity gives it a crisp finish. Light-bodied and '
        'refreshing with floral hints.',
    aromas: ['guava', 'pineapple', 'honeydew', 'white flowers'],
    abv: 12.0,
    grapeVariety: 'Chenin Blanc',
    origin:
        'Soma Vine Village is a boutique winery in Nashik, specialising '
        'in Chenin Blanc, India\'s most widely planted white grape.',
  ),

  Product(
    id: 'four-seasons-barrique-shiraz',
    name: 'Four Seasons Barrique Reserve Shiraz',
    category: DrinkCategory.redWine,
    subcategory: 'Shiraz',
    region: 'Baramati, Maharashtra',
    price: 1000,
    fruit: 7,
    acidity: 5,
    body: 7,
    tannin: 6,
    freshness: 3,
    complexity: 6,
    archetypeTags: [PalateArchetype.fruitForward, PalateArchetype.boldExplorer],
    tastingNotes:
        'Full-bodied with concentrated blackberry, mulberry, and warm '
        'baking spices. French oak barrel ageing adds layers of vanilla, '
        'toast, and a hint of smokiness.',
    aromas: ['blackberry', 'mulberry', 'baking spices', 'vanilla', 'toast'],
    abv: 13.5,
    grapeVariety: 'Shiraz',
    origin:
        'Four Seasons Wines in Baramati, Pune district, is one of India\'s '
        'larger wineries, known for consistent barrel-aged reds.',
  ),

  Product(
    id: 'vallonne-merlot',
    name: 'Vallonné Vineyards Merlot',
    category: DrinkCategory.redWine,
    subcategory: 'Merlot',
    region: 'Nashik, Maharashtra',
    price: 900,
    fruit: 6,
    acidity: 5,
    body: 6,
    tannin: 5,
    freshness: 4,
    complexity: 5,
    archetypeTags: [PalateArchetype.balancedSipper],
    tastingNotes:
        'Medium-bodied with red plum, blackberry, and subtle herbal '
        'undertones. Smooth tannins and a well-rounded palate with a '
        'touch of oak-derived spice.',
    aromas: ['red plum', 'blackberry', 'herbs', 'light oak'],
    abv: 13.0,
    grapeVariety: 'Merlot',
    origin:
        'Vallonné Vineyards in Nashik produces small-batch wines with '
        'a focus on French grape varieties.',
  ),

  Product(
    id: 'sdu-madera-shiraz',
    name: 'SDU Madera Shiraz',
    category: DrinkCategory.redWine,
    subcategory: 'Shiraz',
    region: 'Karnataka',
    price: 550,
    fruit: 6,
    acidity: 5,
    body: 6,
    tannin: 5,
    freshness: 4,
    complexity: 4,
    archetypeTags: [PalateArchetype.balancedSipper],
    tastingNotes:
        'Medium-bodied with dark fruit, mild pepper, and a hint of '
        'earthiness. Soft tannins and a clean finish make it an '
        'accessible, everyday Indian Shiraz.',
    aromas: ['dark fruit', 'pepper', 'earth', 'mild oak'],
    abv: 13.0,
    grapeVariety: 'Shiraz',
    origin:
        'SDU Winery in Karnataka offers value-driven wines, with Madera '
        'being their approachable Shiraz range.',
  ),

  // ───────────────────────────────────────────────────────────────────────
  //  INTERNATIONAL WINES (15)
  // ───────────────────────────────────────────────────────────────────────

  Product(
    id: 'cloudy-bay-sauvignon-blanc',
    name: 'Cloudy Bay Sauvignon Blanc',
    category: DrinkCategory.whiteWine,
    subcategory: 'Sauvignon Blanc',
    region: 'Marlborough, New Zealand',
    price: 3500,
    fruit: 7,
    acidity: 8,
    body: 3,
    tannin: 1,
    freshness: 9,
    complexity: 6,
    archetypeTags: [PalateArchetype.crispPurist],
    tastingNotes:
        'Benchmark Marlborough Sauvignon Blanc with intense passionfruit, '
        'grapefruit, and fresh-cut herbs. Racy acidity with a long, '
        'mineral finish. Vivid and electrifying.',
    aromas: ['passionfruit', 'grapefruit', 'fresh herbs', 'flint'],
    abv: 13.5,
    grapeVariety: 'Sauvignon Blanc',
    origin:
        'Cloudy Bay, established in 1985 in Marlborough, helped define '
        'New Zealand Sauvignon Blanc as a world-class style.',
  ),

  Product(
    id: 'penfolds-bin-389',
    name: 'Penfolds Bin 389 Cabernet Shiraz',
    category: DrinkCategory.redWine,
    subcategory: 'Cabernet Sauvignon-Shiraz Blend',
    region: 'South Australia',
    price: 8500,
    fruit: 7,
    acidity: 5,
    body: 8,
    tannin: 8,
    freshness: 3,
    complexity: 9,
    archetypeTags: [PalateArchetype.boldExplorer],
    tastingNotes:
        'Known as "Baby Grange", this rich blend offers blackcurrant, '
        'dark chocolate, and cigar box aromatics. Dense, chewy tannins '
        'with layers of mulberry, espresso, and American oak spice.',
    aromas: ['blackcurrant', 'dark chocolate', 'cigar box', 'espresso'],
    abv: 14.5,
    grapeVariety: 'Cabernet Sauvignon, Shiraz',
    origin:
        'Penfolds\' iconic Bin 389 is matured in the same barrels used '
        'for Grange, first produced by Max Schubert in 1960.',
  ),

  Product(
    id: 'antinori-tignanello',
    name: 'Antinori Tignanello',
    category: DrinkCategory.redWine,
    subcategory: 'Sangiovese-Cabernet Sauvignon Blend',
    region: 'Tuscany, Italy',
    price: 12000,
    fruit: 7,
    acidity: 6,
    body: 8,
    tannin: 7,
    freshness: 3,
    complexity: 9,
    archetypeTags: [PalateArchetype.boldExplorer],
    tastingNotes:
        'The original Super Tuscan: dark cherry, plum, and violet with '
        'layers of leather, tobacco, and balsamic. Silky tannins, superb '
        'structure, and a very long, complex finish.',
    aromas: ['dark cherry', 'plum', 'violet', 'leather', 'tobacco'],
    abv: 13.5,
    grapeVariety: 'Sangiovese, Cabernet Sauvignon, Cabernet Franc',
    origin:
        'Created by Marchesi Antinori in 1971, Tignanello was the first '
        'Sangiovese aged in barriques, pioneering the Super Tuscan category.',
  ),

  Product(
    id: 'marques-de-riscal-reserva',
    name: 'Marqués de Riscal Reserva',
    category: DrinkCategory.redWine,
    subcategory: 'Tempranillo',
    region: 'Rioja, Spain',
    price: 3800,
    fruit: 6,
    acidity: 6,
    body: 7,
    tannin: 6,
    freshness: 4,
    complexity: 7,
    archetypeTags: [PalateArchetype.boldExplorer],
    tastingNotes:
        'Classic Rioja Reserva with ripe cherry, dried fig, and warm '
        'spice. American oak ageing adds vanilla and coconut notes. '
        'Well-integrated tannins with a long, savoury finish.',
    aromas: ['cherry', 'dried fig', 'vanilla', 'coconut', 'leather'],
    abv: 14.0,
    grapeVariety: 'Tempranillo, Graciano, Mazuelo',
    origin:
        'Founded in 1858, Marqués de Riscal is one of the oldest '
        'wineries in Rioja and a benchmark for the region.',
  ),

  Product(
    id: 'kim-crawford-sauvignon-blanc',
    name: 'Kim Crawford Sauvignon Blanc',
    category: DrinkCategory.whiteWine,
    subcategory: 'Sauvignon Blanc',
    region: 'Marlborough, New Zealand',
    price: 2800,
    fruit: 7,
    acidity: 8,
    body: 3,
    tannin: 1,
    freshness: 8,
    complexity: 5,
    archetypeTags: [PalateArchetype.crispPurist],
    tastingNotes:
        'Vibrant and aromatic with tropical passionfruit, citrus, and '
        'herbaceous notes. Zesty acidity and a clean, lingering finish. '
        'Consistently one of the best-selling NZ Sauvignon Blancs worldwide.',
    aromas: ['passionfruit', 'citrus', 'green pepper', 'herb'],
    abv: 13.0,
    grapeVariety: 'Sauvignon Blanc',
    origin:
        'Founded by Kim Crawford in 1996, now one of New Zealand\'s most '
        'recognised wine brands globally.',
  ),

  Product(
    id: 'catena-zapata-malbec',
    name: 'Catena Zapata Malbec',
    category: DrinkCategory.redWine,
    subcategory: 'Malbec',
    region: 'Mendoza, Argentina',
    price: 4500,
    fruit: 8,
    acidity: 5,
    body: 8,
    tannin: 7,
    freshness: 3,
    complexity: 8,
    archetypeTags: [PalateArchetype.boldExplorer, PalateArchetype.fruitForward],
    tastingNotes:
        'Deep and concentrated with ripe blackberry, plum, and violet. '
        'Rich layers of dark chocolate, coffee, and sweet spice from '
        'oak. Plush tannins with a velvety, lingering finish.',
    aromas: ['blackberry', 'plum', 'violet', 'dark chocolate', 'coffee'],
    abv: 13.5,
    grapeVariety: 'Malbec',
    origin:
        'Catena Zapata pioneered high-altitude Malbec in Mendoza, with '
        'vineyards reaching over 1,500 metres in the Andes foothills.',
  ),

  Product(
    id: 'louis-jadot-beaujolais-villages',
    name: 'Louis Jadot Beaujolais-Villages',
    category: DrinkCategory.redWine,
    subcategory: 'Gamay',
    region: 'Beaujolais, France',
    price: 2500,
    fruit: 7,
    acidity: 6,
    body: 4,
    tannin: 3,
    freshness: 7,
    complexity: 4,
    archetypeTags: [PalateArchetype.fruitForward],
    tastingNotes:
        'Light and juicy with bright red cherry, raspberry, and a hint '
        'of banana from carbonic maceration. Soft tannins, vibrant '
        'acidity, and a fresh, easy-drinking finish.',
    aromas: ['red cherry', 'raspberry', 'banana', 'peony'],
    abv: 13.0,
    grapeVariety: 'Gamay',
    origin:
        'Maison Louis Jadot, founded in 1859 in Burgundy, is one of '
        'France\'s most respected négociants.',
  ),

  Product(
    id: 'oyster-bay-pinot-noir',
    name: 'Oyster Bay Pinot Noir',
    category: DrinkCategory.redWine,
    subcategory: 'Pinot Noir',
    region: 'Marlborough, New Zealand',
    price: 3200,
    fruit: 7,
    acidity: 6,
    body: 4,
    tannin: 3,
    freshness: 7,
    complexity: 5,
    archetypeTags: [PalateArchetype.fruitForward],
    tastingNotes:
        'Elegant and silky with ripe cherry, strawberry, and a hint of '
        'wild thyme. Subtle oak adds a gentle spice. Light tannins with '
        'a smooth, lingering finish.',
    aromas: ['cherry', 'strawberry', 'thyme', 'subtle oak'],
    abv: 13.5,
    grapeVariety: 'Pinot Noir',
    origin:
        'Oyster Bay, founded in 1990, is Marlborough\'s largest privately '
        'owned wine company.',
  ),

  Product(
    id: 'torres-vina-sol',
    name: 'Torres Viña Sol',
    category: DrinkCategory.whiteWine,
    subcategory: 'Parellada',
    region: 'Catalonia, Spain',
    price: 1500,
    fruit: 6,
    acidity: 6,
    body: 3,
    tannin: 1,
    freshness: 7,
    complexity: 4,
    archetypeTags: [PalateArchetype.crispPurist],
    tastingNotes:
        'Light and fresh with green apple, white peach, and delicate '
        'floral notes. Clean acidity and a crisp, dry finish. A '
        'versatile, food-friendly white.',
    aromas: ['green apple', 'white peach', 'white flowers', 'citrus'],
    abv: 11.5,
    grapeVariety: 'Parellada',
    origin:
        'Torres has been producing wine in Catalonia since 1870, and '
        'Viña Sol has been their flagship white since 1962.',
  ),

  Product(
    id: 'jacobs-creek-double-barrel-shiraz',
    name: "Jacob's Creek Double Barrel Shiraz",
    category: DrinkCategory.redWine,
    subcategory: 'Shiraz',
    region: 'South Australia',
    price: 2200,
    fruit: 7,
    acidity: 4,
    body: 7,
    tannin: 6,
    freshness: 3,
    complexity: 7,
    archetypeTags: [PalateArchetype.boldExplorer, PalateArchetype.fruitForward],
    tastingNotes:
        'Matured first in French oak, then finished in Irish whiskey '
        'barrels. Rich blackberry and plum with layers of toffee, '
        'whiskey-caramel, and toasted oak. Round, full-bodied finish.',
    aromas: ['blackberry', 'plum', 'toffee', 'caramel', 'whiskey oak'],
    abv: 14.5,
    grapeVariety: 'Shiraz',
    origin:
        'Jacob\'s Creek, founded in 1847 in the Barossa Valley, created '
        'this innovative double-barrel-aged range.',
  ),

  Product(
    id: 'ruffino-chianti-classico',
    name: 'Ruffino Chianti Classico',
    category: DrinkCategory.redWine,
    subcategory: 'Sangiovese',
    region: 'Tuscany, Italy',
    price: 2800,
    fruit: 6,
    acidity: 7,
    body: 6,
    tannin: 6,
    freshness: 5,
    complexity: 6,
    archetypeTags: [PalateArchetype.balancedSipper],
    tastingNotes:
        'Classic Chianti with sour cherry, red plum, and dried violet. '
        'Firm acidity and grippy tannins balanced by earthy, savoury '
        'notes. Dried herb and a touch of leather on the finish.',
    aromas: ['sour cherry', 'red plum', 'violet', 'dried herbs', 'leather'],
    abv: 13.0,
    grapeVariety: 'Sangiovese',
    origin:
        'Ruffino, founded in 1877, is one of the most iconic Chianti '
        'Classico producers in Tuscany.',
  ),

  Product(
    id: 'moet-chandon-imperial',
    name: 'Moët & Chandon Impérial',
    category: DrinkCategory.sparklingWine,
    subcategory: 'Champagne',
    region: 'Champagne, France',
    price: 5500,
    fruit: 6,
    acidity: 7,
    body: 4,
    tannin: 1,
    freshness: 8,
    complexity: 7,
    archetypeTags: [PalateArchetype.crispPurist],
    tastingNotes:
        'Fine, persistent mousse with green apple, white peach, and '
        'brioche. Elegant acidity with notes of toasted almond and '
        'citrus zest. Crisp, celebratory, and refined.',
    aromas: ['green apple', 'white peach', 'brioche', 'toasted almond'],
    abv: 12.0,
    grapeVariety: 'Pinot Noir, Chardonnay, Pinot Meunier',
    origin:
        'Founded in 1743, Moët & Chandon is the world\'s largest '
        'Champagne house, with vineyards spanning over 1,200 hectares.',
  ),

  Product(
    id: 'santa-margherita-pinot-grigio',
    name: 'Santa Margherita Pinot Grigio',
    category: DrinkCategory.whiteWine,
    subcategory: 'Pinot Grigio',
    region: 'Alto Adige, Italy',
    price: 3200,
    fruit: 6,
    acidity: 7,
    body: 3,
    tannin: 1,
    freshness: 8,
    complexity: 5,
    archetypeTags: [PalateArchetype.crispPurist],
    tastingNotes:
        'Dry and elegant with golden apple, citrus, and a touch of white '
        'almond. Clean minerality and vibrant acidity. The wine that '
        'popularised Pinot Grigio worldwide.',
    aromas: ['golden apple', 'citrus', 'white almond', 'mineral'],
    abv: 12.5,
    grapeVariety: 'Pinot Grigio',
    origin:
        'Santa Margherita pioneered single-varietal Pinot Grigio in 1961 '
        'from the cool-climate Alto Adige region.',
  ),

  Product(
    id: 'robert-mondavi-cabernet-sauvignon',
    name: 'Robert Mondavi Cabernet Sauvignon',
    category: DrinkCategory.redWine,
    subcategory: 'Cabernet Sauvignon',
    region: 'Napa Valley, California',
    price: 5500,
    fruit: 8,
    acidity: 5,
    body: 8,
    tannin: 7,
    freshness: 3,
    complexity: 8,
    archetypeTags: [PalateArchetype.boldExplorer, PalateArchetype.fruitForward],
    tastingNotes:
        'Opulent Napa Cabernet with ripe blackcurrant, black cherry, and '
        'cassis. Rich layers of vanilla, mocha, and cedar from French '
        'oak. Firm but polished tannins with a long, plush finish.',
    aromas: ['blackcurrant', 'black cherry', 'vanilla', 'mocha', 'cedar'],
    abv: 14.5,
    grapeVariety: 'Cabernet Sauvignon',
    origin:
        'Robert Mondavi Winery, established in 1966, was pivotal in '
        'putting Napa Valley on the world wine map.',
  ),

  Product(
    id: 'chateau-leoville-barton',
    name: 'Château Léoville-Barton',
    category: DrinkCategory.redWine,
    subcategory: 'Cabernet Sauvignon-Merlot Blend',
    region: 'Saint-Julien, Bordeaux',
    price: 15000,
    fruit: 6,
    acidity: 6,
    body: 8,
    tannin: 8,
    freshness: 3,
    complexity: 9,
    archetypeTags: [PalateArchetype.boldExplorer],
    tastingNotes:
        'A Second Growth Bordeaux of great pedigree. Blackcurrant, '
        'graphite, and cedar with undertones of cigar box and dark '
        'earth. Powerful, structured tannins that demand cellaring. '
        'Extraordinarily long finish.',
    aromas: ['blackcurrant', 'graphite', 'cedar', 'cigar box', 'dark earth'],
    abv: 13.0,
    grapeVariety: 'Cabernet Sauvignon, Merlot, Cabernet Franc',
    origin:
        'A Second Growth (Deuxième Cru) in the 1855 Classification, '
        'Léoville-Barton has been run by the Barton family since 1826.',
  ),

  // ───────────────────────────────────────────────────────────────────────
  //  WHISKIES (10)
  // ───────────────────────────────────────────────────────────────────────

  Product(
    id: 'amrut-fusion',
    name: 'Amrut Fusion',
    category: DrinkCategory.whisky,
    subcategory: 'Single Malt',
    region: 'Bangalore, India',
    price: 5500,
    fruit: 5,
    acidity: 3,
    body: 7,
    tannin: 4,
    freshness: 3,
    complexity: 8,
    archetypeTags: [PalateArchetype.boldExplorer],
    tastingNotes:
        'A groundbreaking Indian single malt blending Indian and '
        'Scottish barley. Rich barley sweetness, dark chocolate, and '
        'dried fruit with a distinct peaty undertone. Warm, complex '
        'finish with notes of sherry and oak.',
    aromas: ['barley', 'dark chocolate', 'dried fruit', 'peat', 'sherry'],
    abv: 50.0,
    grapeVariety: 'Single Malt (Indian & Peated Scottish Barley)',
    origin:
        'Amrut Distilleries in Bangalore produced India\'s first single '
        'malt whisky, with Fusion earning 97 points from Jim Murray.',
  ),

  Product(
    id: 'paul-john-brilliance',
    name: 'Paul John Brilliance',
    category: DrinkCategory.whisky,
    subcategory: 'Single Malt',
    region: 'Goa, India',
    price: 4500,
    fruit: 6,
    acidity: 3,
    body: 6,
    tannin: 3,
    freshness: 4,
    complexity: 7,
    archetypeTags: [PalateArchetype.balancedSipper],
    tastingNotes:
        'Smooth and honeyed with creamy vanilla, ripe banana, and '
        'tropical fruit. Gentle spice and a mellow, lingering finish. '
        'Non-peated expression showcasing Goan coastal maturation.',
    aromas: ['honey', 'vanilla', 'banana', 'tropical fruit', 'light spice'],
    abv: 46.0,
    grapeVariety: 'Single Malt (Indian Barley)',
    origin:
        'Paul John Distillery in Goa matures its whisky in the tropical '
        'climate, accelerating the angel\'s share and deepening flavour.',
  ),

  Product(
    id: 'rampur-select',
    name: 'Rampur Select',
    category: DrinkCategory.whisky,
    subcategory: 'Single Malt',
    region: 'Uttar Pradesh, India',
    price: 3800,
    fruit: 5,
    acidity: 3,
    body: 6,
    tannin: 4,
    freshness: 4,
    complexity: 6,
    archetypeTags: [PalateArchetype.balancedSipper],
    tastingNotes:
        'Elegant and refined with apricot, vanilla, and toffee. Gentle '
        'oak influence with hints of cinnamon and nutmeg. Smooth, '
        'medium-bodied palate with a warm, clean finish.',
    aromas: ['apricot', 'vanilla', 'toffee', 'cinnamon', 'nutmeg'],
    abv: 43.0,
    grapeVariety: 'Single Malt (Indian Barley)',
    origin:
        'Rampur Distillery in Uttar Pradesh has been distilling since '
        '1943 and released its first single malt in 2016.',
  ),

  Product(
    id: 'glenfiddich-12',
    name: 'Glenfiddich 12 Year Old',
    category: DrinkCategory.whisky,
    subcategory: 'Single Malt',
    region: 'Speyside, Scotland',
    price: 3500,
    fruit: 6,
    acidity: 3,
    body: 5,
    tannin: 3,
    freshness: 5,
    complexity: 6,
    archetypeTags: [PalateArchetype.balancedSipper],
    tastingNotes:
        'The world\'s most popular single malt with fresh pear, '
        'butterscotch, and subtle oak. Creamy mouthfeel with malt '
        'sweetness and a clean, smooth finish.',
    aromas: ['pear', 'butterscotch', 'oak', 'malt', 'cream'],
    abv: 40.0,
    grapeVariety: 'Single Malt (Malted Barley)',
    origin:
        'Glenfiddich, meaning "Valley of the Deer", was founded in 1887 '
        'by William Grant in Dufftown, Speyside.',
  ),

  Product(
    id: 'lagavulin-16',
    name: 'Lagavulin 16 Year Old',
    category: DrinkCategory.whisky,
    subcategory: 'Single Malt',
    region: 'Islay, Scotland',
    price: 8500,
    fruit: 3,
    acidity: 3,
    body: 8,
    tannin: 5,
    freshness: 3,
    complexity: 9,
    archetypeTags: [PalateArchetype.boldExplorer],
    tastingNotes:
        'Intensely peaty and smoky with iodine, seaweed, and smoked '
        'meat. Underneath the smoke lies rich dried fruit, dark '
        'chocolate, and maritime salt. Extraordinarily long, warming '
        'finish with campfire embers.',
    aromas: ['peat smoke', 'iodine', 'seaweed', 'dried fruit', 'dark chocolate'],
    abv: 43.0,
    grapeVariety: 'Single Malt (Peated Malted Barley)',
    origin:
        'Lagavulin distillery, established in 1816 on Islay\'s southern '
        'coast, is renowned for producing the most richly flavoured '
        'Islay malt.',
  ),

  Product(
    id: 'talisker-10',
    name: 'Talisker 10 Year Old',
    category: DrinkCategory.whisky,
    subcategory: 'Single Malt',
    region: 'Isle of Skye, Scotland',
    price: 5500,
    fruit: 4,
    acidity: 3,
    body: 7,
    tannin: 4,
    freshness: 4,
    complexity: 8,
    archetypeTags: [PalateArchetype.boldExplorer],
    tastingNotes:
        'Maritime and peppery with sea salt, smoked barley, and a '
        'signature black pepper kick. Dried fruit sweetness balances '
        'the smoke. Warm, lingering finish with volcanic minerality.',
    aromas: ['sea salt', 'black pepper', 'smoke', 'dried fruit', 'seaweed'],
    abv: 45.8,
    grapeVariety: 'Single Malt (Peated Malted Barley)',
    origin:
        'The only distillery on the Isle of Skye, Talisker has been '
        'producing whisky since 1830, known as "the lava of the Cuillins".',
  ),

  Product(
    id: 'glenmorangie-original',
    name: 'Glenmorangie Original',
    category: DrinkCategory.whisky,
    subcategory: 'Single Malt',
    region: 'Highland, Scotland',
    price: 3800,
    fruit: 6,
    acidity: 3,
    body: 5,
    tannin: 3,
    freshness: 5,
    complexity: 6,
    archetypeTags: [PalateArchetype.balancedSipper],
    tastingNotes:
        'Delicate and elegant with vanilla, honeyed peach, and citrus. '
        'Floral notes and gentle spice from ten years in American oak '
        'bourbon casks. Smooth, mellow, and perfectly balanced.',
    aromas: ['vanilla', 'peach', 'citrus', 'floral', 'gentle spice'],
    abv: 40.0,
    grapeVariety: 'Single Malt (Malted Barley)',
    origin:
        'Glenmorangie in Tain, Ross-shire, uses Scotland\'s tallest '
        'stills (5.14m) to produce an exceptionally smooth spirit.',
  ),

  Product(
    id: 'jameson-irish-whiskey',
    name: 'Jameson Irish Whiskey',
    category: DrinkCategory.whisky,
    subcategory: 'Blended Whiskey',
    region: 'Ireland',
    price: 2200,
    fruit: 5,
    acidity: 3,
    body: 4,
    tannin: 2,
    freshness: 5,
    complexity: 4,
    archetypeTags: [PalateArchetype.balancedSipper],
    tastingNotes:
        'Triple-distilled for exceptional smoothness with light floral '
        'notes, green apple, and vanilla. Toasted wood and mild sherry '
        'sweetness. Clean, approachable, and versatile.',
    aromas: ['green apple', 'vanilla', 'floral', 'toasted wood', 'light sherry'],
    abv: 40.0,
    grapeVariety: 'Blended (Malted & Unmalted Barley, Grain)',
    origin:
        'John Jameson founded his distillery in Dublin in 1780. Now '
        'the world\'s best-selling Irish whiskey.',
  ),

  Product(
    id: 'jim-beam-bourbon',
    name: 'Jim Beam Bourbon',
    category: DrinkCategory.whisky,
    subcategory: 'Bourbon',
    region: 'Kentucky, USA',
    price: 1800,
    fruit: 5,
    acidity: 3,
    body: 5,
    tannin: 4,
    freshness: 4,
    complexity: 4,
    archetypeTags: [PalateArchetype.balancedSipper],
    tastingNotes:
        'Classic bourbon with caramel, vanilla, and toasted oak. '
        'Medium-bodied with a warm corn sweetness and a touch of '
        'cinnamon spice. Clean, straightforward finish.',
    aromas: ['caramel', 'vanilla', 'toasted oak', 'corn', 'cinnamon'],
    abv: 40.0,
    grapeVariety: 'Bourbon (Corn, Rye, Malted Barley)',
    origin:
        'The Beam family has been making bourbon in Kentucky since 1795, '
        'spanning eight generations of distillers.',
  ),

  Product(
    id: 'monkey-shoulder',
    name: 'Monkey Shoulder',
    category: DrinkCategory.whisky,
    subcategory: 'Blended Malt',
    region: 'Speyside, Scotland',
    price: 3000,
    fruit: 6,
    acidity: 3,
    body: 5,
    tannin: 3,
    freshness: 5,
    complexity: 5,
    archetypeTags: [PalateArchetype.balancedSipper],
    tastingNotes:
        'A triple malt blend of Glenfiddich, Balvenie, and Kininvie. '
        'Smooth and creamy with vanilla, honey, and baked orange. '
        'Light spice and a malty, easy-going finish.',
    aromas: ['vanilla', 'honey', 'orange', 'malt', 'light spice'],
    abv: 40.0,
    grapeVariety: 'Blended Malt (Three Speyside Malts)',
    origin:
        'Named after the shoulder strain maltmen got from turning barley '
        'by hand, created by William Grant & Sons.',
  ),

  // ───────────────────────────────────────────────────────────────────────
  //  BEERS (10)
  // ───────────────────────────────────────────────────────────────────────

  Product(
    id: 'bira-91-white',
    name: 'Bira 91 White',
    category: DrinkCategory.craftBeer,
    subcategory: 'Wheat Beer',
    region: 'India',
    price: 200,
    fruit: 6,
    acidity: 4,
    body: 3,
    tannin: 1,
    freshness: 7,
    complexity: 3,
    archetypeTags: [PalateArchetype.crispPurist],
    tastingNotes:
        'A light, unfiltered wheat ale with orange peel, coriander, and '
        'subtle banana. Low bitterness with a smooth, creamy mouthfeel. '
        'Refreshing and sessionable.',
    aromas: ['orange peel', 'coriander', 'banana', 'wheat'],
    abv: 4.7,
    grapeVariety: 'Wheat Ale',
    origin:
        'Bira 91, founded in 2015 by Ankur Jain, became India\'s '
        'fastest-growing craft beer brand.',
  ),

  Product(
    id: 'bira-91-blonde',
    name: 'Bira 91 Blonde',
    category: DrinkCategory.craftBeer,
    subcategory: 'Lager',
    region: 'India',
    price: 200,
    fruit: 4,
    acidity: 4,
    body: 3,
    tannin: 1,
    freshness: 7,
    complexity: 3,
    archetypeTags: [PalateArchetype.crispPurist],
    tastingNotes:
        'A crisp, clean lager with subtle malt sweetness, light citrus '
        'hops, and a dry finish. Easy-drinking with a pleasant '
        'bitterness and high drinkability.',
    aromas: ['light malt', 'citrus hops', 'bread crust'],
    abv: 4.5,
    grapeVariety: 'Lager',
    origin:
        'Bira 91 Blonde is the brand\'s flagship lager, brewed to be '
        'a refreshing alternative to mainstream Indian lagers.',
  ),

  Product(
    id: 'simba-stout',
    name: 'Simba Stout',
    category: DrinkCategory.craftBeer,
    subcategory: 'Stout',
    region: 'India',
    price: 220,
    fruit: 3,
    acidity: 3,
    body: 7,
    tannin: 4,
    freshness: 3,
    complexity: 6,
    archetypeTags: [PalateArchetype.boldExplorer],
    tastingNotes:
        'A rich, dark stout with roasted coffee, dark chocolate, and '
        'caramel malt. Full-bodied with a creamy head and a bitter '
        'chocolate finish. Bold for the Indian craft scene.',
    aromas: ['roasted coffee', 'dark chocolate', 'caramel', 'roasted malt'],
    abv: 5.0,
    grapeVariety: 'Stout',
    origin:
        'Simba Craft Beers launched in 2016, pushing India\'s craft '
        'beer boundaries with styles like stout and wit.',
  ),

  Product(
    id: 'white-owl-spark',
    name: 'White Owl Spark',
    category: DrinkCategory.craftBeer,
    subcategory: 'Wheat Beer',
    region: 'India',
    price: 200,
    fruit: 5,
    acidity: 4,
    body: 3,
    tannin: 1,
    freshness: 7,
    complexity: 3,
    archetypeTags: [PalateArchetype.crispPurist],
    tastingNotes:
        'A Belgian-style witbier with orange peel, coriander, and a '
        'touch of lemon. Hazy, light-bodied, and effervescent with '
        'low bitterness and a clean finish.',
    aromas: ['orange peel', 'coriander', 'lemon', 'yeast'],
    abv: 4.5,
    grapeVariety: 'Wheat Beer',
    origin:
        'White Owl Brewery, founded in Mumbai in 2014, is one of '
        'India\'s pioneering microbreweries.',
  ),

  Product(
    id: 'kingfisher-ultra',
    name: 'Kingfisher Ultra',
    category: DrinkCategory.beer,
    subcategory: 'Lager',
    region: 'India',
    price: 160,
    fruit: 3,
    acidity: 3,
    body: 3,
    tannin: 1,
    freshness: 6,
    complexity: 2,
    archetypeTags: [PalateArchetype.crispPurist],
    tastingNotes:
        'A clean, light-bodied premium lager with mild malt sweetness '
        'and subtle hop bitterness. Highly carbonated and refreshing '
        'with a crisp, dry finish.',
    aromas: ['light malt', 'mild hops', 'grain'],
    abv: 5.0,
    grapeVariety: 'Lager',
    origin:
        'Kingfisher, brewed by United Breweries (now part of Heineken), '
        'is India\'s most iconic beer brand, launched in 1978.',
  ),

  Product(
    id: 'hoegaarden',
    name: 'Hoegaarden',
    category: DrinkCategory.beer,
    subcategory: 'Wheat Beer',
    region: 'Belgium',
    price: 250,
    fruit: 5,
    acidity: 4,
    body: 3,
    tannin: 1,
    freshness: 8,
    complexity: 4,
    archetypeTags: [PalateArchetype.crispPurist],
    tastingNotes:
        'The original Belgian witbier with orange peel, coriander, and '
        'a hint of chamomile. Hazy, unfiltered, with a smooth, creamy '
        'texture and a refreshingly tart finish.',
    aromas: ['orange peel', 'coriander', 'chamomile', 'wheat'],
    abv: 4.9,
    grapeVariety: 'Wheat Beer',
    origin:
        'Hoegaarden revived the Belgian witbier style in 1966, brewed '
        'in the town of Hoegaarden since the 15th century.',
  ),

  Product(
    id: 'guinness-draught',
    name: 'Guinness Draught',
    category: DrinkCategory.beer,
    subcategory: 'Dry Stout',
    region: 'Ireland',
    price: 300,
    fruit: 2,
    acidity: 4,
    body: 6,
    tannin: 3,
    freshness: 4,
    complexity: 6,
    archetypeTags: [PalateArchetype.boldExplorer],
    tastingNotes:
        'Iconic dry stout with roasted barley, coffee, and dark '
        'chocolate. Silky smooth from the nitrogen-infused pour. '
        'Surprisingly light body for a stout with a dry, bitter finish.',
    aromas: ['roasted barley', 'coffee', 'dark chocolate', 'caramel'],
    abv: 4.2,
    grapeVariety: 'Dry Stout',
    origin:
        'Arthur Guinness signed a 9,000-year lease at St. James\'s Gate, '
        'Dublin in 1759. Now the world\'s most famous stout.',
  ),

  Product(
    id: 'chimay-blue',
    name: 'Chimay Blue',
    category: DrinkCategory.craftBeer,
    subcategory: 'Belgian Strong Dark Ale',
    region: 'Belgium',
    price: 550,
    fruit: 6,
    acidity: 4,
    body: 7,
    tannin: 3,
    freshness: 3,
    complexity: 8,
    archetypeTags: [PalateArchetype.boldExplorer],
    tastingNotes:
        'A Trappist masterpiece with dark fruit, caramel, and toasted '
        'bread. Rich, full-bodied with notes of fig, raisin, and '
        'Belgian candi sugar. Complex finish with warming alcohol.',
    aromas: ['dark fruit', 'caramel', 'fig', 'raisin', 'toasted bread'],
    abv: 9.0,
    grapeVariety: 'Belgian Strong Dark Ale',
    origin:
        'Brewed by Trappist monks at Scourmont Abbey since 1862, '
        'Chimay Blue (Grand Réserve) is their strongest and most complex.',
  ),

  Product(
    id: 'sierra-nevada-pale-ale',
    name: 'Sierra Nevada Pale Ale',
    category: DrinkCategory.craftBeer,
    subcategory: 'Pale Ale',
    region: 'USA',
    price: 350,
    fruit: 5,
    acidity: 4,
    body: 5,
    tannin: 2,
    freshness: 6,
    complexity: 5,
    archetypeTags: [PalateArchetype.balancedSipper],
    tastingNotes:
        'A craft beer icon with Cascade hop-driven pine, grapefruit, '
        'and floral notes balanced by toasty malt. Medium-bodied with '
        'a clean, assertive bitterness and a refreshing finish.',
    aromas: ['pine', 'grapefruit', 'floral hops', 'toasty malt'],
    abv: 5.6,
    grapeVariety: 'Pale Ale',
    origin:
        'Sierra Nevada Brewing Co., founded by Ken Grossman in 1980 in '
        'Chico, California, helped launch the American craft beer revolution.',
  ),

  Product(
    id: 'paulaner-hefeweizen',
    name: 'Paulaner Hefeweizen',
    category: DrinkCategory.beer,
    subcategory: 'Hefeweizen',
    region: 'Germany',
    price: 350,
    fruit: 6,
    acidity: 4,
    body: 4,
    tannin: 1,
    freshness: 7,
    complexity: 4,
    archetypeTags: [PalateArchetype.fruitForward],
    tastingNotes:
        'A classic Bavarian wheat beer with banana, clove, and bubblegum '
        'from the yeast. Unfiltered and hazy with a creamy, full '
        'mouthfeel. Refreshing with a soft, bready finish.',
    aromas: ['banana', 'clove', 'bubblegum', 'bread', 'wheat'],
    abv: 5.5,
    grapeVariety: 'Hefeweizen',
    origin:
        'Paulaner Brewery, founded in 1634 by Minim friars in Munich, '
        'is one of the six breweries permitted to serve at Oktoberfest.',
  ),

  // ───────────────────────────────────────────────────────────────────────
  //  S8.2 — BRAND EXPANSION (5 new Indian SKUs)
  //
  //  Closes the "feels alien to my region" gap flagged in the
  //  marketing audit. Adds value-tier and iconic-mass-market entries
  //  the original seed missed.
  // ───────────────────────────────────────────────────────────────────────

  Product(
    id: 'big-banyan-shiraz',
    name: 'Big Banyan Shiraz',
    category: DrinkCategory.redWine,
    subcategory: 'Shiraz',
    region: 'Bangalore, Karnataka',
    price: 600,
    fruit: 7,
    acidity: 5,
    body: 5,
    tannin: 5,
    freshness: 4,
    complexity: 4,
    archetypeTags: [PalateArchetype.fruitForward],
    tastingNotes:
        'Soft and approachable with ripe plum, dark cherry, and a touch '
        'of pepper. Smooth tannins, easy weeknight red. Friendly with '
        'biryani, butter chicken, and Indo-Chinese.',
    aromas: ['plum', 'cherry', 'black pepper', 'vanilla'],
    abv: 12.5,
    grapeVariety: 'Shiraz',
    origin:
        'Big Banyan Wines from Karnataka, marketed by John Distilleries '
        'as approachable everyday wine for the Indian table.',
  ),

  Product(
    id: 'reveilo-cabernet-sauvignon',
    name: 'Reveilo Cabernet Sauvignon',
    category: DrinkCategory.redWine,
    subcategory: 'Cabernet Sauvignon',
    region: 'Nashik, Maharashtra',
    price: 950,
    fruit: 6,
    acidity: 6,
    body: 6,
    tannin: 7,
    freshness: 4,
    complexity: 6,
    archetypeTags: [PalateArchetype.boldExplorer],
    tastingNotes:
        'Structured Cabernet with blackcurrant, cedar, and a graphite '
        'streak. Firm tannins, gentle oak. Pairs assertively with '
        'kebabs, Rogan Josh, and grilled red meat.',
    aromas: ['blackcurrant', 'cedar', 'graphite', 'tobacco'],
    abv: 13.5,
    grapeVariety: 'Cabernet Sauvignon',
    origin:
        'Reveilo Wines (formerly Vintage Wines), Nashik. Italian '
        'winemaker collaboration, focus on Mediterranean varietals.',
  ),

  Product(
    id: 'winery52-red',
    name: 'Winery 52 Reserve Red',
    category: DrinkCategory.redWine,
    subcategory: 'Red Blend',
    region: 'Pune, Maharashtra',
    price: 850,
    fruit: 6,
    acidity: 5,
    body: 6,
    tannin: 5,
    freshness: 4,
    complexity: 5,
    archetypeTags: [PalateArchetype.fruitForward, PalateArchetype.boldExplorer],
    tastingNotes:
        'Cabernet-Shiraz blend, ripe black fruit, gentle spice, '
        'rounded oak. Crowd-pleaser at hosting. Built for paneer '
        'tikka, Rogan Josh, and tandoori platters.',
    aromas: ['blackberry', 'plum', 'spice', 'cedar'],
    abv: 13.0,
    grapeVariety: 'Cabernet Sauvignon-Shiraz',
    origin:
        'Winery 52, a younger Pune-based label aimed at the modern '
        'Indian wine drinker — accessible price, party-friendly profile.',
  ),

  Product(
    id: 'tamakua-riesling',
    name: 'Tamakua Riesling',
    category: DrinkCategory.whiteWine,
    subcategory: 'Riesling',
    region: 'Nashik, Maharashtra',
    price: 1100,
    fruit: 7,
    acidity: 8,
    body: 3,
    tannin: 1,
    freshness: 8,
    complexity: 5,
    archetypeTags: [PalateArchetype.crispPurist],
    tastingNotes:
        'Off-dry Riesling with green apple, lime zest, and a slight '
        'petrol note. Crisp acidity makes this the answer to "what do '
        'I drink with biryani?" — sweetness tames chilli heat.',
    aromas: ['green apple', 'lime', 'jasmine', 'petrol'],
    abv: 11.5,
    grapeVariety: 'Riesling',
    origin:
        'Tamakua, a small-batch Nashik label experimenting with '
        'Riesling — an unusual choice for India that pairs '
        'unusually well with regional spice.',
  ),

  Product(
    id: 'old-monk-7',
    name: 'Old Monk 7-Year XXX Rum',
    category: DrinkCategory.rum,
    subcategory: 'Dark Rum',
    region: 'Ghaziabad, Uttar Pradesh',
    price: 450,
    fruit: 5,
    acidity: 2,
    body: 7,
    tannin: 2,
    freshness: 3,
    complexity: 6,
    archetypeTags: [PalateArchetype.boldExplorer],
    tastingNotes:
        'India\'s most iconic rum. Smooth, vanilla-forward dark rum '
        'aged 7 years. Caramel, molasses, and a soft burn. The cult '
        'reference point — works neat, with cola, or in winter cocktails.',
    aromas: ['vanilla', 'caramel', 'molasses', 'cinnamon'],
    abv: 42.8,
    grapeVariety: 'Dark Rum',
    origin:
        'Old Monk by Mohan Meakin, launched 1954 in Kasauli. Cultural '
        'institution across South Asia — generations of Indian drinkers '
        'started here.',
  ),
];

