package com.equalizer.flutter.equalizer_flutter;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.media.audiofx.AudioEffect;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** EqualizerFlutterPlugin */
public class EqualizerFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context applicationContext;
  private Activity activity;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    this.applicationContext = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "equalizer_flutter");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "open":
        int sessionId = (int)call.argument("audioSessionId");
        int content_type = (int)call.argument("contentType");
        displayDeviceEqualizer(sessionId, content_type, result);
        break;
      case "setAudioSessionId":
        setAudioSessionId((int)call.arguments);
        break;
      case "removeAudioSessionId":
        removeAudioSessionId((int)call.arguments);
        break;
      case "init":
        CustomEQ.init((int)call.arguments);
        break;
      case "enable":
        CustomEQ.enable((boolean)call.arguments);
        break;
      case "release":
        CustomEQ.release();
        break;
      case "getBandLevelRange":
        result.success(CustomEQ.getBandLevelRange());
        break;
      case "getCenterBandFreqs":
        result.success(CustomEQ.getCenterBandFreqs());
        break;
      case "getPresetNames":
        result.success(CustomEQ.getPresetNames());
        break;
      case "getBandLevel":
        result.success(CustomEQ.getBandLevel((int)call.arguments));
        break;
      case "setBandLevel":
        int bandId = (int)call.argument("bandId");
        int level = (int)call.argument("level");
        CustomEQ.setBandLevel(bandId, level);
        break;
      case "setPreset":
        CustomEQ.setPreset((String)call.arguments);
        break;
      case "setBassStrength":
          int strength = (int) call.arguments;
          CustomEQ.setBassStrength(strength);
          result.success("Bass strength set to " + strength);
          break;
      default:
        result.notImplemented();
        break;
    }
  }

  void removeAudioSessionId(int sessionId) {
    Intent i = new Intent(AudioEffect.ACTION_CLOSE_AUDIO_EFFECT_CONTROL_SESSION);
    i.putExtra(AudioEffect.EXTRA_PACKAGE_NAME, applicationContext.getPackageName());
    i.putExtra(AudioEffect.EXTRA_AUDIO_SESSION, sessionId);
    applicationContext.sendBroadcast(i);
  }

  void setAudioSessionId(int sessionId) {
    Intent i = new Intent(AudioEffect.ACTION_OPEN_AUDIO_EFFECT_CONTROL_SESSION);
    i.putExtra(AudioEffect.EXTRA_PACKAGE_NAME, applicationContext.getPackageName());
    i.putExtra(AudioEffect.EXTRA_AUDIO_SESSION, sessionId);
    applicationContext.sendBroadcast(i);
  }

  void displayDeviceEqualizer(int sessionId, int content_type, Result result) {
    Intent intent = new Intent(AudioEffect.ACTION_DISPLAY_AUDIO_EFFECT_CONTROL_PANEL);
    intent.putExtra(AudioEffect.EXTRA_PACKAGE_NAME, applicationContext.getPackageName());
    intent.putExtra(AudioEffect.EXTRA_AUDIO_SESSION, sessionId);
    intent.putExtra(AudioEffect.EXTRA_CONTENT_TYPE, content_type);
    if ((intent.resolveActivity(applicationContext.getPackageManager()) != null)) {
      activity.startActivityForResult(intent, 0);
    } else {
      result.error("EQ",
              "No equalizer found!",
              "This device may lack equalizer functionality."
      );
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    applicationContext = null;
    channel.setMethodCallHandler(null);
    channel = null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    this.activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
  }
}
