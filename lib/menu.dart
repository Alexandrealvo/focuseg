import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // String _nome = "Alexandre";

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: new Text('Raja'),
            accountEmail: new Text('testemail@test.com'),
            currentAccountPicture: new CircleAvatar(
              backgroundImage: new NetworkImage(
                  'http://focuseg.com.br/areadm/downloads/fotosprofissionais/fb7b319d456ab143bc392b380a9ef915.jpg'),
            ),
            decoration: BoxDecoration(
                color: Colors.red[900],
                image: DecorationImage(
                    fit: BoxFit.fill, image: AssetImage('images/tela.jpg'))),
          ),
          Card(
            child: InkWell(
              splashColor: Colors.red[900].withAlpha(30),
              onTap: () {
                print('ola teste.');
              },
              child: Container(
                width: 30,
                height: 100,
                child: Text('A card that can be tapped'),
              ),
            ),
          ),
          Card(
            child: new Container(
              padding: new EdgeInsets.all(32.0),
              color: Colors.red[900],
              child: new Column(
                children: <Widget>[
                  new Text('Hello World'),
                  new Text('How are you?'),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Profile'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('Feedback'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () => {Navigator.of(context).pop()},
          ),
        ],
      ),
    );
  }
}
