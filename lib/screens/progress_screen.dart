import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';

class ProgressStatsScreen extends StatelessWidget {
  final ApplicationState appState;
  ProgressStatsScreen({required this.appState});

  @override
  Widget build(BuildContext context) {
    final deckStats = appState.deckStats;
    
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'PLAYER STATS',
          style: TextStyle(
            color: Color(0xFF00FF00),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF6B1FB1),
        elevation: 0,
      ),
      body: deckStats.isEmpty
          ? Center(
              child: Container(
                padding: EdgeInsets.all(20),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.videogame_asset,
                      color: Color(0xFFFF00FF),
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'NO STATS AVAILABLE',
                      style: TextStyle(
                        color: Color(0xFFFF00FF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'START A QUEST TO EARN XP!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    color: Color(0xFF6B1FB1),
                    child: Text(
                      'ACHIEVEMENT BOARD',
                      style: TextStyle(
                        color: Color(0xFFFFFF00),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildOverallStats(deckStats, appState),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    color: Color(0xFF6B1FB1),
                    child: Text(
                      'DECK STATS',
                      style: TextStyle(
                        color: Color(0xFFFFFF00),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: deckStats.entries.map((entry) {
                        Deck? deck;
                        try {
                          deck = appState.myDecks.firstWhere((d) => d.id == entry.key);
                        } catch (e) {
                          deck = null;
                        }
                        if (deck == null) return SizedBox.shrink();
                
                        final stats = entry.value;
                        final accuracy = stats.totalStudied > 0 
                            ? (stats.correctAnswers / stats.totalStudied * 100).toInt() 
                            : 0;
                            
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
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
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                color: Color(0xFF00FFFF),
                                width: double.infinity,
                                child: Text(
                                  deck.title.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    _buildStatRow('CARDS STUDIED', '${stats.totalStudied}', Color(0xFFFFFF00)),
                                    SizedBox(height: 8),
                                    _buildStatRow('CORRECT', '${stats.correctAnswers}', Color(0xFF00FF00)),
                                    SizedBox(height: 8),
                                    _buildStatRow('INCORRECT', '${stats.incorrectAnswers}', Color(0xFFFF0000)),
                                    SizedBox(height: 16),
                                    _buildAccuracyBar(accuracy),
                                    SizedBox(height: 8),
                                    Text(
                                      'ACCURACY: $accuracy%',
                                      style: TextStyle(
                                        color: _getAccuracyColor(accuracy),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildOverallStats(Map<String, DeckStats> deckStats, ApplicationState appState) {
    int totalStudied = 0;
    int totalCorrect = 0;
    int totalIncorrect = 0;
    
    deckStats.values.forEach((stats) {
      totalStudied += stats.totalStudied;
      totalCorrect += stats.correctAnswers;
      totalIncorrect += stats.incorrectAnswers;
    });
    
    final overallAccuracy = totalStudied > 0 
        ? (totalCorrect / totalStudied * 100).toInt() 
        : 0;
    
    return Container(
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
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Color(0xFFFF00FF),
            width: double.infinity,
            child: Text(
              'OVERALL PERFORMANCE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox('STUDIED', totalStudied.toString(), Color(0xFFFFFF00)),
                _buildStatBox('CORRECT', totalCorrect.toString(), Color(0xFF00FF00)),
                _buildStatBox('WRONG', totalIncorrect.toString(), Color(0xFFFF0000)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                _buildAccuracyBar(overallAccuracy),
                SizedBox(height: 8),
                Text(
                  'TOTAL ACCURACY: $overallAccuracy%',
                  style: TextStyle(
                    color: _getAccuracyColor(overallAccuracy),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      width: 80,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFF121212),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildAccuracyBar(int percentage) {
    return Container(
      height: 20,
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
            flex: percentage,
            child: Container(
              color: _getAccuracyColor(percentage),
            ),
          ),
          if (percentage < 100)
            Expanded(
              flex: 100 - percentage,
              child: Container(),
            ),
        ],
      ),
    );
  }
  
  Color _getAccuracyColor(int percentage) {
    if (percentage >= 80) return Color(0xFF00FF00); // Green for high accuracy
    if (percentage >= 50) return Color(0xFFFFFF00); // Yellow for medium accuracy
    return Color(0xFFFF0000); // Red for low accuracy
  }
}
