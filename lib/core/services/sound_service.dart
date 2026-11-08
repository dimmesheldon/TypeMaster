import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final SoundService _instance = SoundService._();
  static SoundService get instance => _instance;

  SoundService._();

  bool _enabled = true;
  bool _initialized = false;
  Uint8List? _clickBytes;

  bool get enabled => _enabled;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('sound_enabled') ?? true;
    _clickBytes = _generateClick();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
  }

  void playClick() {
    if (!_enabled || _clickBytes == null) return;
    final player = AudioPlayer();
    player.play(BytesSource(_clickBytes!));
    player.onPlayerComplete.first.then((_) => player.dispose());
  }

  void playError() {
    if (!_enabled || _clickBytes == null) return;
    final player = AudioPlayer();
    final errorBytes = _generateError();
    player.play(BytesSource(errorBytes));
    player.onPlayerComplete.first.then((_) => player.dispose());
  }

  // Gera um clique de teclado (onda senoidal com decay rápido)
  Uint8List _generateClick() => _generateTone(
    frequency: 1800,
    decayRate: 0.006,
    durationMs: 35,
    amplitude: 20000,
  );

  // Gera um som de erro (tom mais grave e rápido)
  Uint8List _generateError() => _generateTone(
    frequency: 400,
    decayRate: 0.008,
    durationMs: 80,
    amplitude: 18000,
  );

  Uint8List _generateTone({
    required double frequency,
    required double decayRate,
    required int durationMs,
    required int amplitude,
  }) {
    const sampleRate = 22050;
    final numSamples = (sampleRate * durationMs / 1000).round();
    final dataSize = numSamples * 2;

    final buffer = Uint8List(44 + dataSize);
    final bdata = ByteData.view(buffer.buffer);

    // RIFF header
    buffer[0] = 0x52; buffer[1] = 0x49; buffer[2] = 0x46; buffer[3] = 0x46;
    bdata.setUint32(4, 36 + dataSize, Endian.little);
    buffer[8] = 0x57; buffer[9] = 0x41; buffer[10] = 0x56; buffer[11] = 0x45;

    // fmt chunk
    buffer[12] = 0x66; buffer[13] = 0x6D; buffer[14] = 0x74; buffer[15] = 0x20;
    bdata.setUint32(16, 16, Endian.little);
    bdata.setUint16(20, 1, Endian.little);  // PCM
    bdata.setUint16(22, 1, Endian.little);  // mono
    bdata.setUint32(24, sampleRate, Endian.little);
    bdata.setUint32(28, sampleRate * 2, Endian.little);
    bdata.setUint16(32, 2, Endian.little);
    bdata.setUint16(34, 16, Endian.little);

    // data chunk
    buffer[36] = 0x64; buffer[37] = 0x61; buffer[38] = 0x74; buffer[39] = 0x61;
    bdata.setUint32(40, dataSize, Endian.little);

    for (var i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final env = math.exp(-decayRate * sampleRate * t);
      final sample = (amplitude * env * math.sin(2 * math.pi * frequency * t)).round();
      bdata.setInt16(44 + i * 2, sample.clamp(-32768, 32767), Endian.little);
    }

    return buffer;
  }
}
