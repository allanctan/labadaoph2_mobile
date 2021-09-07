import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/order/orders_page.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer();

  Widget _createHeader(BuildContext context) {
    return Container(
      height: 90,
      color: Theme.of(context).accentColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 40, 0, 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order By Status',
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .apply(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createDrawerItem(BuildContext context,
      {required String text,
      bool notify = false,
      required GestureTapCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
      child: ListTile(
        title: Text(
          text,
          style: Theme.of(context).textTheme.headline5,
        ),
        tileColor: Colors.black12,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _createHeader(context),
            _createDrawerItem(context, text: '1 - New', onTap: () {
              Navigator.of(context)
                  .pushNamed(OrdersPage.routeName, arguments: "new_");
            }),
            _createDrawerItem(context, text: '2 - For Pickup', onTap: () {}),
            _createDrawerItem(context, text: '3 - In Process', onTap: () {}),
            _createDrawerItem(context, text: '4 - For Payment', onTap: () {}),
            _createDrawerItem(context, text: '5 - Paid', onTap: () {}),
            _createDrawerItem(context, text: '6 - For Delivery', onTap: () {}),
            _createDrawerItem(context, text: '7 - Done', onTap: () {}),
            _createDrawerItem(context, text: 'Archived', onTap: () {
              Navigator.of(context)
                  .pushNamed(OrdersPage.routeName, arguments: "archived");
            }),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
