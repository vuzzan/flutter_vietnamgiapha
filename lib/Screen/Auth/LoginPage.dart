import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vietnamgiapha/Data/User.dart';
import 'package:vietnamgiapha/Screen/HomePage.dart';
import 'package:vietnamgiapha/utils/custom_exception.dart';
import 'package:vietnamgiapha/utils/database_helper.dart';
import 'package:vietnamgiapha/utils/network_util.dart';
import 'package:vietnamgiapha/utils/show_process.dart';
import 'package:vietnamgiapha/utils/colors.dart';
import 'package:vietnamgiapha/utils/internet_access.dart';
import 'package:vietnamgiapha/utils/show_dialog.dart';

enum AuthState { LOGGED_IN, LOGGED_OUT }

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  ShowDialog _showDialog;
  String _password, _email;

  FocusNode _emailNode = new FocusNode();
  FocusNode _passwordNode = new FocusNode();
  bool _obscureText = true;
  bool _isLoadingValue = false;
  bool _autoValidate = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();


  DatabaseHelper db = new DatabaseHelper();
  User user;

  bool internetAccess = false;
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'https://so789.xyz/server_files';
  static final loginURL = baseURL + "/login_data.php";
  static final signupURL = baseURL + "/signup_data.php";
  static final finalURL = baseURL + "/user_actions.php";
  static final _apiKEY = "somerandomkey";
  
  Future<User> getUserDetails(String user) async {
    return NetworkUtil.post(
        finalURL, 
        body: {"email": user, "action": "1"}).then(
            (dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"]);
      return User.map(res['user']);
    });
  }

  void onUserError() {
    user = null;
    var db = new DatabaseHelper();
    db.deleteUsers();
    onAuthStateChanged(AuthState.LOGGED_OUT, null);
  }

  void onUserSuccess(User userDetails) {
    user = userDetails;
    onAuthStateChanged(AuthState.LOGGED_IN, user);
    print("Remember login user " + user.toString());
  }
  // Load user from internet
  doGetUser(String userEmail) async {
    try {
      var user = await getUserDetails(userEmail);
      if (user == null) {
        onUserError();
      } else {
        onUserSuccess(user);
      }
    } on Exception catch (error) {
      print(error.toString());
      onUserError();
    }
  }

  void loadingUser() async {
    var db = new DatabaseHelper();
    var isLoggedIn = await db.isLoggedIn();
    if (isLoggedIn) {
      if (internetAccess) {
        final userEmail = await db.getUser();
        await doGetUser(userEmail);

      } else {
        // get from database
        final user = await db.getUserDetails();
        onAuthStateChanged(AuthState.LOGGED_IN, user);
      }
    } else{
      onAuthStateChanged(AuthState.LOGGED_OUT, null);
    }
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    internetAccess = await checkInternetAccess.check();
  }

  @override
  void initState() {
    getInternetAccessObject();
    //
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _showDialog = new ShowDialog();
    //
    final user = User.loadingUser(internetAccess: internetAccess);
    //
    super.initState();
  }
  void _fieldFocusChange(
      BuildContext context, FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }
  

  Future<User> login(String email, String password) {
    return NetworkUtil.post(loginURL, body: {
      "token": _apiKEY,
      "email": email,
      "password": password
    }).then((dynamic res) {
      //print(res);
      //print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"].toString());
      return new User.map(res["user"]);
      //return new User.map(res);
    });
  }


  Function callbackUser(User userDetails) {
    setState(() {
      this.user = userDetails;
    });
    db.updateUser(user);
  }

  onAuthStateChanged(AuthState state, User user) {
    if (state == AuthState.LOGGED_IN) {
      //save user
      this.callbackUser(user);
      //
      print("Go to home...");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    user: this.user,
                    callbackUser: this.callbackUser,
                  )));
    }
    setState(() {
      _isLoading = false;
    });
  }

  doLogin(String email, String password) async{
    try {
      var user = await login(email, password);
      
      setState(() => _isLoadingValue = false);
      print( user );
      var db = new DatabaseHelper();
      await db.saveUser(user);
      onAuthStateChanged(AuthState.LOGGED_IN, user);
      
    } on Exception catch(error) {

      _showDialog.showDialogCustom(context, "Error", error.toString(),
        fontSize: 17.0, boxHeight: 58.0);
      setState(() {
        _isLoadingValue = false;
      });
    }
  }

  void _submit() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    if (await checkInternetAccess.check()) {
      final form = formKey.currentState;
      if (form!=null && form.validate()) {
        setState(() => _isLoadingValue = true);
        form.save();
        print('Login '+_email+" password: "+_password);
        await doLogin(_email, _password);
      } else {
        setState(() {
          _autoValidate = true;
        });
        //_showSnackBar("Please check internet connection");
      }
    } else {
      _showSnackBar("Please check internet connection");
    }
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  Widget build(BuildContext context) {
     var loginBtn = new Container(
      child: new RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: kHAutoBlue300,
        onPressed: _submit,
        child: Container(
          margin: EdgeInsets.all(15.0),
          child: new Text("LOGIN"),
        ),
      ),
    );
  String validateEmail(String value) {
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value))
        return 'Enter Valid Email';
      else
        return null;
    }

    String validatePassword(String value) {
      if (value.isEmpty)
        return 'Please enter password';
      else
        return null;
    }

    void _toggle() {
      setState(() {
        _obscureText = !_obscureText;
      });
    }
  var loginForm =new ListView(
      children: <Widget>[
       Container(
          child: Column(
            children: <Widget>[
              Image.asset(
                "assets/images/logo.png",
                height: 200.0,
              ),
              Container(
                child: Text(
                  "Home Automation",
                  style: TextStyle(
                    fontSize: 25.0,
                    fontFamily: "Raleway",
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 41.0,
        ),
        new Form(
          autovalidate: _autoValidate,
          key: formKey,
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: new TextFormField(
                  autofocus: true,
                  onSaved: (val) => _email = val.trim(),
                  validator: validateEmail,
                  focusNode: _emailNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (val) {
                    _fieldFocusChange(context, _emailNode, _passwordNode);
                  },
                  decoration: new InputDecoration(
                    hintText: "Email",
                    contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                )
              ),
              new Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: new TextFormField(
                        onSaved: (val) => _password = val,
                        validator: validatePassword,
                        focusNode: _passwordNode,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (val) {
                          _passwordNode.unfocus();
                          //_submit();
                        },
                        decoration: new InputDecoration(
                          hintText: "Password",
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          prefixIcon: Icon(
                            Icons.lock_open,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            onPressed: _toggle,
                          ),
                        ),
                        obscureText: _obscureText,
                      ),
                    ),
                  ],
                ),
              ),
              

            ]
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Center(
          child: _isLoadingValue ? new ShowProgress() : loginBtn,
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: FlatButton(
            onPressed: () async {
              // Map result = await Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => SignupScreen()));
              // if (result != null && result['success']) {
              //   _showDialog.showDialogCustom(
              //       context, result['message'], "You may login now");
              // }
            },
            child: Text(
              'Register?',
              textScaleFactor: 1,
              style: TextStyle(
                color: kHAutoBlue50,
              ),
            ),
          ),
        )
      ]
  );




    return new WillPopScope(
        onWillPop: () => new Future<bool>.value(false),
        child: new Scaffold(
          appBar: null,
          key: scaffoldKey,
          body: new Center(
            child: Container(
              padding: EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
              child: _isLoading ? ShowProgress() : loginForm,
            ),
          ),
        ),
      );
  }
}