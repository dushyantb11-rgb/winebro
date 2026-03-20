
class AromaCategory {
  const AromaCategory({
    required this.name,
    required this.color,
    required this.subcategories,
  });

  final String name;
  final int color;
  final List<AromaSubcategory> subcategories;

  List<String> get allAromas =>
      subcategories.expand((s) => s.aromas).toList();
}

class AromaSubcategory {
  const AromaSubcategory({
    required this.name,
    required this.aromas,
  });

  final String name;
  final List<String> aromas;
}

const kAromaWheel = <AromaCategory>[

  AromaCategory(
    name: 'Fruity',
    color: 0xFFD4544A,
    subcategories: [
      AromaSubcategory(
        name: 'Citrus',
        aromas: ['Lemon', 'Lime', 'Grapefruit', 'Orange', 'Tangerine', 'Yuzu', 'Nimbu (Indian lime)'],
      ),
      AromaSubcategory(
        name: 'Stone Fruit',
        aromas: ['Peach', 'Apricot', 'Nectarine', 'Plum', 'Cherry', 'Aam (Mango)'],
      ),
      AromaSubcategory(
        name: 'Tropical',
        aromas: ['Pineapple', 'Passion Fruit', 'Lychee', 'Guava', 'Coconut', 'Jackfruit', 'Papaya'],
      ),
      AromaSubcategory(
        name: 'Berry',
        aromas: ['Strawberry', 'Raspberry', 'Blackberry', 'Blueberry', 'Cranberry', 'Jamun (Indian blackberry)'],
      ),
      AromaSubcategory(
        name: 'Dried Fruit',
        aromas: ['Raisin', 'Fig', 'Date', 'Prune', 'Dried Apricot', 'Munakka'],
      ),
    ],
  ),

  AromaCategory(
    name: 'Floral',
    color: 0xFFB8145E,
    subcategories: [
      AromaSubcategory(
        name: 'White Flowers',
        aromas: ['Jasmine', 'Honeysuckle', 'Orange Blossom', 'Champa', 'Mogra'],
      ),
      AromaSubcategory(
        name: 'Red Flowers',
        aromas: ['Rose', 'Violet', 'Hibiscus', 'Lavender', 'Gulab (Desi rose)'],
      ),
      AromaSubcategory(
        name: 'Blossom',
        aromas: ['Elderflower', 'Acacia', 'Linden', 'Mahua'],
      ),
    ],
  ),

  AromaCategory(
    name: 'Spice',
    color: 0xFFEFBF04,
    subcategories: [
      AromaSubcategory(
        name: 'Sweet Spice',
        aromas: ['Vanilla', 'Cinnamon', 'Nutmeg', 'Clove', 'Star Anise', 'Elaichi (Cardamom)', 'Jaggery'],
      ),
      AromaSubcategory(
        name: 'Savoury Spice',
        aromas: ['Black Pepper', 'White Pepper', 'Cumin', 'Coriander Seed', 'Fennel', 'Ajwain', 'Hing (Asafoetida)'],
      ),
      AromaSubcategory(
        name: 'Warming Spice',
        aromas: ['Ginger', 'Turmeric', 'Saffron (Kesar)', 'Long Pepper (Pippali)', 'Mace (Javitri)'],
      ),
      AromaSubcategory(
        name: 'Heat',
        aromas: ['Red Chilli', 'Green Chilli', 'Szechuan Pepper', 'Kashmiri Chilli', 'Guntur Chilli'],
      ),
    ],
  ),

  AromaCategory(
    name: 'Herbal',
    color: 0xFF14A358,
    subcategories: [
      AromaSubcategory(
        name: 'Fresh Herbs',
        aromas: ['Mint', 'Basil', 'Thyme', 'Rosemary', 'Curry Leaf', 'Coriander Leaf (Dhania)', 'Pudina'],
      ),
      AromaSubcategory(
        name: 'Dried Herbs',
        aromas: ['Bay Leaf (Tej Patta)', 'Oregano', 'Sage', 'Kasuri Methi (Dried Fenugreek)'],
      ),
      AromaSubcategory(
        name: 'Vegetal',
        aromas: ['Grass', 'Green Bell Pepper', 'Asparagus', 'Green Tea', 'Eucalyptus'],
      ),
    ],
  ),

  AromaCategory(
    name: 'Earthy',
    color: 0xFF6B6166,
    subcategories: [
      AromaSubcategory(
        name: 'Earth',
        aromas: ['Wet Earth (Petrichor)', 'Mushroom', 'Truffle', 'Forest Floor', 'Clay'],
      ),
      AromaSubcategory(
        name: 'Mineral',
        aromas: ['Flint', 'Chalk', 'Slate', 'Wet Stone', 'Graphite', 'Salt'],
      ),
      AromaSubcategory(
        name: 'Fermented',
        aromas: ['Soy Sauce', 'Miso', 'Tamarind (Imli)', 'Kokum', 'Amchur (Dried Mango)'],
      ),
    ],
  ),

  AromaCategory(
    name: 'Oak & Wood',
    color: 0xFFC9A003,
    subcategories: [
      AromaSubcategory(
        name: 'Oak',
        aromas: ['Vanilla', 'Toast', 'Cedar', 'Coconut', 'Caramel'],
      ),
      AromaSubcategory(
        name: 'Smoke',
        aromas: ['Charcoal', 'Bonfire', 'Peat', 'Tobacco', 'Incense (Agarbatti)', 'Tandoor Smoke'],
      ),
      AromaSubcategory(
        name: 'Nutty',
        aromas: ['Almond', 'Walnut', 'Hazelnut', 'Cashew', 'Peanut', 'Roasted Chana'],
      ),
      AromaSubcategory(
        name: 'Sweet',
        aromas: ['Honey', 'Toffee', 'Butterscotch', 'Chocolate', 'Coffee', 'Ghee', 'Rose Water'],
      ),
    ],
  ),
];

