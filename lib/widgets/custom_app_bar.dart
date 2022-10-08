import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {

  final double size;

  const CustomAppBar({Key? key, this.size = 100}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.only(top: 8.0, left: 16),
                child: Text('Welcome'),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 8),
                child: Text('Arbaaz', style: TextStyle(fontSize: 24)),
              )
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 24, right: 16.0),
          child: CircleAvatar(),
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(size);
}
