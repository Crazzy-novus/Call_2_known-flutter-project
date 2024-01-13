import 'package:animations/animations.dart';
import 'package:call_2_known/terms_condition.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Class to create the Navigation Bar and other list of items in navigation bar
class NavBar extends StatelessWidget {
  const NavBar({super.key});

  /// Function to Open Mail App From Current flutter app
  _sendEmail() async {
    final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'duraivignesh222@gmail.com',
      queryParameters: {},
    );
    try {
      await launchUrl(Uri.parse(_emailLaunchUri.toString()));
    } catch (e) {
      print('Error launching email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Call~Mingle'),
            accountEmail: Text('Get Connect to Connect'),
          ),
          ListTile(
            leading: Icon(Icons.alternate_email),
            title: Text('Contact Us'),
            onTap: () {
              _sendEmail();
            },
          ),
          ListTile(
            leading: Icon(Icons.report),
            title: Text('Report us'),
            onTap: () {
              _sendEmail();
            },
          ),
          ListTile(
            leading: Icon(Icons.document_scanner),
            title: Text('Terms & Conditions'),
            onTap: () {
              showModal(
                context: context,
                builder: (context) {
                  return termsCondition();
                },
              );
            },
          ),
          Ink(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                const url = 'https://www.linkedin.com/in/duraivignesh-c/';
                if (await launchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/linkedin.png'),
                ),
                title: Text('Linked In'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
