import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomCushedImage extends StatelessWidget {
  const CustomCushedImage({
    super.key,
    required this.image,
    required this.height,
    required this.width,
    this.hasShadow = true,
    this.isImage = false,
  });
  final String image;
  final double height;
  final double width;
  final bool hasShadow;
  final bool isImage;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height > 1 ? height : MediaQuery.of(context).size.height * height,
      width: width > 1 ? width : MediaQuery.of(context).size.width * width,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: hasShadow
                ? Colors.black.withOpacity(0.16)
                : Colors.transparent, // Light shadow
            blurRadius: 12,
            spreadRadius: 3,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(10), // Optional rounded corners
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 0.95,
          child: CachedNetworkImage(
            fit: BoxFit.fill,
            imageUrl: image,
            errorWidget: (context, url, error) =>
                Icon(isImage ? Icons.broken_image : Icons.person),
          ),
        ),
      ),
    );
  }
}
