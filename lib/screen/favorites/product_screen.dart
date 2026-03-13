import 'package:bellamarble/core/app_Commanbar.dart';
import 'package:bellamarble/core/app_colors.dart';
import 'package:bellamarble/core/app_images.dart';
import 'package:bellamarble/core/models/product_model.dart';
import 'package:bellamarble/core/widgets/shimmer_loading.dart';
import 'package:bellamarble/screen/categories/details_Screen.dart';
import 'package:bellamarble/screen/favorites/provider/product_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initial data fetch
    Future.microtask(
        () => context.read<ProductListProvider>().fetchInitial());

    // Infinite scroll: load more when near the bottom
    _scrollController.addListener(() {
      final provider = context.read<ProductListProvider>();
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !provider.isLoadingMore &&
          provider.hasMore) {
        provider.loadMore();
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
    return Scaffold(
      backgroundColor: AppColors.background2,
      appBar: const CommonAppBar(title: "Products"),
      body: Consumer<ProductListProvider>(
        builder: (context, provider, _) {
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
                          onChanged: provider.onSearch,
                          style: GoogleFonts.inter(
                              color: Colors.black87, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Search products...",
                            hintStyle: GoogleFonts.inter(
                                color: Colors.grey.shade500),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => provider.isListening
                            ? provider.stopListening()
                            : provider.startListening(),
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

                /// 🧱 PRODUCT LIST
                Expanded(
                  child: provider.isLoading
                      ? _buildShimmer()
                      : provider.errorMessage.isNotEmpty &&
                              provider.filteredProducts.isEmpty
                          ? Center(
                              child: Text(
                                provider.errorMessage,
                                style: GoogleFonts.inter(color: Colors.grey),
                              ),
                            )
                          : provider.filteredProducts.isEmpty
                              ? Center(
                                  child: Text("No products found",
                                      style: GoogleFonts.inter()))
                              : ListView.builder(
                                  controller: _scrollController,
                                  // +1 for the load-more indicator at bottom
                                  itemCount:
                                      provider.filteredProducts.length +
                                          (provider.isLoadingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    // Load-more spinner at the very end
                                    if (index ==
                                        provider.filteredProducts.length) {
                                      return const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      );
                                    }

                                    final product =
                                        provider.filteredProducts[index];
                                    return _ProductCard(product: product);
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

  Widget _buildShimmer() {
    return ListView.builder(
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
    );
  }
}

/// ── Product Card ─────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              TileDetailScreen(title: product.name, product: product),
        ),
      ),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 280,
              child: Image(
                image: product.image.isNotEmpty
                    ? NetworkImage(product.image)
                    : const AssetImage("assets/home_pages/Previous.png") as ImageProvider,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ── LEFT: Name + Availability ──
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: GoogleFonts.inter(
                            color: AppColors.darkblue,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.availability.isNotEmpty)
                          Text(
                            product.availability.trim(),
                            style: GoogleFonts.inter(
                              color: product.availability.toLowerCase().contains('in stock') ? Colors.green : Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ── RIGHT: Size + Qty + Tags ──
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (product.size.isNotEmpty)
                        _InfoChip(
                          label: product.size,
                          icon: Icons.straighten,
                          color: Colors.blueAccent,
                        ),
                      if (product.quantity.isNotEmpty) const SizedBox(height: 4),
                      if (product.quantity.isNotEmpty)
                        _InfoChip(
                          label: "Qty: ${product.quantity}",
                          icon: Icons.inventory_2_outlined,
                          color: Colors.teal,
                        ),
                      if ((product.size.isNotEmpty || product.quantity.isNotEmpty) && product.tags.isNotEmpty)
                        const SizedBox(height: 4),
                      if (product.tags.isNotEmpty) ..._buildTagChips(product.tags),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _InfoChip(
      {required this.label, required this.icon, required this.color});

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
