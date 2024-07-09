import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:ui' as ui;
import 'package:connectivity_plus/connectivity_plus.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Tab Drawer Navigation',
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            buttonTheme: const ButtonThemeData(
              buttonColor: Colors.blue,
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          darkTheme: ThemeData.dark(),
          locale: localeProvider.locale,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            AppLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', 'US'), // English, United States
            const Locale('fr', 'FR'), // French, France
          ],
          home: MyHomePage(),
        );
      },
    );
  }
}

class ConnectivityProvider with ChangeNotifier {
  bool _isConnected = true;
  late StreamSubscription<ConnectivityResult> _subscription;

  ConnectivityProvider() {
    _checkConnection();
    _subscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  bool get isConnected => _isConnected;

  void _checkConnection() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _isConnected = result != ConnectivityResult.none;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en', 'US'); // Default locale

  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();
    }
  }
}

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  final Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'title': 'Tab Drawer Navigation',
      'contacts': 'Contacts',
      'call': 'Call',
      'calculator': 'Calculator',
    },
    'fr': {
      'title': 'Navigation à onglets et tiroir',
      'contacts': 'Contacts',
      'call': 'Appeller',
      'calculator': 'Calculatrice',
    },
  };

  final Map<String, Map<String, String>> _pageTranslations = {
    'en': {
      'contacts_page_title': 'Contacts List',
      'call_page_title': 'Call History',
      'calculator_page_title': 'Calculator',
    },
    'fr': {
      'contacts_page_title': 'Liste des Contacts',
      'call_page_title': 'Écran d\'Appeller',
      'calculator_page_title': 'Calculatrice',
    },
  };

  String translate(String key) {
    return _localizedStrings[ui.window.locale.languageCode]![key] ?? key;
  }

  String translatePage(String pageKey) {
    return _pageTranslations[ui.window.locale.languageCode]![pageKey] ??
        pageKey;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations();
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  File? _image;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizedStrings = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final connectivityProvider = Provider.of<ConnectivityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          )
        ],
        title: Text(AppLocalizations.of(context).translate('Application')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
                icon: Icon(Icons.contact_page),
                text: AppLocalizations.of(context).translate('Contacts')),
            Tab(
                icon: Icon(Icons.call),
                text: AppLocalizations.of(context).translate('Call')),
            Tab(
                icon: Icon(Icons.calculate),
                text: AppLocalizations.of(context).translate('Calculator')),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('Hirwa Clement Rhodin'),
              accountEmail: Text('h1rhodin@gmail.com'),
              currentAccountPicture: GestureDetector(
                onTap: () => _showImageSourceActionSheet(context),
                child: CircleAvatar(
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : AssetImage('assets/profile.jpg') as ImageProvider,
                  child: ClipOval(
                    child: _image == null
                        ? Image.asset('assets/profile.jpg')
                        : Image.file(_image!, fit: BoxFit.cover),
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
              ),
            ),
            ListTile(
              leading: Icon(Icons.contact_page),
              title: Text(localizedStrings.translate('Contacts')),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.call),
              title: Text(localizedStrings.translate('Call')),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.calculate),
              title: Text(localizedStrings.translate('Calculator')),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(2);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.brightness_6),
              title: Text('Toggle Theme'),
              trailing: Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.translate),
              title: Text('English'),
              onTap: () {
                localeProvider.setLocale(const Locale('en', 'US'));
              },
            ),
            ListTile(
              leading: Icon(Icons.translate),
              title: Text('French'),
              onTap: () {
                localeProvider.setLocale(const Locale('fr', 'FR'));
              },
            ),
            ListTile(
              leading: Icon(Icons.wifi_off),
              title: Text(connectivityProvider.isConnected
                  ? 'Connected to the internet'
                  : 'No internet connection'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ContactsScreen(),
          CallScreen(),
          CalculatorScreen(),
        ],
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  void _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? themeIndex = prefs.getInt('themeMode');
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners();
    }
  }

  void toggleTheme(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isDarkMode) {
      _themeMode = ThemeMode.dark;
      prefs.setInt('themeMode', ThemeMode.dark.index);
    } else {
      _themeMode = ThemeMode.light;
      prefs.setInt('themeMode', ThemeMode.light.index);
    }
    notifyListeners();
  }
}

class Contact {
  final String name;
  final String phone;

  Contact({required this.name, required this.phone});
}

