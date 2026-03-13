import 'dart:ui';
import 'package:bellamarble/core/models/product_model.dart';
import 'package:bellamarble/screen/categories/provider/product_detail_provider.dart';
import 'package:bellamarble/core/widgets/shimmer_loading.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_Commanbar.dart';
import '../../core/app_colors.dart';

class TileDetailScreen extends StatefulWidget {
  final String title;
  final Product? product;

  const TileDetailScreen({super.key, required this.title, this.product});

  @override
  State<TileDetailScreen> createState() => _TileDetailScreenState();
}

class _TileDetailScreenState extends State<TileDetailScreen> {
  String? selectedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.product != null) {
        final provider = context.read<ProductDetailProvider>();
        provider.setInitialProduct(widget.product!);
        provider.fetchProductDetails(widget.product!.productId.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background2,
      appBar: CommonAppBar(title: widget.title),
      body: Consumer<ProductDetailProvider>(
        builder: (context, provider, _) {
          final product = provider.product;
          final isLoading = provider.isLoading;
          final error = provider.errorMessage;

          if (isLoading && product == null) {
            return const DetailShimmer();
          }

          if (product == null) {
            return Center(
                child: Text(
              error.isNotEmpty ? error : "Product not found",
              style: GoogleFonts.inter(fontSize: 15),
            ));
          }

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    // ✅ HERO IMAGE — full width, 55% screen height
                    GestureDetector(
                      onTap: () {
                        if (product.image.isNotEmpty) {
                          setState(() => selectedImage = product.image);
                        }
                      },
                      child: SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.55,
                        child: product.image.isNotEmpty
                            ? Image.network(
                                product.image,
                                width: double.infinity,
                                height: screenHeight * 0.55,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, size: 60),
                                ),
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 60),
                              ),
                      ),
                    ),

                    // ✅ SCROLLABLE DETAILS
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Name + Availability
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (product.availability.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: product.availability
                                            .toLowerCase()
                                            .contains('in stock')
                                        ? Colors.green.withOpacity(0.12)
                                        : Colors.orange.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: product.availability
                                              .toLowerCase()
                                              .contains('in stock')
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                  child: Text(
                                    product.availability.trim(),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: product.availability
                                              .toLowerCase()
                                              .contains('in stock')
                                          ? Colors.green[700]
                                          : Colors.orange[700],
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// Description
                          if (product.description.isNotEmpty)
                            Text(
                              product.description.trim(),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),

                          const SizedBox(height: 16),

                          /// ✅ TAGS — displayed on the RIGHT with chips
                          if (product.tags.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Tags",
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const Spacer(),
                                    // Tags aligned to the right
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      alignment: WrapAlignment.end,
                                      children: product.tags
                                          .split(',')
                                          .map((t) => t.trim())
                                          .where((t) => t.isNotEmpty)
                                          .map(
                                            (tag) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.deepPurple
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.deepPurple
                                                      .withOpacity(0.4),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                      Icons.label_outline,
                                                      size: 12,
                                                      color:
                                                          Colors.deepPurple),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    tag,
                                                    style: GoogleFonts.inter(
                                                      color:
                                                          Colors.deepPurple,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),

                          /// DETAILS BOX — Name, Size, Quantity
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: Colors.grey.shade200),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _DetailRow("Name", product.name),
                                if (product.size.isNotEmpty)
                                  _DetailRow("Size", product.size),
                                if (product.quantity.isNotEmpty)
                                  _DetailRow("Available Qty", product.quantity),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// BOTTOM BUTTONS
                          Row(
                            children: [
                              Container(
                                height: 52,
                                width: 52,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.darkblue),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.share_outlined),
                                  onPressed: () {
                                    final shareText =
                                        "Check out ${product.name} at Bella Marble!\n\nTags: ${product.tags}\n\nDownload the app for more details.";
                                    Share.share(shareText);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final Uri launchUri = Uri(
                                      scheme: 'tel',
                                      path: '+919876543210',
                                    );
                                    if (await canLaunchUrl(launchUri)) {
                                      await launchUrl(launchUri);
                                    }
                                  },
                                  child: Container(
                                    height: 54,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(26),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xff1E194A),
                                          Color(0xff473BB0),
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Call Now",
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// 🔥 BLUR + ZOOM OVERLAY
              if (selectedImage != null)
                GestureDetector(
                  onTap: () => setState(() => selectedImage = null),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {},
                        child: InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              selectedImage!,
                              width:
                                  MediaQuery.of(context).size.width * 0.95,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.error,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Reusable detail row with Inter font
class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const _DetailRow(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
