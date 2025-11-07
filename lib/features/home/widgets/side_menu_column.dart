import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SideMenuColumn extends StatelessWidget {
  const SideMenuColumn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final double columnTotalWidth = screenHeight * 0.132;
    final double hiddenWidth = columnTotalWidth * 0.4;

    return Positioned(
      left: -hiddenWidth,
      top: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () {
          print("Side Menu Tapped");
        },
        child: SizedBox(
          width: columnTotalWidth,
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
                top: columnTotalWidth*0.6,
                right: 0,
                child: Container(
                  width: columnTotalWidth * 0.25,
                  height: columnTotalWidth * 0.3,
                  decoration: const BoxDecoration(
                    color: AppColors.accentGold,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.background,
                    size: columnTotalWidth * 0.18,
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