import 'package:flutter/material.dart';
import 'package:tflite_audio/tflite_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String _sound = "Press the button to start";
  bool _recording = false;
  late Stream<Map<dynamic, dynamic>> result;
  int inferenceTime = 0;
  @override
  void initState() {
    super.initState();
    TfliteAudio.loadModel(
      inputType: 'rawAudio',
      model: 'assets/soundclassifier_with_metadata.tflite',
      label: 'assets/labels.txt',
      outputRawScores: false,
      numThreads: 1,
      isAsset: true,
    );
  }

  void _recorder() {
    String recognition = "";
    if (!_recording) {
      setState(() => _recording = true);
      result = TfliteAudio.startAudioRecognition(
          detectionThreshold: 0.5,
          sampleRate: 44100,
          bufferSize: 22016,
          numOfInferences: 2);

      result.listen((event) {
        recognition = event["recognitionResult"];
      }).onDone(() {
        setState(() {
          _recording = false;
          _sound = recognition.split(" ")[1];
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  "What's this sound?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
              MaterialButton(
                onPressed: _recorder,
                color: _recording ? Colors.grey : Colors.pink,
                textColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(25),
                child: const Icon(Icons.mic, size: 60),
              ),
              Text(
                _sound,
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
