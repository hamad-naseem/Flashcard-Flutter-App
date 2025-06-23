import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import 'package:go_router/go_router.dart';

class DeckDetailsScreen extends StatefulWidget {
  final ApplicationState appState;
  DeckDetailsScreen({required this.appState});

  @override
  State<DeckDetailsScreen> createState() => _DeckDetailsScreenState();
}

class _DeckDetailsScreenState extends State<DeckDetailsScreen> {
  late Deck deck;
  bool isMyDeck = true;
  bool creatingNew = false;
  bool editingDeck = false;

  // Deck fields
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = GoRouterState.of(context).extra as Map<String, dynamic>? ?? {};
    if (args.containsKey('deck')) {
      deck = args['deck'];
      isMyDeck = args['isMyDeck'] ?? true;
      creatingNew = false;
    } else if (args['create'] == true) {
      creatingNew = true;
      // Create a new deck with empty ID - will be set when saved
      deck = Deck(
        id: '', 
        title: '', 
        description: '', 
        tags: [], 
        flashcards: [],
        userId: widget.appState.user?.uid ?? '',
      );
    } else {
      context.pop(); // No deck data, exit
    }

    _titleController = TextEditingController(text: deck.title);
    _descController = TextEditingController(text: deck.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveDeck() {
    if (_formKey.currentState!.validate()) {
      Deck updatedDeck = Deck(
        id: deck.id,
        title: _titleController.text,
        description: _descController.text,
        tags: [],
        flashcards: deck.flashcards,
        isFavorite: deck.isFavorite,
        userId: widget.appState.user?.uid ?? '',
      );
      
      if (creatingNew) {
        widget.appState.addDeck(updatedDeck);
        context.pop();
      } else {
        widget.appState.updateDeck(updatedDeck);
      }
      
      setState(() {
        deck = updatedDeck;
        creatingNew = false;
        editingDeck = false;
      });
    }
  }

  void _startQuiz() {
    if (deck.flashcards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'DECK HAS NO CARDS!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color(0xFFFF0000),
        ),
      );
      return;
    }
    context.push('/flashcardQuiz', extra: deck);
  }

  void _addFlashcard() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: FlashcardFormScreen(
          onSubmit: (flashcard) {
            setState(() {
              deck.flashcards.add(flashcard);
              widget.appState.updateDeck(deck);
            });
            Navigator.pop(dialogContext);
          },
        ),
      ),
    );
  }

  void _editFlashcard(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: FlashcardFormScreen(
          flashcard: deck.flashcards[index],
          onSubmit: (edited) {
            setState(() {
              deck.flashcards[index] = edited;
              widget.appState.updateDeck(deck);
            });
            Navigator.pop(dialogContext);
          },
        ),
      ),
    );
  }

  void _deleteFlashcard(int index) {
    showDialog(
      context: context,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF1D1D1D),
            border: Border.all(
              color: Color(0xFFFF0000),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(6, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                color: Color(0xFFFF0000),
                child: Text(
                  'DELETE CARD?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Are you sure you want to delete this card?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFFF0000), width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pop(c),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xFF00FF00),
                            border: Border(
                              right: BorderSide(color: Color(0xFFFF0000), width: 1),
                            ),
                          ),
                          child: Text(
                            'CANCEL',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            deck.flashcards.removeAt(index);
                            widget.appState.updateDeck(deck);
                          });
                          Navigator.pop(c);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          color: Color(0xFFFF0000),
                          child: Text(
                            'DELETE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          creatingNew ? 'CREATE DECK' : deck.title.toUpperCase(),
          style: TextStyle(
            color: Color(0xFF00FF00),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF6B1FB1),
        elevation: 0,
        actions: [
          if (!creatingNew && isMyDeck)
            IconButton(
              icon: Icon(
                editingDeck ? Icons.check : Icons.edit,
                color: Color(0xFFFFFF00),
              ),
              onPressed: () {
                if (editingDeck) {
                  _saveDeck();
                } else {
                  setState(() {
                    editingDeck = true;
                  });
                }
              },
            )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: creatingNew || editingDeck ? buildEditForm() : buildDeckView(),
      ),
      floatingActionButton: creatingNew
          ? null
          : Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Color(0xFFFF00FF),
                borderRadius: BorderRadius.circular(0),
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: InkWell(
                onTap: _addFlashcard,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
    );
  }

  Widget buildEditForm() {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          _buildRetroTextField(
            controller: _titleController,
            label: 'DECK TITLE',
            validator: (v) => (v == null || v.trim().isEmpty) ? 'ENTER TITLE' : null,
          ),
          SizedBox(height: 20),
          _buildRetroTextField(
            controller: _descController,
            label: 'DESCRIPTION',
            maxLines: 3,
          ),
          SizedBox(height: 30),
          _buildRetroButton(
            label: 'SAVE DECK',
            onPressed: _saveDeck,
            color: Color(0xFF00FF00),
          ),
        ],
      ),
    );
  }

  Widget buildDeckView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF1D1D1D),
            border: Border.all(
              color: Color(0xFF00FFFF),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DESCRIPTION:',
                style: TextStyle(
                  color: Color(0xFF00FFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                deck.description.isEmpty ? 'NO DESCRIPTION' : deck.description,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        _buildRetroButton(
          label: 'START QUIZ',
          onPressed: _startQuiz,
          color: Color(0xFFFF00FF),
          icon: Icons.play_arrow,
        ),
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          color: Color(0xFF6B1FB1),
          child: Text(
            'FLASHCARDS: ${deck.flashcards.length}',
            style: TextStyle(
              color: Color(0xFFFFFF00),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10),
        deck.flashcards.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'NO CARDS YET. ADD SOME!',
                    style: TextStyle(
                      color: Color(0xFF00FF00),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : Expanded(
                child: ListView.builder(
                  itemCount: deck.flashcards.length,
                  itemBuilder: (c, index) {
                    final card = deck.flashcards[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Color(0xFF1D1D1D),
                        border: Border.all(
                          color: Color(0xFF00FF00),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            color: Color(0xFF00FF00),
                            width: double.infinity,
                            child: Text(
                              'CARD ${index + 1}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Q:',
                                  style: TextStyle(
                                    color: Color(0xFFFFFF00),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  card.question,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'A:',
                                  style: TextStyle(
                                    color: Color(0xFFFF00FF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  card.answer,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isMyDeck)
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Color(0xFF00FF00), width: 2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _editFlashcard(index),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF00FFFF),
                                          border: Border(
                                            right: BorderSide(color: Color(0xFF00FF00), width: 1),
                                          ),
                                        ),
                                        child: Text(
                                          'EDIT',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _deleteFlashcard(index),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                      alignment: Alignment.center,
                                      color: Color(0xFFFF0000),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
        SizedBox(height: 16),
        _buildRetroButton(
          label: 'ADD FLASHCARD',
          onPressed: _addFlashcard,
          color: Color(0xFF00FFFF),
        ),
      ],
    );
  }

  Widget _buildRetroTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: Color(0xFF00FF00),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF00FF00).withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              color: Color(0xFF00FF00),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              errorStyle: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildRetroButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.white,
              ),
              SizedBox(width: 8),
            ],
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlashcardFormScreen extends StatefulWidget {
  final Flashcard? flashcard;
  final void Function(Flashcard) onSubmit;

  FlashcardFormScreen({this.flashcard, required this.onSubmit});

  @override
  State<FlashcardFormScreen> createState() => _FlashcardFormScreenState();
}

class _FlashcardFormScreenState extends State<FlashcardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.flashcard?.question ?? '');
    _answerController = TextEditingController(text: widget.flashcard?.answer ?? '');
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(Flashcard(
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          widget.flashcard == null ? 'ADD CARD' : 'EDIT CARD',
          style: TextStyle(
            color: Color(0xFF00FF00),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF6B1FB1),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: Color(0xFFFFFF00),
            ),
            onPressed: _submit,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildRetroTextField(
                controller: _questionController,
                label: 'QUESTION',
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'ENTER QUESTION' : null,
              ),
              SizedBox(height: 24),
              _buildRetroTextField(
                controller: _answerController,
                label: 'ANSWER',
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'ENTER ANSWER' : null,
              ),
              SizedBox(height: 30),
              _buildRetroButton(
                label: 'SAVE CARD',
                onPressed: _submit,
                color: Color(0xFF00FF00),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetroTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: Color(0xFF00FF00),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF00FF00).withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              color: Color(0xFF00FF00),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              errorStyle: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildRetroButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
