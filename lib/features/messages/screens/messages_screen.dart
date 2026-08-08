import 'package:flutter/material.dart';

import '../../../shared/demo/demo_data.dart';
import '../../../shared/widgets/ui_bits.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final threads = DemoData.messages.where((m) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return m.title.toLowerCase().contains(q) ||
          m.preview.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('Messages'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compose coming soon')),
              );
            },
            icon: const Icon(Icons.edit_square),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: AppSearchField(
              hintText: 'Search messages',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: threads.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final thread = threads[index];
                return ListTile(
                  leading: AvatarCircle(
                    label: thread.title,
                    backgroundColor: thread.isGroup
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)
                        : null,
                  ),
                  title: Text(
                    thread.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    thread.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        thread.timeLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      UnreadBadge(count: thread.unread),
                    ],
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Open chat: ${thread.title}')),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
