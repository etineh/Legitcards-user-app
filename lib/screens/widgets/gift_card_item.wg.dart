import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:legit_cards/constants/app_colors.dart';
import '../../data/models/gift_card_trades_m.dart';

class GiftCardItemWG extends StatelessWidget {
  final GiftCardAssetM giftCardAsset;
  final VoidCallback onTap;

  const GiftCardItemWG({
    super.key,
    required this.giftCardAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = giftCardAsset.cardActive;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.5,
        child: Container(
          // margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 🖼️ Image section
              Expanded(
                // flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: giftCardAsset.images.isNotEmpty
                        ? giftCardAsset.images[0]
                        : '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.card_giftcard, size: 40),
                    ),
                  ),
                ),
              ),

              // 🏷️ Label section with name and status indicator
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.lightPurple : Colors.grey[400],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  border: const Border(
                    top: BorderSide(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Status indicator dot
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? Colors.greenAccent : Colors.redAccent,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          giftCardAsset.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
