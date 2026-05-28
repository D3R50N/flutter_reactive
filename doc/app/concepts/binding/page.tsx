import { CodeBlock } from "@/components/docs/code-block"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import Link from "next/link"

export default function BindingPage() {
  return (
    <div className="space-y-10">
      <section className="space-y-4">
        <h1 className="text-3xl font-bold tracking-tight">Binding &amp; Widgets</h1>
        <p className="text-muted-foreground leading-relaxed">
          Binding allows you to connect your reactive values directly to a Flutter State.
          When the value changes, the UI updates automatically — without calling <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">setState()</code>.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Automatic Binding with react()</h2>
        <p className="text-muted-foreground">
          The simplest method: use <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">react()</code> to create a Reactive 
          automatically bound to the current State.
        </p>
        <CodeBlock
          filename="auto_binding.dart"
          language="dart"
          code={`class _MyPageState extends State<MyPage> {
  // Auto-bind to current State
  late final counter = react(0);
  
  // Nullable + auto-bind
  late final name = reactN<String>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Counter: \${counter.value}'),
        Text('Name: \${name.value ?? "Not set"}'),
        ElevatedButton(
          onPressed: () => counter.inc(),
          child: Text('Increment'),
        ),
      ],
    );
  }
}`}
        />
        <Card className="bg-primary/5 border-primary/20">
          <CardHeader className="pb-2">
            <CardTitle className="text-base text-primary">It&apos;s Magic!</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground">
              With <code className="font-mono bg-muted px-1 py-0.5 rounded">react()</code>, no need to call <code className="font-mono bg-muted px-1 py-0.5 rounded">setState()</code>, 
              manage <code className="font-mono bg-muted px-1 py-0.5 rounded">dispose()</code>, or create manual listeners.
              The UI updates automatically when the value changes.
            </p>
          </CardContent>
        </Card>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Manual Binding</h2>
        <p className="text-muted-foreground">
          For more control, you can use <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">bind()</code> and 
          <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded ml-1">unbind()</code> manually:
        </p>
        <CodeBlock
          filename="manual_binding.dart"
          language="dart"
          code={`final counter = Reactive(0);

class _MyPageState extends State<MyPage> {
  @override
  void initState() {
    super.initState();
    // Bind to State
    counter.bind(this);
  }

  @override
  void dispose() {
    // Unbind properly
    counter.unbind(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Counter: \${counter.value}');
  }
}`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Custom Listeners</h2>
        <p className="text-muted-foreground">
          You can also listen to changes with callbacks:
        </p>
        <CodeBlock
          filename="listeners.dart"
          language="dart"
          code={`void onCounterChanged(int value) {
  debugPrint('Counter changed: \$value');
}

// Listen to changes
counter.listen(onCounterChanged);

// Listen and immediately receive the current value
counter.listen(onCounterChanged, true);

// Stop listening
counter.unlisten(onCounterChanged);`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Streams</h2>
        <p className="text-muted-foreground">
          Every Reactive exposes a Stream for integration with StreamBuilder or other Stream-based APIs:
        </p>
        <CodeBlock
          filename="streams.dart"
          language="dart"
          code={`// Listen via Stream
counter.stream.listen((value) {
  debugPrint('Stream value: \$value');
});

// Global configuration to emit immediately
Reactive.streamEmitOnListen = true;

// Usage with StreamBuilder
StreamBuilder<int>(
  stream: counter.stream,
  builder: (context, snapshot) {
    return Text(snapshot.data?.toString() ?? '');
  },
);`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">ReactiveBuilder (Rxb)</h2>
        <p className="text-muted-foreground">
          To build reactive widgets without binding to State. <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">Rxb</code> is the short alias.
        </p>
        <CodeBlock
          filename="reactive_builder.dart"
          language="dart"
          code={`final counter = Reactive(0);
final price = 100.rt;
final quantity = 2.rt;

// Automatic read tracking
ReactiveBuilder(() {
  return Text('Count: \${counter.value}');
});

// Or with short alias Rxb
Rxb(() => Text('Count: \${counter.value}'));

// Explicit watch of a single Reactive
Rxb.watch(
  counter,
  (value) => Text('Count: \$value'),
);

// Watch multiple Reactives (watch2..watch5)
Rxb.watch2(
  price,
  quantity,
  (price, qty) => Text('Total: \${price * qty}'),
);

// Via StreamBuilder
Rxb.stream(
  counter,
  (context, snapshot) => Text('Count: \${snapshot.data}'),
  withInitial: true,
);

// Shortcut on Reactive
counter.build((value) => Text('Count: \$value'));`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">ReactiveStateBuilder (Rxsb)</h2>
        <p className="text-muted-foreground">
          Build different widgets based on state value. <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">Rxsb</code> is the short alias.
        </p>
        <CodeBlock
          filename="reactive_state_builder.dart"
          language="dart"
          code={`Rxsb<bool>(
  initialState: false,
  states: {
    true: (reactive) => ElevatedButton(
      onPressed: () => reactive.value = false,
      child: const Text('Disable'),
    ),
    false: (reactive) => ElevatedButton(
      onPressed: () => reactive.value = true,
      child: const Text('Enable'),
    ),
  },
);`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">updateState() Extension</h2>
        <p className="text-muted-foreground">
          Force a State refresh if needed:
        </p>
        <CodeBlock
          filename="update_state.dart"
          language="dart"
          code={`class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Force a rebuild
        updateState();
        
        // Or with callback
        updateState(() {
          // Logic before rebuild
        });
      },
      child: Text('Refresh'),
    );
  }
}`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Next Step</h2>
        <div className="p-4 rounded-lg border border-border bg-card">
          <p className="text-muted-foreground">
            Learn how to validate your reactive data with the built-in validation system.
          </p>
          <Link 
            href="/concepts/validation" 
            className="inline-block mt-3 text-primary hover:underline font-medium"
          >
            Discover Validation &rarr;
          </Link>
        </div>
      </section>
    </div>
  )
}
