import 'package:flutter/material.dart';

class PersistentHeader extends SliverPersistentHeaderDelegate {
  final Widget widget;

  PersistentHeader({required this.widget});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return widget;
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
