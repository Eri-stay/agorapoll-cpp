import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../widgets/poll_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/my_polls_bloc.dart';
import '../bloc/my_polls_event.dart';
import '../bloc/my_polls_state.dart';
import '../../auth/repository/auth_repository.dart';
import '../../shared/repositories/polls_repository.dart';
import '../../create_poll/screens/create_poll_screen.dart';

class MyPollsScreen extends StatelessWidget {
  const MyPollsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyPollsBloc(
        pollsRepository: PollsRepository(),
        authRepository: AuthRepository(),
      )..add(LoadMyPolls()),
      child: BlocBuilder<MyPollsBloc, MyPollsState>(
        builder: (context, state) {
          // --- State 1: LOADING ---
          if (state is MyPollsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentGold),
            );
          }

          // --- State 2: ERROR ---
          if (state is MyPollsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 36,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 200,
                      child: PrimaryButton(
                        text: "TRY AGAIN",
                        onPressed: () {
                          // Reload
                          context.read<MyPollsBloc>().add(LoadMyPolls());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // --- State 3: DATA LOADED ---
          if (state is MyPollsLoaded) {
            final hiddenWidth =
                MediaQuery.of(context).size.height * 0.4 * 0.132;

            if (state.polls.isEmpty) {
              return EmptyPollsWidget(
                onCreatePollTapped: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePollScreen(),
                    ),
                  );
                },
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                left: hiddenWidth + 16,
                right: 16,
                top: 0,
                bottom: 0,
              ),
              child: RefreshIndicator(
                color: AppColors.accentGold,
                onRefresh: () async {
                  final bloc = context.read<MyPollsBloc>();
                  bloc.add(LoadMyPolls());
                  await Future.value();
                },
                child: ListView.builder(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // To allow scrolling even if there are few items (for RefreshIndicator)
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: state.polls.length,
                  itemBuilder: (context, index) {
                    return PollCard(poll: state.polls[index]);
                  },
                ),
              ),
            );
          }

          // Initial state
          return const SizedBox.shrink();
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
