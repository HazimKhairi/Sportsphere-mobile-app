import 'package:flutter/material.dart';

abstract final class SphereRadius {
  static const chip = Radius.circular(8);
  static const card = Radius.circular(12);
  static const sheet = Radius.circular(16);
  static const modal = Radius.circular(24);
  static const pill = Radius.circular(999);

  static const cardRect = BorderRadius.all(card);
  static const sheetTop = BorderRadius.vertical(top: sheet);
  static const modalRect = BorderRadius.all(modal);
  static const pillRect = BorderRadius.all(pill);
}
