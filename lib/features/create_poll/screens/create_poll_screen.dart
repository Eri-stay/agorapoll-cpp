import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/create_poll_bloc.dart';
import '../bloc/create_poll_event.dart';
import '../bloc/create_poll_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/settings_switch.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/repository/auth_repository.dart';
import 'poll_created_screen.dart';
import '../../shared/repositories/polls_repository.dart';

class CreatePollScreen extends StatelessWidget {
  const CreatePollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreatePollBloc(
        authRepository: AuthRepository(),
        pollsRepository: PollsRepository(),
      ),
      child: const _CreatePollView(),
    );
  }
}

class _CreatePollView extends StatefulWidget {
  const _CreatePollView({Key? key}) : super(key: key);

  @override
  State<_CreatePollView> createState() => _CreatePollViewState();
}

class _CreatePollViewState extends State<_CreatePollView> {
  final _questionController = TextEditingController();

  // List of answer option controllers
  final List<GlobalKey<_OptionItemState>> _optionKeys = [];

  // Settings (Toggle Switches)
  bool _isAnonymous = false;
  bool _allowMultiple = false;
  bool _allowChangeVote = true;

  @override
  void initState() {
    super.initState();
    // Add 2 empty options at the start
    _addOption();
    _addOption();
  }

  void _addOption() {
    setState(() {
      _optionKeys.add(GlobalKey<_OptionItemState>());
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _removeOption(int index) {
    if (_optionKeys.length > 2) {
      setState(() {
        _optionKeys.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A poll must have at least 2 options"),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _createPoll() {
    final question = _questionController.text.trim();

    final options = _optionKeys
        .map((key) => key.currentState?.text ?? "") // Get text from each option
        .where((text) => text.trim().isNotEmpty)
        .toList();

    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a question!"),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter at least 2 options!"),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    context.read<CreatePollBloc>().add(
      CreatePollSubmitted(
        question: question,
        options: options,
        isAnonymous: _isAnonymous,
        allowMultiple: _allowMultiple,
        isChangeable: _allowChangeVote,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreatePollBloc, CreatePollState>(
      listener: (context, state) {
        if (state is CreatePollSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PollCreatedScreen(
                pollId: state.pollId,
                pollCode: state.pollCode,
              ),
            ),
          );
        }
        if (state is CreatePollError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'CREATE POLL',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 20,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: Colors.grey[300], height: 1.0),
          ),
        ),
        body: BlocBuilder<CreatePollBloc, CreatePollState>(
          builder: (context, state) {
            final isLoading = state is CreatePollLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Question Input ---
                  const Text(
                    "Question",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _questionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Type your question here...",
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    style: const TextStyle(fontSize: 18, fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 32),

                  // --- Answer Options ---
                  const Text(
                    "ANSWER OPTIONS",
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...List.generate(_optionKeys.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            // Widget for each option
                            child: _OptionItem(
                              key: _optionKeys[index],
                              index: index,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => _removeOption(index),
                          ),
                        ],
                      ),
                    );
                  }),

                  InkWell(
                    onTap: _addOption,
                    // Додаємо сплеш-ефект при натисканні
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      // Відступи, щоб кнопка була візуально вирівняна
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: const [
                          Icon(Icons.add, color: AppColors.textPrimary),
                          SizedBox(width: 8),
                          Text(
                            "Add option",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- Settings Toggles ---
                  SettingsSwitch(
                    title: "Anonymous",
                    subtitle: "Hide voter identities",
                    value: _isAnonymous,
                    onChanged: (val) => setState(() => _isAnonymous = val),
                  ),
                  SettingsSwitch(
                    title: "Multiple answers",
                    subtitle: "Allow users to select multiple options",
                    value: _allowMultiple,
                    onChanged: (val) => setState(() => _allowMultiple = val),
                  ),
                  SettingsSwitch(
                    title: "Allow to change vote",
                    subtitle: "Users can modify their response",
                    value: _allowChangeVote,
                    onChanged: (val) => setState(() => _allowChangeVote = val),
                  ),

                  const SizedBox(height: 40),

                  // --- Submit Button ---
                  PrimaryButton(
                    text: isLoading ? 'CREATING...' : 'CREATE',
                    // If loading, disable button
                    onPressed: isLoading ? () {} : _createPoll,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// -- Widget for each answer option --
class _OptionItem extends StatefulWidget {
  final int index;

  const _OptionItem({Key? key, required this.index}) : super(key: key);

  @override
  State<_OptionItem> createState() => _OptionItemState();
}

class _OptionItemState extends State<_OptionItem> {
  late TextEditingController controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  // Getter to access the text
  String get text => controller.text;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();

    // Listen to focus changes
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: "Option ${widget.index + 1}",
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        // If focused - gray, if not - transparent
        fillColor: _isFocused ? AppColors.textFieldFill : Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
