import Link from "next/link"
import { CodeBlock } from "@/components/docs/code-block"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

export default function DependenciesPage() {
  return (
    <div className="space-y-10">
      <section className="space-y-4">
        <h1 className="text-3xl font-bold tracking-tight">
          ReactiveDependency (RxDep)
        </h1>
        <p className="text-muted-foreground leading-relaxed">
          Share stores and services across your app without wiring them through
          every constructor.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Why it exists</h2>
        <Card className="bg-primary/5 border-primary/20">
          <CardHeader className="pb-2">
            <CardTitle className="text-base text-primary">
              Lightweight dependency cache
            </CardTitle>
          </CardHeader>
          <CardContent className="text-sm text-muted-foreground">
            <p>
              <code className="font-mono bg-muted px-1 py-0.5 rounded">
                ReactiveDependency
              </code>{" "}
              gives you a tiny cache for objects that should be reused instead of
              recreated.
            </p>
          </CardContent>
        </Card>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Create a store</h2>
        <CodeBlock
          filename="user_store.dart"
          language="dart"
          code={`class UserStore extends ReactiveDependency {
  final name = ''.reactive();

  void updateName(String value) {
    name.value = value;
  }
}`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Register and reuse</h2>
        <CodeBlock
          filename="cache.dart"
          language="dart"
          code={`// Register with the .dependency extension
final userStore = UserStore().dependency;

// Register through the cache helper
final cachedStore = RxDep.use(() => UserStore());

// Reuse the cached instance later
final sameStore = UserStore().dep;
final foundStore = RxDep.of<UserStore>();`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Lifecycle hooks</h2>
        <p className="text-muted-foreground">
          Use <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">onCreate</code> and{" "}
          <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">onDispose</code> to manage setup and cleanup.
        </p>
        <CodeBlock
          filename="lifecycle.dart"
          language="dart"
          code={`class UserStore extends ReactiveDependency {
  final name = ''.reactive();

  @override
  void onCreate() {
    debugPrint('UserStore created');
  }

  @override
  void onDispose() {
    debugPrint('UserStore disposed');
  }
}

final userStore = UserStore().dep;
final sameStore = UserStore().dep;

RxDep.drop<UserStore>();
userStore.dispose();`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Utility methods</h2>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border">
                <th className="text-left py-3 px-4 font-medium text-foreground">
                  Method
                </th>
                <th className="text-left py-3 px-4 font-medium text-foreground">
                  Description
                </th>
              </tr>
            </thead>
            <tbody>
              <tr className="border-b border-border/50">
                <td className="py-3 px-4">
                  <code className="text-accent">RxDep.has&lt;T&gt;()</code>
                </td>
                <td className="py-3 px-4 text-muted-foreground">
                  Checks whether a type is currently cached
                </td>
              </tr>
              <tr className="border-b border-border/50">
                <td className="py-3 px-4">
                  <code className="text-accent">RxDep.of&lt;T&gt;()</code>
                </td>
                <td className="py-3 px-4 text-muted-foreground">
                  Returns the cached instance for a type
                </td>
              </tr>
              <tr className="border-b border-border/50">
                <td className="py-3 px-4">
                  <code className="text-accent">RxDep.drop&lt;T&gt;()</code>
                </td>
                <td className="py-3 px-4 text-muted-foreground">
                  Removes and disposes a cached instance
                </td>
              </tr>
              <tr className="border-b border-border/50">
                <td className="py-3 px-4">
                  <code className="text-accent">RxDep.clear()</code>
                </td>
                <td className="py-3 px-4 text-muted-foreground">
                  Clears the full cache
                </td>
              </tr>
              <tr className="border-b border-border/50">
                <td className="py-3 px-4">
                  <code className="text-accent">RxDep.use(() =&gt; T())</code>
                </td>
                <td className="py-3 px-4 text-muted-foreground">
                  Creates or reuses an instance from a factory
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Practical example</h2>
        <CodeBlock
          filename="auth_store.dart"
          language="dart"
          code={`class AuthStore extends ReactiveDependency {
  final user = ReactiveN<User>();
  final isLoading = false.rx;

  bool get isLoggedIn => user.value != null;

  @override
  void onCreate() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    isLoading.value = true;
    final loadedUser = await LocalStorage.getUser();
    user.value = loadedUser;
    isLoading.value = false;
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final loadedUser = await Api.login(email, password);
      user.value = loadedUser;
      await LocalStorage.saveUser(loadedUser);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    user.value = null;
    await LocalStorage.clearUser();
  }

  @override
  void onDispose() {
    user.dispose();
    isLoading.dispose();
  }
}

final authStore = AuthStore().dep;

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Rxb(() {
      if (authStore.isLoading.value) {
        return const CircularProgressIndicator();
      }

      final currentUser = authStore.user.value;
      if (currentUser == null) {
        return const Text('Please sign in');
      }

      return Text('Welcome, \${currentUser.name}!');
    });
  }
}`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Next Step</h2>
        <div className="p-4 rounded-lg border border-border bg-card">
          <p className="text-muted-foreground">
            Now that your shared stores are in place, explore the examples for
            end-to-end usage.
          </p>
          <Link
            href="/examples/counter"
            className="inline-block mt-3 text-primary hover:underline font-medium"
          >
            View Examples &rarr;
          </Link>
        </div>
      </section>
    </div>
  )
}
