// import 'package:flutter/material.dart';
// import '../../../core/theme/app_colors.dart';
//
// class CreatePollScreen extends StatelessWidget{
//   const CreatePollScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         centerTitle: true,
//         title: const Text(
//           'CREATE A POLL',
//           style: TextStyle(
//             fontFamily: 'Cinzel',
//             fontWeight: FontWeight.bold,
//             color: AppColors.textPrimary,
//             fontSize: 22,
//           )
//         ),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1.0),
//           child: Container(
//             color: Colors.grey[300],
//             height: 1.0,
//           ),
//         ),
//       ),
//       body: Column(
//
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CreatePollScreen extends StatelessWidget{
  const CreatePollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Poll',
          style: TextStyle(
            fontFamily: 'Cinzel',
          ),
        ),
      ),
      body: Column(
        children: [
          Text(
            'Hello',
            style: TextStyle(
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}