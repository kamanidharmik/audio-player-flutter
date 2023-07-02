import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:media_info/media_info.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  late final Widget child;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Audio Player',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyAudioPlayer());
  }
}

class MyAudioPlayer extends StatefulWidget {
  const MyAudioPlayer({super.key});

  @override
  State<MyAudioPlayer> createState() => _MyAudioPlayerState();
}

class _MyAudioPlayerState extends State<MyAudioPlayer> {
  bool isplaying = false;
  bool play = false;
  AssetsAudioPlayer asp = AssetsAudioPlayer();
  late double slidervalue;

  List<Audio> audio = [
    Audio("assets/songs/song.mp3",
        metas: Metas(image: const MetasImage.asset("assets/images/s1.jpg"))),
    Audio("assets/songs/b.mp3",
        metas: Metas(image: const MetasImage.asset("assets/images/s2.jpg"))),
    Audio("assets/songs/a.mp3",
        metas: Metas(image: const MetasImage.asset("assets/images/s3.jpg"))),
  ];

  var path = "assets/songs/song.mp3";
  List<String> images = [
    "assets/images/s1.jpg",
    "assets/images/s2.jpg",
    "assets/images/s3.jpg",
  ];

  List<String> names = ["Song 1", "Song 2", "Song 3"];

  //This Variale Increment and Decrement The Value Of Songs
  int image1 = 0;

  @override
  void initState() {
    //Below Code Initialize The PlayList
    asp.open(Playlist(audios: audio), showNotification: true, autoStart: false);
    var path = "assets/songs/song.mp3";
    //getFileDuration(path);
    //print(totaltime);
    super.initState();
  }

  double totaltime = 150;
  String formatedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(title: const Text('Play Audio')),
          body: Container(
              margin: const EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  Container(
                    height: 300,
                    child: Image(
                      image: AssetImage(images[image1]),
                      height: 300,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                      names[image1],
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //Player Builder Returns The The Minitues Values

                  Container(
                      child: StreamBuilder(
                    stream: asp.currentPosition,
                    builder: (context, snapshot) {
                      final Duration? duration = snapshot.data;
                      return Slider(
                          value: duration != null
                              ? duration.inSeconds.toDouble()
                              : 95.0,
                          min: 0.0,
                          max: asp.current.hasValue
                              ? asp
                                  .current.valueOrNull!.audio.duration.inSeconds
                                  .toDouble()
                              : 150,
                          onChanged: (double value) async {
                            setState(() {
                              slidervalue = value;
                              asp.seek(Duration(seconds: slidervalue.toInt()));
                            });
                          });
                    },
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                        alignment: Alignment.topLeft,
                        child: PlayerBuilder.currentPosition(
                            player: asp,
                            builder: ((context, position) {
                              return Text(
                                formatedTime(timeInSecond: position.inSeconds),
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              );
                            })),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                        alignment: Alignment.topRight,
                        child: PlayerBuilder.currentPosition(
                            player: asp,
                            builder: ((context, position) {
                              return Text(
                                formatedTime(
                                    timeInSecond: asp.current.hasValue
                                        ? asp.current.value!.audio.duration
                                            .inSeconds
                                        : 150),
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              );
                            })),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              asp.previous();
                              image1 == 0 ? print("Its Last") : image1--;
                              print(" Remove 1 in : $image1");
                            });
                          },
                          child: const Text("Privious")),
                      FloatingActionButton(
                          onPressed: () {
                            print(
                                "Seconds Are : ${asp.currentPosition.value.inSeconds.toDouble()}");

                            if (asp.isPlaying.value == false) {
                              setState(() {
                                asp.play();
                              });
                            } else {
                              setState(() {
                                asp.pause();
                              });
                            }
                          },
                          child: asp.isPlaying.value == false
                              ? const Icon(Icons.play_arrow)
                              : const Icon(Icons.pause)),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              asp.next();

                              image1 == 2 ? print("Its Last") : image1++;
                              print(" Added 1 in : $image1");
                            });
                          },
                          child: const Text("Next")),
                    ],
                  ),
                ],
              ))),
    );
  }
}
