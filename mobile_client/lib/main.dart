import 'package:flutter/material.dart';

import 'api/api_client.dart';
import 'models/item.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'MCS4302 Running System',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: const ItemsScreen(),
      );
}

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final api = ApiClient();
  late Future<List<Item>> _future;
  bool _busy = false;

  @override
  void dispose() {
    api.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _future = api.getItems();
  }

  void _refresh() {
    if (mounted) setState(() => _future = api.getItems());
  }

  Future<void> _addItem() async {
    if (_busy) return;
    setState(() => _busy = true);
    var name = "";
    var priceText = "";
    final formKey = GlobalKey<FormState>();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('New item'),
          content: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                onChanged: (value) => name = value,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.trim().isEmpty || v.trim().length > 120
                    ? 'Enter a name (1-120 characters)' : null,
              ),
              TextFormField(
                onChanged: (value) => priceText = value,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final price = double.tryParse(v ?? '');
                  return price == null || !price.isFinite || price < 0
                      ? 'Enter a nonnegative price' : null;
                },
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      await api.createItem(name.trim(), double.parse(priceText));
      _refresh();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _busy ? null : _refresh),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _busy ? null : _addItem, child: const Icon(Icons.add)),
      body: FutureBuilder<List<Item>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: ${snap.error}', textAlign: TextAlign.center),
              ),
            );
          }
          final items = snap.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) => ListTile(
              leading: CircleAvatar(child: Text('${items[i].id}')),
              title: Text(items[i].name),
              trailing: Text('Rs. ${items[i].price.toStringAsFixed(2)}'),
            ),
          );
        },
      ),
    );
  }
}
