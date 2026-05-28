import { CodeBlock } from "@/components/docs/code-block"
import Link from "next/link"

export default function FormExamplePage() {
  return (
    <div className="space-y-10">
      <section className="space-y-4">
        <div className="text-sm text-muted-foreground">Examples</div>
        <h1 className="text-3xl font-bold tracking-tight">Form with Validation</h1>
        <p className="text-muted-foreground leading-relaxed">
          A complete sign-up form with real-time validation and error handling.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Full Code</h2>
        <CodeBlock
          filename="signup_form.dart"
          language="dart"
          code={`import 'package:flutter/material.dart';
import 'package:flutter_reactive/flutter_reactive.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  // Reactive fields with validation
  late final email = react('')
      .require((v) => v.isNotEmpty, 'Email required')
      .require((v) => v.contains('@'), 'Invalid email format')
      .require((v) => v.contains('.'), 'Domain required');

  late final password = react('')
      .require((v) => v.length >= 8, 'Minimum 8 characters')
      .require(
        (v) => v.contains(RegExp(r'[A-Z]')),
        'At least one uppercase letter',
      )
      .require(
        (v) => v.contains(RegExp(r'[0-9]')),
        'At least one number',
      );

  late final confirmPassword = react('');

  late final acceptTerms = react(false);

  // Error states
  String? emailError;
  String? passwordError;
  String? confirmError;

  // Submission state
  bool isSubmitting = false;

  // Entire form validity
  bool get isFormValid =>
      emailError == null &&
      passwordError == null &&
      confirmError == null &&
      email.value.isNotEmpty &&
      password.value.isNotEmpty &&
      password.value == confirmPassword.value &&
      acceptTerms.value;

  void validateEmail(String value) {
    try {
      email.value = value;
      emailError = null;
    } on ReactiveValidatorError catch (e) {
      emailError = e.message;
    }
    updateState();
  }

  void validatePassword(String value) {
    try {
      password.value = value;
      passwordError = null;
    } on ReactiveValidatorError catch (e) {
      passwordError = e.message;
    }
    // Revalidate confirmation if it exists
    if (confirmPassword.value.isNotEmpty) {
      validateConfirmPassword(confirmPassword.value);
    }
    updateState();
  }

  void validateConfirmPassword(String value) {
    confirmPassword.value = value;
    if (value != password.value) {
      confirmError = 'Passwords do not match';
    } else {
      confirmError = null;
    }
    updateState();
  }

  Future<void> submitForm() async {
    if (!isFormValid) return;

    isSubmitting = true;
    updateState();

    // Simulate an API call
    await Future.delayed(const Duration(seconds: 2));

    isSubmitting = false;
    updateState();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign-up successful!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email
            TextField(
              onChanged: validateEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                errorText: emailError,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Password
            TextField(
              onChanged: validatePassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                errorText: passwordError,
                border: const OutlineInputBorder(),
                helperText: '8+ characters, 1 uppercase letter, 1 number',
              ),
            ),
            const SizedBox(height: 16),

            // Confirm password
            TextField(
              onChanged: validateConfirmPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm password',
                prefixIcon: const Icon(Icons.lock_outline),
                errorText: confirmError,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Terms checkbox
            Row(
              children: [
                Checkbox(
                  value: acceptTerms.value,
                  onChanged: (v) => acceptTerms.value = v ?? false,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => acceptTerms.toggle(),
                    child: const Text(
                      "I accept the terms of service",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: isFormValid && !isSubmitting ? submitForm : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Create account"),
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
        <h2 className="text-xl font-semibold">Key Takeaways</h2>
        <ul className="space-y-2 text-muted-foreground list-disc list-inside">
          <li>Chain validators with <code className="font-mono text-sm bg-muted px-1 py-0.5 rounded">.require()</code></li>
          <li>Validate in real time as the user types</li>
          <li>Handle errors with <code className="font-mono text-sm bg-muted px-1 py-0.5 rounded">ReactiveValidatorError</code></li>
          <li>Use the derived <code className="font-mono text-sm bg-muted px-1 py-0.5 rounded">isFormValid</code> state for the button</li>
          <li>Use <code className="font-mono text-sm bg-muted px-1 py-0.5 rounded">.toggle()</code> for the checkbox</li>
        </ul>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Next Example</h2>
        <div className="p-4 rounded-lg border border-border bg-card">
          <p className="text-muted-foreground">
            See how to build a todo list with add, delete, and filtering.
          </p>
          <Link 
            href="/examples/todo" 
            className="inline-block mt-3 text-primary hover:underline font-medium"
          >
            Todo List Example →
          </Link>
        </div>
      </section>
    </div>
  )
}
