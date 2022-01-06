import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodexpress/main.dart';
import 'package:foodexpress/providers/auth.dart';
import 'package:foodexpress/src/Widget/notification_text.dart';
import 'package:foodexpress/src/Widget/styled_flat_button.dart';
import 'package:foodexpress/src/shared/colors.dart';
import 'package:foodexpress/src/utils/validate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {

  final  userdata;

  EditProfilePage({Key key, @required this.userdata}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name;
  String email;
  String phone;
  String address;
  String username;
  File _image;
  String base64Image;
  String fileName;
  String message = '';
  Map response = new Map();

  Future<void> submit() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      response = await Provider.of<AuthProvider>(context,listen: false)
          .ProfileUpdate(name, email, phone,username,address,fileName,base64Image);
      if (response['success']) {
        message = response['message'];
        _showAlert(context,true);
      } else {
        message = response['message'];
        _showAlert(context, false);
      }

    }

  }
  Future<void> _showAlert(BuildContext context, bool) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Profile '),
          content:Consumer<AuthProvider>(
            builder: (context, provider, child) => provider.notification ?? NotificationText('Profile Updated Not successful.'),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                if(bool){
                  Navigator.of(context).pop();
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => MyHomePage(title: 'Profile',tabsIndex: 3,)));
                }else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Future getImage() async {
      var _picker = ImagePicker();
      var image = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = File(image.path);
        base64Image = base64Encode(_image.readAsBytesSync());
        fileName = _image.path.split("/").last;
      });

    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text("Edit Profile"  ),
      ),
      body: ListView(
          children: <Widget>[
            Form(
              key: _formKey,
              child:Column(
                children:<Widget>[
                  SizedBox(
                    height: 24,
                  ),
                  Stack(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              radius: 80,
                              backgroundColor: Color(0xff476cfb),
                              child: ClipOval(
                                child: new SizedBox(
                                  width: 150.0,
                                  height: 150.0,
                                  child: (_image!=null)?Image.file(
                                    _image,
                                    fit: BoxFit.fill,
                                  ):Image.network(
                                    widget.userdata['image'],
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 60.0),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera,
                                size: 30.0,
                              ),
                              onPressed: () {
                                getImage();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    child:
                    _nameWidget(),
                    margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                  ),
                  Container(
                    child:
                    _emailWidget(),
                    margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                  ),
                  Container(
                    child:
                    _phoneWidget(),
                    margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                  ),
                  Container(
                    child:
                    _usernameWidget(),
                    margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                  ),
                  Container(
                    child:
                    _addressWidget(),
                    margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child:
                    StyledFlatButton(
                      'Update',
                      onPressed: submit,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            )
          ]
      ),
    );
  }

  var border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(width: 1, color: Colors.grey));

  Widget _nameWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Name *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: false,
                  initialValue:widget.userdata['name'],
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 18,height: 0.6,),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54)),
                    hintText: "Enter name",
                  ),
                  validator: (value) {
                    name = value.trim();
                    return Validate.requiredField(value, 'Name is required.');
                  }
              )

            ],
          ),
        )
      ],
    );
  }

  Widget _emailWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Email *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: false,
                  initialValue:widget.userdata['email'],
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 18,height: 0.6,),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54)),
                    hintText: "Enter email",
                  ),
                  validator: (value) {
                    email = value.trim();
                    return Validate.requiredField(value, 'Email is required.');
                  }
              )
            ],
          ),


        )
      ],
    );
  }

  Widget _phoneWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Phone *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: false,
                  initialValue:widget.userdata['phone'],
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 18,height: 0.6,),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54)),
                    hintText: "Enter phone",
                  ),
                  validator: (value) {
                    phone = value.trim();
                    return Validate.requiredField(value, 'Phone is required.');
                  }
              )
            ],
          ),


        )
      ],
    );
  }

  Widget _usernameWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Username',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: false,
                  initialValue:widget.userdata['username'] !=null ? widget.userdata['username']: '',
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 18,height: 0.6,),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54)),
                    hintText: "Enter username",
                  ),
                  validator: (value) {
                    username = value.trim();
                    return Validate.NorequiredField();
                  }
              )
            ],
          ),


        )
      ],
    );
  }
  Widget _addressWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Address',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: false,
                  initialValue:widget.userdata['address'] !=null ? widget.userdata['address'] : '',
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 18,height: 0.6,),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54)),
                    hintText: "Enter address",
                  ),
                  validator: (value) {
                    address = value.trim();
                    return Validate.NorequiredField();
                  }
              )
            ],
          ),


        )
      ],
    );
  }

}
