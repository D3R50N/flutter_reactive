import { CodeBlock } from "@/components/docs/code-block"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import Link from "next/link"

export default function ValidationPage() {
  return (
    <div className="space-y-10">
      <section className="space-y-4">
        <h1 className="text-3xl font-bold tracking-tight">Validation</h1>
        <p className="text-muted-foreground leading-relaxed">
          Flutter Reactive includes a powerful validation system. Add rules with 
          <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded ml-1">.require()</code> to 
          prevent invalid values from being assigned.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Adding Validators</h2>
        <p className="text-muted-foreground">
          Chain multiple validators with <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">.require()</code>:
        </p>
        <CodeBlock
          filename="validators.dart"
          language="dart"
          code={`final counter = 0
    .rt
    .require((v) => v >= 0, 'Counter cannot be negative')
    .require((v) => v <= 100, 'Counter must be <= 100');

final email = ''.rt
    .require((v) => v.isNotEmpty, 'Email required')
    .require((v) => v.contains('@'), 'Invalid email');

final password = ''.rt
    .require((v) => v.length >= 8, 'Minimum 8 characters')
    .require((v) => v.contains(RegExp(r'[A-Z]')), 'At least one uppercase')
    .require((v) => v.contains(RegExp(r'[0-9]')), 'At least one digit');`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Handling Validation Errors</h2>
        <p className="text-muted-foreground">
          When validation fails, a <code className="font-mono text-sm bg-muted px-1.5 py-0.5 rounded">ReactiveValidatorError</code> is thrown:
        </p>
        <CodeBlock
          filename="handle_errors.dart"
          language="dart"
          code={`final counter = 0
    .rt
    .require((v) => v >= 0, 'Must be positive')
    .require((v) => v <= 10, 'Must be <= 10');

try {
  counter.value = 11; // Fails!
} on ReactiveValidatorError catch (e) {
  debugPrint('Message: \${e.message}');     // 'Must be <= 10'
  debugPrint('Invalid value: \${e.value}'); // 11
}

// Value remains unchanged after error
debugPrint('Current value: \${counter.value}'); // 0`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Practical Example: Form</h2>
        <CodeBlock
          filename="form_validation.dart"
          language="dart"
          code={`class _SignUpFormState extends State<SignUpForm> {
  late final email = react('')
      .require((v) => v.isNotEmpty, 'Email required')
      .require((v) => v.contains('@'), 'Invalid email format');
  
  late final password = react('')
      .require((v) => v.length >= 8, '8 characters minimum')
      .require((v) => v.contains(RegExp(r'[A-Z]')), 'One uppercase required');
  
  String? emailError;
  String? passwordError;

  void submitForm() {
    emailError = null;
    passwordError = null;
    
    try {
      // Validate by assigning current values
      email.value = email.value;
    } on ReactiveValidatorError catch (e) {
      emailError = e.message;
    }
    
    try {
      password.value = password.value;
    } on ReactiveValidatorError catch (e) {
      passwordError = e.message;
    }
    
    if (emailError == null && passwordError == null) {
      // Everything is valid, submit!
      print('Form submitted!');
    }
    
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: (v) {
            try {
              email.value = v;
              emailError = null;
            } on ReactiveValidatorError catch (e) {
              emailError = e.message;
            }
            updateState();
          },
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: emailError,
          ),
        ),
        TextField(
          obscureText: true,
          onChanged: (v) {
            try {
              password.value = v;
              passwordError = null;
            } on ReactiveValidatorError catch (e) {
              passwordError = e.message;
            }
            updateState();
          },
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: passwordError,
          ),
        ),
        ElevatedButton(
          onPressed: submitForm,
          child: Text('Sign Up'),
        ),
      ],
    );
  }
}`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Best Practices</h2>
        <div className="grid gap-4 sm:grid-cols-2">
          <Card>
            <CardHeader>
              <CardTitle className="text-base text-green-500">Do</CardTitle>
            </CardHeader>
            <CardContent className="text-sm text-muted-foreground space-y-2">
              <p>Clear error messages for users</p>
              <p>Validate as the user types</p>
              <p>Combine with transactions for rollback</p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader>
              <CardTitle className="text-base text-destructive">Don&apos;t</CardTitle>
            </CardHeader>
            <CardContent className="text-sm text-muted-foreground space-y-2">
              <p>Ignore validation errors</p>
              <p>Put complex validations in require()</p>
              <p>Forget to try/catch when assigning</p>
            </CardContent>
          </Card>
        </div>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Next Step</h2>
        <div className="p-4 rounded-lg border border-border bg-card">
          <p className="text-muted-foreground">
            Learn how to create derived states that update automatically.
          </p>
          <Link 
            href="/concepts/derived" 
            className="inline-block mt-3 text-primary hover:underline font-medium"
          >
            Discover Derived State &rarr;
          </Link>
        </div>
      </section>
    </div>
  )
}
