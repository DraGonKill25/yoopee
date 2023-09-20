import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class WaterDropClipper extends CustomClipper<Path> {
  /*@override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(
        size.width * 0.75, size.height / 4, size.width, size.height / 2);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 3 / 4, size.width / 2, size.height);
    path.quadraticBezierTo(
        size.width * 0.25, size.height * 3 / 4, 0, size.height / 2);
    path.quadraticBezierTo(
        size.width * 0.25, size.height / 4, size.width / 2, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }*/
  @override
  Path getClip(Size size) {
    final path = Path();

    // Demi-cercle en bas
    path.moveTo(0, size.height); // Coin inférieur gauche
    path.quadraticBezierTo(size.width / 2, size.height + 40, size.width,
        size.height); // Coin inférieur droit

    // Ligne droite montante vers le point de rencontre
    path.lineTo(size.width / 2, 0);

    // Ligne droite montante vers le point de rencontre
    path.lineTo(size.width / 2, 0);

    // Fermeture du chemin
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final audioPlayer = AudioPlayer();
  List<String> songOptions = [
    'ocean-waves.mp3',
    'bubble.mp3',
    'waterfall.mp3',
    'water-cup.mp3',
    'bubbles.mp3'
  ];

  List<List<int>> vibrationPatterns = [
    [100, 200, 300, 100, 200, 300, 100, 200, 300],
    [500, 500, 500, 500, 500, 500, 500, 500, 500],
    [1000, 200, 1000, 1000, 200, 1000, 1000, 200, 1000],
    [200, 1000, 200, 1000, 200, 1000, 200, 1000, 200, 1000, 200, 1000],
    [300, 300, 300, 300, 300, 300, 300, 300]
  ];

  int selectedSongIndex = 0;
  int selectedVibrationIndex = 0;

  void _selectSong(String songName) {
    audioPlayer.stop();
    audioPlayer.play(AssetSource(songName));
  }

  void _playAudioAndVibrate() {
    _selectSong(songOptions[selectedSongIndex]);

    Vibration.vibrate(
      pattern: vibrationPatterns[selectedVibrationIndex],
      intensities: [128, 255, 64, 255],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("YOOPEE")),
        backgroundColor: const Color.fromARGB(255, 0, 78, 143),
      ),
      body: LiquidSwipe(
        pages: [
          Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/falls.jpg', // Remplacez par le chemin de votre image
                fit: BoxFit.fill,
              ),
              _buildContent(),
            ],
          ),
          Container(
            color: const Color.fromARGB(255, 15, 163, 237),
            child: _buildContent(),
          ),
          Container(
            color: const Color.fromARGB(255, 0, 16, 118),
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        songOptions.length,
                        (index) => ListTile(
                          title: Text(songOptions[index]),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              selectedSongIndex = index;
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              child: const Text("Musique"),
            ),
            const SizedBox(width: 30),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        vibrationPatterns.length,
                        (index) => ListTile(
                          title: Text("Vibration ${index + 1}"),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              selectedVibrationIndex = index;
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              child: const Text("Vibration"),
            ),
          ]),
          const SizedBox(height: 10),
          /*ElevatedButton(
            onPressed: _playAudioAndVibrate,
            /*style: ElevatedButton.styleFrom(
                //primary: const Color.fromARGB(255, 15, 163, 237),
                //shape: WaterDropClipper(),
                ),*/
            child: SizedBox(
              width: 100,
              height: 50,
              child: ClipPath(
                clipper: WaterDropClipper(),
                child: Container(
                  color: const Color.fromARGB(244, 9, 221, 84),
                  alignment: Alignment.center,
                  child: const Text(
                    "Lancer",
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),*/
          ClipPath(
            clipper: WaterDropClipper(),
            child: InkWell(
              onTap: _playAudioAndVibrate,
              child: Container(
                width: 150,
                height: 75,
                color: const Color.fromARGB(244, 9, 221, 84),
                alignment: Alignment.center,
                child: const Text(
                  "Lancer",
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
