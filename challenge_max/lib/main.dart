import 'package:challenge_max/models/completedChallenges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'models/challenge.dart';
import 'services/challenge_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => CompletedChallenges(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weekly Challenges',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ConfettiController _confettiController;
  bool _bingoFired = false;
  bool _fullFired = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Challenges')),
      body: Consumer<CompletedChallenges>(
        builder: (ctx, completed, _) {
          // check for bingoes
          if (completed.hasBingo && !_bingoFired) {
            _bingoFired = true;
            _confettiController.play();
          }
          if (completed.isFullBoard && !_fullFired) {
            _fullFired = true;
            _confettiController.play();
          }

          return Stack(
            alignment: Alignment.topCenter,
            children: [
              // your existing StreamBuilder→GridView code:
              _buildGridBody(),

              // the confetti overlay
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 50,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGridBody() {
    return StreamBuilder<List<Challenge>>(
      stream: ChallengeService().streamWeeklyChallenges(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || snap.data == null || snap.data!.isEmpty) {
          return const Center(child: Text('No challenges available.'));
        }
        final challenges = snap.data!;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 5,
              childAspectRatio: 1,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: challenges.map((c) {
                final done = 
                  context.watch<CompletedChallenges>().isDone(c.id);
                final label = c.id.replaceAll('challenge_', 'C');
                return Card(
                  color: done ? Colors.deepOrange : null,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChallengeDetailPage(challenge: c),
                      ),
                    ),
                    child: Center(child: Text(label,
                      style: TextStyle(
                        color: done ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    )),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}


class ChallengeDetailPage extends StatefulWidget {
  final Challenge challenge;
  const ChallengeDetailPage({super.key, required this.challenge});

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = context.watch<CompletedChallenges>().isDone(widget.challenge.id);
    return Scaffold(
      appBar: AppBar(title: Text(widget.challenge.title)),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Text(
                widget.challenge.description,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          if (done)
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            disabledBackgroundColor: Colors.deepOrange,
            disabledForegroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: done
              ? null
              : () {
                  _confettiController.play();
                  context.read<CompletedChallenges>().markDone(widget.challenge.id);
                },
          child: const Text(
            'Challenge Completed!',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
