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

/// Батьківський віджет, який надає BLoC дереву.
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
      // Ми не використовуємо DefaultTabController, бо керуємо ним вручну
      child: const _PollDetailsView(),
    );
  }
}

/// Основний Stateful віджет, що керує TabController та відображенням.
class _PollDetailsView extends StatefulWidget {
  const _PollDetailsView({Key? key}) : super(key: key);

  @override
  State<_PollDetailsView> createState() => _PollDetailsViewState();
}

class _PollDetailsViewState extends State<_PollDetailsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Ініціалізуємо TabController, вказуючи `vsync: this`
    _tabController = TabController(length: 2, vsync: this);
    // Додаємо слухача, щоб реагувати на зміну вкладок
    _tabController.addListener(_handleTabSelection);
  }

  /// Метод, що викликається при кожній зміні вкладки.
  void _handleTabSelection() {
    // Якщо вибрана друга вкладка (індекс 1 - "Results")
    if (_tabController.indexIsChanging && _tabController.index == 1) {
      final currentState = context.read<PollDetailBloc>().state;
      // Завантажуємо результати, тільки якщо BLoC у правильному стані
      // і якщо результати ще не були завантажені (`pollResult == null`).
      if (currentState is PollDetailLoaded && currentState.pollResult == null) {
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
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
        // Реакція на одноразові події

        if (state is PollDeleted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Poll was successfully deleted"),
              backgroundColor: AppColors.snackBarGrey,
            ),
          );
        }

        if (state is PollDetailError) {
          // Показуємо будь-яку іншу помилку
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        // Визначаємо змінні для AppBar на основі поточного стану
        String title = "LOADING...";
        String? code;

        if (state is PollDetailLoaded) {
          title = state.poll.code;
          code = state.poll.code;
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
              // Показуємо меню, тільки якщо дані завантажені
              if (state is PollDetailLoaded)
                PollActionMenu(
                  poll: state.poll,
                  isAuthor: state.isAuthor,
                  onDelete: () {
                    context.read<PollDetailBloc>().add(DeletePoll());
                  },
                  onClose: () {
                    context.read<PollDetailBloc>().add(TogglePollStatus());
                  },
                  onReport: () {
                    print("Reporting poll: ${state.poll.id}");
                  },
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.textPrimary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.accentGold,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: "My Vote"),
                    Tab(text: "Results"),
                  ],
                ),
              ),
            ),
          ),
          body: Builder(
            builder: (context) {
              // Логіка відображення тіла екрану
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
                  // Запобігаємо свайпу, щоб наш listener працював надійно
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    VotingTab(state: state),
                    ResultsTab(state: state),
                  ],
                );
              }

              // Повертаємо пустий контейнер для інших випадків
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}
