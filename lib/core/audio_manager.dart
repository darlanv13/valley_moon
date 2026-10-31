import 'dart:async';
import 'package:flame_audio/flame_audio.dart';

/// Audio Manager with smooth volume crossfading for Day, Night and Weather themes.
class ValleyMoonAudioManager {
  static final ValleyMoonAudioManager _instance = ValleyMoonAudioManager._internal();
  factory ValleyMoonAudioManager() => _instance;
  ValleyMoonAudioManager._internal();

  String? _currentTrack;
  double _volume = 0.4;
  bool _isTransitioning = false;
  bool isEnabled = true;

  Future<void> initialize() async {
    try {
      if (isEnabled) {
        await FlameAudio.bgm.initialize();
      }
    } catch (_) {}
  }

  /// Changes background music with a smooth fade-out and fade-in transition.
  Future<void> crossfadeTo(String trackName, {double targetVolume = 0.4}) async {
    if (!isEnabled || _currentTrack == trackName || _isTransitioning) return;

    _isTransitioning = true;

    try {
      // 1. Fade out current track
      if (_currentTrack != null) {
        const fadeSteps = 5;
        final stepDelay = const Duration(milliseconds: 100);
        for (var i = fadeSteps; i >= 0; i--) {
          final vol = (targetVolume * (i / fadeSteps)).clamp(0.0, 1.0);
          try {
            FlameAudio.bgm.audioPlayer.setVolume(vol);
          } catch (_) {}
          await Future.delayed(stepDelay);
        }
      }

      // 2. Play new track at 0 volume
      _currentTrack = trackName;
      await FlameAudio.bgm.play(trackName, volume: 0.0);

      // 3. Fade in new track to target volume
      const fadeSteps = 5;
      final stepDelay = const Duration(milliseconds: 100);
      for (var i = 1; i <= fadeSteps; i++) {
        _volume = (targetVolume * (i / fadeSteps)).clamp(0.0, 1.0);
        try {
          FlameAudio.bgm.audioPlayer.setVolume(_volume);
        } catch (_) {}
        await Future.delayed(stepDelay);
      }
    } catch (_) {
      // Graceful fallback if background audio cannot transition
      try {
        await FlameAudio.bgm.play(trackName, volume: targetVolume);
      } catch (_) {}
    } finally {
      _isTransitioning = false;
    }
  }

  void playSFX(String sfxName, {double volume = 0.6}) {
    if (!isEnabled) return;
    try {
      FlameAudio.play(sfxName, volume: volume);
    } catch (_) {}
  }

  void stop() {
    try {
      FlameAudio.bgm.stop();
      _currentTrack = null;
    } catch (_) {}
  }
}
