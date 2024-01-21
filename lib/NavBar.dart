import 'package:animations/animations.dart';
import 'package:call_2_known/terms_condition.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Class to create the Navigation Bar and other list of items in navigation bar
/// The `NavBar` class is a Flutter widget that represents a navigation drawer with various options such
/// as contacting the app, reporting issues, viewing terms and conditions, and accessing the developer's
/// LinkedIn profile.
class NavBar extends StatelessWidget {
  const NavBar({super.key});

  /// Function to Open Mail App From Current flutter app
  /// The function `_sendEmail()` launches the default email client with a pre-filled email address.
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
        ],
      ),
    );
  }
}
