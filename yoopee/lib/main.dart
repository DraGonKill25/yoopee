import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
/*
class WaterDropClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height); // Coin inférieur gauche
    path.quadraticBezierTo(size.width / 2, size.height + 40, size.width,
        size.height); // Coin inférieur droit
    path.lineTo(
        size.width / 2, 0); // Ligne droite montante vers le point de rencontre
    path.close(); // Fermeture du chemin
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}*/

class WaterDropClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Calculer le centre du cercle
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    // Calculer le rayon du cercle (la moitié de la largeur ou de la hauteur)
    double radius = size.width / 4;

    path.addOval(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius));

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
    [500, 1000, 500, 1000, 500, 1000, 500, 1000, 500, 1000],
    [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000],
    [2000, 1000, 2000, 2000, 1000, 2000, 2000, 1000, 2000],
    [1000, 2000, 1000, 2000, 1000, 2000, 1000, 2000, 1000],
    [600, 600, 600, 600, 600, 600, 600, 600, 600]
  ];

  int selectedSongIndex = 0;
  int selectedVibrationIndex = 0;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

    tz.initializeTimeZones();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = DarwinInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: (details) =>
            onSelectNotification(details.payload));
  }

  Future<void> _selectSong(String songName) async {
    await audioPlayer.stop();
    await audioPlayer.play(AssetSource(songName));
  }

  Future<void> _playAudioAndVibrate() async {
    await _selectSong(songOptions[selectedSongIndex]);

    Vibration.vibrate(
      pattern: vibrationPatterns[selectedVibrationIndex],
      intensities: [128, 255, 64, 255],
    );

    // Set an alarm after 5 seconds
    //await scheduleNotification();
  }

  Future<void> scheduleNotification(Duration delay) async {
    // Obtenez l'heure actuelle
    DateTime now = DateTime.now();

    // Calculez le temps planifié en ajoutant le délai à l'heure actuelle
    DateTime scheduledTime = now.add(delay);

    // Convertissez le temps planifié en TZDateTime
    final String timeZoneName = tz.local.name;
    tz.TZDateTime scheduledTZTime = tz.TZDateTime(
      tz.getLocation(timeZoneName),
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'alarm_channel',
      'Alarme',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Planifiez la notification en utilisant le temps calculé
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Alarme de vibration',
      'Il est temps de vibrer !',
      scheduledTZTime,
      platformChannelSpecifics,
      // ignore: deprecated_member_use
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {}

  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint("Notification payload: $payload");
    }
  }

  Future<void> _selectTimeForNotification(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      // Obtenez la date et l'heure actuelles
      DateTime now = DateTime.now();

      // Calculez le DateTime pour le temps sélectionné
      DateTime selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // Calculez la différence entre le temps sélectionné et le temps actuel
      Duration delay = selectedDateTime.difference(now);

      // Utilisez la durée calculée pour planifier la notification
      await scheduleNotification(delay);
      print("Rappel défini à : ${selectedTime.hour}:${selectedTime.minute}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("YOOPEE")),
        backgroundColor: const Color.fromARGB(255, 0, 78, 143),
      ),
      body: Stack(
        children: [
          LiquidSwipe(
            pages: [
              Stack(
                fit: StackFit.expand,
                children: [
                  _buildContent(),
                  Image.asset(
                    'assets/falls.jpg', // Remplacez par le chemin de votre image
                    fit: BoxFit.fill,
                  ),
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
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
              ],
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 20), // Espace supplémentaire

            // Bouton pour définir un rappel
            TextButton(
              onPressed: () {
                _selectTimeForNotification(context);
              },
              child: const Text(
                "Définir un rappel",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
