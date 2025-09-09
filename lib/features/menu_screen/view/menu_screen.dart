import 'package:chiken_odyssey/constants/app_data.dart';
import 'package:chiken_odyssey/constants/image_source.dart';
import 'package:chiken_odyssey/features/menu_screen/widgets/menu_card.dart';
import 'package:chiken_odyssey/features/menu_screen/widgets/privacy_policy_section.dart';
import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuList = AppData.menuList;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageSource.background),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(ImageSource.logo, height: 205),
            const SizedBox(height: 60),
            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 20),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menuList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                return MenuCard(data: menuList[index]);
              },
            ),
            SizedBox(height: 12),
            PrivactyPolicySection(),
          ],
        ),
      ),
    );
  }
}
