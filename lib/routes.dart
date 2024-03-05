import 'package:flutter/cupertino.dart';

import 'pages/mapa_page.dart'; 

class Routes {
  static Map<String, Widget Function(BuildContext context)> routes =
      <String, WidgetBuilder>{  
    '/mapa': (context) => const Mapa(),

  };

  static String initialRoute = '/mapa';
}
