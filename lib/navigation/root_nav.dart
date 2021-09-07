import 'package:flutter/cupertino.dart';
import 'package:labadaph2_mobile/common/error_page.dart';
import 'package:labadaph2_mobile/common/loading.dart';
import 'package:labadaph2_mobile/navigation/routes.dart';

class RootNav extends StatelessWidget {
  static const String routeName = '/root-nav';
  final Routes routes = new Routes();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
        future: routes.routeLogin(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data ?? ErrorPage("Cannot navigate page.");
          } else {
            return LoadingPanel(true);
          }
        });
  }
}
