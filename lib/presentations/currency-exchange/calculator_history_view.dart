// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/fonts.dart';
import '../../data/models/calculator/historyitem.dart';

class CalculatorHistoryView extends StatelessWidget {
  const CalculatorHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator History'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              try {
                final Box<HistoryItem> box = Hive.box<HistoryItem>('history');
                await box.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History cleared successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error clearing history: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Box<HistoryItem>>(
        future: _ensureBoxIsOpen(),
        builder: (BuildContext context, AsyncSnapshot<Box<HistoryItem>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.error, size: 64, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final Box<HistoryItem> box = snapshot.data!;

          return ValueListenableBuilder<Box<HistoryItem>>(
            valueListenable: box.listenable(),
            builder: (BuildContext context, Box<HistoryItem> box, _) {
              if (box.values.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Theme.of(context).disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No calculations yet',
                        style: Font.montserratFont(
                          fontSize: 18,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final List<HistoryItem> history = box.values
                  .toList()
                  .reversed
                  .toList();

              return ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: history.length,
                separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 8),
                itemBuilder: (BuildContext context, int index) {
                  final HistoryItem item = history[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        item.title,
                        style: Font.montserratFont(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.subtitle,
                            style: Font.montserratFont(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year} ${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                            style: Font.montserratFont(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await box.deleteAt(box.length - 1 - index);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Box<HistoryItem>> _ensureBoxIsOpen() async {
    if (Hive.isBoxOpen('history')) {
      return Hive.box<HistoryItem>('history');
    } else {
      return await Hive.openBox<HistoryItem>('history');
    }
  }
}