import { CodeBlock } from "@/components/docs/code-block";
import { Badge } from "@/components/ui/badge";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Code, Layers, Package, RefreshCw } from "lucide-react";
import Link from "next/link";

export default function HomePage() {
  return (
    <div className="space-y-12">
      <section className="space-y-4">
        <div className="flex items-center gap-3">
          <Badge
            variant="secondary"
            className="bg-primary/10 text-primary border-primary/20"
          >
            v1.0.4
          </Badge>
          <Badge variant="outline">Stable</Badge>
        </div>
        <h1 className="text-4xl font-bold tracking-tight text-balance">
          Flutter Reactive
        </h1>
        <p className="text-xl text-muted-foreground leading-relaxed text-pretty max-w-2xl">
          Say goodbye to repetitive{" "}
          <code className="text-primary font-mono">setState()</code> calls.
          Flutter Reactive keeps your state local, your shared stores reusable,
          and your UI updates predictable.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-lg font-semibold">Quick Install</h2>
        <CodeBlock
          code="dart pub add flutter_reactive"
          language="bash"
          filename="Terminal"
        />
      </section>

      <section className="space-y-6">
        <div className="flex items-center justify-between gap-4">
          <div>
            <h2 className="text-2xl font-bold">Main Use Cases</h2>
            <p className="text-muted-foreground mt-1">
              Concrete workflows you can ship with the package today.
            </p>
          </div>
          <Link
            href="/use-cases"
            className="text-primary hover:underline font-medium text-sm"
          >
            Open the full guide
          </Link>
        </div>
        <div className="grid gap-4 md:grid-cols-2">
          <UseCaseCard
            icon={<Code className="h-5 w-5" />}
            title="Forms with live validation"
            description="Validate as users type, surface field errors immediately, and block invalid submit actions."
            href="/use-cases"
          />
          <UseCaseCard
            icon={<RefreshCw className="h-5 w-5" />}
            title="Transactional updates"
            description="Group several changes, then rollback everything if one step fails."
            href="/concepts/transactions"
          />
          <UseCaseCard
            icon={<Layers className="h-5 w-5" />}
            title="Derived totals and labels"
            description="Build totals, summaries, and status chips from source reactives."
            href="/concepts/derived"
          />
          <UseCaseCard
            icon={<Package className="h-5 w-5" />}
            title="Shared stores and services"
            description="Keep app-wide state in one place with lightweight dependency caching."
            href="/concepts/dependencies"
          />
        </div>
      </section>

      <section className="space-y-6">
        <h2 className="text-2xl font-bold">Quick Example</h2>
        <CodeBlock
          filename="counter_page.dart"
          language="dart"
          code={`class _CounterPageState extends State<CounterPage> {
  late final counter = react(0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Counter: \${counter.value}'),
        ElevatedButton(
          onPressed: () => counter.inc(),
          child: Text('Increment'),
        ),
      ],
    );
  }
}`}
        />
      </section>

      <section className="space-y-6">
        <h2 className="text-2xl font-bold">Comparison</h2>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border">
                <th className="text-left py-3 px-2 font-medium">Feature</th>
                <th className="text-center py-3 px-2 font-medium text-primary">
                  Flutter Reactive
                </th>
                <th className="text-center py-3 px-2 font-medium text-muted-foreground">
                  GetX
                </th>
                <th className="text-center py-3 px-2 font-medium text-muted-foreground">
                  Provider
                </th>
                <th className="text-center py-3 px-2 font-medium text-muted-foreground">
                  Bloc
                </th>
              </tr>
            </thead>
            <tbody>
              <ComparisonRow
                label="Minimal boilerplate"
                values={[true, true, false, false]}
              />
              <ComparisonRow
                label="Easy to learn"
                values={[true, true, true, false]}
              />
              <ComparisonRow
                label="Built-in reactivity"
                values={[true, false, false, false]}
              />
              <ComparisonRow
                label="Automatic UI updates"
                values={[true, true, false, true]}
              />
              <ComparisonRow
                label="Zero external dependencies"
                values={[true, false, false, false]}
              />
              <ComparisonRow
                label="Derived values"
                values={[true, false, false, false]}
              />
              <ComparisonRow
                label="Side effects and streams"
                values={[true, true, false, true]}
              />
              <ComparisonRow
                label="Transactions / rollback"
                values={[true, false, false, false]}
              />
              <ComparisonRow
                label="Save / restore checkpoints"
                values={[true, false, false, false]}
              />
              <ComparisonRow
                label="Shared dependencies"
                values={[true, false, false, false]}
              />
            </tbody>
          </table>
        </div>
      </section>

      <section className="space-y-4">
        <h2 className="text-2xl font-bold">Next Steps</h2>
        <div className="grid gap-3 sm:grid-cols-2">
          <Link
            href="/installation"
            className="group p-4 rounded-lg border border-border bg-card hover:bg-accent transition-colors"
          >
            <h3 className="font-medium group-hover:text-primary transition-colors">
              Installation
            </h3>
            <p className="text-sm text-muted-foreground mt-1">
              Set up Flutter Reactive in your project.
            </p>
          </Link>
          <Link
            href="/use-cases"
            className="group p-4 rounded-lg border border-border bg-card hover:bg-accent transition-colors"
          >
            <h3 className="font-medium group-hover:text-primary transition-colors">
              Use Cases
            </h3>
            <p className="text-sm text-muted-foreground mt-1">
              Follow concrete workflows instead of only API snippets.
            </p>
          </Link>
        </div>
      </section>
    </div>
  );
}

function FeatureCard({
  icon,
  title,
  description,
  href,
}: {
  icon: React.ReactNode;
  title: string;
  description: string;
  href: string;
}) {
  return (
    <Link href={href}>
      <Card className="h-full hover:bg-accent/50 transition-colors cursor-pointer group">
        <CardHeader className="pb-2">
          <div className="flex items-center gap-3">
            <div className="p-2 rounded-md bg-primary/10 text-primary group-hover:bg-primary group-hover:text-primary-foreground transition-colors">
              {icon}
            </div>
            <CardTitle className="text-base">{title}</CardTitle>
          </div>
        </CardHeader>
        <CardContent>
          <CardDescription>{description}</CardDescription>
        </CardContent>
      </Card>
    </Link>
  );
}

function UseCaseCard({
  icon,
  title,
  description,
  href,
}: {
  icon: React.ReactNode;
  title: string;
  description: string;
  href: string;
}) {
  return (
    <Link href={href}>
      <Card className="h-full hover:bg-accent/50 transition-colors cursor-pointer group">
        <CardHeader className="pb-2">
          <div className="flex items-center gap-3">
            <div className="p-2 rounded-md bg-primary/10 text-primary group-hover:bg-primary group-hover:text-primary-foreground transition-colors">
              {icon}
            </div>
            <CardTitle className="text-base">{title}</CardTitle>
          </div>
        </CardHeader>
        <CardContent>
          <CardDescription>{description}</CardDescription>
        </CardContent>
      </Card>
    </Link>
  );
}

function ComparisonRow({
  label,
  values,
}: {
  label: string;
  values: boolean[];
}) {
  return (
    <tr className="border-b border-border">
      <td className="py-3 px-2 text-muted-foreground">{label}</td>
      {values.map((value, index) => (
        <td key={index} className="text-center py-3 px-2">
          {value ? (
            <span className="text-green-500">Yes</span>
          ) : (
            <span className="text-muted-foreground/50">No</span>
          )}
        </td>
      ))}
    </tr>
  );
}
