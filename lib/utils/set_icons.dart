import 'package:flutter/material.dart';

IconData setIcons(String type) {
  if (type == "Tennis") return Icons.sports_tennis;
  if (type == "Basketball") return Icons.sports_basketball;
  if (type == "Soccer") return Icons.sports_soccer;
  if (type == "Swimming") return Icons.water;
  return Icons.sports;
}
