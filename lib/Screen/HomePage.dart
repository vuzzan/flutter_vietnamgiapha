import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:vietnamgiapha/Data/User.dart';
import 'package:vietnamgiapha/Screen/Auth/LoginPage.dart';


class HomeScreen extends StatefulWidget {
  final User user;
  final Function callbackUser;

  HomeScreen({this.user, this.callbackUser});
  @override
  _HomePageState createState() {
    return new _HomePageState(user, callbackUser);
  }
}

class _HomePageState extends State<HomeScreen> {
  User user;
  Function callbackUser;

  Function callbackThis(User user) {
    this.callbackUser(user);
    setState(() {
      this.user = user;
    });
  }

  _HomePageState(User user, Function callbackUser) {
    print("new state home");
    this.user = user;
    this.callbackUser = callbackUser;
    print("call callback");
  }

    @override
    Widget build(BuildContext context) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text('Việt Nam Gia Phả - ' + user.name),
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

class HomeAutomationSplashScreen extends StatefulWidget {
  @override
  _HomeAutomationSplashScreenState createState() =>
      new _HomeAutomationSplashScreenState();
}

class _HomeAutomationSplashScreenState
    extends State<HomeAutomationSplashScreen> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 3,
      loadingText: Text("Please wait..."),
      navigateAfterSeconds: new LoginPage(),
      title: new Text(
        'Home Automation',
        style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 35.0),
      ),
      backgroundColor: Colors.white,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 100.0,
      image: Image.asset("assets/images/logo.png"),
      onClick: () => print("Home Automation"),
      loaderColor: Colors.white,
    );
  }
}