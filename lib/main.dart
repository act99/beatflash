import 'dart:async';
import 'dart:math';
import 'dart:core';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen/screen.dart';
import 'package:tf_audio/admob.dart';
import 'package:tf_audio/decibel_recognization.dart';
import 'package:torch_compat/torch_compat.dart';
import 'package:wakelock/wakelock.dart';

enum Command {
  start,
  stop,
  change,
}

const AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT;

void main() {
  runApp(MyApp());
  Screen.keepOn(true);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DroptheBeat(),
    );
  }
}

class DroptheBeat extends StatefulWidget {
  @override
  _DroptheBeatState createState() => _DroptheBeatState();
}

class _DroptheBeatState extends State<DroptheBeat>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Stream stream;
  StreamSubscription listener;
  List<int> currentSamples;
  // Refreshes the Widget for every possible tick to force a rebuild of the sound wave
  AnimationController controller;
  // AppLifecycleState appLifecycleState;

  Color _iconColor = Colors.white;
  bool isRecording = false;
  bool memRecordingState = false;
  bool isActive;
  DateTime startTime;

  // noise decibel
  StreamSubscription<NoiseReading> _noiseSubscription;
  NoiseMeter _noiseMeter;
  NoiseReading noiseReadingData;
  var totalDecibelListB = [];
  var decibelAverageB;
  bool _isRecording = false;

  // microphone values
  var average;
  var allValue;
  var max;
  var min;
  var decibel;
  var waveform;

  // admobManage
  AdmobManager admob = AdmobManager();

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   setState(() {
  //     appLifecycleState = state;
  //   });
  // }

  @override
  void initState() {
    print("Init application");
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      initPlatformState();
    });
    _noiseMeter = new NoiseMeter(onError);
    admob.init();
    admob.showBannerAd();
  }

  // Decibel void
  void onError(PlatformException e) {
    print(e.toString());
    _isRecording = false;
  }

  void onData(NoiseReading noiseReading) {
    this.setState(() {
      if (!this._isRecording) {
        this._isRecording = true;
      }
    });
    print(noiseReading.toString());
    setState(() {
      noiseReadingData = noiseReading;
    });

    totalDecibelListB.add(noiseReadingData.bValue);
    var resultB = totalDecibelListB.map((e) => e).reduce((a, b) => a + b) /
        totalDecibelListB.length;

    decibelAverageB = resultB;

    print('1. $resultB');
    flareBombIng(noiseReadingData.bValue, resultB);
  }

  // void flareBomb(double bvalue, double bresult) {
  //   if (bvalue > bresult) {
  //     TorchCompat.turnOn();
  //     TorchCompat.turnOff();
  //   } else {
  //     TorchCompat.turnOff();
  //   }
  // }

  void flareBombIng(double bvalue, double bresult) {
    bvalue > bresult ? TorchCompat.turnOff() : TorchCompat.turnOn();
  }

  void start() async {
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
      setState(() {
        Wakelock.enabled;
      });
    } catch (err) {
      print(err);
    }
  }

  void stop() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription.cancel();
        _noiseSubscription = null;
      }
      setState(() {
        Wakelock.disable();
      });
      this.setState(() {
        this._isRecording = false;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  // microphone void
  void _controlMicStream({Command command: Command.change}) async {
    switch (command) {
      case Command.change:
        _changeListening();
        break;
      case Command.start:
        _startListening();
        start();
        break;
      case Command.stop:
        _stopListening();
        stop();
        totalDecibelListB.clear();
        noiseReadingData = null;
        setState(() {});
        TorchCompat.turnOff();
        break;
    }
  }

  Future<bool> _changeListening() async =>
      !isRecording ? await _startListening() : _stopListening();

  Future<bool> _startListening() async {
    if (await Permission.contacts.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
    }

// You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
    ].request();
    print(statuses[Permission.location]);

    if (isRecording) return false;
    // if this is the first time invoking the microphone() method to get the stream, we don't yet have access to the sampleRate and bitDepth properties
    stream = await MicStream.microphone(
        audioSource: AudioSource.DEFAULT,
        sampleRate: 16000,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: AUDIO_FORMAT);
    // after invoking the method for the first time, though, these will be available;
    // It is not necessary to setup a listener first, the stream only needs to be returned first
    print(
        "Start Listening to the microphone, sample rate is ${await MicStream.sampleRate}, bit depth is ${await MicStream.bitDepth}");

    setState(() {
      isRecording = true;
      startTime = DateTime.now();
    });
    listener = stream.listen((samples) async {
      bool first = true;
      currentSamples = [];
      List<int> sampleAdd = [];
      int tmp = 0;
      for (int sample in samples) {
        if (sample > 128) sample -= 255;
        if (first) {
          tmp = sample * 128;
        } else {
          tmp += sample;
          currentSamples.add(tmp);
          sampleAdd.add(tmp);
          tmp = 0;
        }
        first = !first;
      }
      waveform = sampleAdd;
      currentSamples.sort();
      average = currentSamples.first + currentSamples.last;
      allValue = currentSamples.map((e) => e).reduce((a, b) => a + b) /
          currentSamples.length;
      // max = currentSamples.first
      int maxDecibel = currentSamples.last;
      int minDecibel = currentSamples.first;
      max = maxDecibel;
      min = minDecibel * -1;
      double mean = 0.5 * (min.abs() + max.abs());
      double maxAmp = pow(2, 15) + 0.0;
      decibel = 20 * log(maxAmp * mean) * log10e * 0.5;

      if (average < 256 && average > 230) {
        TorchCompat.turnOn();
      } else {
        TorchCompat.turnOff();
      }
      // print(currentSamples);
      print(waveform);
      print('decibel = $decibel');
      print(max);
      print(min);
      print(average);
    });
    return true;
  }

  bool _stopListening() {
    if (!isRecording) return false;
    print("Stop Listening to the microphone");
    listener.cancel();
    TorchCompat.turnOff();
    setState(() {
      isRecording = false;
      currentSamples = null;
      startTime = null;
      waveform = null;
    });
    return true;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;
    isActive = true;

    controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..addListener(() {
            if (isRecording) setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed)
              controller.reverse();
            else if (status == AnimationStatus.dismissed) controller.forward();
          })
          ..forward();
  }

  Color _getBgColor() => (isRecording) ? Colors.cyan : Colors.cyan;
  Icon _getIcon() => (isRecording)
      ? Icon(
          Icons.stop,
          color: Colors.red,
        )
      : Icon(
          Icons.play_arrow,
          color: Colors.white,
        );

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: isRecording
            ? EdgeInsets.only(bottom: height * 0.1)
            : EdgeInsets.only(bottom: height * 0.4),
        child: FloatingActionButton(
          onPressed: _controlMicStream,
          child: _getIcon(),
          foregroundColor: _iconColor,
          backgroundColor: _getBgColor(),
          tooltip: (isRecording) ? "Stop recording" : "Start recording",
        ),
      ),
      body: isRecording
          ? CustomPaint(
              painter: WavePainter(waveform, _getBgColor(), context),
            )
          : StartScreen(),
    );
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     isActive = true;
  //     print("Resume app");

  //     _controlMicStream(
  //         command: memRecordingState ? Command.start : Command.stop);
  //   } else if (isActive) {
  //     memRecordingState = isRecording;
  //     _controlMicStream(command: Command.stop);

  //     print("Pause app");
  //     isActive = false;
  //   }
  // }

  @override
  void dispose() {
    listener.cancel();
    controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    TorchCompat.turnOff();
    TorchCompat.dispose();
    Wakelock.disable();

    super.dispose();
  }
}

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: height * 0.3,
          ),
          Container(
            width: width * 1,
            child: Text(
              'Drop the beat Bomb!',
              style: TextStyle(
                color: Colors.cyan,
                fontSize: height * 0.038,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  List<int> samples;
  List<Offset> points;
  Color color;
  BuildContext context;
  Size size;

  // Set max val possible in stream, depending on the config
  final int absMax =
      (AUDIO_FORMAT == AudioFormat.ENCODING_PCM_8BIT) ? 127 : 32767;

  WavePainter(this.samples, this.color, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    this.size = context.size;
    size = this.size;

    Paint paint = new Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    points = toPoints(samples);

    Path path = new Path();
    path.addPolygon(points, false);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldPainting) => true;

  // Maps a list of ints and their indices to a list of points on a cartesian grid
  List<Offset> toPoints(List<int> samples) {
    List<Offset> points = [];
    if (samples == null)
      samples =
          List<int>.filled(size.width.toInt(), (0.5 * size.height).toInt());
    for (int i = 0; i < min(size.width, samples.length).toInt(); i++) {
      points.add(
          new Offset(i.toDouble(), project(samples[i], absMax, size.height)));
    }
    return points;
  }

  double project(int val, int max, double height) {
    double waveHeight =
        (max == 0) ? val.toDouble() : (val / max) * 0.5 * height;
    return waveHeight + 0.5 * height;
  }
}
