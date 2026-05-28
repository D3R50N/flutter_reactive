import { CodeBlock } from "@/components/docs/code-block"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import Link from "next/link"

export default function ReactivePage() {
  return (
    <div className="space-y-10">
      <section className="space-y-4">
        <h1 className="text-3xl font-bold tracking-tight">Reactive &amp; ReactiveN</h1>
        <p className="text-muted-foreground leading-relaxed">
          The <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">Reactive&lt;T&gt;</code> and 
          <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded ml-1">ReactiveN&lt;T&gt;</code> classes are the heart of Flutter Reactive.
          They encapsulate a value and automatically notify listeners when it changes.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Basic Creation</h2>
        <p className="text-muted-foreground">
          Use <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">Reactive&lt;T&gt;</code> for non-nullable values 
          and <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">ReactiveN&lt;T&gt;</code> for values that can be null.
        </p>
        <CodeBlock
          filename="basic_reactive.dart"
          language="dart"
          code={`// Non-nullable Reactive (strict mode by default)
final counter = Reactive(0);

// Nullable Reactive
final user = ReactiveN<String>();

// Via the .rt extension (shortcut)
final count = 0.rt;

// Non-strict mode: same value = notification anyway
final looseCounter = 0.rtNonStrict;`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Naming Convention</h2>
        <Card className="bg-primary/5 border-primary/20">
          <CardHeader className="pb-2">
            <CardTitle className="text-base text-primary">Best Practice</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground">
              Use descriptive names directly: <code className="font-mono bg-muted px-1 py-0.5 rounded">counter</code>, 
              <code className="font-mono bg-muted px-1 py-0.5 rounded ml-1">user</code>, 
              <code className="font-mono bg-muted px-1 py-0.5 rounded ml-1">items</code>. 
              There is no required <code className="font-mono bg-muted px-1 py-0.5 rounded">r</code> prefix in the docs or the API.
            </p>
          </CardContent>
        </Card>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Modifying the Value</h2>
        <p className="text-muted-foreground">
          Several ways to update a Reactive&apos;s value:
        </p>
        <CodeBlock
          filename="update_value.dart"
          language="dart"
          code={`final counter = Reactive(0);

// Direct assignment
counter.value = 1;

// set() method
counter.set(2);

// update() method with callback
counter.update((currentValue) => currentValue + 1);

// Async update
await counter.setAsync(Future.value(10));`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Strict vs Non-Strict Mode</h2>
        <div className="grid gap-4 sm:grid-cols-2">
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Strict Mode (default)</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground">
                Only notifies if the new value is different from the old one.
                Ideal for predictable change detection.
              </p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Non-Strict Mode</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground">
                Notifies on every modification, even if the value stays the same.
                Useful for forcing a refresh.
              </p>
            </CardContent>
          </Card>
        </div>
        <CodeBlock
          filename="strict_mode.dart"
          language="dart"
          code={`// Strict mode (default): strict = true
final strictCounter = Reactive(0);
strictCounter.value = 0; // No notification (same value)

// Non-strict mode: strict = false
final looseCounter = 0.rtNonStrict;
looseCounter.value = 0; // Notification triggered`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Type Extensions</h2>
        <p className="text-muted-foreground">
          Flutter Reactive provides convenient extensions based on data type:
        </p>
        
        <div className="space-y-4">
          <div>
            <h3 className="font-medium mb-2">Reactive&lt;bool&gt;</h3>
            <CodeBlock
              language="dart"
              code={`final enabled = true.rt;
enabled.toggle();   // Inverts the value
enabled.enable();   // true
enabled.disable();  // false
print(enabled.isTrue);  // true or false
print(enabled.isFalse); // inverse`}
            />
          </div>

          <div>
            <h3 className="font-medium mb-2">Reactive&lt;num&gt;</h3>
            <CodeBlock
              language="dart"
              code={`final count = 5.rt;
count.inc();        // +1
count.dec();        // -1
count.increment(3); // +3
count.clamp(0, 10); // Clamps between 0 and 10
print(count.isZero);
print(count.isPositive);

// Arithmetic operators
final sum = count + 5;
final product = count * 2;`}
            />
          </div>

          <div>
            <h3 className="font-medium mb-2">Reactive&lt;String&gt;</h3>
            <CodeBlock
              language="dart"
              code={`final text = 'hello'.rt;
text.append(' world');  // 'hello world'
text.prepend('Say: ');  // 'Say: hello world'
text.toUpper();         // 'SAY: HELLO WORLD'
text.toLower();         // 'say: hello world'
text.clear();           // ''
print(text.length);
print(text.isEmpty);`}
            />
          </div>

          <div>
            <h3 className="font-medium mb-2">Reactive&lt;List&gt; / Reactive&lt;Map&gt;</h3>
            <CodeBlock
              language="dart"
              code={`final items = <String>[].rt;
items.add('Item 1');
items.addAll(['Item 2', 'Item 3']);
items.remove('Item 1');
items.clear();

final data = <String, int>{}.rt;
data.put('key', 42);
data.remove('key');
print(data.has('key'));`}
            />
          </div>
        </div>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Next Step</h2>
        <div className="p-4 rounded-lg border border-border bg-card">
          <p className="text-muted-foreground">
            Learn how to bind your reactive values to Flutter States for automatic UI updates.
          </p>
          <Link 
            href="/concepts/binding" 
            className="inline-block mt-3 text-primary hover:underline font-medium"
          >
            Discover Binding &amp; Widgets &rarr;
          </Link>
        </div>
      </section>
    </div>
  )
}
