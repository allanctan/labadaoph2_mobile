import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'appstate_notifier.dart';

class ThemeTestPage extends StatefulWidget {
  static const String routeName = '/themeTest';

  ThemeTestPage();

  @override
  State<StatefulWidget> createState() => new _ThemeTestPageState();
}

class _ThemeTestPageState extends State<ThemeTestPage> {
  final _formKey = new GlobalKey<FormState>();

  bool _obscureText = true;
  bool _checkbox1 = true;
  Object? _checkbox2 = false;
  bool _switch = false;

  String _gender = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Stack(
      children: <Widget>[
        _showForm(),
      ],
    ));
  }

  Widget _showForm() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: new ListView(
              children: <Widget>[
                SwitchListTile(
                  contentPadding: EdgeInsets.fromLTRB(16, 0, 8, 0),
                  title: Row(
                    children: [
                      Text(
                        "Dark Mode",
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.brightness_2,
                      ),
                    ],
                  ),
                  value: Provider.of<AppStateNotifier>(context, listen: false)
                      .isDarkMode,
                  onChanged: (boolVal) {
                    setState(() {
                      Provider.of<AppStateNotifier>(context, listen: false)
                          .updateTheme(boolVal);
                    });
                  },
                ),
                Center(
                  child: Text("Example : Headline 1",
                      style: Theme.of(context).textTheme.headline1),
                ),
                Center(
                  child: Text("Example : Headline 2",
                      style: Theme.of(context).textTheme.headline2),
                ),
                Center(
                  child: Text("Example : Headline 3",
                      style: Theme.of(context).textTheme.headline3),
                ),
                Center(
                  child: Text("Example : Headline 4",
                      style: Theme.of(context).textTheme.headline4),
                ),
                Center(
                  child: Text("Example : Headline 5",
                      style: Theme.of(context).textTheme.headline5),
                ),
                Center(
                  child: Text("Example : Headline 6",
                      style: Theme.of(context).textTheme.headline6),
                ),
                Center(
                  child: Text("Example : Subtitle 1",
                      style: Theme.of(context).textTheme.subtitle1),
                ),
                Center(
                  child: Text("Example : Subtitle 2",
                      style: Theme.of(context).textTheme.subtitle2),
                ),
                Center(
                  child: Text("Example : Button",
                      style: Theme.of(context).textTheme.button),
                ),
                Center(
                  child: Text("Example : Caption",
                      style: Theme.of(context).textTheme.caption),
                ),
                Center(
                  child: Text("Example : BodyText 1",
                      style: Theme.of(context).textTheme.bodyText1),
                ),
                Center(
                  child: Text("Example : BodyText 2",
                      style: Theme.of(context).textTheme.bodyText2),
                ),
                Center(
                  child: Text("Example : Overline",
                      style: Theme.of(context).textTheme.overline),
                ),
                SizedBox(
                  height: 30,
                ),
                // MOBILE NUMBER
                new TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  autofocus: false,
                  decoration: new InputDecoration(
                      hintText: '09XX-XXXXXXX',
                      labelText: 'Mobile Number',
                      icon: new Icon(
                        Icons.local_phone,
                      )),
                  validator: (value) =>
                      value!.isEmpty ? 'Mobile Number can\'t be empty.' : null,
                ),
                SizedBox(
                  height: 8,
                ),
                // PASSWORD
                TextFormField(
                  maxLines: 1,
                  obscureText: _obscureText,
                  autofocus: false,
                  decoration: new InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.remove_red_eye,
                            color: (_obscureText)
                                ? Theme.of(context).disabledColor
                                : Theme.of(context).primaryColor),
                        onPressed: () => setState(() {
                          _obscureText = !_obscureText;
                        }),
                      ),
                      labelText: 'Password',
                      icon: new Icon(
                        Icons.lock,
                      )),
                  validator: (value) {
                    if (value!.isEmpty)
                      return 'Password can\'t be empty';
                    else if (value.length < 6) {
                      return 'Password should be at least 6 characters long';
                    } else
                      return null;
                  },
                ),
                new ElevatedButton(
                  child: new Text('ELEVATED Button'),
                  onPressed: () {
                    final form = _formKey.currentState;
                    if (form!.validate()) {
                      form.save();
                    }
                  },
                ),
                new TextButton(
                  child: new Text('Text Button'),
                  onPressed: () {
                    _formKey.currentState!.reset();
                    /*...*/
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _gender,
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  decoration: new InputDecoration(
                      labelText: 'Gender',
                      icon: new Icon(
                        Icons.wc,
                      )),
                  onChanged: (newValue) {
                    setState(() {
                      _gender = newValue!;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Please select gender.";
                    else
                      return null;
                  },
                  items: <String>['', 'Male', 'Female']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                CheckboxListTile(
                  title: Text("Checkbox 1"),
                  value: _checkbox1,
                  onChanged: (value) {
                    setState(() {
                      _checkbox1 = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                RadioListTile(
                  title: Text("Yah!"),
                  value: true,
                  groupValue: _checkbox2,
                  onChanged: (value) {
                    setState(() {
                      _checkbox2 = value;
                    });
                  },
                ),
                RadioListTile(
                  title: Text("Ney"),
                  value: false,
                  groupValue: _checkbox2,
                  onChanged: (value) {
                    setState(() {
                      _checkbox2 = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: Text("Enable Switch"),
                  value: _switch,
                  onChanged: (value) {
                    setState(() {
                      _switch = value;
                    });
                  },
                ),
                ListTile(
                  title: Text("List Tile"),
                  subtitle: Text("Subtitle"),
                  trailing: IconButton(
                    icon: Icon(Icons.chevron_right),
                    onPressed: null,
                  ),
                ),
                Container(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Container(
                      child: Center(child: Text("NA")),
                      color: Theme.of(context).colorScheme.secondary,
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.zero,
                    ),
                    title: Text("Nike Airforce"),
                    trailing: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("P7,430"),
                    ),
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.secondary),
                      borderRadius: BorderRadius.circular(5)),
                  margin: EdgeInsets.all(4),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.flight),
                    title: Text("Nike Airforce"),
                    trailing: Text("P7,430"),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text("IN"),
                      backgroundColor: Theme.of(context).accentColor,
                      radius: 16,
                    ),
                    title: Text("Nike Airforce"),
                    subtitle: Text("Favorite Classic"),
                    trailing: Text("P7,430"),
                  ),
                ),
              ],
            ),
          ),
        ),);
  }
}
