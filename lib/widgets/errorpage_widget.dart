import 'package:flutter/material.dart';
import 'package:rickandmorty/constants/styles_constants.dart';

/// Author: Carlos López-Jamar
/// Widget: ErrorPage (or No Internet page)
/// Version 3.3.4

class ErrorPage extends StatelessWidget {
  final String errorMessage;
  final IconData? iconPage;
  const ErrorPage({Key? key, required this.errorMessage, this.iconPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: StaticStyles.darkBackground,
      body: LayoutBuilder(
        builder: (context, viewportConstraints) {
          return ListView(
            children: [
              ConstrainedBox(
                constraints: viewportConstraints.copyWith(
                  minHeight: viewportConstraints.maxHeight,
                  maxHeight: double.infinity,
                ),
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(children: [
                      CircleAvatar(
                        backgroundColor: StaticStyles.primaryGreen,
                        radius: size.height / 12.0,
                        child: Icon(iconPage ?? Icons.error, size: size.width * 0.3, color: StaticStyles.darkBackground),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 24.0),
                          child: Align(
                              child: Text(
                                  errorMessage.isEmpty
                                      ? 'Error, no characters loaded. Click for request characters again here below.'
                                      : errorMessage,
                                  textAlign: TextAlign.center,
                                  style: StaticStyles.greyTitleStyle)))
                    ])
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
