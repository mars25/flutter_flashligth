import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const TrainingApp());
}

// class TrainingApp extends StatelessWidget {
//   const TrainingApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: .fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

class TrainingApp extends StatefulWidget {
  const TrainingApp({super.key});

  @override
  State<TrainingApp> createState() => _TrainingAppState();
}

class _TrainingAppState extends State<TrainingApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isFlashOn = false;
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  bool _isListening = false;
  bool _isPermissionGranted = false;
  VideoPlayerController? _videoPlayerController;
  File? _videoFile;

  Future<void> _toggleFlashLight() async {
    try {
      // Ensure camera permission is granted before toggling torch
      if (!await Permission.camera.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Camera permission required to use flashlight'),
          ));
          return;
        }
      }

      if (_isFlashOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }

      if (!mounted) return;
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      // ignore: avoid_print
      print('error toggling flashlight: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flashlight not available')),
      );
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null) return;

    _videoFile = File(result.files.single.path!);
    _videoPlayerController?.dispose();
    _videoPlayerController = VideoPlayerController.file(_videoFile!)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController!.play();
      });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.microphone.status;
    if (status == PermissionStatus.granted) {
      setState(() {
        _isPermissionGranted = true;
      });
    }
  }
  
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      debugLogging: true,
    );
    setState(() {});
  }

  void _startListening() async {
    if (!_isPermissionGranted) {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Microphone permission is required to use speech recognition.'),
        ));
        return;
      }
      setState(() {
        _isPermissionGranted = true;
      });
    }

    if (!_speechEnabled) {
      _initSpeech();
    }
    
    if (_speechEnabled) {
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _lastWords = result.recognizedWords;
          });
        },
        localeId: 'es-ES',
        onDevice: false,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
      );
      setState(() {
        _isListening = true;
      });
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized)
              AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController!),
              ),
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Recognized words:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(_lastWords.isEmpty ? 'Tap the microphone to start listening...' : _lastWords),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'increment',
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'flash',
            onPressed: _toggleFlashLight,
            tooltip: 'Toggle flashlight',
            child: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'mic',
            onPressed: _isListening ? _stopListening : _startListening,
            tooltip: 'Listen',
            child: Icon(_isListening ? Icons.mic_off : Icons.mic),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'video',
            onPressed: _pickVideo,
            tooltip: 'Pick Video',
            child: const Icon(Icons.video_library),
          ),
          if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized)
          FloatingActionButton(
            heroTag: 'play-pause',
            onPressed: () {
              setState(() {
                if (_videoPlayerController!.value.isPlaying) {
                  _videoPlayerController!.pause();
                } else {
                  _videoPlayerController!.play();
                }
              });
            },
            child: Icon(
              _videoPlayerController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
        ],
      ),
    );
  }
}
