import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/duration_formatter.dart';

class ProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const ProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final max = duration.inMilliseconds.toDouble();
    final value = position.inMilliseconds
        .clamp(0, duration.inMilliseconds)
        .toDouble();

    return Column(
      children: [
        Slider(
          min: 0,
          max: max > 0 ? max : 1,
          value: max > 0 ? value : 0,
          activeColor: AppColors.primary,
          inactiveColor: Colors.grey[800],
          onChanged: (newValue) {
            onSeek(Duration(milliseconds: newValue.toInt()));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DurationFormatter.format(position),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                DurationFormatter.format(duration),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}