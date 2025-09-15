import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:neuroinsight/screens/users/views/auto_tasks_carousel.dart';
import 'package:neuroinsight/screens/users/views/todays_progress_screen.dart';


import 'info_card.dart';

class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame({super.key});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class CardItem {
  final IconData icon;
  bool isFlipped = false;
  bool isMatched = false;

  CardItem({required this.icon});
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  late List<CardItem> _cards;
  bool _gameStarted = false;

  IconData? _currentTargetIcon;
  int _score = 0;
  int _chainCount = 0;
  final Map<IconData, int> _iconTotalCounts = {};

  String _greeting = '';
  String _animationAsset = '';
  String _userName = '';
  String _timeOfDayTitle = '';


  @override
  void initState() {
    super.initState();
    _setupGame();
    _setupGreeting();
  }

  void _setupGreeting() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour < 12) {
        _greeting = 'Good Morning,';
        _animationAsset = 'assets/animations/Good morning.json';
        _timeOfDayTitle = 'Morning Routine';
      } else if (hour < 17) {
        _greeting = 'Good Afternoon,';
        _animationAsset = 'assets/animations/Afternoon.json';
        _timeOfDayTitle = 'Afternoon Routine';
      } else if (hour < 21) {
        _greeting = 'Good Evening,';
        _animationAsset = 'assets/animations/sunset.json';
        _timeOfDayTitle = 'Evening Routine';
      } else {
        _greeting = 'Good Night,';
        _animationAsset = 'assets/animations/night.json';
        _timeOfDayTitle = 'Night Routine';
      }
      _userName = FirebaseAuth.instance.currentUser?.displayName ?? 'User';
    });
  }


  void _setupGame() {
    setState(() {
      _gameStarted = false;
      _score = 0;
      _currentTargetIcon = null;
      _chainCount = 0;
      _iconTotalCounts.clear();

      final List<IconData> icons = [
        Icons.memory, Icons.favorite, Icons.star,
        Icons.anchor, Icons.camera, Icons.lightbulb,
      ];

      for (var icon in icons) {
        _iconTotalCounts[icon] = 2;
      }

      _cards = [...icons, ...icons]
          .map((icon) => CardItem(icon: icon))
          .toList();

      _cards.shuffle();
    });
  }

  void _startPreview() {
    if (_gameStarted) return;

    setState(() {
      for (var card in _cards) {
        card.isFlipped = true;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          for (var card in _cards) {
            card.isFlipped = false;
          }
          _gameStarted = true;
        });
      }
    });
  }

  void _onCardTapped(int index) {
    if (!_gameStarted || _cards[index].isMatched || _cards[index].isFlipped) return;

    final tappedCard = _cards[index];
    setState(() {
      tappedCard.isFlipped = true;
    });

    if (_currentTargetIcon == null) {
      _currentTargetIcon = tappedCard.icon;
      _chainCount = 1;
      tappedCard.isMatched = true;
    } else {
      if (tappedCard.icon == _currentTargetIcon) {
        tappedCard.isMatched = true;
        _chainCount++;
        setState(() {
          _score += 10;
        });

        if (_chainCount == _iconTotalCounts[_currentTargetIcon]) {
          _currentTargetIcon = null;
          _chainCount = 0;
        }
      } else {
        setState(() {
          _score -= 5;
        });
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              tappedCard.isFlipped = false;
            });
          }
        });
      }
    }
    _checkWinCondition();
  }

  void _checkWinCondition() {
    bool allMatched = _cards.every((card) => card.isMatched);
    if (allMatched) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance.collection('sequential_memory_sessions').add({
          'patientId': user.uid,
          'finalScore': _score,
          'timestamp': FieldValue.serverTimestamp(),
          'boardSize': _cards.length,
        });
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Congratulations!'),
          content: Text('You found all the icons!\nFinal Score: $_score'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _setupGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF2DB8A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // New background color
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_animationAsset.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Lottie.asset(_animationAsset, height: 100, width: 100),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_greeting,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(color: Colors.black54)),
                          Text(_userName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const TodaysProgressWidget(),

            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
              child: Text(
                _timeOfDayTitle,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
            const AutoTasksCarousel(),

            InfoCard(
              title: "COGNITIVE GAME",
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Mind Memory',
                      style: GoogleFonts.lora(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      return GestureDetector(
                        onTap: () => _onCardTapped(index),
                        child: Card(
                          elevation: 2.0,
                          color: card.isMatched
                              ? accentColor.withOpacity(0.2)
                              : (card.isFlipped
                              ? Colors.white
                              : Colors.grey.shade200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: card.isFlipped ? accentColor : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: card.isFlipped
                                ? Icon(card.icon,
                                key: ValueKey(card.icon),
                                size: 40,
                                color: Colors.black87)
                                : const SizedBox.shrink(
                                key: ValueKey('hidden')),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play Memory'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _startPreview,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.psychology,
                              color: Colors.black54),
                          const SizedBox(width: 8),
                          Text('Score: ',
                              style: Theme.of(context).textTheme.titleLarge),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child,
                                Animation<double> animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: Text(
                              '$_score',
                              key: ValueKey<int>(_score),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}