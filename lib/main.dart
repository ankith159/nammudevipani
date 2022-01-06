import 'dart:ffi';
import 'dart:io';
import 'package:location/location.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:foodexpress/models/cartmodel.dart';
import 'package:foodexpress/providers/auth.dart';
import 'package:foodexpress/src/screens/Category.dart';
import 'package:foodexpress/src/screens/CheckOutPage.dart';
import 'package:foodexpress/src/screens/ProfilePage.dart';
import 'package:foodexpress/src/screens/Transaction.dart';
import 'package:foodexpress/src/screens/cartpage.dart';
import 'package:foodexpress/src/screens/loginPage.dart';
import 'package:foodexpress/src/screens/orderhistory.dart';
import 'package:foodexpress/src/screens/shopPage.dart';
import 'package:foodexpress/src/screens/signupPage.dart';
import 'package:foodexpress/src/shared/colors.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import './src/shared/styles.dart';
import './src/shared/fryo_icons.dart';
import 'config/api.dart';
//
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final AuthProvider _auth = AuthProvider();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _auth),
      ],
      child: ScopedModel(
          model: CartModel(),
          child: MaterialApp(
            title: 'Food Exprese',
            theme: ThemeData(
                primarySwatch: Colors.green, primaryColor: Colors.green),
            routes: {
              '/': (BuildContext context) => MyHomePage(),
              '/home': (BuildContext context) => MyHomePage(),
              '/category': (BuildContext context) => Category(
                    shopID: '1',
                  ),
              '/cart': (BuildContext context) => CartPage(),
              '/register': (BuildContext context) => Register(),
              '/chekout': (BuildContext context) => CheckOutPage(),
              '/login': (BuildContext context) => LoginPage(),
            },
          )),
    );
  }
}

class MyHomePage extends StatefulWidget {
  String title;
  int tabsIndex;
  MyHomePage({Key key, this.title, this.tabsIndex}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState(title);
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState(this.authenticated);
  @override
  int _selectedIndex = 0;
  String _title;
  String _sitename;
  var authenticated;
  String token;
  String deviceId;
  String api = FoodApi.baseApi;
  // FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  Future<String> _getId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.device; // unique ID on Android
    }
  }

  @override
  void initState() {
    super.initState();
    token = Provider.of<AuthProvider>(context, listen: false).token;
    checkLocation();
    // firebaseMessaging.configure(
    //   onLaunch: (Map<String, dynamic> msg) {
    //     print(" onLaunch called ${(msg)}");
    //   },
    //   onResume: (Map<String, dynamic> msg) {
    //     print(" onResume called ${(msg)}");
    //   },
    //   onMessage: (Map<String, dynamic> msg) {
    //     print(" onMessage called ${(msg)}");
    //   },
    // );
    // firebaseMessaging.requestNotificationPermissions(
    //     const IosNotificationSettings(sound: true, alert: true, badge: true));
    // firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings setting) {
    //   print('IOS Setting Registed');
    // });
    // firebaseMessaging.getToken().then((token) {
    //   update(token);
    // });
  }

  checkLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  update(String token) async {
    deviceId = await _getId();
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setString('deviceToken', token);
    await storage.setString('deviceId', deviceId);
    print(token);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    authenticated = Provider.of<AuthProvider>(context).status;
    token = Provider.of<AuthProvider>(context, listen: false).token;
    _sitename = Provider.of<AuthProvider>(context).sitename;
    final _tabs = [
      ShopPage(),
      OrderPage(),
      Transaction(),
      ProfilePage(),
    ];

    return  UpgradeAlert(
            child: Scaffold(
      backgroundColor: Color(0xffF4F7FA),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: new IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
        title: Text(
            widget.title != null
                ? widget.title
                : _title != null
                    ? _title
                    : _sitename != null
                        ? _sitename
                        : '',
            textAlign: TextAlign.center),
        actions: <Widget>[
          authenticated == Status.Authenticated
              ? Text('')
              : IconButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  iconSize: 21,
                  icon: Icon(Icons.exit_to_app),
                ),
        ],
      ),
      body: SafeArea(
          child: _tabs[
              widget.tabsIndex != null ? widget.tabsIndex : _selectedIndex]),
      bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.white,
          color: primaryColor,
          buttonBackgroundColor: primaryColor,
          height: 60,
          animationDuration: Duration(
            milliseconds: 200,
          ),
          index: widget.tabsIndex != null ? widget.tabsIndex : _selectedIndex,
          items: <Widget>[
            Icon(Fryo.shop, size: 30, color: Colors.white),
            Icon(Fryo.cart, size: 30, color: Colors.white),
            Icon(Fryo.list, size: 30, color: Colors.white),
            Icon(Fryo.user_1, size: 30, color: Colors.white),
          ],
          onTap: _onItemTapped),
    ));
  }

  Void _onItemTapped(int index) {
    setState(() {
      widget.tabsIndex = null;
      widget.title = null;
      print(index);
      ScopedModel.of<CartModel>(context, rebuildOnChange: true).clearCart();
      if (index == 1) {
        if (authenticated == Status.Authenticated) {
          _selectedIndex = 1;
          _title = 'My Order';
        } else {
          _selectedIndex = 0;
          _title = _sitename;
          Navigator.of(context).maybePop();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        }
      } else if (index == 2) {
        if (authenticated == Status.Authenticated) {
          _selectedIndex = 2;
          _title = 'Transaction';
        } else {
          _selectedIndex = 0;
          _title = _sitename;
          Navigator.of(context).maybePop();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        }
      } else if (index == 3) {
        if (authenticated == Status.Authenticated) {
          _selectedIndex = 3;
          _title = 'Profile';
        } else {
          _selectedIndex = 0;
          _title = _sitename;
          Navigator.of(context).maybePop();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        }
      } else {
        _selectedIndex = 0;
        _title = _sitename;
      }
    });
  }
}
