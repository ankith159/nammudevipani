import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodexpress/config/api.dart';
import 'package:foodexpress/src/Widget/notification_text.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class AuthProvider with ChangeNotifier {

  Status _status = Status.Uninitialized;
  String _token;
  String _user;
  String _userEmail;
  String _sitename;
  String _currency;
  String _currencyname;
  String _stripekey;
  String _stripesecret;
  String _razorpayKey;
  String _paystackKey;
  String _otpLimit;
  NotificationText _notification;

  Status get status => _status;
  String get token => _token;
  String get sitename => _sitename;
  String get currency => _currency;
  String get currencyname => _currencyname;
  String get stripekey => _stripekey;
  String get stripesecret => _stripesecret;
  String get razorpayKey => _razorpayKey;
  String get paystackKey => _paystackKey;
  String get userName => _user;
  String get userEmail => _userEmail;
  String get otpLimit => _otpLimit;

  NotificationText get notification => _notification;

  final String api = FoodApi.baseApi;

  initAuthProvider() async {
    String token = await getToken();
    String user = await getUser();
    String useremail = await getUserEmail();
    if (token != null) {
      _token = token;
      refreshToken();
      _user = user;
      _userEmail = useremail;
      _status = Status.Authenticated;
    } else {
      _status = Status.Unauthenticated;
    }

    _currency = await getCurrency();
    _sitename = await getSiteName();
    _currencyname = await getCurrencyName();
    _stripekey =await getStripeKey();
    _stripesecret =await getStripeSecret();
    _razorpayKey =await getRazorpayKey();
    _paystackKey =await getPaystackKey();
    _otpLimit =await getOtp();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = Status.Authenticating;
    _notification = null;
    notifyListeners();

    final url = "$api/login";

    Map<String, String> body = {
      'email': email,
      'password': password,
      'role': '2',
    };

    final response = await http.post(Uri.parse(url), body: body,);

    Map<String, dynamic> apiResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      _status = Status.Authenticated;
      _token = apiResponse['token'];
      _user = apiResponse['data']['name'];
      _userEmail = apiResponse['data']['email'];
      await storeUserData(apiResponse);
      notifyListeners();
      return true;
    }

    if (response.statusCode == 401) {
      _status = Status.Unauthenticated;
      _notification = NotificationText(apiResponse['message']);
      notifyListeners();
      return false;
    }

    _status = Status.Unauthenticated;
    _notification = NotificationText('Server error.');
    notifyListeners();
    return false;
  }

  Future<bool> Otplogin(String value) async {
    _status = Status.Authenticating;
    _notification = null;
    notifyListeners();

    final url = "$api/verify-otp";

    Map<String, String> body = {
      'code': value,
    };

    final response = await http.post(Uri.parse(url), body: body,);

    if (response.statusCode == 200) {
      Map<String, dynamic> apiResponse = json.decode(response.body);
      print(apiResponse);
      _status = Status.Authenticated;
      _token = apiResponse['token'];
      _user = apiResponse['data']['name'];
      _userEmail = apiResponse['data']['email'];
      await storeUserData(apiResponse);
      notifyListeners();
      return true;
    }

    if (response.statusCode == 401) {
      _status = Status.Unauthenticated;
      _notification = NotificationText('The code is not valid');
      notifyListeners();
      return false;
    }

    _status = Status.Unauthenticated;
    _notification = NotificationText('Server error.');
    notifyListeners();
    return false;
  }
  Future<bool> Otpregister(String value) async {
    _notification = null;
    final url = "$api/get-otp";
    Map<String, String> body = {
      'otp': value,
    };
    final response = await http.post(Uri.parse(url), body: body,);
    if (response.statusCode == 200) {
      Map<String, dynamic> apiResponse = json.decode(response.body);
      return true;
    }

    if (response.statusCode == 401) {
      _status = Status.Unauthenticated;
      _notification = NotificationText('This user data not found');
      notifyListeners();
      return false;
    }

    _status = Status.Unauthenticated;
    _notification = NotificationText('Server error.');
    notifyListeners();
    return false;
  }


  Future<Map> register(String name, String email,String phone, String password, String passwordConfirm) async {
    final url = "$api/reg";
    _notification = null;
    notifyListeners();
    Map<String, String> body = {
      'name': name,
      'email': email,
      'phone': phone,
      'role': '2',
      'password': password,
      'password_confirmation': passwordConfirm,
    };

    Map<String, dynamic> result = {
      "success": false,
      "message": 'Unknown error.'
    };

    final response = await http.post( Uri.parse(url), body: body );
    Map apiResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      _notification = NotificationText('Registration successful, please log in.', type: 'info');
      notifyListeners();
      result['success'] = true;
      return result;
    }

    if (response.statusCode == 422) {
      if (apiResponse['message'].containsKey('email')) {
        result['message'] = apiResponse['message']['email'][0];
        _notification = NotificationText( result['message']);
        notifyListeners();
        return result;
      }

      if (apiResponse['message'].containsKey('password')) {
        result['message'] = apiResponse['message']['password'][0];
        _notification = NotificationText( result['message']);
        notifyListeners();
        return result;
      }

      return result;
    }

    return result;
  }

  Future<Map> ProfileUpdate(String name, String email,String phone, String username, String address,String fileName, String base64Image) async {
    Map<String, String> params = {
      "name":name,
      "email": email,
      "phone": phone,
      "username": username,
      "address": address,
      "image": base64Image != null ? base64Image:'',
      "fileName": fileName != null?fileName:'',
    };

    Map<String, dynamic> result = {
      "success": false,
      "message": 'Unknown error.'
    };
    final url = "$api/profile";
    final response = await http.put(Uri.parse(url),body:params, headers: {HttpHeaders.acceptHeader: "application/json",HttpHeaders.authorizationHeader: 'Bearer $token'});
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      _notification = NotificationText('Successfully Updated Profile', type: 'info');
      result['success'] = true;
      return result;
    } else {
      throw Exception('Failed to data');
    }

  }

  Future<Map> ChangePassword(String password_current,String password, String passwordConfirm) async {
    Map<String, String> params = {
      "password_current":password_current,
      "password": password,
      "password_confirmation": passwordConfirm,
    };

    Map<String, dynamic> result = {
      "success": false,
      "message": 'Unknown error.'
    };
    final url = "$api/change-password";
    final response = await http.put(Uri.parse(url),body:params, headers: {HttpHeaders.acceptHeader: "application/json",HttpHeaders.authorizationHeader: 'Bearer $token'});
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      print(resBody);
      _notification = NotificationText('Successfully Change Password ', type: 'info');
      result['success'] = true;
      return result;
    }else if (response.statusCode == 422) {
      print(resBody);
      result['success'] = false;
      if (resBody['message'].containsKey('password_current')) {
        _notification = NotificationText(resBody['message']['password_current'][0],);
        result['message'] = resBody['message']['password_current'][0];
        return result;
      } if (resBody['message'].containsKey('password')) {
        _notification = NotificationText(resBody['message']['password'][0],);
        result['message'] = resBody['message']['password'][0];
        return result;
      }
      return result;
    }else {
      throw Exception('Failed to data');
    }
  }
  Future<bool> refreshToken() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    storage.remove('token');
    _status = Status.Authenticating;
    _notification = null;
    notifyListeners();
    final url = "$api/refresh";
    final response = await http.get(Uri.parse(url),headers: {HttpHeaders.acceptHeader: "application/json",HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      Map<String, dynamic> apiResponse = json.decode(response.body);
      _status = Status.Authenticated;
      _token = apiResponse['token'];
      await storeUserData(apiResponse);
      notifyListeners();
      return true;
    }
    _status = Status.Unauthenticated;
    _notification = NotificationText('Server error.');
    notifyListeners();
    return false;
  }


  Future<bool> setting() async {
    final url = "$api/settings";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> apiResponse = json.decode(response.body);
      _sitename = apiResponse['data']['site_name'].toString();
      _currency = apiResponse['data']['currency_code'].toString();
      _currencyname = apiResponse['data']['currency_name'].toString();
      _stripekey = apiResponse['data']['stripe_key'].toString();
      _stripesecret = apiResponse['data']['stripe_secret'].toString();
      _razorpayKey = apiResponse['data']['razorpay_key'].toString();
      _paystackKey = apiResponse['data']['paystack_key'].toString();
      _otpLimit = apiResponse['data']['otp_digit_limit'].toString();
      await storeSettingData(apiResponse);
      notifyListeners();
      return true;
    }

    if (response.statusCode == 401) {
      _status = Status.Unauthenticated;
      _notification = NotificationText('Invalid email or password.');
      notifyListeners();
      return false;
    }

    _status = Status.Unauthenticated;
    _notification = NotificationText('Server error.');
    notifyListeners();
    return false;
  }
  storeUserData(apiResponse) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setString('token', apiResponse['token']);
    if(apiResponse['data'] !=null){
      await storage.setString('email', apiResponse['data']['email']);
    }
  }
  storeSettingData(apiResponse) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setString('sitename', apiResponse['data']['site_name'].toString());
    await storage.setString('currency', apiResponse['data']['currency_code'].toString());
    await storage.setString('currencyname',apiResponse['data']['currency_name'].toString());
    await storage.setString('stripekey', apiResponse['data']['stripe_key'].toString());
    await storage.setString('stripesecret', apiResponse['data']['stripe_secret'].toString());
    await storage.setString('razorpayKey', apiResponse['data']['razorpay_key'].toString());
    await storage.setString('paystackKey', apiResponse['data']['paystack_key'].toString());
    await storage.setString('otp', apiResponse['data']['otp_digit_limit'].toString());
  }
  Future<String> getToken() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String token = storage.getString('token');
    return token;
  }
  Future<String> getSiteName() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String sitename = storage.getString('sitename');
    return sitename;
  }
  Future<String> getCurrency() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String currency = storage.getString('currency');
    return currency;
  }
  Future<String> getCurrencyName() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String currencyname = storage.getString('currencyname');
    return currencyname;
  }
  Future<String> getStripeKey() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String stripekey = storage.getString('stripekey');
    return stripekey;
  }
  Future<String> getStripeSecret() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String stripesecret = storage.getString('stripesecret');
    return stripesecret;
  }
  Future<String> getRazorpayKey() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String razorpayKey = storage.getString('razorpayKey');
    return razorpayKey;
  }
  Future<String> getPaystackKey() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String paystackKey = storage.getString('paystackKey');
    return paystackKey;
  }
  Future<String> getOtp() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String otp = storage.getString('otp');
    return otp;
  }
  Future<String> getUser() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String name = storage.getString('name');
    return name;
  }

  Future<String> getUserEmail() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String email = storage.getString('email');
    return email;
  }

  logOut() async {
    _status = Status.Unauthenticated;
    _token = null;
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.clear();
    notifyListeners();
    return true;
  }

}