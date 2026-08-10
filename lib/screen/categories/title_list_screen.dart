import 'package:bellamarble/core/models/product_model.dart';
import 'package:bellamarble/screen/categories/provider/titlelist_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bellamarble/core/widgets/app_network_image.dart';

import '../../core/app_colors.dart';
import '../../core/app_Commanbar.dart';
import '../../core/app_images.dart';
import '../../core/widgets/shimmer_loading.dart';
import 'details_Screen.dart';

class TileListScreen extends StatefulWidget {
  final String title;
  final String categoryId;

  const TileListScreen({
    super.key,
    required this.title,
    required this.categoryId,
  });

  @override
  State<TileListScreen> createState() => _TileListScreenState();
}

class _TileListScreenState extends State<TileListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<TileListProvider>().fetchProducts(widget.categoryId),
    );

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<TileListProvider>().loadMore(widget.categoryId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = widget.title.replaceAll("\n", " ");

    return Scaffold(
      backgroundColor: AppColors.background2,
      appBar: CommonAppBar(title: displayTitle),
      body: Consumer<TileListProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// 🔍 SEARCH BAR
                Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.search,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(AppImages.search),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: provider.searchController,
                          onChanged: (val) =>
                              provider.onSearch(val, widget.categoryId),
                          style: GoogleFonts.inter(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: "Search Anything...",
                            hintStyle: GoogleFonts.inter(
                              color: Colors.grey.shade500,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),

                      /// 🎤 MIC
                      GestureDetector(
                        onTap: () {
                          provider.isListening
                              ? provider.stopListening()
                              : provider.startListening();
                        },
                        child: Icon(
                          provider.isListening
                              ? Icons.mic
                              : Icons.mic_none_rounded,
                          color: AppColors.darkblue,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// 🧱 PRODUCT CARD LIST
                Expanded(
                  child: provider.isLoading
                      ? ListView.builder(
                          itemCount: 6,
                          itemBuilder: (_, __) => const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: ShimmerLoading(
                              child: SizedBox(
                                height: 350,
                                width: double.infinity,
                                child: ColoredBox(color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      : provider.errorMessage.isNotEmpty
                      ? Center(child: Text(provider.errorMessage))
                      : provider.filteredProducts.isEmpty
                      ? const Center(child: Text("No products found"))
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount:
                              provider.filteredProducts.length +
                              (provider.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == provider.filteredProducts.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final product = provider.filteredProducts[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TileDetailScreen(
                                      title: product.name,
                                      product: product,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 280,
                                      child: AppNetworkImage(
                                        url: product.image,
                                        width: 400,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          // ── LEFT: Name + Availability ──
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  style: GoogleFonts.inter(
                                                    color: AppColors.darkblue,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (product
                                                    .availability
                                                    .isNotEmpty)
                                                  Text(
                                                    product.availability.trim(),
                                                    style: GoogleFonts.inter(
                                                      color:
                                                          product.availability
                                                              .toLowerCase()
                                                              .contains(
                                                                'in stock',
                                                              )
                                                          ? Colors.green
                                                          : Colors.orange,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // ── RIGHT: Size + Qty + Tags ──
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              if (product.size.isNotEmpty)
                                                _InfoChip(
                                                  label: product.size,
                                                  icon: Icons.straighten,
                                                  color: Colors.blueAccent,
                                                ),
                                              if (product.quantity.isNotEmpty)
                                                const SizedBox(height: 4),
                                              if (product.quantity.isNotEmpty)
                                                _InfoChip(
                                                  label:
                                                      "Qty: ${product.quantity}",
                                                  icon: Icons
                                                      .inventory_2_outlined,
                                                  color: Colors.teal,
                                                ),
                                              if ((product.size.isNotEmpty ||
                                                      product
                                                          .quantity
                                                          .isNotEmpty) &&
                                                  product.tags.isNotEmpty)
                                                const SizedBox(height: 4),
                                              if (product.tags.isNotEmpty)
                                                ..._buildTagChips(product.tags),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildTagChips(String tags) {
    return tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .map(
          (tag) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _InfoChip(
              label: tag,
              icon: Icons.label_outline,
              color: Colors.deepPurpleAccent,
            ),
          ),
        )
        .toList();
  }
}

/// Pill-shaped info chip for size and tags
class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 11),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
