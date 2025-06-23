import 'package:cloud_firestore/cloud_firestore.dart';

// Flashcard model
class Flashcard {
  String question;
  String answer;

  Flashcard({required this.question, required this.answer});

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
    };
  }

  // Create from Firestore document
  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
    );
  }
}

class Deck {
  String id; // Changed to String for Firestore document ID
  String title;
  String description;
  List<String> tags;
  List<Flashcard> flashcards;
  bool isFavorite;
  String userId; // Added to track deck owner
  bool isPublic; // Added to track if deck is public

  Deck({
    required this.id,
    required this.title,
    required this.description,
    this.tags = const [],
    this.flashcards = const [],
    this.isFavorite = false,
    required this.userId,
    this.isPublic = false,
  });

  // Create a copy with some fields replaced
  Deck copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? tags,
    List<Flashcard>? flashcards,
    bool? isFavorite,
    String? userId,
    bool? isPublic,
  }) {
    return Deck(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      flashcards: flashcards ?? this.flashcards,
      isFavorite: isFavorite ?? this.isFavorite,
      userId: userId ?? this.userId,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'tags': tags,
      'flashcards': flashcards.map((card) => card.toMap()).toList(),
      'isFavorite': isFavorite,
      'userId': userId,
      'isPublic': isPublic,
    };
  }

  // Create from Firestore document
  factory Deck.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<Flashcard> cards = [];
    
    if (data['flashcards'] != null) {
      cards = (data['flashcards'] as List).map((cardMap) {
        return Flashcard.fromMap(cardMap as Map<String, dynamic>);
      }).toList();
    }
    
    return Deck(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      flashcards: cards,
      isFavorite: data['isFavorite'] ?? false,
      userId: data['userId'] ?? '',
      isPublic: data['isPublic'] ?? false,
    );
  }
}

class DeckStats {
  final int totalStudied;
  final int correctAnswers;
  final int incorrectAnswers;

  DeckStats({this.totalStudied=0, this.correctAnswers=0, this.incorrectAnswers=0});

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'totalStudied': totalStudied,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
    };
  }

  // Create from Firestore document
  factory DeckStats.fromMap(Map<String, dynamic> map) {
    return DeckStats(
      totalStudied: map['totalStudied'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      incorrectAnswers: map['incorrectAnswers'] ?? 0,
    );
  }
}
