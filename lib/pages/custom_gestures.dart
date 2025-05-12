import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/custom_gesture_provider.dart';

class CustomGesturesScreen extends StatefulWidget {
  const CustomGesturesScreen({super.key});

  @override
  State<CustomGesturesScreen> createState() => _CustomGesturesScreenState();
}

class _CustomGesturesScreenState extends State<CustomGesturesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _wordController = TextEditingController();

  final List<String> _fingerStates = ['straight', 'slightlybent', 'fullybent'];

  String _finger1 = 'straight';
  String _finger2 = 'straight';
  String _finger3 = 'straight';
  String _finger4 = 'straight';
  String _finger5 = 'straight';

  Future<void> _saveGesture() async {
  if (_formKey.currentState!.validate()) {
    final pattern = [_finger1, _finger2, _finger3, _finger4, _finger5].join('_');
    final word = _wordController.text.trim();

    final provider = context.read<CustomGestureProvider>();
    final success = await provider.addCustomGesture(pattern, word);

    if (!mounted) return;

    if (!success) {
      final reason = provider.lastError ?? 'Could not save gesture.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(reason)),
      );
      return;
    }

    _wordController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Custom gesture saved!')),
    );
  }
}

  String normalizePattern(String pattern) {
  return pattern.replaceAll(' ', '_');
}

  @override
  Widget build(BuildContext context) {
    final gestures = context.watch<CustomGestureProvider>().customGestures;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Gestures'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Define a New Gesture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFingerDropdown('Finger 1', _finger1, (val) {
                        setState(() => _finger1 = val!);
                      }),
                      _buildFingerDropdown('Finger 2', _finger2, (val) {
                        setState(() => _finger2 = val!);
                      }),
                      _buildFingerDropdown('Finger 3', _finger3, (val) {
                        setState(() => _finger3 = val!);
                      }),
                      _buildFingerDropdown('Finger 4', _finger4, (val) {
                        setState(() => _finger4 = val!);
                      }),
                      _buildFingerDropdown('Finger 5', _finger5, (val) {
                        setState(() => _finger5 = val!);
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _wordController,
                    decoration: const InputDecoration(
                      labelText: 'Word or Phrase',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Enter a word or phrase'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _saveGesture,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Gesture'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Text(
              'Saved Custom Gestures',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: gestures.isEmpty
                  ? const Center(child: Text('No custom gestures saved yet.'))
                  : ListView.builder(
                      itemCount: gestures.length,
                      itemBuilder: (context, index) {
                        final entry = gestures[index];
                        final pattern = entry['pattern'] ?? '';
                        final label = entry['label'] ?? '';
                        return ListTile(
                          title: Text(label),
                          subtitle: Text(pattern),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              context
                                  .read<CustomGestureProvider>()
                                  .removeCustomGesture(pattern);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFingerDropdown(
    String label,
    String currentValue,
    void Function(String?) onChanged,
  ) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 150),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: _fingerStates
            .map((state) => DropdownMenuItem(value: state, child: Text(state)))
            .toList(),
      ),
    );
  }
}