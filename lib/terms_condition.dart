/// The `termsCondition` class is a Flutter widget that displays a dialog box containing the terms and
/// conditions of an application, loaded from a Markdown file.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// The `termsCondition` class is a dialog widget that displays terms and conditions content and has a
/// close button.
class termsCondition extends StatelessWidget {
  termsCondition({super.key});

  @override
  Widget build(BuildContext context) {
    /// The `Dialog` widget is creating a dialog box with rounded corners. It has a child
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder(
                future:
                    Future.delayed(Duration(microseconds: 150)).then((value) {
                  return rootBundle.loadString(
                      'assets/TERMS_AND_CONDITION/terms_conditions.md');
                }),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Markdown(
                      data: snapshot.data!,
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                }),
          ),
          /// The `TextButton` widget is creating a button with the label "CLOSE".
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                // Background color of the button
                padding: const EdgeInsets.all(10),
                // Padding around the button content
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                )),
                alignment: Alignment.center,
                height: 20,
                width: 200,
                child: Text("CLOSE"),
              )),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
