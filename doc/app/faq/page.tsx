import { CodeBlock } from "@/components/docs/code-block";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import Link from "next/link";

const faqItems = [
  {
    category: "Getting Started",
    questions: [
      {
        question:
          "What is the difference between `Reactive<T>` and `ReactiveN<T>`?",
        answer: `\`Reactive<T>\` is for non-nullable values and requires an initial value.
\`ReactiveN<T>\` accepts \`null\` and can be created without an initial value.

Use \`ReactiveN\` when a value can genuinely be absent, such as a logged-out user or an empty optional field.`,
        code: `// Non-nullable - initial value required
final counter = Reactive(0);
final shortHand = 0.rt;

// Nullable - can be null
final user = ReactiveN<User>();
print(user.value); // null`,
      },
      {
        question: "Should I always use `react()` instead of `Reactive()`?",
        answer: `\`react()\` is a \`State\` extension that creates a reactive value and binds it to the current widget state.
It is convenient, but it is not mandatory.

Use \`Reactive()\` directly when:
- you want a global reactive value outside a widget
- you want manual binding for fine-grained control
- you are using \`ReactiveBuilder\` without a \`State\` object`,
        code: `// With react() - auto-bound to the State
class _MyState extends State<MyWidget> {
  late final counter = react(0);
}

// With Reactive() - global or manually bound
final globalCounter = Reactive(0);`,
      },
      {
        question: "How do I migrate from 0.x to 1.0?",
        answer: `The main 1.0 changes are:

1. \`ReactiveBuilder\` is now the main API, with \`Rxb\` as a shorter alias
2. \`computed()\` became \`compute()\`
3. \`.reactive()\` became \`.rt\`
4. \`listen()\` can emit immediately with a second argument
5. \`extensions/list.dart\` became \`extensions/iterable.dart\`
6. New aliases include \`Rxb\`, \`Rxsb\`, and \`RxDep\``,
        code: `// Before (0.x)
ReactiveBuilder<int>(
  reactive: counter,
  builder: (value) => Text('\$value'),
);

// After (1.0) - with Rxb
Rxb.watch(
  counter,
  (value) => Text('\$value'),
);

// Or automatic tracking
Rxb(() => Text('\${counter.value}'));

// Before
final count = 0.reactive();
final total = Reactive.computed(() => a.value + b.value);

// After
final shortHand = 0.rx;
final count = 0.rx;
final total = Reactive.compute(() => a.value + b.value);`,
      },
    ],
  },
  {
    category: "Performance",
    questions: [
      {
        question: "How do I avoid unnecessary rebuilds?",
        answer: `Flutter Reactive is designed to minimize rebuilds:

1. **Strict mode is on by default**: equal values do not notify
2. **Use small builders**: keep the reactive read close to the widget that needs it
3. **Avoid recreating reactives in build()**: create them once and reuse them`,
        code: `// Bad: rebuilds the whole widget tree
class _State extends State<Widget> {
  late final data = react(complexObject);

  Widget build(context) {
    return Column(
      children: [
        Text(data.value.title),
        Text(data.value.count.toString()),
      ],
    );
  }
}

// Good: targeted builders
Widget build(context) {
  return Column(
    children: [
      data.build((item) => Text(item.title)),
      data.build((item) => Text(item.count.toString())),
    ],
  );
}`,
      },
      {
        question: "Is `Reactive.compute()` performant?",
        answer: `Yes. \`compute()\` automatically tracks dependencies and only recalculates when one of them changes.

For expensive work, keep the computation lightweight, debounce the input, or move the heavy processing away from the UI thread.`,
        code: `// compute() tracks rA and rB automatically
final sum = Reactive.compute(() => rA.value + rB.value);

// For expensive work, debounce first
rInput.debounce(300, (value) async {
  final result = await heavyComputation(value);
  rResult.value = result;
});`,
      },
      {
        question: "How do I handle large reactive lists?",
        answer: `For large lists:

1. Prefer mutation helpers instead of rebuilding the entire list
2. Use identifiers to target the item you want to update
3. Paginate long datasets
4. Use ListView.builder or another virtualized list in Flutter`,
        code: `// Bad: recreate the whole list every time
rItems.value = [...rItems.value, newItem];

// Good: use the helper
rItems.add(newItem);

// Good: update one item
final index = rItems.value.indexWhere((item) => item.id == id);
rItems[index] = updatedItem;`,
      },
    ],
  },
  {
    category: "Common Issues",
    questions: [
      {
        question: 'Why am I seeing "Reactive is already disposed"?',
        answer: `This usually happens when a reactive value is used after \`dispose()\` was called, or when a widget-bound reactive is updated after the widget is gone.

**Fixes:**
1. Do not use the reactive after disposal
2. Do not dispose shared/global reactives too early
3. Check \`mounted\` before writing from async callbacks`,
        code: `// Bad: value is updated after the widget is gone
Future<void> loadData() async {
  final data = await api.fetch();
  rData.value = data;
}

// Good: guard with mounted
Future<void> loadData() async {
  final data = await api.fetch();
  if (mounted) {
    rData.value = data;
  }
}`,
      },
      {
        question: "Why is my UI not updating?",
        answer: `The most common reasons are:

1. The reactive is not bound: did you use \`react()\` or \`bind()\`?
2. Strict mode ignored the assignment because the value did not change
3. You mutated an object in place without notifying
4. The widget does not read the value inside \`build()\` or a reactive builder`,
        code: `// Bad: mutating an object in place without a notification
rUser.value.name = 'New Name'; // No rebuild

// Good: create a new value
rUser.value = rUser.value.copyWith(name: 'New Name');

// Or use mutate() when in-place mutation is intentional
rUser.mutate((user) => user.name = 'New Name');`,
      },
      {
        question: "Why is `ReactiveValidatorError` not being caught?",
        answer: `\`ReactiveValidatorError\` is thrown synchronously. Make sure you:

1. Wrap the assignment in try/catch
2. Catch the correct exception type
3. Do not expect await to catch a synchronous validation error`,
        code: `// Bad: missing or generic catch
rCounter.value = -1;

// Good: catch the specific error
try {
  rCounter.value = -1;
} on ReactiveValidatorError catch (error) {
  print('Error: \${error.message}');
  print('Invalid value: \${error.value}');
}`,
      },
      {
        question: "Why is my transaction rollback not working?",
        answer: `Rollback in \`Reactive.run()\` only applies to reactives modified during the transaction itself.

**Check that:**
1. Every related mutation is inside the \`run()\` callback
2. You did not disable \`rollbackOnError\`
3. The error is actually thrown and not swallowed`,
        code: `// Bad: one mutation happens outside the transaction
rA.value = 10; // Not part of rollback
await Reactive.run(() {
  rB.value = 20;
  throw Exception('Oops');
});

// Good: everything happens inside the transaction
await Reactive.run(() {
  rA.value = 10;
  rB.value = 20;
  throw Exception('Oops');
});`,
      },
    ],
  },
  {
    category: "Patterns and Debugging",
    questions: [
      {
        question: "How do I listen to changes and cancel later?",
        answer: `Use \`listen()\` when you want a side effect that is not tied to the widget tree. Keep the returned subscription and call \`cancel()\` when you no longer need it.

This is the right pattern for search requests, analytics, syncing, and other imperative reactions.`,
        code: `final subscription = query.listen((value) {
  debugPrint('Query changed: \$value');
}, true);

// Later, when the screen is closed or the work is no longer needed
subscription.cancel();`,
      },
      {
        question: "How do I share a reactive value across widgets?",
        answer: `There are a few good options:

1. A global reactive value for simple cases
2. Constructor injection for explicit and testable code
3. \`ReactiveDependency\` / \`RxDep\` for reusable stores and service objects`,
        code: `// Global
final appState = Reactive(AppState());

// Injection
class MyWidget extends StatefulWidget {
  final Reactive<int> counter;
  const MyWidget({required this.counter});
}

// Shared store
final authStore = AuthStore().dep;`,
      },
      {
        question: "How do I test code that uses Flutter Reactive?",
        answer: `Reactive values are plain Dart objects, so they are easy to test:

1. Create the reactive in the test
2. Change the value
3. Assert on the result or the listener output`,
        code: `test('counter increments', () {
  final counter = Reactive(0);

  counter.inc();
  expect(counter.value, equals(1));

  counter.inc(5);
  expect(counter.value, equals(6));
});

test('validation rejects invalid values', () {
  final age = Reactive(0)
      .require((value) => value >= 0, 'Must be positive');

  expect(
    () => age.value = -1,
    throwsA(isA<ReactiveValidatorError>()),
  );
});`,
      },
      {
        question: "How do I debug reactive notifications?",
        answer: `Start with \`listen()\` and print the values. You can also add breakpoints inside the callbacks or temporarily use \`rtNonStrict\` to see every assignment.`,
        code: `counter.listen((value) {
  debugPrint('[DEBUG] counter = \$value');
});

counter.listen((value) {
  debugPrint('[DEBUG] counter changed to: \$value');
  debugPrint(StackTrace.current.toString());
});

final debugCounter = 0.rtNonStrict;`,
      },
    ],
  },
];

