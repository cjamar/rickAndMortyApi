// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:rickandmorty/constants/styles_constants.dart';

// class CustomSearchBar extends StatefulWidget {
//   final Size size;
//   final String searchBarName;
//   final Function()? onPressed;
//   final Function()? filterListName;

//   const CustomSearchBar(
//       {super.key, required this.size, required this.searchBarName, this.onPressed, this.filterListName});

//   @override
//   State<CustomSearchBar> createState() => _CustomSearchBarState();
// }

// class _CustomSearchBarState extends State<CustomSearchBar> {
//   Widget textSearchBar = Text('', style: StaticStyles.mainTitleStyleGreen);
//   IconData iconSearchBar = Icons.search;
//   Timer? _debounce;

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return SizedBox(
//       width: size.width * 0.95,
//       height: size.height * 0.07,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           textSearchBar,
//           IconButton(
//               icon: Icon(
//                 iconSearchBar,
//                 color: StaticStyles.primaryGreen,
//                 size: 26,
//               ),
//               onPressed: () {
//                 setState(() {
//                   if (iconSearchBar == Icons.search) {
//                     iconSearchBar = Icons.close;
//                     textSearchBar = SizedBox(
//                       width: size.width * 0.7,
//                       child: TextField(
//                         onChanged: (value) {
//                           if (_debounce?.isActive ?? false) _debounce!.cancel();
//                           _debounce = Timer(const Duration(seconds: 1), () {
//                             setState(() {
//                               widget.filterListName;
//                             });
//                           });
//                         },
//                         autofocus: true,
//                         decoration: InputDecoration(
//                             hintText: 'Searching..',
//                             hintStyle: StaticStyles.searchBarHintStyle,
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 15),
//                             border: InputBorder.none),
//                         style: StaticStyles.searchBarLabelStyle,
//                         cursorColor: StaticStyles.primaryGreen,
//                       ),
//                     );
//                   } else {
//                     widget.filterListName;
//                     iconSearchBar = Icons.search;
//                     textSearchBar = Text(widget.searchBarName, style: StaticStyles.mainTitleStyleGreen);
//                   }
//                 });
//               })
//         ],
//       ),
//     );
//   }
// }
