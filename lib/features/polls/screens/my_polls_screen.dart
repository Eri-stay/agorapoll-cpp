import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/poll_model.dart';
import '../data/mock_polls.dart';
import '../widgets/poll_card.dart';

class MyPollsScreen extends StatefulWidget {
  const MyPollsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyPollsScreenState();
}

class _MyPollsScreenState extends State<MyPollsScreen> {
  List<Poll> _polls = [];

  void _showMockPolls() {
    setState(() {
      _polls = mockPolls;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hiddenWidth = MediaQuery.of(context).size.height * 0.4 * 0.132;
    // if (polls.isEmpty) ... else ...
    return _polls.isEmpty
        ? EmptyPollsWidget(onCreatePollTapped: _showMockPolls)
        : Padding(
            padding: EdgeInsets.only(
              left: hiddenWidth + 16,
              right: 16,
              top: 16.0,
              bottom: 16.0,
            ),
            child: ListView.builder(
              itemCount: _polls.length,
              itemBuilder: (context, index) {
                return PollCard(poll: _polls[index]);
              },
            ),
          );
  }
}

class EmptyPollsWidget extends StatelessWidget {
  final VoidCallback onCreatePollTapped;

  const EmptyPollsWidget({Key? key, required this.onCreatePollTapped})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hiddenWidth = MediaQuery.of(context).size.height * 0.4 * 0.132;
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          //padding: const EdgeInsets.symmetric(horizontal: 40.0),
          padding: EdgeInsets.only(
            left: hiddenWidth + 40,
            right: 40,
            bottom: 100,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Image.asset(
                'assets/images/meander_circle.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Agora is empty. Create your first poll to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                text: 'CREATE A POLL',
                onPressed: onCreatePollTapped,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
