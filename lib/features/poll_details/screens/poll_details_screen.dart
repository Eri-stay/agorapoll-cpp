import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/repository/auth_repository.dart';
import '../../shared/repositories/polls_repository.dart';
import '../bloc/poll_detail_bloc.dart';
import '../bloc/poll_detail_event.dart';
import '../bloc/poll_detail_state.dart';
import 'voting_tab.dart';
import 'results_tab.dart';
import '../../shared/widgets/poll_action_menu.dart';

class PollDetailsScreen extends StatelessWidget {
  final String pollId;

  const PollDetailsScreen({Key? key, required this.pollId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PollDetailBloc(
        pollsRepository: PollsRepository(),
        authRepository: AuthRepository(),
      )..add(LoadPollDetails(pollId)),
      child: DefaultTabController(length: 2, child: const _PollDetailsView()),
    );
  }
}

class _PollDetailsView extends StatefulWidget {
  const _PollDetailsView({Key? key}) : super(key: key);

  @override
  State<_PollDetailsView> createState() => _PollDetailsViewState();
}

class _PollDetailsViewState extends State<_PollDetailsView>
    with SingleTickerProviderStateMixin {
  // <--- Додай Ticker
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    // Якщо вибрана друга вкладка (Results)
    if (_tabController.index == 1) {
      // Перевіряємо, чи BLoC у правильному стані, щоб уникнути помилок
      final currentState = context.read<PollDetailBloc>().state;
      if (currentState is PollDetailLoaded && currentState.pollResult == null) {
        // Завантажуємо результати, тільки якщо вони ще не завантажені
        context.read<PollDetailBloc>().add(LoadPollResults());
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Poll code copied!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.snackBarGrey,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PollDetailBloc, PollDetailState>(
      listener: (context, state) {
        if (state is PollDetailLoaded &&
            state.hasVoted &&
            !state.isSubmitting) {
          // to do Перевірка, щоб не показувати це при кожному ребілді (можна покращити через Action State)
        }
      },
      builder: (context, state) {
        String title = "LOADING...";
        String? code;
        bool isAuthor = false;

        if (state is PollDetailLoaded) {
          title = state.poll.code;
          code = state.poll.code;
          isAuthor = state.isAuthor;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cinzel',
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: 24,
                letterSpacing: 1.5,
              ),
            ),
            actions: [
              if (code != null)
                IconButton(
                  icon: const Icon(Icons.copy, color: AppColors.textSecondary),
                  onPressed: () => _copyCode(context, code!),
                ),
              if (state is PollDetailLoaded)
                PollActionMenu(
                  poll: state.poll,
                  isAuthor: state.isAuthor, // Get from BLoC
                  onDelete: () {
                    // TO DO: Додати подію в PollDetailBloc для видалення
                    print("Deleting poll from details: ${state.poll.id}");
                  },
                  onClose: () {
                    // TO DO: Додати подію в PollDetailBloc для закриття
                    print("Closing poll from details: ${state.poll.id}");
                  },
                  onReport: () {
                    // TO DO: Додати подію в PollDetailBloc для скарги
                    print("Reporting poll: ${state.poll.id}");
                  },
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                color: Colors.grey[200], // Сіра смужка під табами
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.textPrimary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.accentGold,
                  indicatorWeight: 3,
                  labelStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: [
                    Tab(text: "My Vote"),
                    Tab(text: "Results"),
                  ],
                ),
              ),
            ),
          ),
          body: Builder(
            builder: (context) {
              if (state is PollDetailLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accentGold),
                );
              }
              if (state is PollDetailError) {
                return Center(child: Text(state.message));
              }
              if (state is PollDetailLoaded) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    VotingTab(state: state), // Вкладка голосування
                    ResultsTab(state: state),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}
