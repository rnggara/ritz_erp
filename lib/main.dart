import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cyphermweb/app.dart';
import 'package:cyphermweb/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kaliber',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: MyHomePage(title: 'Kaliber'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  TextEditingController user = new TextEditingController();
  TextEditingController pass = new TextEditingController();
  String dropdownValue = "RITZ";

  Future writeText(String username, String password) async {
    final path = await getApplicationDocumentsDirectory();
    final file_path = await path.path;
    File file = File('$file_path/env.txt');
    file.writeAsString('$username|$password');
  }

  Future getFileEnv() async {
    try {
      String fileName = "env.txt";
      String dir = (await getApplicationDocumentsDirectory()).path;
      String savePath = '$dir/$fileName';

      //for a directory: await Directory(savePath).exists();
      if (await File(savePath).exists()) {
        print("File exists");
      } else {
        print("File don't exists");
      }

      final path = await getApplicationDocumentsDirectory();
      final file_path = await path.path;
      File file = File('$file_path/env.txt');

      final content = file.readAsString();
      content.then((String value) {
        setState(() {
          var split = value.toString().split("|");
          user.text = split[0].toString();
          pass.text = split[1].toString();
        });
      });
    } catch (e) {}
  }

  Future login() async {
    var url = Uri.parse("https://erp.ritzcorpora.com/ritz/public/api/login");
    String ErrorMsg = "";
    ProgressDialog pr;
    pr = new ProgressDialog(context, showLogs: true);
    pr.style(message: 'Please wait...');
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    await pr.show();
    if (user.text == "") {
      await pr.hide();
      ErrorMsg = "username cannot be empty";
      return await CoolAlert.show(
          context: context, type: CoolAlertType.error, text: ErrorMsg);
    } else {
      if (pass.text == "") {
        await pr.hide();
        ErrorMsg = "password cannot be empty";
        return await CoolAlert.show(
            context: context, type: CoolAlertType.error, text: ErrorMsg);
      } else {
        try {
          final response = await http.post(url, body: {
            "username": user.text.replaceAll(" ", ""),
            "password": pass.text.replaceAll(" ", ""),
            "company": "1"
          });

          print(response);

          final datauser = jsonDecode(response.body);
          if (datauser.length < 3) {
            ErrorMsg = "Login Error";
          } else {
            if (datauser['success']) {
              writeText(user.text, pass.text);
              await pr.hide();
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => AppWeb(
                            username: user.text,
                            password: pass.text,
                            company: dropdownValue,
                          )));
            } else {
              await pr.hide();
              return await CoolAlert.show(
                  context: context,
                  type: CoolAlertType.error,
                  text: datauser['message']);
            }
          }
        } catch (e) {
          await pr.hide();
          return await CoolAlert.show(
              context: context, type: CoolAlertType.error, text: 'error');
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getFileEnv();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
//    var dropdownItems = ["RITZ"];

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: data.size.width - 30,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage('img/logo.png')),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 30)),
              TextField(
                controller: user,
                decoration: InputDecoration(
                  icon: Icon(
                    CupertinoIcons.person,
                    // color: Colors.black,
                  ),
                  hintText: "Username",
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
              ),
              TextField(
                controller: pass,
                obscureText: true,
                decoration: InputDecoration(
                    icon: Icon(
                      CupertinoIcons.lock_circle,
                    ),
                    hintText: "Password"),
              ),
//              Container(
//                child: DropdownButton(
//                  isExpanded: true,
//                  value: dropdownValue,
//                  onChanged: (value) {
//                    setState(() {
//                      dropdownValue = value.toString();
//                    });
//                  },
//                  items: dropdownItems.map((item) {
//                    return DropdownMenuItem(
//                      value: item,
//                      child: Text(item),
//                    );
//                  }).toList(),
//                ),
//              ),
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
              ),
              Container(
                width: data.size.width - 100,
                height: 50,
                margin: const EdgeInsets.only(top: 50.0),
                child: FlatButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  onPressed: () {
                    // _login();
                    login();
                  },
                  color: Colors.blue[600],
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Raleway',
                      fontSize: 22.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
