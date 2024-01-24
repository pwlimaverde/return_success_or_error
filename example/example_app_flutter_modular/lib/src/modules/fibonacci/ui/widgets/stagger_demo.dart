import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

import 'stagger_animation.dart';

class StaggerDemo extends StatefulWidget {
  final void Function() calc;
  final void Function()? calcIsolate;
  const StaggerDemo({
    super.key,
    required this.calc,
    required this.calcIsolate,
  });

  @override
  StaggerDemoState createState() => StaggerDemoState();
}

class StaggerDemoState extends State<StaggerDemo>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);

    _playAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 10.0; // 1.0 is normal animation speed.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: widget.calc,
              child: const Text('Calc Fibonacci'),
            ),
            ElevatedButton(
              onPressed: widget.calcIsolate,
              style: ElevatedButton.styleFrom(),
              child: const Text('Calc Fibonacci Isolate'),
            )
          ],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _playAnimation();
          },
          child: Center(
            child: Container(
              width: 300.0,
              height: 300.0,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                border: Border.all(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              child: StaggerAnimation(controller: _controller.view),
            ),
          ),
        ),
      ],
    );
  }
}
