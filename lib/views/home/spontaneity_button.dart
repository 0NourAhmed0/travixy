import 'dart:math';
import 'package:flutter/material.dart';

class SpontaneityButton extends StatelessWidget {
  final List places;

  const SpontaneityButton({
    super.key,
    required this.places,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (places.isEmpty) return;

        final random = Random();

        final randomPlace =
            places[random.nextInt(places.length)];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Try visiting: ${randomPlace.name}",
            ),
          ),
        );
      },
      child: const Text(
        "Feeling Spontaneous 🎲",
      ),
    );
  }
}