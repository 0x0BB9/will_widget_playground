import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:will_widget_playground/main.dart';

class SplashWidget extends StatefulWidget {
  const SplashWidget({super.key});

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  @override
  void initState() {
    super.initState();
    enterFullScreen();
    Future.delayed(Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (BuildContext context) {
        return const DemoHomePage();
      }));

      ///       builder: (BuildContext context) => const MyHomePage(),
      ///     ),);
    });
  }

  @override
  Widget build(BuildContext context) {
    // I need to add a splash screen here.
    return Scaffold(
      backgroundColor: Color(0xFF42a5f5),
      body: Center(
        child: Image.asset('assets/images/AI_growing.gif'),
      ),
    );
  }

  @override
  dispose() {
    exitFullScreen();
    super.dispose();
  }

  void enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

// Unset Full Screen to normal state (Now Status Bar and Navigation Bar Are Visible)
  void exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }
}


