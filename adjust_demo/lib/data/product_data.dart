import '../models/product.dart';

/// The fixed catalog of demo products (~20 items).
///
/// All data is fake but plausible — realistic names, prices, ratings, stock
/// levels and descriptions — so the app feels like a real store. Ids are stable
/// (`p01`…) so they can be referenced by persisted cart lines, wishlist entries
/// and orders in later phases. The `imageSeed` drives a procedurally-drawn
/// placeholder, so no binary image assets are needed.
class ProductData {
  const ProductData._();

  static const List<Product> all = <Product>[
    Product(
      id: 'p01',
      name: 'Vortex Pro Gaming Mouse',
      categoryId: 'gaming',
      price: 59.99,
      rating: 4.7,
      ratingCount: 1284,
      stock: 42,
      description:
          'A lightweight 26,000 DPI optical gaming mouse with six programmable '
          'buttons, on-the-fly sensitivity switching and a braided cable. Tuned '
          'for fast-paced competitive play.',
      imageSeed: 'gaming-mouse',
    ),
    Product(
      id: 'p02',
      name: 'Aurora Mechanical Keyboard',
      categoryId: 'gaming',
      price: 119.00,
      rating: 4.8,
      ratingCount: 2043,
      stock: 18,
      description:
          'A hot-swappable mechanical keyboard with tactile brown switches, '
          'per-key RGB lighting and a machined aluminium frame. Sounds crisp, '
          'feels premium.',
      imageSeed: 'mech-keyboard',
    ),
    Product(
      id: 'p03',
      name: 'Pulse 360 Bluetooth Speaker',
      categoryId: 'audio',
      price: 79.50,
      rating: 4.5,
      ratingCount: 876,
      stock: 30,
      description:
          'A pocket-sized speaker with surprisingly big 360° sound, deep bass '
          'and 20-hour battery life. IPX7 waterproof, so it goes wherever you do.',
      imageSeed: 'bt-speaker',
    ),
    Product(
      id: 'p04',
      name: 'NexusHub 7-in-1 USB-C Hub',
      categoryId: 'accessories',
      price: 45.99,
      rating: 4.4,
      ratingCount: 512,
      stock: 64,
      description:
          'Expand a single USB-C port into HDMI 4K, two USB-A, SD/microSD and '
          '100W pass-through charging. A tidy desk companion for any laptop.',
      imageSeed: 'usbc-hub',
    ),
    Product(
      id: 'p05',
      name: 'EchoBuds Wireless Earbuds',
      categoryId: 'audio',
      price: 99.99,
      rating: 4.6,
      ratingCount: 3120,
      stock: 25,
      description:
          'True-wireless earbuds with active noise cancellation, transparency '
          'mode and a wireless charging case. Crystal-clear calls and 28 hours '
          'of total playback.',
      imageSeed: 'earbuds',
    ),
    Product(
      id: 'p06',
      name: 'ErgoRise Laptop Stand',
      categoryId: 'office',
      price: 34.95,
      rating: 4.3,
      ratingCount: 640,
      stock: 80,
      description:
          'An adjustable aluminium stand that lifts your laptop to eye level '
          'for better posture and airflow. Folds flat to slip into any bag.',
      imageSeed: 'laptop-stand',
    ),
    Product(
      id: 'p07',
      name: 'RapidStore 1TB NVMe SSD',
      categoryId: 'electronics',
      price: 89.99,
      rating: 4.9,
      ratingCount: 4210,
      stock: 12,
      description:
          'A blazing-fast PCIe Gen4 SSD with read speeds up to 7,000 MB/s. '
          'Cut load times and boot in seconds. Five-year warranty included.',
      imageSeed: 'ssd',
    ),
    Product(
      id: 'p08',
      name: 'ClearView 4K Webcam',
      categoryId: 'electronics',
      price: 69.00,
      rating: 4.2,
      ratingCount: 388,
      stock: 5,
      description:
          'A 4K UHD webcam with autofocus, HDR and a dual noise-cancelling mic '
          'array. Look sharp on every call, in any lighting.',
      imageSeed: 'webcam',
    ),
    Product(
      id: 'p09',
      name: 'Studio Cast USB Microphone',
      categoryId: 'audio',
      price: 129.00,
      rating: 4.7,
      ratingCount: 1560,
      stock: 22,
      description:
          'A cardioid condenser mic with zero-latency monitoring and a built-in '
          'pop filter. Podcast-, stream- and studio-ready straight out of the box.',
      imageSeed: 'microphone',
    ),
    Product(
      id: 'p10',
      name: 'Titan Wireless Controller',
      categoryId: 'gaming',
      price: 64.99,
      rating: 4.5,
      ratingCount: 2298,
      stock: 0,
      description:
          'A low-latency wireless controller with hall-effect sticks, remappable '
          'back paddles and 40-hour battery life. Works across PC and console.',
      imageSeed: 'controller',
    ),
    Product(
      id: 'p11',
      name: 'Lumina 27" QHD Monitor',
      categoryId: 'electronics',
      price: 249.99,
      rating: 4.6,
      ratingCount: 934,
      stock: 9,
      description:
          'A 27-inch 1440p IPS display with a 165Hz refresh rate, 1ms response '
          'and 99% sRGB coverage. Buttery-smooth for both work and play.',
      imageSeed: 'monitor',
    ),
    Product(
      id: 'p12',
      name: 'ComfortCore Office Chair',
      categoryId: 'office',
      price: 199.00,
      rating: 4.4,
      ratingCount: 721,
      stock: 15,
      description:
          'An ergonomic mesh chair with adjustable lumbar support, 4D armrests '
          'and a synchronised tilt. Built to keep you comfortable through long days.',
      imageSeed: 'office-chair',
    ),
    Product(
      id: 'p13',
      name: 'Halo LED Desk Lamp',
      categoryId: 'office',
      price: 39.99,
      rating: 4.3,
      ratingCount: 456,
      stock: 50,
      description:
          'A dimmable desk lamp with five color temperatures, a USB charging '
          'port and a memory function that recalls your favourite setting.',
      imageSeed: 'desk-lamp',
    ),
    Product(
      id: 'p14',
      name: 'Clean Code Handbook',
      categoryId: 'books',
      price: 32.50,
      rating: 4.8,
      ratingCount: 5120,
      stock: 100,
      description:
          'A practical guide to writing readable, maintainable software. Packed '
          'with real-world refactoring examples and hard-won engineering wisdom.',
      imageSeed: 'book-cleancode',
    ),
    Product(
      id: 'p15',
      name: 'Grid Dot Notebook',
      categoryId: 'office',
      price: 14.99,
      rating: 4.6,
      ratingCount: 812,
      stock: 200,
      description:
          'A premium dot-grid notebook with 160 gsm bleed-proof pages, a lay-flat '
          'binding and a ribbon marker. Perfect for sketches, notes and planning.',
      imageSeed: 'notebook',
    ),
    Product(
      id: 'p16',
      name: 'Precision Mechanical Pencil',
      categoryId: 'office',
      price: 9.99,
      rating: 4.5,
      ratingCount: 340,
      stock: 3,
      description:
          'A 0.5mm drafting pencil with a knurled metal grip, retractable tip '
          'and a satisfying click. Balanced for hours of comfortable writing.',
      imageSeed: 'pencil',
    ),
    Product(
      id: 'p17',
      name: 'PowerCell 20K Power Bank',
      categoryId: 'accessories',
      price: 49.99,
      rating: 4.7,
      ratingCount: 2760,
      stock: 38,
      description:
          'A 20,000mAh power bank with 65W USB-C PD fast charging and a digital '
          'battery display. Enough juice to top up a laptop and two phones.',
      imageSeed: 'power-bank',
    ),
    Product(
      id: 'p18',
      name: 'Pulse Smart Watch',
      categoryId: 'electronics',
      price: 179.00,
      rating: 4.4,
      ratingCount: 1890,
      stock: 20,
      description:
          'A fitness-focused smart watch with GPS, heart-rate and SpO₂ sensors, '
          'a bright AMOLED display and a 10-day battery. Water resistant to 50m.',
      imageSeed: 'smart-watch',
    ),
    Product(
      id: 'p19',
      name: 'UltraLink 8K HDMI Cable',
      categoryId: 'accessories',
      price: 19.99,
      rating: 4.2,
      ratingCount: 275,
      stock: 150,
      description:
          'A certified HDMI 2.1 cable supporting 8K@60Hz, 4K@120Hz and 48Gbps '
          'bandwidth. Braided, gold-plated and built to last.',
      imageSeed: 'hdmi',
    ),
    Product(
      id: 'p20',
      name: 'Voyager Tech Backpack',
      categoryId: 'accessories',
      price: 74.99,
      rating: 4.6,
      ratingCount: 1420,
      stock: 27,
      description:
          'A water-resistant 22L backpack with a padded 16" laptop sleeve, a '
          'hidden anti-theft pocket and a built-in USB charging pass-through.',
      imageSeed: 'backpack',
    ),
    Product(
      id: 'p21',
      name: 'ChargePad Wireless Charger',
      categoryId: 'accessories',
      price: 29.99,
      rating: 4.3,
      ratingCount: 968,
      stock: 60,
      description:
          'A slim 15W Qi wireless charging pad with a non-slip surface and a '
          'soft status LED. Case-friendly and safe for overnight charging.',
      imageSeed: 'wireless-charger',
    ),
  ];
}
