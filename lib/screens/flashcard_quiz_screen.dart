import 'package:flutter/material.dart';
import '../models.dart';
import '../app_state.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';

class FlashcardQuizScreen extends StatefulWidget {
  final ApplicationState appState;
  FlashcardQuizScreen({required this.appState});

  @override
  State<FlashcardQuizScreen> createState() => _FlashcardQuizScreenState();
}

class _FlashcardQuizScreenState extends State<FlashcardQuizScreen> with SingleTickerProviderStateMixin {
  late Deck deck;
  int currentIndex = 0;
  int correct = 0;
  bool showAnswer = false;
  
  // Animation controller for card flip
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deck = GoRouterState.of(context).extra as Deck;
  }

  void _toggleAnswer() {
    if (showAnswer) {
      _animationController.reverse().then((_) {
        setState(() {
          showAnswer = false;
        });
      });
    } else {
      setState(() {
        showAnswer = true;
      });
      _animationController.forward();
    }
  }

  void _answer(bool correctAnswer) {
    if (correctAnswer) {
      correct++;
    }
    if (currentIndex < deck.flashcards.length - 1) {
      // Reset animation for next card
      _animationController.reset();
      
      setState(() {
        currentIndex++;
        showAnswer = false;
      });
    } else {
      // Quiz ends: update stats and show results
      widget.appState.updateDeckStats(deck.id, deck.flashcards.length, correct, deck.flashcards.length - correct);
      context.pop();
      _showResultsDialog();
    }
  }

  void _showResultsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF1D1D1D),
            border: Border.all(
              color: Color(0xFFFFFF00),
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
                color: Color(0xFFFFFF00),
                child: Text(
                  'QUEST COMPLETE!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'SCORE: $correct / ${deck.flashcards.length}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF00FF00),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Accuracy: ${(correct / deck.flashcards.length * 100).toInt()}%',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildProgressBar(correct, deck.flashcards.length),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFFFFF00), width: 2),
                  ),
                ),
                child: InkWell(
                  onTap: () => Navigator.pop(c),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    color: Color(0xFF00FFFF),
                    child: Text(
                      'CONTINUE',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProgressBar(int value, int max) {
    final double percentage = value / max;
    
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: Color(0xFF00FF00),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: (percentage * 100).toInt(),
            child: Container(
              color: Color(0xFF00FF00),
            ),
          ),
          if (percentage < 1.0)
            Expanded(
              flex: 100 - (percentage * 100).toInt(),
              child: Container(),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Flashcard card = deck.flashcards[currentIndex];
    
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'QUIZ: ${deck.title.toUpperCase()}',
          style: TextStyle(
            color: Color(0xFF00FF00),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF6B1FB1),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFF1D1D1D),
                border: Border.all(
                  color: Color(0xFFFF00FF),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CARD: ${currentIndex + 1}/${deck.flashcards.length}',
                    style: TextStyle(
                      color: Color(0xFFFF00FF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'SCORE: $correct',
                    style: TextStyle(
                      color: Color(0xFF00FFFF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildProgressBar(currentIndex + 1, deck.flashcards.length),
            SizedBox(height: 30),
            Expanded(
              child: GestureDetector(
                onTap: _toggleAnswer,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    // Calculate the rotation angle based on animation value
                    final angle = _animation.value * math.pi;
                    
                    return Center(
                      child: Stack(
                        children: [
                          // Front side (Question)
                          Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // Perspective
                              ..rotateY(angle),
                            alignment: Alignment.center,
                            child: Visibility(
                              visible: angle < math.pi/2, // Only show front when angle < 90 degrees
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color(0xFF1D1D1D),
                                  border: Border.all(
                                    color: Color(0xFF00FFFF),
                                    width: 3,
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
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      width: double.infinity,
                                      color: Color(0xFF00FFFF),
                                      child: Text(
                                        'QUESTION',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Center(
                                          child: Text(
                                            card.question,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Back side (Answer) - pre-rotated 180 degrees so it appears right-side up after flip
                          Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // Perspective
                              ..rotateY(angle - math.pi), // Subtract pi to start from 180 degrees
                            alignment: Alignment.center,
                            child: Visibility(
                              visible: angle >= math.pi/2, // Only show back when angle >= 90 degrees
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color(0xFF1D1D1D),
                                  border: Border.all(
                                    color: Color(0xFFFF00FF),
                                    width: 3,
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
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      width: double.infinity,
                                      color: Color(0xFFFF00FF),
                                      child: Text(
                                        'ANSWER',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Center(
                                          child: Text(
                                            card.answer,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            if (!showAnswer)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFFFFFF00),
                    width: 2,
                  ),
                ),
                child: Text(
                  'TAP CARD TO FLIP',
                  style: TextStyle(
                    color: Color(0xFFFFFF00),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildRetroButton(
                      label: 'CORRECT',
                      onPressed: () => _answer(true),
                      color: Color(0xFF00FF00),
                      icon: Icons.check,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildRetroButton(
                      label: 'WRONG',
                      onPressed: () => _answer(false),
                      color: Color(0xFFFF0000),
                      icon: Icons.close,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
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
