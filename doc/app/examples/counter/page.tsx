import { CodeBlock } from "@/components/docs/code-block"
import Link from "next/link"

export default function CounterExamplePage() {
  return (
    <div className="space-y-10">
      <section className="space-y-4">
        <div className="text-sm text-muted-foreground">Examples</div>
        <h1 className="text-3xl font-bold tracking-tight">Simple Counter</h1>
        <p className="text-muted-foreground leading-relaxed">
          The classic starter example: a counter with increment, decrement, and reset.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Full Code</h2>
        <CodeBlock
          filename="counter_page.dart"
          language="dart"
          code={`import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  // Create a Reactive automatically bound to the State
  late final counter = react(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Reactive Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Displays the value and updates automatically
            Text(
              '\${counter.value}',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decrement button
                FloatingActionButton(
                  heroTag: 'dec',
                  onPressed: () => counter.dec(),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                // Reset button
                FloatingActionButton(
                  heroTag: 'reset',
                  onPressed: () => counter.value = 0,
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 16),
                // Increment button
                FloatingActionButton(
                  heroTag: 'inc',
                  onPressed: () => counter.inc(),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">ReactiveBuilder Version</h2>
        <p className="text-muted-foreground">
          If you prefer not to bind to a State, use ReactiveBuilder:
        </p>
        <CodeBlock
          filename="counter_builder.dart"
          language="dart"
          code={`import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';

// Global Reactive (not bound to a State)
final counter = Reactive(0);

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter with ReactiveBuilder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ReactiveBuilder rebuilds automatically
            ReactiveBuilder.watch(
              counter,
              (value) => Text(
                '\$value',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'dec',
                  onPressed: () => counter.dec(),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'inc',
                  onPressed: () => counter.inc(),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Validated Version</h2>
        <p className="text-muted-foreground">
          Add validators to keep the value within a safe range:
        </p>
        <CodeBlock
          filename="counter_validated.dart"
          language="dart"
          code={`class _CounterPageState extends State<CounterPage> {
  // Counter limited between 0 and 10
  late final counter = react(0)
      .require((v) => v >= 0, 'Minimum reached')
      .require((v) => v <= 10, 'Maximum reached');
  
  String? message;

  void increment() {
    try {
      counter.inc();
      message = null;
    } on ReactiveValidatorError catch (e) {
      message = e.message;
    }
  }

  void decrement() {
    try {
      counter.dec();
      message = null;
    } on ReactiveValidatorError catch (e) {
      message = e.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('\${counter.value}', style: TextStyle(fontSize: 48)),
        if (message != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message!,
              style: TextStyle(color: Colors.orange),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: decrement,
              child: Icon(Icons.remove),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: increment,
              child: Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Key Takeaways</h2>
        <ul className="space-y-2 text-muted-foreground list-disc list-inside">
          <li><code className="font-mono text-sm bg-muted px-1 py-0.5 rounded">react(0)</code> creates a Reactive bound to the State</li>
          <li><code className="font-mono text-sm bg-muted px-1 py-0.5 rounded">.inc()</code> and <code className="font-mono text-sm bg-muted px-1 py-0.5 rounded">.dec()</code> are shortcuts for +1 and -1</li>
          <li>The UI updates automatically without calling <code className="font-mono text-sm bg-muted px-1 py-0.5 rounded">setState()</code></li>
          <li>Validators prevent invalid values</li>
        </ul>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Next Example</h2>
        <div className="p-4 rounded-lg border border-border bg-card">
          <p className="text-muted-foreground">
            See how to build a form with real-time validation.
          </p>
          <Link 
            href="/examples/form" 
            className="inline-block mt-3 text-primary hover:underline font-medium"
          >
            Form Example →
          </Link>
        </div>
      </section>
    </div>
  )
}
