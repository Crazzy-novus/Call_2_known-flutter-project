import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:convert' as convert;

import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart'
    show Contact, FlutterContacts;
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart'
    show Fluttertoast, Toast, ToastGravity;

import 'package:call_2_known/NavBar.dart';

// List to store contacts Global variable
List<Contact> getContacts = [];
List<SerializedContact>? _contacts;

/// Manin function Start of the Program.
void main() {
  runApp(const MaterialApp(
    home: MyHomePage(),
  ));
}

/// Class to serialize a Contact

class SerializedContact {
  String? name;
  String? phones;

  SerializedContact({this.name, this.phones});

  /// Converts this object to a JSON string

  SerializedContact.fromJson(Map<String, dynamic> map)
      : name = map['name'],
        phones = map['phones'];
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phones': phones,
    };
  }
}

/// Function to serialize a List<Contact>

Future<List<SerializedContact>> serializeContacts(
    List<Contact> contacts) async {
  List<SerializedContact> serializedContacts = [];
  for (Contact contact in contacts) {
    SerializedContact serializedContact = SerializedContact(
      name: contact.displayName,
      phones: contact.phones[0].number.isNotEmpty
          ? contact.phones[0].number
          : "0000000000",
    );
    serializedContacts.add(serializedContact);
  }
  return serializedContacts;
}

/// Function to get location to store contact file in memory

Future<String> getExternalDocumentPath() async {
  // To check whether permission is given for this app or not.
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    // If not we will ask for permission first
    await Permission.storage.request();
  }
  final Directory directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

/// Function to fetch contacts from FlutterContacts if file is empty or does not exist

