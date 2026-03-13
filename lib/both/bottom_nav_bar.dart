import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/app_colors.dart';
import '../core/app_images.dart';
import '../screen/favorites/product_screen.dart';
import '../screen/contact_Screen/contact_screens.dart';
import '../screen/home/home_screen.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int _currentIndex = 0;

  /// ✅ Pages (same length as bottom items)
  final List<Widget> _pages = const [
    HomeScreen(),
    ProductScreen(),
    ContactScreens(),
  ];

  final List<String> _labels = [
    "Home",
    "Product",
    "Contact",
  ];

  /// ✅ SVG Icons
  final List<String> _svgIcons = [
    AppImages.Home,
    AppImages.dashboard,
    AppImages.Contact,
  ];

  int get _safeIndex =>
      _currentIndex.clamp(0, _pages.length - 1);

  @override
  Widget build(BuildContext context) {
    final index = _safeIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,

      body: _pages[index],


      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: SizedBox(
          height: 70,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / _svgIcons.length;
              return Stack(
                clipBehavior: Clip.none,
                children: [
              /// 🔹 Bottom Bar
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(_svgIcons.length, (i) {
                    final bool isSelected = index == i;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() => _currentIndex = i);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: isSelected ? 0.0 : 1.0,
                              child: SvgPicture.asset(
                                _svgIcons[i],
                                height: 24,
                                colorFilter: const ColorFilter.mode(
                                  Colors.grey,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: isSelected ? 0.0 : 1.0,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  _labels[i],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              /// 🔹 Floating Selected Circle
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                left: (index * itemWidth) + (itemWidth / 2) - 30,
                top: -20,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppColors.darkblue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkblue.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: SvgPicture.asset(
                      _svgIcons[index],
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
            }
          ),
        ),
      ),
    );
  }
}

class Favorites extends StatelessWidget {
  const Favorites({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Favorites Screen"));
  }
}

class Contact extends StatelessWidget {
  const Contact({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Contact Screen"));
  }
}
