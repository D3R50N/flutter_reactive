import { CodeBlock } from "@/components/docs/code-block"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import Link from "next/link"

export default function TransactionsPage() {
  return (
    <div className="space-y-10">
      <section className="space-y-4">
        <h1 className="text-3xl font-bold tracking-tight">Transactions &amp; Rollback</h1>
        <p className="text-muted-foreground leading-relaxed">
          Transactions let you group multiple changes and automatically roll them back if something fails.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Basic Transaction</h2>
        <p className="text-muted-foreground">
          Use <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">Reactive.run()</code> to execute
          several changes inside one transaction:
        </p>
        <CodeBlock
          filename="basic_transaction.dart"
          language="dart"
          code={`final counter = 0.reactive();

await Reactive.run(() {
  counter.inc(5);  // +5
  counter.dec(2);  // -2
});

print(counter.value); // 3`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Automatic Rollback</h2>
        <p className="text-muted-foreground">
          By default, if an error occurs during the transaction, every change is rolled back:
        </p>
        <CodeBlock
          filename="auto_rollback.dart"
          language="dart"
          code={`final counter = 0
    .reactive()
    .require((v) => v >= 0, 'Must stay positive');

// Initial value
print(counter.value); // 0

await Reactive.run(
  () {
    counter.inc(5);  // OK: 0 → 5
    counter.dec(10); // Error! 5 - 10 = -5 < 0
  },
  onError: (error) {
    debugPrint('Error: \$error');
  },
);

// Automatic rollback: back to the initial value
print(counter.value); // 0`}
        />
        <Card className="bg-primary/5 border-primary/20">
          <CardHeader className="pb-2">
            <CardTitle className="text-base text-primary">🔒 Data Safety</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground">
              Rollback keeps your data consistent, even when an error happens in the middle of a series of changes.
              No partial update is ever applied.
            </p>
          </CardContent>
        </Card>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Manual Rollback</h2>
        <p className="text-muted-foreground">
          You can disable automatic rollback and trigger it yourself later:
        </p>
        <CodeBlock
          filename="manual_rollback.dart"
          language="dart"
          code={`final balanceA = 10.reactive();
final balanceB = 20.reactive();

// Disable automatic rollback
final tx = await Reactive.run(
  () {
    balanceA.value = 100;
    balanceB.value = 200;
  },
  rollbackOnError: false,
);

print(balanceA.value); // 100
print(balanceB.value); // 200

// Decide later to cancel
if (someCondition) {
  tx.rollback();
  print(balanceA.value); // 10
  print(balanceB.value); // 20
}`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Save &amp; Restore (Checkpoints)</h2>
        <p className="text-muted-foreground">
          Outside transactions, you can save and restore a Reactive&apos;s state:
        </p>
        <CodeBlock
          filename="checkpoints.dart"
          language="dart"
          code={`final name = ''.reactive();

// Save a checkpoint
name.value = 'Andy';
name.save('step1');

name.value = 'Max';
name.save('step2');

name.value = 'John';

// Restore a checkpoint
name.restore('step1');
print(name.value); // 'Andy'

name.restore('step2');
print(name.value); // 'Max'

// Delete a checkpoint
name.unsave('step1');

// Delete all checkpoints
name.unsaveAll();`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Practical Example: Money Transfer</h2>
        <CodeBlock
          filename="transfer_example.dart"
          language="dart"
          code={`class Account {
  final String name;
  final Reactive<double> balance;
  
  Account(this.name, double initialBalance)
      : balance = initialBalance
            .reactive()
            .require((v) => v >= 0, 'Insufficient balance');
}

Future<bool> transfer({
  required Account from,
  required Account to,
  required double amount,
}) async {
  try {
    await Reactive.run(() {
      from.balance.update((v) => v - amount);
      to.balance.update((v) => v + amount);
    });
    return true;
  } catch (e) {
    // Automatic rollback!
    debugPrint('Transfer failed: \$e');
    return false;
  }
}

// Usage
final alice = Account('Alice', 100.0);
final bob = Account('Bob', 50.0);

// Valid transfer
await transfer(from: alice, to: bob, amount: 30.0);
print(alice.balance.value); // 70.0
print(bob.balance.value);   // 80.0

// Invalid transfer (insufficient balance)
await transfer(from: alice, to: bob, amount: 100.0);
// Automatic rollback!
print(alice.balance.value); // 70.0 (unchanged)
print(bob.balance.value);   // 80.0 (unchanged)`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Side-Effect Helpers</h2>
        <p className="text-muted-foreground">
          Flutter Reactive also provides helpers for side effects:
        </p>
        <CodeBlock
          filename="side_effects.dart"
          language="dart"
          code={`final searchQuery = ''.reactive();

// Run when a condition is met
counter.when(
  (v) => v == 0,
  (_) => debugPrint('Counter is zero!'),
);

// Debounce: wait until the user stops typing
searchQuery.debounce(300, (value) {
  debugPrint('Search: \$value');
  // Call the API after 300ms of inactivity
});

// Throttle: limit call frequency
counter.throttle(1000, (value) {
  debugPrint('Throttled: \$value');
  // Maximum one call per second
});`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Next Step</h2>
        <div className="p-4 rounded-lg border border-border bg-card">
          <p className="text-muted-foreground">
            Now that you understand transactions, explore real-world examples.
          </p>
          <Link 
            href="/examples/counter" 
            className="inline-block mt-3 text-primary hover:underline font-medium"
          >
            View Examples →
          </Link>
        </div>
      </section>
    </div>
  )
}
