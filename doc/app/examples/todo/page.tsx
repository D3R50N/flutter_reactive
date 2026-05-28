import { CodeBlock } from "@/components/docs/code-block"
import Link from "next/link"

export default function TodoExamplePage() {
  return (
    <div className="space-y-10">
      <section className="space-y-4">
        <div className="text-sm text-muted-foreground">Examples</div>
        <h1 className="text-3xl font-bold tracking-tight">Todo List</h1>
        <p className="text-muted-foreground leading-relaxed">
          A practical todo list with add, remove, filtering, and derived
          statistics.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Data Model</h2>
        <CodeBlock
          filename="todo_model.dart"
          language="dart"
          code={`class Todo {
  final String id;
  final String title;
  final bool completed;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.completed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Todo copyWith({
    String? title,
    bool? completed,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt,
    );
  }
}

enum TodoFilter { all, active, completed }`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">State Management</h2>
        <CodeBlock
          filename="todo_state.dart"
          language="dart"
          code={`class TodoState {
  final todos = <Todo>[].reactive();
  final filter = TodoFilter.all.reactive();
  final newTodoText = ''.reactive();

  late final filteredTodos = Reactive.compute(() {
    final currentTodos = todos.value;
    final currentFilter = filter.value;

    switch (currentFilter) {
      case TodoFilter.all:
        return currentTodos;
      case TodoFilter.active:
        return currentTodos.where((todo) => !todo.completed).toList();
      case TodoFilter.completed:
        return currentTodos.where((todo) => todo.completed).toList();
    }
  });

  late final totalCount = todos.as((items) => items.length);
  late final activeCount = todos.as(
    (items) => items.where((todo) => !todo.completed).length,
  );
  late final completedCount = todos.as(
    (items) => items.where((todo) => todo.completed).length,
  );
  late final allCompleted = Reactive.compute(
    () => todos.value.isNotEmpty && activeCount.value == 0,
  );

  void addTodo() {
    final text = newTodoText.value.trim();
    if (text.isEmpty) return;

    todos.add(Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: text,
    ));
    newTodoText.clear();
  }

  void toggleTodo(String id) {
    final index = todos.value.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    final todo = todos.value[index];
    todos[index] = todo.copyWith(completed: !todo.completed);
  }

  void removeTodo(String id) {
    todos.removeWhere((todo) => todo.id == id);
  }

  void clearCompleted() {
    todos.removeWhere((todo) => todo.completed);
  }

  void toggleAll() {
    final completed = allCompleted.value;
    todos.value = todos.value
        .map((todo) => todo.copyWith(completed: !completed))
        .toList();
  }
}`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">User Interface</h2>
        <CodeBlock
          filename="todo_page.dart"
          language="dart"
          code={`class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final state = TodoState();
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    state.newTodoText.listen((value) {
      if (textController.text != value) {
        textController.text = value;
      }
    });
    state.todos.bind(this);
    state.filter.bind(this);
  }

  @override
  void dispose() {
    state.todos.unbind(this);
    state.filter.unbind(this);
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '\${state.activeCount.value} left',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    onChanged: (value) => state.newTodoText.value = value,
                    onSubmitted: (_) => state.addTodo(),
                    decoration: const InputDecoration(
                      hintText: 'Add a task...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: state.addTodo,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final option in TodoFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: state.filter.value == option,
                      onSelected: (_) => state.filter.value = option,
                      label: Text(_filterLabel(option)),
                    ),
                  ),
                const Spacer(),
                if (state.completedCount.value > 0)
                  TextButton(
                    onPressed: state.clearCompleted,
                    child: const Text('Clear completed'),
                  ),
              ],
            ),
          ),

          Expanded(
            child: state.filteredTodos.value.isEmpty
                ? const Center(child: Text('No tasks'))
                : ListView.builder(
                    itemCount: state.filteredTodos.value.length,
                    itemBuilder: (context, index) {
                      final todo = state.filteredTodos.value[index];
                      return TodoTile(
                        todo: todo,
                        onToggle: () => state.toggleTodo(todo.id),
                        onDelete: () => state.removeTodo(todo.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all:
        return 'All';
      case TodoFilter.active:
        return 'Active';
      case TodoFilter.completed:
        return 'Completed';
    }
  }
}

class TodoTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: todo.completed,
        onChanged: (_) => onToggle(),
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.completed ? TextDecoration.lineThrough : null,
          color: todo.completed ? Colors.grey : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}`}
        />
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Key Takeaways</h2>
        <ul className="space-y-2 text-muted-foreground list-disc list-inside">
          <li>
            Derived state keeps filtering and statistics in sync automatically
          </li>
          <li>
            List helpers such as <code className="font-mono text-sm bg-muted px-1 py-0.5 rounded">.add()</code> and{" "}
            <code className="font-mono text-sm bg-muted px-1 py-0.5 rounded">.removeWhere()</code> stay ergonomic
          </li>
          <li>State and UI remain cleanly separated</li>
          <li>Bindings keep the page in sync with the underlying store</li>
        </ul>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Next Example</h2>
        <div className="p-4 rounded-lg border border-border bg-card">
          <p className="text-muted-foreground">
            Explore a more advanced example with transactions and automatic rollback.
          </p>
          <Link
            href="/examples/cart"
            className="inline-block mt-3 text-primary hover:underline font-medium"
          >
            Shopping Cart Example &rarr;
          </Link>
        </div>
      </section>
    </div>
  )
}
