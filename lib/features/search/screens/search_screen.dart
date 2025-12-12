import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/formatters/uppercase_text_formatter.dart';
import '../../shared/repositories/polls_repository.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../../poll_details/screens/poll_details_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(pollsRepository: PollsRepository()),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView({Key? key}) : super(key: key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final TextEditingController _pinController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _pinController.addListener(() {
      final isEnabled = _pinController.text.length == 6;
      if (isEnabled != _isButtonEnabled) {
        setState(() {
          _isButtonEnabled = isEnabled;
        });
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    if (_isButtonEnabled) {
      context.read<SearchBloc>().add(SearchSubmitted(_pinController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Стилі для пін-коду, щоб відповідати дизайну
    final defaultPinTheme = PinTheme(
      width: 25,
      height: 40,
      textStyle: const TextStyle(
        fontFamily: 'Cinzel',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 2.0, color: Colors.grey[300]!),
        ),
      ),
    );

    return BlocListener<SearchBloc, SearchState>(
      listener: (context, state) {
        if (state is SearchSuccess) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PollDetailsScreen(pollId: state.pollId),
            ),
          );
        }
        if (state is SearchError) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 60.0,
              right: 40.0,
              bottom: 100,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'ENTER CODE',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 36,
                    letterSpacing: 1.2,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'to join the poll',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),

                // Віджет для вводу коду
                Pinput(
                  controller: _pinController,
                  length: 6,
                  keyboardType: TextInputType.text,
                  animationDuration: Duration.zero,

                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                    UpperCaseTextFormatter(),
                  ],

                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: const Border(
                        bottom: BorderSide(
                          width: 2.0,
                          color: AppColors.accentGold,
                        ),
                      ),
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme,
                  separatorBuilder: (index) => const SizedBox(width: 6),
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                ),

                const SizedBox(height: 48),

                BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    final isLoading = state is SearchLoading;
                    return PrimaryButton(
                      text: isLoading ? 'SEARCHING...' : 'ENTER',
                      onPressed: _isButtonEnabled && !isLoading
                          ? _submitSearch
                          : () {},
                      color: _isButtonEnabled && !isLoading
                          ? AppColors.accentGold
                          : Colors.grey[400],
                    );
                  },
                ),

                const SizedBox(height: 16),
                const Text(
                  'Enter the 6-character code shared by the poll creator',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
