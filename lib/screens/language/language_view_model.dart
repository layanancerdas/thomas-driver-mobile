import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tomas_driver/main.dart';
import 'package:tomas_driver/screens/home/home.dart';
import './language.dart';

abstract class LanguageViewModel extends State<Language> {
  int selectedLanguage = 0;

  List languages = [
    {'name': "English", 'code': 'en'},
    {'name': "Bahasa Indonesia", 'code': 'id'},
  ];

  void toggleSelectedLanguage(int value) {
    setState(() {
      selectedLanguage = value;
    });
  }

  Future<void> onSave() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('language', languages[selectedLanguage]['code']);
    // store.dispatch(SetSelectedLanguage(
    //     selectedLanguage: languages[selectedLanguage]));
    // Navigator.pop(context);
    MainApp.of(context).onLocaleChange(
        Locale.fromSubtags(languageCode: languages[selectedLanguage]['code']));
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => Home(index: 3)), (route) => false);
  }

  Future<void> initLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String language = prefs.getString('language') ?? 'en';
    print(language);
    languages.asMap().forEach((index, element) {
      if (element['code'] == language) {
        setState(() {
          selectedLanguage = index;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initLanguage();
  }
}
