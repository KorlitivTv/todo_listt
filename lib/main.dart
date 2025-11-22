import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple ToDo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const TodoHomePage(),
    );
  }
}

class TodoItem {
  final String id;
  final String title;
  bool isDone;
  final DateTime createdAt;

  TodoItem({
    required this.id,
    required this.title,
    this.isDone = false,
    required this.createdAt,
  });
}

enum TodoFilter { all, active, done }

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<TodoItem> _items = [];
  TodoFilter _filter = TodoFilter.all;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTodo() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _items.insert(
        0,
        TodoItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: text,
          createdAt: DateTime.now(),
        ),
      );
      _controller.clear();
    });
  }

  void _toggleTodo(TodoItem item) {
    setState(() {
      item.isDone = !item.isDone;
    });
  }

  void _deleteTodo(TodoItem item) {
    setState(() {
      _items.removeWhere((t) => t.id == item.id);
    });
  }

  void _clearCompleted() {
    setState(() {
      _items.removeWhere((t) => t.isDone);
    });
  }

  List<TodoItem> get _filteredItems {
    switch (_filter) {
      case TodoFilter.active:
        return _items.where((t) => !t.isDone).toList();
      case TodoFilter.done:
        return _items.where((t) => t.isDone).toList();
      case TodoFilter.all:
      default:
        return _items;
    }
  }

  String get _filterLabel {
    switch (_filter) {
      case TodoFilter.all:
        return 'All';
      case TodoFilter.active:
        return 'Active';
      case TodoFilter.done:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _items.where((t) => t.isDone).length;
    final activeCount = _items.length - completedCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My ToDo / Bucket List'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Felső kártya: input + statisztika
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add a new task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onSubmitted: (_) => _addTodo(),
                            decoration: const InputDecoration(
                              hintText: 'e.g. Finish web dev project',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _addTodo,
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Total: ${_items.length}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Active: $activeCount',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Done: $completedCount',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter sor
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                const Text(
                  'Filter:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('All'),
                  selected: _filter == TodoFilter.all,
                  onSelected: (_) {
                    setState(() => _filter = TodoFilter.all);
                  },
                ),
                const SizedBox(width: 4),
                ChoiceChip(
                  label: const Text('Active'),
                  selected: _filter == TodoFilter.active,
                  onSelected: (_) {
                    setState(() => _filter = TodoFilter.active);
                  },
                ),
                const SizedBox(width: 4),
                ChoiceChip(
                  label: const Text('Completed'),
                  selected: _filter == TodoFilter.done,
                  onSelected: (_) {
                    setState(() => _filter = TodoFilter.done);
                  },
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed:
                      completedCount > 0 ? _clearCompleted : null,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Clear done'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Lista
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      'No tasks in "$_filterLabel".\nAdd something above!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: _filteredItems.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteTodo(item),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          color: Colors.red.shade400,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: item.isDone,
                              onChanged: (_) => _toggleTodo(item),
                            ),
                            title: Text(
                              item.title,
                              style: TextStyle(
                                decoration: item.isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: item.isDone
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'Added: ${item.createdAt.toLocal()}'
                                  .split('.')
                                  .first,
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteTodo(item),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