Future<void> fetchContacts() async {
  if (await FlutterContacts.requestPermission()) {
    getContacts = await FlutterContacts.getContacts(
      withProperties: true,
    );
    if (getContacts.isNotEmpty) {
      List<SerializedContact> contacts = await serializeContacts(getContacts);
      _contacts = contacts;
      Fluttertoast.showToast(
        msg: 'Contacts loaded successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
      saveToFile(contacts);
    } else {
      Fluttertoast.showToast(
        msg: 'Contacts not found',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
    }
  }
}

/// Function to save contacts to file

Future<void> saveToFile(List<SerializedContact> contacts) async {
  try {
    Directory? directory = await getDownloadsDirectory();
    String filePath = '${directory?.path}/Contact.json';

    File file = File(filePath);

    final jsonString = jsonEncode(contacts);
    await file.writeAsString(jsonString);

    // Show toast message upon successful file creation
  } catch (e) {
    // Handle or rethrow the error as needed
    Fluttertoast.showToast(
      msg: 'error Contacts not stored in memory',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }
}

/// Class to Home Page
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String _name = '0000';
  late String _phoneNumber = '0000';
  late String _count = '0000';
  late String _incoming = '0000';
  late String _outgoing = '0000';
  late String _duration = '0000';
  late Timer _timer;

  Iterable<CallLogEntry>? _callLogEntries;

  /// Function to get Contact details From Previously saved file else from Phone Contact

  void getPhoneData() async {
    try {
      Directory? directory = await getDownloadsDirectory();
      String filePath = '${directory?.path}/Contact.json';
      File file = File(filePath);

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final list = convert.jsonDecode(jsonString) as List;
        setState(() {
          _contacts = list
              .map((contactJson) => SerializedContact.fromJson(contactJson))
              .toList();
        });

        if (_contacts!.isNotEmpty) {
          // File is not empty, try to parse contacts from the file

          Fluttertoast.showToast(
            msg: 'Contacts loaded Successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black87,
            textColor: Colors.white,
          );
        } else {
          // File is empty, fall back to getting contacts from FlutterContacts
          await fetchContacts();
        }
      } else {
        // File does not exist, fetch contacts using FlutterContacts
        await fetchContacts();
      }
    } catch (e) {
      // Handle or log the error as needed
      Fluttertoast.showToast(
        msg: 'Error in getting data from file',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
    }
  }

  /// Function to generate random number to get random contact to call

  int getRandomContact() {
    var random = Random();
    int totalContact = _contacts!.length;
    return random.nextInt(totalContact);
  }

  /// Function to get CallLog from Phone Contacts

  void getCallLog() async {
    _callLogEntries = await CallLog.get();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPhoneData();
    getCallLog();

    // Default values
    _name = 'System';
    _phoneNumber = '0011223344';

    // Start a timer to update the data every 10 seconds
    _timer = Timer.periodic(Duration(seconds: 6), (timer) {
      setState(() {
        // Simulated dynamic update
        var n = getRandomContact();
        _name = _contacts![n].name!;
        _phoneNumber = _contacts![n].phones!;
        // get the total duration of  call for a particular contact
        _duration = _callLogEntries!
            .where((element) => element.name == _name)
            .fold(0, (sum, element) => sum + element.duration!)
            .toString();
        _count = _callLogEntries!
            .where((element) => element.name == _name)
            .length
            .toString();
        _incoming = _callLogEntries!
            .where((element) =>
                element.name == _name && element.callType == CallType.incoming)
            .length
            .toString();
        _outgoing = _callLogEntries!
            .where((element) =>
                element.name == _name && element.callType == CallType.outgoing)
            .length
            .toString();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Function to make a phone call

  void _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: const Text(
          "Call~Mingle",
          style: TextStyle(
            color: Colors.blue,
            fontSize: 30,
            fontFamily: 'Roboto',
            wordSpacing: 2.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Card(
              color: Colors.blue.shade200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Container(
                      alignment: Alignment.center,
                      width: 60,
                      height: 48,
                      child: Icon(Icons.account_circle,
                          size: 60, color: Colors.deepPurple.shade400),
                    ),
                    title: Container(
                      alignment: Alignment.bottomLeft,
                      width: 0,
                      height: 30,
                      child: Text(_name,
                          style: const TextStyle(
                              color: Colors.lime,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                    subtitle: Text(_phoneNumber,
                        style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {},
                        child: const Text('Make Call'),
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
                height: 280,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      children: [
                        Positioned(
                            top: 0,
                            left: 0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const SizedBox(width: 80),
                                TextButton(
                                    child: Text(_incoming,
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () {}),
                                Text('Incoming',
                                    style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                              ],
                            )),
                        Positioned(
                            top: 0,
                            right: 0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                    child: Text(_duration,
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () {}),
                                Text('Total Time ',
                                    style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                              ],
                            )),
                        Positioned(
                            bottom: 0,
                            left: 0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                    child: Text(_outgoing,
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () {}),
                                Text('OutGoing',
                                    style: const TextStyle(
                                        color: Colors.amberAccent,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                              ],
                            )),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                    child: Text(_count,
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () {}),
                                Text('Total Calls',
                                    style: const TextStyle(
                                        color: Colors.teal,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                              ],
                            )),
                        Positioned(
                          // top: MediaQuery.of(context).size.height / 2,
                          //left: MediaQuery.of(context).size.width / 2,
                          child: Center(
                              child: Column(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(height: 100),
                              TextButton(
                                  child: Text('HAVE A TIME',
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold)),
                                  onPressed: () {}),
                              Text('TRY TO TALK',
                                  style: const TextStyle(
                                      color: Colors.purple,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 50),
            Center(
                child: Row(
              children: [
                const SizedBox(width: 25.0),
                TextButton(
                  onPressed: () {
                    int index = getRandomContact();
                    _makePhoneCall(_contacts![index].phones!);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    // Background color of the button
                    padding: const EdgeInsets.all(16),
                    // Padding around the button content
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    "Pick Contact",
                    style: TextStyle(
                      color: Colors.yellow, // Text color of the button
                      fontSize: 18, // Font size of the text
                    ),
                  ),
                ),
                const SizedBox(width: 50.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditContactScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    // Background color of the button
                    padding: const EdgeInsets.all(16),
                    // Padding around the button content
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    "Edit Contact",
                    style: TextStyle(
                      color: Colors.greenAccent, // Text color of the button
                      fontSize: 18, // Font size of the text
                    ),
                  ),
                ),
              ],
            )),
            const SizedBox(height: 75),
            TextButton(
              onPressed: () {
                fetchContacts();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                // Background color of the button
                padding: const EdgeInsets.all(16),
                // Padding around the button content
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
              ),
              child: const Text(
                "Reset Contacts",
                style: TextStyle(
                  color: Colors.blue, // Text color of the button
                  fontSize: 18, // Font size of the text
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}

/// Class to list all contacts details in list and make changes in list
class EditContactScreen extends StatefulWidget {
  const EditContactScreen({super.key});

  @override
  State<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  void removeItem(int index) {
    setState(() {
      _contacts!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Edit List",
            style: TextStyle(color: Colors.blue),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save), // Icon you want to use
              onPressed: () {
                saveToFile(_contacts!);
              },
            ),
            const SizedBox(width: 25.0),
          ],
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: (_contacts == null)
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.8, // Set a specific height

                child: Column(children: [
                  Expanded(
                      child: ListView.builder(
                          itemCount: _contacts!.length,
                          itemBuilder: (BuildContext, int index) {
                            String number =
                                (_contacts![index].phones!.isNotEmpty)
                                    ? _contacts![index].phones!
                                    : "";
                            String name = (_contacts![index].name!.isNotEmpty)
                                ? _contacts![index].name!
                                : "";
                            return ListTile(
                              title: Text(name),
                              subtitle: Text(number),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => removeItem(index),
                              ),
                            );
                          }))
                ])));
  }
}
