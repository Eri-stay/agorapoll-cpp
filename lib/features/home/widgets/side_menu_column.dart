import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SideMenuColumn extends StatelessWidget {
  const SideMenuColumn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () {
          // Тут буде логіка відкриття меню
          print("Side Menu Tapped");
        },
        child: Container(
          width: 85, // Ширина колони, можна налаштувати
          color: Colors.transparent,
          child: Stack(
            children: [
              // Column
              Positioned.fill(
                left: -70,
                child: Image.asset(
                  'assets/images/roman-pillar-normal.png',
                  fit: BoxFit.fitHeight,
                ),
              ),
              // Tab with arrow
              Positioned(
                top: 60,
                right: 26,
                child: Container(
                  width: 24,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppColors.mutedGold,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: AppColors.background,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}