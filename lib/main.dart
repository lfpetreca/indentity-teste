import 'package:flutter/material.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TokenResponse? tokenResponse;

  void _auth() async {
    //ipconfig ip  192.168.15.4
    //IS url  'http://192.168.15.4:5000';
    Uri redirectUri = Uri(
      scheme: 'http',
      host: '192.168.15.4',
      port: 4000,
    );
    Uri authorizationUrl = Uri(
      scheme: 'http',
      host: '192.168.15.4',
      port: 5000,
    );
    print("IDENTITY_URL => $authorizationUrl");
    Issuer issuer = await Issuer.discover(authorizationUrl);
    // create the client
    Client client = Client(
      issuer,
      'api_app',
    );

    print("CLIENT => $client");
    // create a function to open a browser with an url
    Future<void> urlLauncher(String url) async {
      url = url.replaceAll('+', '%20');
      //print("BEFORE => $url");
      //Uri encodedUrl = Uri.parse(url);
      print("AFTER ENCODED_URL => $url");
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        var canLaunchUrlTeste = await canLaunchUrlString(url);
        print("URL => $url");
        print("CAN $canLaunchUrlTeste");
        throw Exception('Unable to lauch authorization Url $url');
      }
    }

    // create an authenticator
    Authenticator authenticator = Authenticator(
      client,
      scopes: <String>[
        'api_app',
        'api_admin',
        'api_chat',
      ],
      port: 4000,
      redirectUri: redirectUri,
      urlLancher: urlLauncher,
    );

    // starts the authentication
    Credential credential = await authenticator.authorize();
    tokenResponse = await credential.getTokenResponse();

    // close the webview when finished
    print(credential.getUserInfo());
    Future<UserInfo> userInfo =
        credential.getUserInfo(); // TODO: REMOVE THIS LINE

    print("USER_INFO => $userInfo");
    closeInAppWebView();
  }

  void _callApi() async {
    var accessToken = tokenResponse?['accessToken'];
    //http://admin.api.lotus.com.br/juridico/notificacao

    Uri urlTeste = Uri(
      scheme: 'http',
      host: 'localhost',
      port: 5002,
    );
    var url = Uri.http(
      urlTeste.toString(),
      'juridico/notificacao',
    );
    //var testUrlApi = 'http://localhost:5002/juridico/notificacao';
    Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
    };
    var response = await http.get(
      url,
      headers: headers,
    );
    var body = response.body; // TODO: REMOVE THIS LINE
    //just to check response
    final a = "" + body;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Teste LOGIN:',
            ),
            Text(
              '$tokenResponse',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: _auth,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: _callApi,
            tooltip: 'CALL',
            child: const Icon(Icons.account_box),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
