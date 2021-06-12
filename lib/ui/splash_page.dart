import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '/core/router/app_specific/app_state.dart';

class SplashPage extends StatelessWidget {
  /// The Splash page that is displayed when the app starts.
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GetIt.I.allReady(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          // Add a small timer and trigger splash finished
          // Ensures that the render finished
          Timer(
            Duration(milliseconds: 500),
            () => GetIt.instance<AppState>().setSplashFinished(),
          );
        }

        return Scaffold(
          body: Center(
            child: Text(
              'DB Thingy',
              style: Theme.of(context).textTheme.headline1,
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
