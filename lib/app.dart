import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AppWeb extends StatefulWidget {
  String? username, password, company;
  AppWeb({Key? key, this.username, this.password, this.company})
      : super(key: key);

  @override
  State<AppWeb> createState() => _AppWebState();
}

class _AppWebState extends State<AppWeb> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  var willPop = false;

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
      child: SafeArea(
        child: WillPopScope(
          child: Scaffold(
            body: Container(
              child: InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: Uri.parse(url)),
                initialOptions: options,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStop: (controller, url) {
                  var _uri = url.toString().split("?");
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
                      source:
                          'if(\$(".meeting-span")[0]){\$(".meeting-span").click(function(e){e.preventDefault(); Zoom.postMessage(\$(this).text())})}');
                },
                androidOnPermissionRequest:
                    (controller, origin, resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },
              ),
            ),
          ),
          onWillPop: () async => willPop,
        ),
      ),
    );
  }
}
