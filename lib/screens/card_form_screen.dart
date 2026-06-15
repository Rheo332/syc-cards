import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/flashcard.dart';

class CardFormScreen extends StatefulWidget {
  const CardFormScreen({super.key, required this.deckId, this.existingCard});

  final String deckId;
  final Flashcard? existingCard;

  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _frontController;
  late final TextEditingController _backController;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController(
      text: widget.existingCard?.front ?? '',
    );
    _backController = TextEditingController(
      text: widget.existingCard?.back ?? '',
    );
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCard != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Karte bearbeiten' : 'Karte erstellen'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Karte bearbeiten' : 'Neue Karte',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 8),

              Text(
                'Vorder- und Rückseite deiner Lernkarte eingeben.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 32),

              TextFormField(
                controller: _frontController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Vorderseite',
                  hintText: 'Frage oder Begriff',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Bitte Text eingeben.'
                    : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _backController,
                minLines: 4,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Rückseite',
                  hintText: 'Antwort oder Erklärung',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Bitte Text eingeben.'
                    : null,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;

                    final state = AppScope.of(context);

                    if (isEditing) {
                      state.updateCard(
                        deckId: widget.deckId,
                        cardId: widget.existingCard!.id,
                        front: _frontController.text.trim(),
                        back: _backController.text.trim(),
                      );
                    } else {
                      state.addCard(
                        deckId: widget.deckId,
                        front: _frontController.text.trim(),
                        back: _backController.text.trim(),
                      );
                    }

                    Navigator.of(context).pop();
                  },
                  child: Text(isEditing ? 'Speichern' : 'Anlegen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
