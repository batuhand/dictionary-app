import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:login/home_page.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = new TextEditingController();
  final passwordController = new TextEditingController();
  String token;


  @override
  Widget build(BuildContext context) {
    authorize();
    print(token);
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/logo.png'),
      ),
    );

    final email = TextFormField(
      controller: usernameController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      controller: passwordController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          print(usernameController.text);
          print(passwordController.text);
          login(usernameController.text, passwordController.text);
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Log In', style: TextStyle(color: Colors.white)),
      ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            email,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            loginButton,
            forgotLabel
          ],
        ),
      ),
    );
  }
  
  
  login(String username, String password) async{

    print(token);
    String sendToken = "Bearer " + token;
    print(sendToken);
  
      String url = "https://dictionaryapp.azurewebsites.net/api/userlists/";
      url = url + username;
      var response = await http.get(
        Uri.encodeFull(url),
        headers: {
          "Accept": "application/json",
          "Authorization" : sendToken,
        }
      );
      List result = json.decode(response.body);
      print(result[0]["password"].toString());
      String pass = result[0]["password"].toString();
      if(password == pass){
        Navigator.of(context).pushNamed(HomePage.tag);
      }else{
        print("Basarisiz giris");
      }
      print(result);

  }


  authorize() async{
    var body = jsonEncode({"UserName": "admin","Password":"123"});
    try{  
      http.post("https://dictionaryapp.azurewebsites.net/api/auth/login",body: body,headers: {"content-type":"application/json"}).then((response){
        //print(response.statusCode);
        //print(response.body);
        var result = json.decode(response.body);
        //print(result["token"]);
        String tok = result["token"].toString();
        token = tok;


      });
    }catch(e){
      print("error");
      }
    
  }


}
