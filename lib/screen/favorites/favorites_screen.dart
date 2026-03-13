import 'package:bellamarble/core/app_Commanbar.dart';
import 'package:bellamarble/screen/favorites/provider/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_images.dart';
import '../categories/details_Screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background2,
      appBar: const CommonAppBar(title: "Favorite"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<FavoritesProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                // 🔍 Search Bar
                Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.search,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(AppImages.search),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: provider.searchController,
                          onChanged: provider.onSearch,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: "Search Anything...",
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          provider.isListening
                              ? provider.stopListening()
                              : provider.startListening();
                        },
                        child: Icon(
                          provider.isListening
                              ? Icons.mic
                              : Icons.mic_none,
                          color: AppColors.darkblue,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 🧱 Tile List
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.filteredTiles.length,
                    itemBuilder: (context, index) {
                      final tile = provider.filteredTiles[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TileDetailScreen(
                                title: tile["title"]!,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: AssetImage(tile["image"]!),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      tile["title"]!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      "Premium Quality",
                                      style: TextStyle(
                                        fontFamily: 'Pacifico',
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