export default function FAQPage() {
  return (
    <div className="space-y-10">
      <section className="space-y-4">
        <h1 className="text-3xl font-bold tracking-tight">FAQ</h1>
        <p className="text-muted-foreground leading-relaxed">
          Common questions about Flutter Reactive, with practical answers and
          concrete code you can copy into your own project.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-lg font-semibold">Categories</h2>
        <div className="flex flex-wrap gap-2">
          {faqItems.map((cat) => (
            <a
              key={cat.category}
              href={`#${cat.category.toLowerCase().replace(/\s+/g, "-")}`}
              className="px-3 py-1.5 text-sm rounded-full bg-muted hover:bg-accent transition-colors"
            >
              {cat.category}
            </a>
          ))}
        </div>
      </section>

      {faqItems.map((category) => (
        <section
          key={category.category}
          id={category.category.toLowerCase().replace(/\s+/g, "-")}
          className="space-y-4"
        >
          <h2 className="text-xl font-semibold">{category.category}</h2>
          <Accordion type="single" collapsible className="space-y-2">
            {category.questions.map((item, index) => (
              <AccordionItem
                key={index}
                value={`${category.category}-${index}`}
                className="border! border-border rounded-lg"
              >
                <AccordionTrigger className="text-left hover:no-underline  px-4 ">
                  {renderAnswer(item.question)}
                </AccordionTrigger>
                <AccordionContent className="space-y-4 pt-2  px-4">
                  <div className="text-muted-foreground space-y-3">
                    {renderAnswer(item.answer)}
                  </div>
                  {item.code && <CodeBlock code={item.code} language="dart" />}
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </section>
      ))}

      <section className="space-y-4">
        <Card className="bg-primary/5 border-primary/20">
          <CardHeader>
            <CardTitle className="text-lg">Still need help?</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <p className="text-muted-foreground">
              If your question is not listed here, you can:
            </p>
            <ul className="space-y-2 text-muted-foreground list-disc list-inside">
              <li>
                Check the{" "}
                <a
                  href="https://pub.dev/documentation/flutter_reactive/latest/"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-primary hover:underline"
                >
                  complete API reference
                </a>
              </li>
              <li>
                Open an issue on{" "}
                <a
                  href="https://github.com"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-primary hover:underline"
                >
                  GitHub
                </a>
              </li>
            </ul>
          </CardContent>
        </Card>
      </section>

      <section className="pt-4">
        <Link href="/" className="text-primary hover:underline font-medium">
          ← Back to introduction
        </Link>
      </section>
    </div>
  );
}

function renderAnswer(answer: string) {
  const lines = answer.split("\n");
  const blocks: React.ReactNode[] = [];
  let currentList: { type: "ul" | "ol"; items: string[] } | null = null;

  const flushList = () => {
    if (!currentList) return;

    if (currentList.type === "ul") {
      blocks.push(
        <ul key={`list-${blocks.length}`} className="space-y-2 pl-5 list-disc">
          {currentList.items.map((item, index) => (
            <li key={index}>{renderInline(item)}</li>
          ))}
        </ul>,
      );
    } else {
      blocks.push(
        <ol
          key={`list-${blocks.length}`}
          className="space-y-2 pl-5 list-decimal"
        >
          {currentList.items.map((item, index) => (
            <li key={index}>{renderInline(item)}</li>
          ))}
        </ol>,
      );
    }
    currentList = null;
  };

  for (const line of lines) {
    const trimmed = line.trim();

    if (!trimmed) {
      flushList();
      continue;
    }

    const unorderedMatch = trimmed.match(/^-\s+(.*)$/);
    const orderedMatch = trimmed.match(/^\d+\.\s+(.*)$/);

    if (unorderedMatch || orderedMatch) {
      const type = unorderedMatch ? "ul" : "ol";
      const content = (unorderedMatch ?? orderedMatch)![1];
      if (!currentList || currentList.type !== type) {
        flushList();
        currentList = { type, items: [] };
      }
      currentList.items.push(content);
      continue;
    }

    flushList();
    blocks.push(
      <p key={`p-${blocks.length}`} className="leading-relaxed">
        {renderInline(trimmed)}
      </p>,
    );
  }

  flushList();
  return blocks;
}

function renderInline(text: string) {
  const parts: React.ReactNode[] = [];
  const pattern = /(`[^`]+`|\*\*[^*]+\*\*)/g;
  let lastIndex = 0;

  for (const match of text.matchAll(pattern)) {
    const token = match[0];
    const index = match.index ?? 0;

    if (index > lastIndex) {
      parts.push(text.slice(lastIndex, index));
    }

    if (token.startsWith("**") && token.endsWith("**")) {
      parts.push(
        <strong
          key={`${index}-${token}`.replace(/\s+/g, "-")}
          className="font-semibold text-foreground"
        >
          {token.slice(2, -2)}
        </strong>,
      );
    } else if (token.startsWith("`") && token.endsWith("`")) {
      parts.push(
        <code
          key={`${index}-${token}`.replace(/\s+/g, "-")}
          className="mx-0.5 rounded bg-muted px-1 py-0.5 font-mono text-sm text-foreground"
        >
          {token.slice(1, -1)}
        </code>,
      );
    }

    lastIndex = index + token.length;
  }

  if (lastIndex < text.length) {
    parts.push(text.slice(lastIndex));
  }

  return parts.length > 0 ? parts : text;
}
