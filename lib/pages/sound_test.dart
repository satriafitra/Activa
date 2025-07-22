import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundTestPage extends StatefulWidget {
  const SoundTestPage({super.key});

  @override
  State<SoundTestPage> createState() => _SoundTestPageState();
}

class _SoundTestPageState extends State<SoundTestPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playSound() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.play(AssetSource('sounds/success.wav'));
    } catch (e) {
      print("Gagal memutar suara: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Suara'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _playSound,
          child: const Text("Putar Suara"),
        ),
      ),
    );
  }
}
