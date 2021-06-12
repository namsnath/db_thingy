import 'package:flutter/material.dart';

import 'page_configuration.dart';
import '/core/router/generic/enums/page_state.dart';

class PageAction {
  PageState state;
  PageConfiguration? page;
  List<PageConfiguration>? pages;
  Widget? widget;

  PageAction({
    this.state = PageState.none,
    this.page,
    this.pages,
    this.widget,
  });
}
