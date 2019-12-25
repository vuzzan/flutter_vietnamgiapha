import 'package:vietnamgiapha/utils/custom_exception.dart';
import 'package:vietnamgiapha/utils/database_helper.dart';
import 'package:vietnamgiapha/utils/network_util.dart';

class User {
  int _id;
  String _email, _password, _name, _city, _address, _mobile;

  User(this._id, this._email, this._password, this._name, this._city,
      this._mobile, this._address);

  User.map(dynamic obj) {
    this._id = int.parse(obj['id'].toString());
    this._email = obj["email"];
    this._password = obj["password"];
    this._name = obj["name"];
    this._city = obj["city"];
    this._mobile = obj["mobile"];
    this._address = obj["address"];
  }

  int get id => _id;
  String get email => _email;
  String get password => _password;
  String get name => _name;
  String get city => _city;
  String get mobile => _mobile;
  String get address => _address;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = _id;
    map["email"] = _email;
    map["password"] = _password;
    map["name"] = _name;
    map["city"] = _city;
    map["mobile"] = _mobile;
    map["address"] = _address;
    return map;
  }

  @override
  String toString() {
    return "User $name Id=$id";
  }
  
  static final NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'https://so789.xyz/server_files';
  static final loginURL = baseURL + "/login_data.php";
  static final signupURL = baseURL + "/signup_data.php";
  static final finalURL = baseURL + "/user_actions.php";
  static final _apiKEY = "somerandomkey";
  
  static Future<User> getUserDetails(String user) async {
    return NetworkUtil.post(
        finalURL, 
        body: {"email": user, "action": "1"}).then(
            (dynamic res) {
      //print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"]);
      return User.map(res['user']);
    });
  }

  static Future<User> loadingUser({bool internetAccess=true}) async {
    var db = new DatabaseHelper();
    var isLoggedIn = await db.isLoggedIn();
    if (isLoggedIn) {
      if (internetAccess) {
        final userEmail = await db.getUser();
        final user = await getUserDetails(userEmail);
        return user;
      } else {
        // get from database
        final user = await db.getUserDetails();
        //onAuthStateChanged(AuthState.LOGGED_IN, user);
        return user;
      }
    } else{
      //onAuthStateChanged(AuthState.LOGGED_OUT, null);
      return null;
    }
  }
}