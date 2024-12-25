import 'package:flutter/material.dart';
import 'package:onedrive_netflix/src/models/mediaitem.model.dart';

class HeroMediaItem extends StatelessWidget {
  final MediaItem mediaItem;

  const HeroMediaItem({super.key, required this.mediaItem});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Background Image with Gradient
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(204),
                    Colors.black.withAlpha(128),
                  ],
                ).createShader(rect);
              },
              blendMode: BlendMode.darken,
              child: Image.network(
                mediaItem.backdropImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content Overlay
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mediaItem.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      autofocus: true,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(
                        'Play',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.info_outline),
                      label: Text(
                        'More Info',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
