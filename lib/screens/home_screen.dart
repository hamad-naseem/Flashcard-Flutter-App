import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  final ApplicationState appState;
  HomeScreen({required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchTag = '';
  final ScrollController _myDecksScrollController = ScrollController();
  final ScrollController _exploreScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    widget.appState.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _myDecksScrollController.dispose();
    _exploreScrollController.dispose();
    super.dispose();
  }

  List<Deck> get _myDecksFiltered {
    if (_searchTag.isEmpty) return widget.appState.myDecks;
    return widget.appState.myDecks.where((deck) => 
      deck.title.toLowerCase().contains(_searchTag.toLowerCase()) ||
      deck.tags.any((tag) => tag.toLowerCase().contains(_searchTag.toLowerCase()))
    ).toList();
  }

  List<Deck> get _publicDecksFiltered {
    if (_searchTag.isEmpty) return widget.appState.publicDecks;
    return widget.appState.publicDecks.where((deck) => 
      deck.title.toLowerCase().contains(_searchTag.toLowerCase()) ||
      deck.tags.any((tag) => tag.toLowerCase().contains(_searchTag.toLowerCase()))
    ).toList();
  }

  void _showCreateDeckDialog() {
    context.push('/deckDetails', extra: {'create': true});
  }

  void _logout() {
    widget.appState.logout();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'PLAYER: ${widget.appState.username.toUpperCase()}',
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
            icon: Icon(Icons.bar_chart, color: Color(0xFFFFFF00)),
            onPressed: () {
              context.push('/progressStats');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFFFF0000)),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF1D1D1D),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF00FF00), width: 3),
                ),
              ),
              child: Row(
                children: [
                  _buildTabButton("MY DECKS", 0),
                  _buildTabButton("EXPLORE", 1),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color: Color(0xFF00FFFF),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00FFFF).withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'SEARCH DECKS',
                    hintStyle: TextStyle(
                      color: Color(0xFF00FFFF).withOpacity(0.5),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF00FFFF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: TextStyle(
                    color: Color(0xFF00FFFF),
                    fontSize: 16,
                  ),
                  onChanged: (txt) {
                    setState(() {
                      _searchTag = txt.trim();
                    });
                  },
                ),
              ),
            ),
            
            // Deck Lists
            Expanded(
              child: IndexedStack(
                index: _tabController.index,
                children: [
                  _deckList(_myDecksFiltered, isMyDecks: true, scrollController: _myDecksScrollController),
                  _deckList(_publicDecksFiltered, isMyDecks: false, scrollController: _exploreScrollController),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? Container(
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
                onTap: _showCreateDeckDialog,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isSelected = _tabController.index == index;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF6B1FB1) : Color(0xFF1D1D1D),
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Color(0xFFFF00FF) : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Color(0xFFFF00FF) : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _deckList(List<Deck> decks, {required bool isMyDecks, required ScrollController scrollController}) {
    if (decks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isMyDecks ? Icons.library_books : Icons.explore,
              color: Color(0xFF00FF00),
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              isMyDecks ? 'NO DECKS FOUND\nCREATE YOUR FIRST DECK!' : 'NO MATCHING DECKS FOUND',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF00FF00),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isMyDecks) ...[
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showCreateDeckDialog,
                icon: Icon(Icons.add),
                label: Text('CREATE DECK'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF00FF),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      );
    }
    
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      thickness: 6,
      radius: Radius.circular(10),
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.fromLTRB(16, 0, 16, 80), // Added bottom padding for FAB
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: decks.length,
        itemBuilder: (context, index) {
          Deck deck = decks[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Color(0xFF1D1D1D),
              border: Border.all(
                color: Color(0xFFFF00FF),
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
            child: InkWell(
              onTap: () {
                context.push('/deckDetails', extra: {'deck': deck, 'isMyDeck': isMyDecks});
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: Color(0xFFFF00FF),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            deck.title.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (deck.flashcards.isNotEmpty)
                          Text(
                            '${deck.flashcards.length} CARDS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deck.description,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (deck.tags.isNotEmpty) ...[
                          SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: deck.tags.map((tag) => 
                                Container(
                                  margin: EdgeInsets.only(right: 6),
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF00FFFF),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    tag.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFFF00FF), width: 2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              context.push('/deckDetails', extra: {'deck': deck, 'isMyDeck': isMyDecks});
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xFF00FFFF),
                                border: Border(
                                  right: BorderSide(color: Color(0xFFFF00FF), width: 1),
                                ),
                              ),
                              child: Text(
                                'PLAY',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (isMyDecks) Expanded(
                          child: InkWell(
                            onTap: () {
                              context.push('/deckDetails', extra: {'deck': deck, 'isMyDeck': isMyDecks});
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xFF00FF00),
                                border: Border(
                                  right: BorderSide(color: Color(0xFFFF00FF), width: 1),
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
                        if (isMyDecks) InkWell(
                          onTap: () {
                            _confirmDeleteDeck(deck);
                          },
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
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteDeck(Deck deck) {
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
                  'DELETE DECK?',
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
                  'Are you sure you want to delete "${deck.title.toUpperCase()}"?',
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
                          widget.appState.deleteDeck(deck.id);
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
}
