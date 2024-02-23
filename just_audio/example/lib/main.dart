import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Future<Stream<Uint8List>?> tts() async {
    try {
      final response = await Dio().post<ResponseBody>(
        "https://channel-healthcare-whisper.openai.azure.com/openai/deployments/tts/audio/speech",
        queryParameters: {
          "api-version": "2024-02-15-preview",
        },
        data: {
          "model": "tts-1",
          "input":
              "The OpenAI API can be applied to virtually any task. We offer a range of models with different capabilities and price points, as well as the ability to fine-tune custom models.",
          "voice": "alloy",
        },
        options: Options(headers: {
          "api-key": "c813c84dbb614129860f6a1d264cd11c",
        }, responseType: ResponseType.stream),
      );
      return response.data?.stream;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  final stream = await tts();
                  if (stream == null) {
                    print("stream is null");
                    return;
                  }
                  final player1 = AudioPlayer();
                  await player1.setAudioSource(
                      StreamSource(stream.asBroadcastStream()),
                      preload: false);
                  player1.play();
                },
                child: const Text("play"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StreamSource extends StreamAudioSource {
  StreamSource(this.stream);

  final Stream<List<int>> stream;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    return StreamAudioResponse(
      sourceLength: null,
      contentLength: null,
      offset: null,
      stream: stream,
      contentType: 'audio/mpeg',
      rangeRequestsSupported: false,
    );
  }
}
