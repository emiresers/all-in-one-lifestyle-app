// Ürün kartının üç ayrı dokunma hedefi (gövde / favori / sepet) ve dar
// ekranlarda taşmama garantisi.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dummyproject/models/product.dart';
import 'package:dummyproject/widgets/product_card.dart';

final Product _product = Product(
  id: 1,
  title: 'Essence Mascara Lash Princess',
  description: 'desc',
  price: 9.99,
  rating: 2.56,
  category: 'beauty',
  thumbnail: 'https://example.com/a.png',
  reviewCount: 3,
);

final Product _shortProduct = Product(
  id: 2,
  title: 'Powder',
  description: 'desc',
  price: 14.99,
  rating: 4.6,
  category: 'beauty',
  thumbnail: 'https://example.com/b.png',
  reviewCount: 3,
);

Widget _harness({
  required Size size,
  required VoidCallback onTap,
  required VoidCallback onFav,
  required VoidCallback onAdd,
  List<Product>? products,
}) {
  final displayedProducts = products ?? <Product>[_product, _product];

  return MediaQuery(
    data: MediaQueryData(size: size),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        child: Builder(
          builder: (context) => CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: productGridDelegateFor(context),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ProductCard(
                      product: displayedProducts[index],
                      isFavorite: false,
                      onTap: onTap,
                      onToggleFavorite: onFav,
                      onAddToCart: onAdd,
                    ),
                    childCount: displayedProducts.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  for (final Size size in const [
    Size(320, 568),
    Size(375, 812),
    Size(393, 852),
    Size(402, 874),
    Size(430, 932),
  ]) {
    testWidgets('ProductCard ${size.width.toInt()}px genişlikte taşmıyor', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _harness(size: size, onTap: () {}, onFav: () {}, onAdd: () {}),
      );

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('kart gövdesi, favori ve sepet butonu ayrı hedefler', (
    tester,
  ) async {
    int taps = 0;
    int favs = 0;
    int adds = 0;

    const Size size = Size(375, 812);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _harness(
        size: size,
        onTap: () => taps++,
        onFav: () => favs++,
        onAdd: () => adds++,
      ),
    );

    // Favori: kartın görsel alanının sağ üstü.
    await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
    await tester.pump();
    expect(favs, 1, reason: 'favori butonu kendi dokunuşunu almalı');
    expect(taps, 0, reason: 'favoriye basmak detaya gitmemeli');

    // Sepete ekle: kartın sağ altındaki "+".
    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await tester.pump();
    expect(adds, 1, reason: 'sepet butonu kendi dokunuşunu almalı');
    expect(taps, 0, reason: 'sepete eklemek detaya gitmemeli');

    // Kart gövdesi: ürün başlığı.
    await tester.tap(find.text('Essence Mascara Lash Princess').first);
    await tester.pump();
    expect(taps, 1, reason: 'kart gövdesi detaya gitmeli');
  });

  testWidgets('tek ve iki satırlık adlarda fiyatlar aynı hizada', (
    tester,
  ) async {
    const Size size = Size(375, 812);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _harness(
        size: size,
        onTap: () {},
        onFav: () {},
        onAdd: () {},
        products: <Product>[_shortProduct, _product],
      ),
    );

    final shortPriceY = tester.getTopLeft(find.text(r'$14.99')).dy;
    final longPriceY = tester.getTopLeft(find.text(r'$9.99')).dy;

    expect(shortPriceY, longPriceY);
    expect(tester.takeException(), isNull);
  });
}
