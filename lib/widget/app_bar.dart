import 'package:flutter/material.dart';
import 'package:mvc/utils.dart';
import 'package:mvc/controllers/auth_controller.dart';
import 'package:mvc/ui/sign_in_screen.dart';

class TMAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TMAppBar({
    super.key,
    this.isProfileScreenOpen = false,
  });

  final bool isProfileScreenOpen;

  @override
  Widget build(BuildContext context) {
    final user = AuthController.userData;

    return AppBar(
      backgroundColor: AppColors.themeColor,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: InkWell(
        onTap: () {
          if (!isProfileScreenOpen) {
            // 👉 চাইলে এখানে ProfileScreen এ নিয়ে যেতে পারো
            // Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
        child: Row(
          children: [
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Text(
                user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : "?",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user?.fullName ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () async {
            await AuthController.clearUserData();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
                    (route) => false,
              );
            }
          },
          icon: const Icon(Icons.logout, color: Colors.white),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
