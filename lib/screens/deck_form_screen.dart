import 'package:flutter/material.dart';
import 'package:syc_cards/app_state.dart';

import '../models/deck.dart';

class DeckFormScreen extends StatefulWidget {
  const DeckFormScreen({super.key, this.existingDeck});

  final Deck? existingDeck;

  @override
  State<DeckFormScreen> createState() => _DeckFormScreenState();
}

class _DeckFormScreenState extends State<DeckFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingDeck?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingDeck?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingDeck != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Deck bearbeiten' : 'Deck erstellen'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Deck bearbeiten' : 'Neues Deck',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 16),

              Text(
                'Vergib einen Namen und optional eine Beschreibung.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 32),

              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  hintText: 'z.B. Spanisch A1',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Bitte einen Titel eingeben.'
                    : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung',
                  hintText: 'Worum geht es in diesem Deck?',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    final state = AppScope.of(context);
                    if (isEditing) {
                      state.updateDeck(
                        deckId: widget.existingDeck!.id,
                        title: _titleController.text,
                        description: _descriptionController.text,
                      );
                    } else {
                      state.addDeck(
                        title: _titleController.text,
                        description: _descriptionController.text,
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(isEditing ? 'Speichern' : 'Deck anlegen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
