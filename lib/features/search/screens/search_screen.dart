import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/formatters/uppercase_text_formatter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // Слухаємо зміни в контролері, щоб вмикати/вимикати кнопку
    _pinController.addListener(() {
      if (_pinController.text.length == 6) {
        if (!_isButtonEnabled) setState(() => _isButtonEnabled = true);
      } else {
        if (_isButtonEnabled) setState(() => _isButtonEnabled = false);
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
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

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 60.0, right: 40.0, bottom: 100),
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
                      bottom: BorderSide(width: 2.0, color: AppColors.accentGold),
                    ),
                  ),
                ),
                submittedPinTheme: defaultPinTheme,
                separatorBuilder: (index) => const SizedBox(width: 6),
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
              ),

              const SizedBox(height: 48),

              // Кнопка, стан якої залежить від _isButtonEnabled
              PrimaryButton(
                text: 'ENTER',
                onPressed: _isButtonEnabled
                    ? () {
                  print('Entered code: ${_pinController.text}');
                  // Тут буде логіка перевірки коду
                }
                    : (){}, // Передаємо пусту функцію, щоб ElevatedButton сам змінив вигляд
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
    );
  }
}