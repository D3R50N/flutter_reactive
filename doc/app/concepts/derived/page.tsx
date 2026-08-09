import { CodeBlock } from "@/components/docs/code-block";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import Link from "next/link";

export default function DerivedPage() {
  return (
    <div className="space-y-10">
      <section className="space-y-4">
        <h1 className="text-3xl font-bold tracking-tight">Derived State</h1>
        <p className="text-muted-foreground leading-relaxed">
          Derived state lets you create computed values from other Reactives.
          These values update automatically when their sources change.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">as() - Simple Transformation</h2>
        <p className="text-muted-foreground">
          Transform a reactive value into another with{" "}
          <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">
            .as()
          </code>
          :
        </p>
        <CodeBlock
          filename="as_transform.dart"
          language="dart"
          code={`final text = ''.rt;

// Derive text length
final length = text.as((value) => value.length);

// Derive if text is valid
final isValid = text.as((value) => value.length >= 3);

// Usage
text.value = 'Hello';
print(length.value);  // 5
print(isValid.value); // true`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">
          combine() - Combine Multiple Sources
        </h2>
        <p className="text-muted-foreground">
          Combine multiple Reactives into one with{" "}
          <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">
            combine()
          </code>
          :
        </p>
        <CodeBlock
          filename="combine.dart"
          language="dart"
          code={`final firstName = 'John'.rt;
final lastName = 'Doe'.rt;

// Combine with list
final fullName = combine(
  [firstName, lastName],
  (values) => '\${values[0]} \${values[1]}',
);

print(fullName.value); // 'John Doe'

// Typed combine with combine2
final price = 100.rt;
final quantity = 2.rt;

final total = combine2(
  price,
  quantity,
  (price, qty) => price * qty,
);

print(total.value); // 200

// combine3, combine4, combine5 also available
final discount = 0.1.rt;

final finalPrice = combine3(
  price,
  quantity,
  discount,
  (price, qty, discount) => (price * qty) * (1 - discount),
);

print(finalPrice.value); // 180.0`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">
          compute() - Automatic Tracking
        </h2>
        <p className="text-muted-foreground">
          <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">
            compute()
          </code>{" "}
          automatically detects dependencies — no need to list them explicitly:
        </p>
        <CodeBlock
          filename="compute.dart"
          language="dart"
          code={`final price = 100.rt;
final quantity = 2.rt;
final taxRate = 0.2.rt;

// Dependencies are detected automatically
final total = compute(() {
  final subtotal = price.value * quantity.value;
  final tax = subtotal * taxRate.value;
  (p, q, d) => (p * q) * (1 - d),
);`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Dynamic Computation (compute)</h2>
        <p className="text-muted-foreground">
          Automatically tracks dependencies read inside the function:
        </p>
        <CodeBlock
          filename="derived_compute.dart"
          language="dart"
          code={`final price = 100.rx;
final quantity = 2.rx;
final taxRate = 0.2.rx;

// Auto-tracks reads of price, quantity, and taxRate
final grandTotal = compute(() {
  final sub = price.value * quantity.value;
  return sub * (1 + taxRate.value);
});`}
        />
        <Card className="bg-primary/5 border-primary/20">
          <CardHeader className="pb-2">
            <CardTitle className="text-base text-primary">
              When to Use What?
            </CardTitle>
          </CardHeader>
          <CardContent className="text-sm text-muted-foreground space-y-2">
            <p>
              <strong>as()</strong>: Simple transformation of a single source
            </p>
            <p>
              <strong>combine()</strong>: When you know exactly your sources
            </p>
            <p>
              <strong>compute()</strong>: Complex calculations with dynamic
              dependencies
            </p>
          </CardContent>
        </Card>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Read-Only Values</h2>
        <p className="text-muted-foreground">
          Derived Reactives are read-only — you cannot modify their value
          directly:
        </p>
        <CodeBlock
          filename="readonly.dart"
          language="dart"
          code={`final count = 0.rx;
final doubled = count.as((v) => v * 2);

// OK - Modify the source
count.value = 5;
print(doubled.value); // 10

// Error - Derived are read-only
// doubled.value = 20; // Throws an error!`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">
          Practical Example: Shopping Cart
        </h2>
        <CodeBlock
          filename="readonly.dart"
          language="dart"
          code={`
  // Final total with discount
  late final total = combine2(
    subtotal,
    couponDiscount,
    (subtotal, discount) {
      final afterDiscount = subtotal * (1 - discount);
      final tax = afterDiscount * 0.2;
      return afterDiscount + tax;
    },
  );
  
  // Item count
  late final itemCount = compute(() {
    return items.value.fold(0, (sum, item) => sum + item.quantity);
  });
  
  // Cart empty?
  late final isEmpty = items.as((value) => value.isEmpty);
}

// Usage
final cart = CartState();
cart.items.add(CartItem(name: 'Laptop', price: 999.0, quantity: 1));
cart.items.add(CartItem(name: 'Mouse', price: 49.0, quantity: 2));

print(cart.subtotal.value);  // 1097.0
print(cart.tax.value);       // 219.4
print(cart.total.value);     // 1316.4
print(cart.itemCount.value); // 3

// Apply a 10% coupon
cart.couponDiscount.value = 0.1;
print(cart.total.value);     // 1184.76`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Next Step</h2>
        <div className="p-4 rounded-lg border border-border bg-card">
          <p className="text-muted-foreground">
            Learn how to group your modifications with transactions and
            automatic rollback.
          </p>
          <Link
            href="/concepts/transactions"
            className="inline-block mt-3 text-primary hover:underline font-medium"
          >
            Discover Transactions &rarr;
          </Link>
        </div>
      </section>
    </div>
  );
}