class ContactsScreen extends StatelessWidget {
  final List<Contact> contacts = [
    Contact(name: 'John Doe', phone: '+250 787 234 232'),
    Contact(name: 'Jane Smith', phone: '+250 787 634 642'),
    Contact(name: 'Alice Johnson', phone: '+250 787 044 042'),
    Contact(name: 'Bob Brown', phone: '+250 787 521 121'),
    Contact(name: 'John Peter', phone: '+250 787 065 014'),
    Contact(name: 'Kim Brown', phone: '+250 787 521 076'),
    Contact(name: 'Tom John', phone: '+250 787 903 390'),
    Contact(name: 'Bob Dee', phone: '+250 787 983 099'),
    Contact(name: 'One Cross', phone: '+250 787 092 293'),
    Contact(name: 'Bob Rice', phone: '+250 787 872 932'),
    Contact(name: 'Tim Owen', phone: '+250 787 728 822'),
    Contact(name: 'Pop Bruce', phone: '+250 787 323 012'),
    Contact(name: 'Din Prince', phone: '+250 787 473 851'),
  ];

  @override
  Widget build(BuildContext context) {
    final localizedStrings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          localizedStrings.translatePage('contacts_page_title'),
          style: const TextStyle(fontSize: 18, color: Colors.blue),
        ),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              child: Text(contacts[index].name[0]),
            ),
            title: Text(contacts[index].name),
            subtitle: Text(contacts[index].phone),
          );
        },
      ),
    );
  }
}

class CallScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizedStrings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          localizedStrings.translatePage('call_page_title'),
          style: const TextStyle(fontSize: 18, color: Colors.blue),
        ),
      ),
    );
  }
}

class CalculatorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizedStrings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          localizedStrings.translatePage('calculator_page_title'),
          style: const TextStyle(fontSize: 18, color: Colors.black),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Calculation(),
    );
  }
}

class Calculation extends StatefulWidget {
  @override
  _CalculationState createState() => _CalculationState();
}

class _CalculationState extends State<Calculation> {
  List<dynamic> inputList = [0];
  String output = '0';

  void _handleClear() {
    setState(() {
      inputList = [0];
      output = '0';
    });
  }

  void _handlePress(String input) {
    setState(() {
      if (input == 'C') {
        _handleClear();
      } else if (_isOperator(input)) {
        if (inputList.last is int) {
          inputList.add(input);
          output += input;
        }
      } else if (input == '=') {
        while (inputList.length > 2) {
          inputList = _calculate(inputList);
        }
        output = inputList[0].toString();
      } else {
        if (inputList.last is int) {
          int currentValue = inputList.removeLast();
          currentValue = currentValue * 10 + int.parse(input);
          inputList.add(currentValue);
          output += input;
        } else {
          inputList.add(int.parse(input));
          output += input;
        }
      }
    });
  }

  bool _isOperator(String input) {
    return input == '+' || input == '-' || input == '*' || input == '/';
  }

  List<dynamic> _calculate(List<dynamic> list) {
    int result = list[0];
    String operator = list[1];
    int operand = list[2];

    switch (operator) {
      case '+':
        result += operand;
        break;
      case '-':
        result -= operand;
        break;
      case '*':
        result *= operand;
        break;
      case '/':
        result ~/= operand;
        break;
    }
    list.removeRange(0, 3);
    list.insert(0, result);

    return list;
  }

  Widget _buildButton(String input) {
    return Expanded(
      child: Container(
        color: Colors.blue.shade100,
        margin: EdgeInsets.all(2),
        child: ElevatedButton(
          onPressed: () => _handlePress(input),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
          child: Text(
            input,
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.centerRight,
            color: Colors.blue.shade50,
            child: Text(
              output,
              style: TextStyle(fontSize: 48, color: Colors.blue),
            ),
          ),
        ),
        Row(
          children: [
            _buildButton('1'),
            _buildButton('2'),
            _buildButton('3'),
            _buildButton('+'),
          ],
        ),
        Row(
          children: [
            _buildButton('4'),
            _buildButton('5'),
            _buildButton('6'),
            _buildButton('-'),
          ],
        ),
        Row(
          children: [
            _buildButton('7'),
            _buildButton('8'),
            _buildButton('9'),
            _buildButton('*'),
          ],
        ),
        Row(
          children: [
            _buildButton('0'),
            _buildButton('='),
            _buildButton('C'),
            _buildButton('/'),
          ],
        ),
      ],
    );
  }
}
