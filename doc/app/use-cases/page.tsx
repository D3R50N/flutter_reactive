import { CodeBlock } from "@/components/docs/code-block"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

export default function UseCasesPage() {
  return (
    <div className="space-y-10">
      <section className="space-y-4">
        <h1 className="text-3xl font-bold tracking-tight">Use Cases</h1>
        <p className="text-muted-foreground leading-relaxed">
          This page focuses on real workflows. If you want to know what to do
          when a value changes, when to listen, how to cancel, or how to roll
          back changes safely, start here.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">1. Live form validation</h2>
        <p className="text-muted-foreground">
          Use this when you want to reject invalid input immediately and show
          the user exactly what needs to be fixed.
        </p>
        <CodeBlock
          filename="signup_form.dart"
          language="dart"
          code={`class _SignUpFormState extends State<SignUpForm> {
  late final email = react('')
      .require((value) => value.isNotEmpty, 'Email is required')
      .require((value) => value.contains('@'), 'Invalid email format');

  String? emailError;

  void onEmailChanged(String value) {
    try {
      email.value = value;
      emailError = null;
    } on ReactiveValidatorError catch (error) {
      emailError = error.message;
    }
    updateState();
  }

  bool get canSubmit => emailError == null && email.value.isNotEmpty;
}`}
        />
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base">What this gives you</CardTitle>
          </CardHeader>
          <CardContent className="text-sm text-muted-foreground">
            Validation happens at the edge of the field, so the form button can
            stay disabled until the data is actually valid.
          </CardContent>
        </Card>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">2. Listen to changes, then cancel</h2>
        <p className="text-muted-foreground">
          Use this when you need to react to a value change outside the widget
          tree, for example to trigger a search, analytics event, or sync
          request. Keep the returned subscription and cancel it in
          <code className="mx-1 font-mono text-sm bg-muted px-1 py-0.5 rounded">dispose()</code>.
        </p>
        <CodeBlock
          filename="search_controller.dart"
          language="dart"
          code={`class _SearchPageState extends State<SearchPage> {
  late final query = react('');
  late final results = <Product>[].rtNonStrict;
  ReactiveSubscription<String>? querySubscription;

  @override
  void initState() {
    super.initState();

    querySubscription = query.debounce(300, (value) async {
      if (value.isEmpty) {
        results.clear();
        return;
      }

      results.value = await api.searchProducts(value);
    });
  }

  @override
  void dispose() {
    querySubscription?.cancel();
    query.dispose();
    results.dispose();
    super.dispose();
  }
}`}
        />
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base">Why this matters</CardTitle>
          </CardHeader>
          <CardContent className="text-sm text-muted-foreground">
            The subscription gives you a clean cancel path, so you do not keep
            reacting after the screen is gone.
          </CardContent>
        </Card>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">3. Let users cancel a change</h2>
        <p className="text-muted-foreground">
          Use checkpoints when someone starts editing and may want to revert
          later. Save the current value, let them edit, then restore the saved
          version if they press cancel.
        </p>
        <CodeBlock
          filename="profile_editor.dart"
          language="dart"
          code={`final profileName = react('Alice');

void beginEdit() {
  profileName.save('before-edit');
}

void cancelEdit() {
  profileName.restore('before-edit');
}

void commitEdit() {
  profileName.unsave('before-edit');
}`}
        />
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base">Practical pattern</CardTitle>
          </CardHeader>
          <CardContent className="text-sm text-muted-foreground">
            This is the simplest way to support an explicit cancel action after
            a temporary edit flow.
          </CardContent>
        </Card>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">4. Apply several changes atomically</h2>
        <p className="text-muted-foreground">
          Use a transaction when multiple values must stay in sync. If one step
          fails, the package rolls everything back automatically.
        </p>
        <CodeBlock
          filename="checkout.dart"
          language="dart"
          code={`await Reactive.run(() {
  cartTotal.value = cartTotal.value + 29.90;
  inventoryCount.dec();
  appliedCoupon.value = 'WELCOME10';
  if (inventoryCount.value < 0) {
    throw Exception('Out of stock');
  }
});`}
        />
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base">Rollback rule</CardTitle>
          </CardHeader>
          <CardContent className="text-sm text-muted-foreground">
            Only the values touched inside the transaction are part of the
            rollback. Keep every related mutation inside the callback.
          </CardContent>
        </Card>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">5. Share app state once, reuse everywhere</h2>
        <p className="text-muted-foreground">
          Use a dependency when you want a store-like object that can be reused
          across the app without passing it through every constructor.
        </p>
        <CodeBlock
          filename="auth_store.dart"
          language="dart"
          code={`class AuthStore extends ReactiveDependency {
  final user = ReactiveN<User>();
  final isLoading = false.rt;

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      user.value = await api.login(email, password);
    } finally {
      isLoading.value = false;
    }
  }
}

final authStore = AuthStore().dep;`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">6. Derive UI state instead of duplicating it</h2>
        <p className="text-muted-foreground">
          Use computed values for totals, labels, and status chips. They update
          automatically whenever the source values change.
        </p>
        <CodeBlock
          filename="cart_summary.dart"
          language="dart"
          code={`final subtotal = Reactive.combine2(
  cartItems,
  discountRate,
  (items, discount) => items.fold<double>(
    0,
    (sum, item) => sum + item.price,
  ) * (1 - discount),
);

final label = subtotal.as((value) => 'Subtotal: \\$\${value.toStringAsFixed(2)}');`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Feature map</h2>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border">
                <th className="text-left py-3 px-4 font-medium text-foreground">Feature</th>
                <th className="text-left py-3 px-4 font-medium text-foreground">Best for</th>
              </tr>
            </thead>
            <tbody>
              <FeatureRow feature="listen / once / when" use="Side effects, logging, syncing, and triggers" />
              <FeatureRow feature="debounce / throttle" use="Search bars, typing indicators, and rate-limited actions" />
              <FeatureRow feature="save / restore" use="Undo, draft editing, and cancel flows" />
              <FeatureRow feature="Reactive.run()" use="Atomic updates and automatic rollback" />
              <FeatureRow feature="require()" use="Validation and guardrails" />
              <FeatureRow feature="compute / combine / as" use="Derived totals and read-only summaries" />
              <FeatureRow feature="ReactiveDependency / RxDep" use="Stores and shared services" />
              <FeatureRow feature="mutate()" use="In-place updates on mutable models" />
              <FeatureRow feature="stream" use="StreamBuilder integration and stream-based APIs" />
            </tbody>
          </table>
        </div>
      </section>
    </div>
  )
}

function FeatureRow({ feature, use }: { feature: string; use: string }) {
  return (
    <tr className="border-b border-border/50">
      <td className="py-3 px-4 font-mono text-xs sm:text-sm">{feature}</td>
      <td className="py-3 px-4 text-muted-foreground">{use}</td>
    </tr>
  )
}
