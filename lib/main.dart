import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:html/parser.dart' as parser;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final WebViewController _controller;
  late Response response;
  String text = '';
  String title = '';
  String header = '';
  String url = '';
  String platform = '';
  double _webViewHeight = 1.0;

  String _getPlatform() {
    if (Platform.isAndroid) {
      platform = 'ANDROID';
    }
    if (Platform.isIOS) {
      platform = 'IOS';
    }
    if (Platform.isWindows) {
      platform = 'WINDOWS';
    }
    if (Platform.isMacOS) {
      platform = 'MACOS';
    }
    if (kIsWeb) {
      platform = 'WEB';
    }
    return platform;
  }

  Future<void> _loadHtml() async {
    final response = await http.get(Uri.parse(url));
    var doc = parser.parse(response.body);

    setState(() {
      text = response.body;
      title = doc.querySelector('title')!.text.trim();
      header = response.headers['access-control-allow-origin'] ?? 'none';
    });
  }

  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) async {
            debugPrint('Page finished loading: $url');
            final Object result = await _controller.runJavaScriptReturningResult('document.scrollingElement.scrollHeight');
            setState(() {
              _webViewHeight = (result as num).toDouble();
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse('https://youtube.com'));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    String platform = _getPlatform();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                  ),
                  Text(
                    header,
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: _webViewHeight),
                    child: WebViewWidget(controller: _controller),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: Form(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          onSaved: (value) => setState(() {
                            if (value != null) {
                              url = value;
                              _loadHtml();
                            }
                          }),
                        ),
                      ),
                      Expanded(
                        child: Builder(
                          builder: (BuildContext context) {
                            return ElevatedButton(
                              child: const Text('LOAD'),
                              onPressed: () => Form.of(context).save(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Text('APPLICATION RUNNING ON:$platform'),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
