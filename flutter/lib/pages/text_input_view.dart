// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/models/card_view_model.dart';
// import '../models/scan_view_model.dart';

// class CardView extends StatelessWidget {
//   final CardViewModel viewModel;
//   const CardView({super.key, required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Enter Text")),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: ScanViewModel().textController,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: "Enter your text",
//               ),
//               maxLines: 5,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text("Save"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
