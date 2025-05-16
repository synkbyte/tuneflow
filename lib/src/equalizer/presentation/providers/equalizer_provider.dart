import 'package:equalizer_flutter/equalizer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:new_tuneflow/injection_container.dart';

class EqualizerProvider extends ChangeNotifier {
  String mode = 'Custom';

  List<int> bands = List.generate(5, (index) => 0);
  bool isEqEnabled = false;
  List presets = [];
  List<int> range = [];
  List<int> centerBandFreqs = [];
  int bassBoost = 0;
  double speed = 1.0;
  String speedString = '1.0x';

  void setEqEnabled(bool cond) {
    if (cond) {
      initializeAudio();
      fetchBandLevelRange();
      fetchPresets();
      fetchCenterBandFreqs();
      fetchBandLevel();
    } else {
      bassBoost = 0;
      speed = 1.0;
      releaseSession();
      notifyListeners();
    }
    isEqEnabled = cond;
    if (cond) readyEqualiser(cond);
    notifyListeners();
  }

  initializeAudio() async {
    await EqualizerFlutter.init(
      audioHandler.audioPlayer.androidAudioSessionId!,
    );
  }

  fetchPresets() async {
    presets = await EqualizerFlutter.getPresetNames();
    notifyListeners();
  }

  fetchBandLevelRange() async {
    range = await EqualizerFlutter.getBandLevelRange();
    notifyListeners();
  }

  fetchCenterBandFreqs() async {
    centerBandFreqs = await EqualizerFlutter.getCenterBandFreqs();
    notifyListeners();
  }

  fetchBandLevel() async {
    int bandId = 0;
    for (int i = 0; i < centerBandFreqs.length; i++) {
      int band = bandId++;
      int bandLevel = await EqualizerFlutter.getBandLevel(band);
      setBandRange(band, bandLevel);
    }
    notifyListeners();
  }

  releaseSession() {
    EqualizerFlutter.release();
    audioHandler.audioPlayer.setSpeed(1.0);
  }

  void readyEqualiser(bool cond) {
    EqualizerFlutter.setEnabled(cond);
    notifyListeners();
  }

  setBandRange(int id, int val) {
    bands[id] = val;
    if (id == 5) {
      notifyListeners();
    }
  }

  setBandRangeBTN(int id, int val) {
    bands[id] = val;
    notifyListeners();
  }

  Future<void> changeFreq(int bandid, int lowervalue) async {
    EqualizerFlutter.setBandLevel(bandid, lowervalue);
    setBandRangeBTN(bandid, lowervalue);
    notifyListeners();
  }

  changeMode(String mode) {
    this.mode = mode;
    if (mode != 'Custom') {
      EqualizerFlutter.setPreset(mode);
      fetchBandLevelRange();
      fetchCenterBandFreqs();
      fetchBandLevel();
    }
    notifyListeners();
  }

  setBassBoost() {
    EqualizerFlutter.setBassStrength(bassBoost);
  }

  bool isThisPreset(String preset) {
    return mode == preset;
  }

  setSpeed() {
    audioHandler.audioPlayer.setSpeed(speed);
  }
}
