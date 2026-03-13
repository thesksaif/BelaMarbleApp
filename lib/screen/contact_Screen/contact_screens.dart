import 'package:bellamarble/screen/contact_Screen/provider/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/app_Commanbar.dart';
import '../../core/app_colors.dart';
import '../../core/app_images.dart';

class ContactScreens extends StatefulWidget {
  const ContactScreens({super.key});

  @override
  State<ContactScreens> createState() => _ContactScreensState();
}

class _ContactScreensState extends State<ContactScreens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background2,
      appBar: const CommonAppBar(title: "Contact"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff1E194A),
                    Color(0xff1E194A),
                    Color(0xff9F9DB2),
                  ],
                ),
              ),
              child: Center(
                child: Image.asset(
                  "assets/contact/image 27.png",
                  height: 60,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Consumer<ContactProvider>(
              builder: (context, provider, _) {
                return _contactInfoCard(provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactInfoCard(ContactProvider provider) {
    if (provider.isLoading) {
      return Container(
        height: 200,
        decoration: _cardDecoration(),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _sectionTitle("Contact Information"),
          _InfoRow(AppImages.mail, "Email", provider.email),
          _InfoRow(AppImages.phone, "Phone", provider.phone),
          _InfoRow(AppImages.web, "Website", provider.website),
          _InfoRow(AppImages.location, "Location", provider.location),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
        ),
      ],
    );
  }
}


/// ================= SMALL WIDGETS =================

class _sectionTitle extends StatelessWidget {
  final String title;
  const _sectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 36,
          width: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.search,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SvgPicture.asset(AppImages.contact),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String iconPath;
  final String label;
  final String value;

  const _InfoRow(this.iconPath, this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: SvgPicture.asset(
              iconPath,
              color: AppColors.darkblue,height: 20,width: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
