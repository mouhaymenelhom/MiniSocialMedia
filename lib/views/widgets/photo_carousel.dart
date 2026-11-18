import 'package:flutter/material.dart';
import 'package:mini_reseau_social/views/widgets/app_image.dart';

/// Carrousel de photos d'une publication, avec indicateur de position.
class PhotoCarousel extends StatefulWidget {
  const PhotoCarousel({
    super.key,
    required this.photoUrls,
    this.aspectRatio = 4 / 3,
  });

  final List<String> photoUrls;
  final double aspectRatio;

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final count = widget.photoUrls.length;
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        children: <Widget>[
          PageView.builder(
            itemCount: count,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => Semantics(
              label: 'Photo ${index + 1} sur $count',
              image: true,
              child: AppImage(source: widget.photoUrls[index]),
            ),
          ),
          if (count > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (var index = 0; index < count; index++)
                    _Dot(isActive: index == _currentIndex),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.white : Colors.white54,
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Colors.black26, blurRadius: 2),
        ],
      ),
    );
  }
}
