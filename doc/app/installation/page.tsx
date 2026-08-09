import { CodeBlock } from "@/components/docs/code-block"
import Link from "next/link"

export default function InstallationPage() {
  return (
    <div className="space-y-10">
      <section className="space-y-4">
        <h1 className="text-3xl font-bold tracking-tight">Installation</h1>
        <p className="text-muted-foreground leading-relaxed">
          Install Flutter Reactive in your Flutter project in seconds.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Via Command Line</h2>
        <p className="text-muted-foreground">
          The easiest way is to use the <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">dart pub add</code> command:
        </p>
        <CodeBlock
          code="dart pub add flutter_reactive"
          language="bash"
          filename="Terminal"
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Via pubspec.yaml</h2>
        <p className="text-muted-foreground">
          You can also manually add the dependency to your <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">pubspec.yaml</code> file:
        </p>
        <CodeBlock
          filename="pubspec.yaml"
          language="yaml"
          code={`dependencies:
  flutter_reactive: ^2.0.0`}
        />
        <p className="text-muted-foreground">
          Then run:
        </p>
        <CodeBlock
          code="flutter pub get"
          language="bash"
          filename="Terminal"
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Import</h2>
        <p className="text-muted-foreground">
          Once installed, import the package in your Dart files:
        </p>
        <CodeBlock
          filename="main.dart"
          language="dart"
          code={`import 'package:flutter_reactive/flutter_reactive.dart';`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Optional Extensions</h2>
        <p className="text-muted-foreground">
          Some extensions are not exported by default. Import them directly if needed:
        </p>
        <CodeBlock
          filename="imports.dart"
          language="dart"
          code={`// DateTime extensions
import 'package:flutter_reactive/extensions/datetime.dart';

// Duration extensions
import 'package:flutter_reactive/extensions/duration.dart';

// Color extensions
import 'package:flutter_reactive/extensions/color.dart';`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Next Step</h2>
        <div className="p-4 rounded-lg border border-border bg-card">
          <p className="text-muted-foreground">
            Now that Flutter Reactive is installed, learn how to create your first reactive values.
          </p>
          <Link 
            href="/concepts/reactive" 
            className="inline-block mt-3 text-primary hover:underline font-medium"
          >
            Discover Reactive &amp; ReactiveN &rarr;
          </Link>
        </div>
      </section>
    </div>
  )
}
