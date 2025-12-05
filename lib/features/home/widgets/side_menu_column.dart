import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SideMenuColumn extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;

  const SideMenuColumn({Key? key, required this.isOpen, required this.onToggle})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final double columnTotalWidth = screenHeight * 0.132;

    return GestureDetector(
      onTap: onToggle,
      child: SizedBox(
        width: columnTotalWidth,
        height: screenHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/roman-pillar-normal.png',
                fit: BoxFit.fitHeight,
              ),
            ),
            Positioned(
              top: columnTotalWidth * 0.6,
              right: 0,
              child: Container(
                width: columnTotalWidth * 0.242,
                height: columnTotalWidth * 0.3,
                decoration: const BoxDecoration(
                  color: AppColors.accentGold,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                  child: Icon(
                    isOpen ? Icons.close : Icons.chevron_right,
                    key: ValueKey<bool>(isOpen),
                    color: AppColors.background,
                    size: columnTotalWidth * 0.18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
