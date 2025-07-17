import 'package:flutter/material.dart';
import 'dart:math';

class SwipeCardView extends StatefulWidget {
  final String title;
  final String bodyText;
  final Color frontColor;
  final String imageUrl;
  final double cardHeight; 

  const SwipeCardView({
    super.key,
    required this.title,
    required this.bodyText,
    required this.frontColor,
    required this.imageUrl,
    this.cardHeight = 380, 
  });

  @override
  _SwipeCardViewState createState() => _SwipeCardViewState();
}

class _SwipeCardViewState extends State<SwipeCardView>
    with SingleTickerProviderStateMixin {
  double xOffset = 0;
  double rotationDeg = 0;
  double opacity = 1.0;
  bool isSwipedAway = false;
  bool isFlipped = false;
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Flip animation speed
    );
    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void swipeAway(double direction) {
    setState(() {
      xOffset = direction * 1000;
      rotationDeg = direction * 30;
      opacity = 0;
      isSwipedAway = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isSwipedAway
        ? const SizedBox.shrink()
        : GestureDetector(
            onTap: () {
              if (isFlipped) {
                _controller.reverse();
              } else {
                _controller.forward();
              }
              setState(() {
                isFlipped = !isFlipped;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                xOffset += details.delta.dx;
                rotationDeg = xOffset / 10;
                opacity = 1 - (xOffset.abs() / 600);
              });
            },
            onPanEnd: (details) {
              if (xOffset.abs() > 150) {
                swipeAway(xOffset > 0 ? 1 : -1);
              } else {
                setState(() {
                  xOffset = 0;
                  rotationDeg = 0;
                  opacity = 1;
                });
              }
            },
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: opacity,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final isBack = _flipAnimation.value >= (pi / 2);
                  final rotationValue = isBack ? _flipAnimation.value + pi : _flipAnimation.value;
                  
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(xOffset, 0, 0)
                      ..rotateY(rotationValue)
                      ..rotateZ(rotationDeg * 0.01),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: widget.cardHeight,
                      decoration: BoxDecoration(
                        color: widget.frontColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _flipAnimation.value < (pi / 2)
                            ? _frontSide()
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(pi),
                                child: _backSide(),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
  }

  Widget _frontSide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.bodyText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backSide() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Transform.scale(
          scaleX: -1, // This will mirror the image horizontally
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 40,
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
