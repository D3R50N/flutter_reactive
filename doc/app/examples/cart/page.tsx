import { CodeBlock } from "@/components/docs/code-block"
import Link from "next/link"

export default function CartExamplePage() {
  return (
    <div className="space-y-10">
      <section className="space-y-4">
        <div className="text-sm text-muted-foreground">Examples</div>
        <h1 className="text-3xl font-bold tracking-tight">Shopping Cart</h1>
        <p className="text-muted-foreground leading-relaxed">
          A complete shopping cart with automatic totals, promo codes, and
          transactions for critical updates.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Data Models</h2>
        <CodeBlock
          filename="cart_models.dart"
          language="dart"
          code={`class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Cart State</h2>
        <CodeBlock
          filename="cart_state.dart"
          language="dart"
          code={`class CartState {
  final items = <CartItem>[].reactive();
  final promoCode = ReactiveN<String>();
  final discount = 0.0.reactive()
      .require((value) => value >= 0 && value <= 1, 'Invalid discount');

  late final subtotal = Reactive.compute(() {
    return items.value.fold(0.0, (sum, item) => sum + item.total);
  });

  late final discountAmount = Reactive.combine2(
    subtotal,
    discount,
    (currentSubtotal, currentDiscount) => currentSubtotal * currentDiscount,
  );

  late final tax = Reactive.compute(() {
    final afterDiscount = subtotal.value - discountAmount.value;
    return afterDiscount * 0.2;
  });

  late final total = Reactive.compute(() {
    return subtotal.value - discountAmount.value + tax.value;
  });

  late final itemCount = Reactive.compute(() {
    return items.value.fold(0, (sum, item) => sum + item.quantity);
  });

  late final isEmpty = items.as((value) => value.isEmpty);

  Future<void> addProduct(Product product) async {
    await Reactive.run(() {
      final existingIndex = items.value.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingIndex >= 0) {
        final existing = items.value[existingIndex];
        items[existingIndex] = existing.copyWith(
          quantity: existing.quantity + 1,
        );
      } else {
        items.add(CartItem(product: product));
      }
    });
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }

    await Reactive.run(() {
      final index = items.value.indexWhere(
        (item) => item.product.id == productId,
      );
      if (index >= 0) {
        items[index] = items.value[index].copyWith(quantity: quantity);
      }
    });
  }

  void removeProduct(String productId) {
    items.removeWhere((item) => item.product.id == productId);
  }

  void clearCart() {
    items.clear();
    promoCode.value = null;
    discount.value = 0.0;
  }

  Future<bool> applyPromoCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final validCodes = {
      'SAVE10': 0.1,
      'SAVE20': 0.2,
      'HALF': 0.5,
    };

    final upperCode = code.toUpperCase();
    if (validCodes.containsKey(upperCode)) {
      await Reactive.run(() {
        promoCode.value = upperCode;
        discount.value = validCodes[upperCode]!;
      });
      return true;
    }
    return false;
  }

  void removePromoCode() {
    promoCode.value = null;
    discount.value = 0.0;
  }
}`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">User Interface</h2>
        <CodeBlock
          filename="cart_page.dart"
          language="dart"
          code={`class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final cart = CartState();
  final promoController = TextEditingController();
  bool isApplyingPromo = false;
  String? promoError;

  @override
  void initState() {
    super.initState();
    cart.items.bind(this);
    cart.discount.bind(this);
    cart.promoCode.bind(this);
    _addSampleProducts();
  }

  void _addSampleProducts() {
    cart.addProduct(Product(
      id: '1',
      name: 'MacBook Pro',
      price: 2499.0,
      imageUrl: 'assets/macbook.png',
    ));
    cart.addProduct(Product(
      id: '2',
      name: 'Magic Mouse',
      price: 99.0,
      imageUrl: 'assets/mouse.png',
    ));
  }

  @override
  void dispose() {
    cart.items.unbind(this);
    cart.discount.unbind(this);
    cart.promoCode.unbind(this);
    promoController.dispose();
    super.dispose();
  }

  Future<void> applyPromo() async {
    if (promoController.text.isEmpty) return;

    setState(() {
      isApplyingPromo = true;
      promoError = null;
    });

    final success = await cart.applyPromoCode(promoController.text);

    setState(() {
      isApplyingPromo = false;
      if (!success) {
        promoError = 'Invalid promo code';
      } else {
        promoController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart (\${cart.itemCount.value})'),
        actions: [
          if (!cart.isEmpty.value)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: cart.clearCart,
            ),
        ],
      ),
      body: cart.isEmpty.value
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.value.length,
                    itemBuilder: (context, index) {
                      final item = cart.items.value[index];
                      return CartItemTile(
                        item: item,
                        onQuantityChanged: (quantity) => cart.updateQuantity(
                          item.product.id,
                          quantity,
                        ),
                        onRemove: () => cart.removeProduct(item.product.id),
                      );
                    },
                  ),
                ),

                if (cart.promoCode.value == null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: promoController,
                            decoration: InputDecoration(
                              hintText: 'Promo code',
                              errorText: promoError,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isApplyingPromo ? null : applyPromo,
                          child: isApplyingPromo
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Apply'),
                        ),
                      ],
                    ),
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.local_offer, color: Colors.green),
                    title: Text('Code: \${cart.promoCode.value}'),
                    subtitle: Text(
                      '-\${(cart.discount.value * 100).toInt()}%',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: cart.removePromoCode,
                    ),
                  ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: 'Subtotal',
                          value: cart.subtotal.value,
                        ),
                        if (cart.discountAmount.value > 0)
                          _SummaryRow(
                            label: 'Discount',
                            value: -cart.discountAmount.value,
                            isDiscount: true,
                          ),
                        _SummaryRow(
                          label: 'Tax (20%)',
                          value: cart.tax.value,
                        ),
                        const Divider(),
                        _SummaryRow(
                          label: 'Total',
                          value: cart.total.value,
                          isTotal: true,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                            child: const Text('Checkout'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;
  final bool isDiscount;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                : null,
          ),
          Text(
            '\${value.toStringAsFixed(2)} €',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : null,
              fontSize: isTotal ? 18 : null,
              color: isDiscount ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Key Takeaways</h2>
        <ul className="space-y-2 text-muted-foreground list-disc list-inside">
          <li>Derived totals stay in sync automatically</li>
          <li>Transactions keep critical cart updates safe</li>
          <li>Validation protects promo discounts</li>
          <li><code className="font-mono text-sm bg-muted px-1 py-0.5 rounded">ReactiveN</code> is ideal for optional promo codes</li>
          <li>Derived state cascades cleanly from subtotal to total</li>
        </ul>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">See Also</h2>
        <div className="p-4 rounded-lg border border-border bg-card">
          <p className="text-muted-foreground">
            Looking for more examples? Check the FAQ for common questions and
            patterns.
          </p>
          <Link
            href="/faq"
            className="inline-block mt-3 text-primary hover:underline font-medium"
          >
            View FAQ &rarr;
          </Link>
        </div>
      </section>
    </div>
  )
}
