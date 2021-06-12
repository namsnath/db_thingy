import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'router_delegate.dart';

/// An extension of [RootBackButtonDispatcher] that calls [CustomRouterDelegate.popRoute()].
class CustomBackButtonDispatcher extends RootBackButtonDispatcher {
  final log = Logger('CustomBackButtonDispatcher');
  final CustomRouterDelegate _routerDelegate;

  CustomBackButtonDispatcher(this._routerDelegate) : super();

  Future<bool> didPopRoute() {
    return _routerDelegate.popRoute();
  }
}
