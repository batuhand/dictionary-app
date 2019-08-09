import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  static String tag = 'home-page';

  @override
  Widget build(BuildContext context) {
     return MaterialApp(
      home: VoiceHome(),
    );
  }
}



class VoiceHome extends StatefulWidget {
  @override
  _VoiceHomeState createState() => _VoiceHomeState();
}

class _VoiceHomeState extends State<VoiceHome> {
  SpeechRecognition _speechRecognition;
  FlutterTts flutterTts = new FlutterTts();
  bool _isAvailable = false;
  bool _isListening = false;

  String resultText = "";

  String translatedText ="";
 



  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
      (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
      (String speech) => setState(() => resultText = speech),
    );

    _speechRecognition.setRecognitionCompleteHandler(
      () => setState(() => _isListening = false),
    );

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
        );
  }

  @override
  Widget build(BuildContext context) {
    authorize();
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: "btn1",
                  child: Icon(Icons.cancel),
                  mini: true,
                  backgroundColor: Colors.deepOrange,
                  onPressed: () {
                    if (_isListening)
                      _speechRecognition.cancel().then(
                            (result) => setState(() {
                                  _isListening = result;
                                  resultText = "";
                                }),
                          );
                          setState(() {
                            resultText = "";
                            translatedText = "";
                          });
                  },
                ),
                FloatingActionButton(
                  heroTag: "btn2",
                  child: Icon(Icons.mic),
                  onPressed: () {
                    if (_isAvailable && !_isListening)
                      _speechRecognition
                          .listen(locale: "en_US")
                          .then((result) => print('$result'));
                  },
                  backgroundColor: Colors.pink,
                ),
                FloatingActionButton(
                  heroTag: "btn3",
                  child: Icon(Icons.stop),
                  mini: true,
                  backgroundColor: Colors.deepPurple,
                  onPressed: () {
                    if (_isListening)
                      _speechRecognition.stop().then(
                            (result) => setState(() => _isListening = result),
                          );
                  },
                ),
                FloatingActionButton(
                  heroTag: "btn4",
                  child: Icon(Icons.arrow_downward),
                  backgroundColor: Colors.green,
                  onPressed: (){
                    List words = parseString(resultText);
                    translate(words);
                  },
                )
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.cyanAccent[100],
                borderRadius: BorderRadius.circular(6.0),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              ),
              child: Text(
                resultText = "aç google.com",
                style: TextStyle(fontSize: 24.0),
              ),
            ),
            Container(child: Text(
              '$translatedText',
              style: TextStyle(fontSize: 24.0),
            ),
            )
          ],
        ),
      ),
    );
  }


  parseString(String text){

    List words = text.split(" ");
    return words;

  }
    String token;

  translate(List words) async{
    List control = resultText.split(" ");
    if(control[0] == "aç"){
      String url = "http://" + control[1];
      launch(url);
      return 0;
    }

    print(token);
    String sendToken = "Bearer " + token;
    print(sendToken);
    for(int i = 0; i<words.length;i++){
      
      String url = "https://dictionaryapp.azurewebsites.net/api/word/";
      url = url + words[i];
      var response = await http.get(
        Uri.encodeFull(url),
        headers: {
          "Accept": "application/json",
          "Authorization" : sendToken,
        }
      );
      List result = json.decode(response.body);
      setState(() {
        translatedText = translatedText + result[0]["wordEn"] + " " ;
      });
      //flutterTts.speak(result[0]["wordEn"]);
    }
    flutterTts.speak(translatedText);
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