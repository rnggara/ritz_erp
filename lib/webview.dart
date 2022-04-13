import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class Web_View extends StatefulWidget {
  String? username, password, company;
  Web_View({Key? key, this.username, this.password, this.company})
      : super(key: key);

  @override
  _Web_ViewState createState() => _Web_ViewState();
}

class _Web_ViewState extends State<Web_View> {
  late WebViewController controller;
  var willPop = false;
  @override
  void initState() {
    super.initState();
  }

  Future<void> requestCameraPermission() async {
    final serviceStatus = await Permission.camera.isGranted;

    bool isCameraOn = serviceStatus == ServiceStatus.enabled;

    final status = await Permission.camera.request();

    if (status == PermissionStatus.granted) {
      print('Permission Granted');
    } else if (status == PermissionStatus.denied) {
      print('Permission denied');
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('Permission Permanently Denied');
      await openAppSettings();
    }
  }

  void _toBrowser(_uri) async {
    if (await launch(_uri)) {
      await launch(_uri);
    } else {
      throw 'Could not launch $_uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encode = stringToBase64
        .encode(widget.username.toString() + "~" + widget.password.toString());

    var _uri = "";
    var company = widget.company;
    _uri = "https://erp.ritzcorpora.com/ritz/public/";

    String url = "$_uri?m=$encode";

    return new Container(
        color: Colors.white,
        child: SafeArea(
            child: WillPopScope(
                child: Scaffold(
                    body: Container(
                  child: WebView(
                    initialUrl: url,
                    javascriptMode: JavascriptMode.unrestricted,
                    javascriptChannels: Set.from([
                      JavascriptChannel(
                          name: "Zoom",
                          onMessageReceived: (JavascriptMessage message) {
                            print(message.message);
                            _toBrowser(message.message);
                          })
                    ]),
                    onWebViewCreated: (controller) {
                      this.controller = controller;
                      // controller.evaluateJavascript("alert('hello)");
                    },
                    onPageFinished: (String url) async {
                      requestCameraPermission();
                      var _uri = url.split("?");
                      var _isLogin =
                          _uri[0].substring(0, _uri[0].length - 1).split("/");
                      var _last_uri = _isLogin[_isLogin.length - 1];
                      var _project_uri = _isLogin[_isLogin.length - 2];
                      var _req = _uri[_uri.length - 1].toString().split("&");
                      if (_last_uri == "public" &&
                          _project_uri == "ritz" &&
                          _req[_req.length - 1].substring(0, 1) != "m") {
                        Navigator.of(context).pop();
                        setState(() {
                          willPop = true;
                        });
                      }
                      controller.evaluateJavascript(
                          'if(\$(".meeting-span")[0]){\$(".meeting-span").click(function(e){e.preventDefault(); Zoom.postMessage(\$(this).text())})}');
                    },
                  ),
                )),
                onWillPop: () async => willPop)));
  }
}
