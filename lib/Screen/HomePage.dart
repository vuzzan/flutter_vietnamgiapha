import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
    @override
    Widget build(BuildContext context) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text('Việt Nam Gia Phả'),
          ),
        body:
          new Container(
            padding: const EdgeInsets.all(0.0),
            alignment: Alignment.center,
          ),
    
        bottomNavigationBar: new BottomNavigationBar(
          items: [
            new BottomNavigationBarItem(
              icon: const Icon(Icons.star),
              title: new Text('Gia Phả'),
            ),
    
            new BottomNavigationBarItem(
              icon: const Icon(Icons.star),
              title: new Text('Người dùng'),
            )
          ]
    
        ),
      );
    }
}