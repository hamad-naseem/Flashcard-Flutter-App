import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'models.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  
  User? _user;
  User? get user => _user;
  
  String get username => _user?.displayName ?? _user?.email?.split('@')[0] ?? 'User';

  // Decks collections
  List<Deck> _myDecks = [];
  List<Deck> get myDecks => _myDecks;
  
  List<Deck> _publicDecks = [];
  List<Deck> get publicDecks => _publicDecks;

  // Progress tracking
  Map<String, DeckStats> _deckStats = {};
  Map<String, DeckStats> get deckStats => _deckStats;

  Future<void> init() async {
    // Firebase is already initialized in main.dart, so we just need to listen for auth changes
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        _user = user;
        _fetchUserDecks();
        _fetchPublicDecks();
        _fetchUserStats();
      } else {
        _loggedIn = false;
        _user = null;
        _myDecks = [];
        _deckStats = {};
      }
      notifyListeners();
    });
    
    // Load hardcoded public decks for the Explore tab
    _loadHardcodedPublicDecks();
  }

  // Load hardcoded public decks for the Explore tab
  void _loadHardcodedPublicDecks() {
    _publicDecks = [
      Deck(
        id: 'public-1',
        title: 'JavaScript Basics',
        description: 'Learn the fundamentals of JavaScript programming language',
        tags: ['programming', 'web', 'javascript'],
        flashcards: [
          Flashcard(
            question: 'What is JavaScript?',
            answer: 'JavaScript is a high-level, interpreted programming language that conforms to the ECMAScript specification.'
          ),
          Flashcard(
            question: 'What is a variable?',
            answer: 'A variable is a container for storing data values.'
          ),
          Flashcard(
            question: 'What is the difference between let and var?',
            answer: 'var is function scoped while let is block scoped. Variables declared with let can\'t be redeclared in the same scope.'
          ),
          Flashcard(
            question: 'What is a callback function?',
            answer: 'A callback function is a function passed into another function as an argument, which is then invoked inside the outer function.'
          ),
          Flashcard(
            question: 'What is the DOM?',
            answer: 'The Document Object Model (DOM) is a programming interface for HTML and XML documents that represents the page so programs can change the document structure, style, and content.'
          ),
        ],
        isFavorite: false,
        userId: 'system',
      ),
      
      Deck(
        id: 'public-2',
        title: 'World Capitals',
        description: 'Test your knowledge of world capitals',
        tags: ['geography', 'travel', 'education'],
        flashcards: [
          Flashcard(
            question: 'What is the capital of France?',
            answer: 'Paris'
          ),
          Flashcard(
            question: 'What is the capital of Japan?',
            answer: 'Tokyo'
          ),
          Flashcard(
            question: 'What is the capital of Brazil?',
            answer: 'Brasília'
          ),
          Flashcard(
            question: 'What is the capital of Australia?',
            answer: 'Canberra'
          ),
          Flashcard(
            question: 'What is the capital of Egypt?',
            answer: 'Cairo'
          ),
          Flashcard(
            question: 'What is the capital of Canada?',
            answer: 'Ottawa'
          ),
          Flashcard(
            question: 'What is the capital of South Korea?',
            answer: 'Seoul'
          ),
        ],
        isFavorite: false,
        userId: 'system',
      ),
      
      Deck(
        id: 'public-3',
        title: 'Flutter Widgets',
        description: 'Learn common Flutter widgets and their purposes',
        tags: ['programming', 'flutter', 'mobile'],
        flashcards: [
          Flashcard(
            question: 'What is a StatelessWidget?',
            answer: 'A widget that doesn\'t require mutable state. It has no internal state to manage.'
          ),
          Flashcard(
            question: 'What is a StatefulWidget?',
            answer: 'A widget that has mutable state. It can change its appearance in response to events triggered by user interactions or when it receives data.'
          ),
          Flashcard(
            question: 'What is the purpose of the Scaffold widget?',
            answer: 'Scaffold implements the basic material design visual layout structure. It provides APIs for showing drawers, snack bars, and bottom sheets.'
          ),
          Flashcard(
            question: 'What is the difference between Container and SizedBox?',
            answer: 'Container is a convenience widget that combines common painting, positioning, and sizing widgets. SizedBox is simpler and only sizes its child.'
          ),
          Flashcard(
            question: 'What is the purpose of the ListView widget?',
            answer: 'ListView is a scrollable list of widgets arranged linearly. It displays its children one after another in the scroll direction.'
          ),
        ],
        isFavorite: false,
        userId: 'system',
      ),
      
      Deck(
        id: 'public-4',
        title: 'English Vocabulary',
        description: 'Expand your English vocabulary with these words',
        tags: ['language', 'english', 'vocabulary'],
        flashcards: [
          Flashcard(
            question: 'Ubiquitous',
            answer: 'Present, appearing, or found everywhere.'
          ),
          Flashcard(
            question: 'Ephemeral',
            answer: 'Lasting for a very short time.'
          ),
          Flashcard(
            question: 'Serendipity',
            answer: 'The occurrence and development of events by chance in a happy or beneficial way.'
          ),
          Flashcard(
            question: 'Eloquent',
            answer: 'Fluent or persuasive in speaking or writing.'
          ),
          Flashcard(
            question: 'Resilient',
            answer: 'Able to withstand or recover quickly from difficult conditions.'
          ),
          Flashcard(
            question: 'Pragmatic',
            answer: 'Dealing with things sensibly and realistically in a way that is based on practical considerations.'
          ),
        ],
        isFavorite: false,
        userId: 'system',
      ),
      
      Deck(
        id: 'public-5',
        title: 'Science Facts',
        description: 'Interesting facts about science and the natural world',
        tags: ['science', 'education', 'facts'],
        flashcards: [
          Flashcard(
            question: 'What is the speed of light?',
            answer: 'Approximately 299,792,458 meters per second in a vacuum.'
          ),
          Flashcard(
            question: 'What is the most abundant element in the universe?',
            answer: 'Hydrogen'
          ),
          Flashcard(
            question: 'What is the hardest natural substance on Earth?',
            answer: 'Diamond'
          ),
          Flashcard(
            question: 'What is the largest organ in the human body?',
            answer: 'The skin'
          ),
          Flashcard(
            question: 'What is the smallest bone in the human body?',
            answer: 'The stapes (stirrup) bone in the middle ear'
          ),
          Flashcard(
            question: 'What is the most abundant gas in Earth\'s atmosphere?',
            answer: 'Nitrogen (about 78%)'
          ),
        ],
        isFavorite: false,
        userId: 'system',
      ),
    ];
    
    notifyListeners();
  }

  // Logout method
  void logout() {
    FirebaseAuth.instance.signOut();
    // The userChanges listener in init() will handle updating the state
  }

  // Fetch user's decks from Firestore
  Future<void> _fetchUserDecks() async {
    if (_user == null) return;
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('decks')
          .where('userId', isEqualTo: _user!.uid)
          .get();
      
      _myDecks = snapshot.docs.map((doc) => Deck.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching user decks: $e');
    }
  }

  // Fetch public decks from Firestore
  Future<void> _fetchPublicDecks() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('decks')
          .where('isPublic', isEqualTo: true)
          .get();
      
      // Merge Firestore public decks with hardcoded ones
      List<Deck> firestoreDecks = snapshot.docs.map((doc) => Deck.fromFirestore(doc)).toList();
      
      // Only add Firestore decks that don't conflict with our hardcoded ones
      for (var deck in firestoreDecks) {
        if (!_publicDecks.any((d) => d.id == deck.id)) {
          _publicDecks.add(deck);
        }
      }
      
      notifyListeners();
    } catch (e) {
      print('Error fetching public decks: $e');
    }
  }

  // Fetch user's stats from Firestore
  Future<void> _fetchUserStats() async {
    if (_user == null) return;
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('deckStats')
          .get();
      
      _deckStats = {};
      for (var doc in snapshot.docs) {
        _deckStats[doc.id] = DeckStats.fromMap(doc.data());
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching user stats: $e');
    }
  }

  // Deck CRUD operations
  Future<void> addDeck(Deck deck) async {
    if (_user == null) return;
    
    try {
      // Create a new document reference
      final docRef = FirebaseFirestore.instance.collection('decks').doc();
      
      // Set the ID and user ID
      deck.id = docRef.id;
      deck.userId = _user!.uid;
      
      // Save to Firestore
      await docRef.set(deck.toMap());
      
      // Update local state
      _myDecks.add(deck);
      notifyListeners();
    } catch (e) {
      print('Error adding deck: $e');
    }
  }

  Future<void> updateDeck(Deck deck) async {
    if (_user == null) return;
    
    try {
      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('decks')
          .doc(deck.id)
          .update(deck.toMap());
      
      // Update local state
      int index = _myDecks.indexWhere((d) => d.id == deck.id);
      if (index >= 0) {
        _myDecks[index] = deck;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating deck: $e');
    }
  }

  Future<void> deleteDeck(String deckId) async {
    if (_user == null) return;
    
    try {
      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection('decks')
          .doc(deckId)
          .delete();
      
      // Delete stats
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('deckStats')
          .doc(deckId)
          .delete();
      
      // Update local state
      _myDecks.removeWhere((d) => d.id == deckId);
      _deckStats.remove(deckId);
      notifyListeners();
    } catch (e) {
      print('Error deleting deck: $e');
    }
  }

  // Flashcard CRUD operations
  Future<void> addFlashcard(String deckId, Flashcard flashcard) async {
    if (_user == null) return;
    
    try {
      // Find the deck
      int deckIndex = _myDecks.indexWhere((d) => d.id == deckId);
      if (deckIndex < 0) return;
      
      // Add flashcard to the deck
      Deck updatedDeck = _myDecks[deckIndex];
      updatedDeck.flashcards.add(flashcard);
      
      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('decks')
          .doc(deckId)
          .update({
            'flashcards': updatedDeck.flashcards.map((f) => f.toMap()).toList(),
          });
      
      // Update local state
      _myDecks[deckIndex] = updatedDeck;
      notifyListeners();
    } catch (e) {
      print('Error adding flashcard: $e');
    }
  }

  Future<void> updateFlashcard(String deckId, int flashcardIndex, Flashcard flashcard) async {
    if (_user == null) return;
    
    try {
      // Find the deck
      int deckIndex = _myDecks.indexWhere((d) => d.id == deckId);
      if (deckIndex < 0) return;
      
      // Update flashcard in the deck
      Deck updatedDeck = _myDecks[deckIndex];
      if (flashcardIndex >= 0 && flashcardIndex < updatedDeck.flashcards.length) {
        updatedDeck.flashcards[flashcardIndex] = flashcard;
        
        // Update in Firestore
        await FirebaseFirestore.instance
            .collection('decks')
            .doc(deckId)
            .update({
              'flashcards': updatedDeck.flashcards.map((f) => f.toMap()).toList(),
            });
        
        // Update local state
        _myDecks[deckIndex] = updatedDeck;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating flashcard: $e');
    }
  }

  Future<void> deleteFlashcard(String deckId, int flashcardIndex) async {
    if (_user == null) return;
    
    try {
      // Find the deck
      int deckIndex = _myDecks.indexWhere((d) => d.id == deckId);
      if (deckIndex < 0) return;
      
      // Delete flashcard from the deck
      Deck updatedDeck = _myDecks[deckIndex];
      if (flashcardIndex >= 0 && flashcardIndex < updatedDeck.flashcards.length) {
        updatedDeck.flashcards.removeAt(flashcardIndex);
        
        // Update in Firestore
        await FirebaseFirestore.instance
            .collection('decks')
            .doc(deckId)
            .update({
              'flashcards': updatedDeck.flashcards.map((f) => f.toMap()).toList(),
            });
        
        // Update local state
        _myDecks[deckIndex] = updatedDeck;
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting flashcard: $e');
    }
  }

  // Toggle deck favorite status
  Future<void> toggleDeckFavorite(String deckId) async {
    if (_user == null) return;
    
    try {
      // Find the deck
      int deckIndex = _myDecks.indexWhere((d) => d.id == deckId);
      if (deckIndex < 0) return;
      
      // Toggle favorite status
      Deck updatedDeck = _myDecks[deckIndex];
      updatedDeck.isFavorite = !updatedDeck.isFavorite;
      
      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('decks')
          .doc(deckId)
          .update({
            'isFavorite': updatedDeck.isFavorite,
          });
      
      // Update local state
      _myDecks[deckIndex] = updatedDeck;
      notifyListeners();
    } catch (e) {
      print('Error toggling deck favorite: $e');
    }
  }

  // Progress update
  Future<void> updateDeckStats(String deckId, int studied, int correct, int incorrect) async {
    if (_user == null) return;
    
    try {
      // Get current stats
      DeckStats oldStats = _deckStats[deckId] ?? DeckStats();
      
      // Create updated stats
      DeckStats newStats = DeckStats(
        totalStudied: oldStats.totalStudied + studied,
        correctAnswers: oldStats.correctAnswers + correct,
        incorrectAnswers: oldStats.incorrectAnswers + incorrect,
      );
      
      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('deckStats')
          .doc(deckId)
          .set(newStats.toMap());
      
      // Update local state
      _deckStats[deckId] = newStats;
      notifyListeners();
    } catch (e) {
      print('Error updating deck stats: $e');
    }
  }
  
  // Make a deck public or private
  Future<void> setDeckPublic(String deckId, bool isPublic) async {
    if (_user == null) return;
    
    try {
      // Find the deck
      int deckIndex = _myDecks.indexWhere((d) => d.id == deckId);
      if (deckIndex < 0) return;
      
      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('decks')
          .doc(deckId)
          .update({
            'isPublic': isPublic,
          });
      
      // Update local state
      _myDecks[deckIndex] = _myDecks[deckIndex].copyWith(isPublic: isPublic);
      notifyListeners();
    } catch (e) {
      print('Error setting deck public status: $e');
    }
  }
}
