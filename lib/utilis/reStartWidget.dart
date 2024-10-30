import 'package:flutter/material.dart';
import 'dart:io' show Directory, Platform, Process, exit;
import 'package:restart_app/restart_app.dart';  // For mobile platforms

void restartApp() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Custom desktop restart logic
    restartAppForDesktop();
  } else if (Platform.isAndroid || Platform.isIOS) {
    // Use restart_app for mobile platforms
    Restart.restartApp();
  }
}

void restartAppForDesktop() async {
  String executable = Platform.resolvedExecutable;
  String path = Directory.current.path;
  String appPath = '$path/$executable';

  await Process.run(appPath, []);  // Relaunch the app
  exit(0);  // Close current instance
}
