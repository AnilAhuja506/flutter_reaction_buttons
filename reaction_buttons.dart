import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Enum representing different reactions with their respective SVG paths and names
enum Reaction {
  like('assets/reactions/like.svg', 'like'),
  love('assets/reactions/love.svg', 'love'),
  laugh('assets/reactions/laugh.svg', 'laugh'),
  curious('assets/reactions/curious.svg', 'curious'),
  support('assets/reactions/support.svg', 'support'),
  clap('assets/reactions/clap.svg', 'clap'),
  true100('assets/reactions/true100.svg', 'true'),
  none('assets/icons/like.svg', 'none');

  final String svgPath;
  final String name;

  const Reaction(this.svgPath, this.name);
}

// Callback type for when a reaction button is pressed
typedef OnButtonPressedCallback = void Function(Reaction newReaction);

// A button that allows users to select a reaction
class ReactionButton extends StatefulWidget {
  const ReactionButton({
    super.key,
    this.initialReaction,
    this.onReactionChanged,
  });

  final Reaction? initialReaction;
  final OnButtonPressedCallback? onReactionChanged;

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late OverlayPortalController _overlayController;

  Reaction _reaction = Reaction.none;
  Reaction? _hoveredReaction;
  OverlayEntry? _overlayEntry;

  final GlobalKey _buttonKey = GlobalKey();
  final List<GlobalKey> _emojiKey = List.generate(
    Reaction.values.length,
    (index) => GlobalKey(),
  );
  final List<Reaction> reactions = [
    Reaction.like,
    Reaction.love,
    Reaction.laugh,
    Reaction.curious,
    Reaction.support,
    Reaction.clap,
    Reaction.true100,
  ];

  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _reaction = widget.initialReaction ?? Reaction.none;

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Create staggered slide animations for each reaction
    _slideAnimations = List.generate(
      reactions.length,
      (index) {
        final start = index * 0.1;
        final end = start + 0.4; // Each animation lasts 40% of total duration
        return Tween<Offset>(
          begin: const Offset(0, 1), // Start from below
          end: Offset.zero, // Move to original position
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              start,
              end,
              curve: Curves.easeOut,
            ),
          ),
        );
      },
    );

    _overlayController = OverlayPortalController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Toggles the visibility of the reaction popup
  void _toggleReactionPopup(bool show) {
    if (show) {
      _controller.reset();
      _overlayController.show();
      _controller.forward(); // Start staggered animations
    } else {
      _overlayController.hide();
    }
  }

  // Updates the hovered reaction based on the local position
  void _updateHoveredReaction(Offset localPosition) {
    const double spacing = 45; // Horizontal space between reaction icons
    const double iconHeight = 40; // Height of reaction icons
    const double hoverThreshold = 40; // Additional vertical tolerance for hover

    if ((localPosition.dy + 75) < -hoverThreshold ||
        (localPosition.dy + 75) > iconHeight + hoverThreshold) {
      setState(() {
        _hoveredReaction = null; // Reset hovered reaction if outside bounds
      });
      return;
    }

    final int index =
        (localPosition.dx / spacing).clamp(0, reactions.length - 1).toInt();

    if (_hoveredReaction != reactions[index]) {
      HapticFeedback.selectionClick();
      setState(() {
        _hoveredReaction = reactions[index];
      });
    }
  }

  // Handles hover events to update the hovered reaction
  void _handleHover(Offset globalPosition) {
    final RenderBox renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(globalPosition);

    const double iconWidth = 38.0; // Width of each reaction icon
    const double iconSpacing = 45.0; // Spacing between icons
    const double verticalPadding = 40.0; // Vertical tolerance for hover area

    // Ensure hover detection happens within valid bounds
    if ((localPosition.dy + 75) < -verticalPadding ||
        (localPosition.dy + 75) > iconWidth + verticalPadding) {
      setState(() {
        _hoveredReaction = null;
      });
      return;
    }

    // Determine the hovered reaction index
    final int hoverIndex =
        (localPosition.dx / iconSpacing).clamp(0, reactions.length - 1).toInt();

    if (_hoveredReaction != reactions[hoverIndex]) {
      HapticFeedback.selectionClick();
      setState(() {
        _hoveredReaction = reactions[hoverIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) {
        RenderBox renderBox =
            _buttonKey.currentContext!.findRenderObject() as RenderBox;
        Offset offset = renderBox.localToGlobal(Offset.zero);

        return GestureDetector(
          onTap: () => _toggleReactionPopup(false),
          onPanUpdate: (details) {
            _handleHover(details.globalPosition);
          },
          onPanEnd: (_) {
            if (_hoveredReaction != null) {
              onReactionChanged(_hoveredReaction!);
            }
          },
          child: Stack(
            children: [
              // Fullscreen GestureDetector for closing overlay
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _toggleReactionPopup(false),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              // Overlay content with reactions
              AnimatedPositioned(
                duration: Duration(milliseconds: 150),
                left: offset.dx - 10,
                top: _hoveredReaction == null ? offset.dy - 72 : offset.dy - 68,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(reactions.length, (index) {
                        final reaction = reactions[index];
                        final bool isHovered = reaction == _hoveredReaction;

                        return SlideTransition(
                          position: _slideAnimations[index],
                          child: AnimatedScale(
                            scale: _hoveredReaction == null
                                ? 1.0
                                : isHovered
                                    ? 1.8
                                    : 1.0,
                            alignment: Alignment.bottomCenter,
                            duration: const Duration(milliseconds: 150),
                            child: GestureDetector(
                              onTap: () {
                                onReactionChanged(reaction);
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  AnimatedPadding(
                                    duration: Duration(milliseconds: 150),
                                    padding: EdgeInsets.only(
                                      left:
                                          _hoveredReaction == reaction ? 13 : 0,
                                      right:
                                          _hoveredReaction == reaction ? 13 : 0,
                                    ),
                                    child: AnimatedPadding(
                                      duration: Duration(milliseconds: 150),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: _hoveredReaction == null
                                              ? 1.5
                                              : 0.5),
                                      child: SvgPicture.asset(
                                        key: _emojiKey[index],
                                        reaction.svgPath,
                                        height: 40,
                                      ),
                                    ),
                                  ),
                                  if (_hoveredReaction == reaction)
                                    Positioned(
                                      top: -20,
                                      left: 0,
                                      right: 0,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: Text(
                                              reaction.name,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: GestureDetector(
        key: _buttonKey,
        onLongPressStart: (_) {
          HapticFeedback.selectionClick();
          _toggleReactionPopup(true);
        },
        onLongPressMoveUpdate: (details) {
          _updateHoveredReaction(details.localPosition);
        },
        onLongPressEnd: (_) {
          if (_hoveredReaction != null) {
            onReactionChanged(_hoveredReaction!);
          }
        },
        onTap: () {
          setState(() {
            _reaction =
                _reaction == Reaction.none ? Reaction.like : Reaction.none;
            widget.onReactionChanged?.call(_reaction);
          });
        },
        child: RepaintBoundary(
          child: SvgPicture.asset(
            _reaction.svgPath,
            width: 26,
            height: 26,
          ),
        ),
      ),
    );
  }

  OverlayEntry? flyingEmojiOverlay;

  // Animates the selected reaction emoji flying to the button
  void _flyEmoji(BuildContext context, Reaction reaction, Offset startPosition,
      Offset endPosition) {
    _overlayEntry?.remove();
    endPosition = Offset(endPosition.dx - 5, endPosition.dy - 5);
    flyingEmojiOverlay = OverlayEntry(
      builder: (context) => _FlyingEmoji(
        emoji: reaction.svgPath,
        startOffset: startPosition,
        endOffset: endPosition,
        onComplete: () {
          removeOverlay(reaction);
        },
      ),
    );

    Overlay.of(context).insert(flyingEmojiOverlay!);
  }

  // Removes the flying emoji overlay
  void removeOverlay(Reaction reaction) {
    flyingEmojiOverlay?.remove();
  }

  // Handles the reaction change and triggers the flying emoji animation
  void onReactionChanged(Reaction reaction) {
    HapticFeedback.lightImpact();
    _toggleReactionPopup(false);

    final index = reactions.indexOf(reaction);
    RenderBox renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    final RenderBox renderBox1 =
        _emojiKey[index].currentContext!.findRenderObject() as RenderBox;
    final Offset emojiPosition = renderBox1.localToGlobal(Offset.zero);

    _flyEmoji(context, reaction, emojiPosition, offset);

    Future.delayed(const Duration(milliseconds: 450), () {
      setState(() {
        _reaction = reaction;
        widget.onReactionChanged?.call(_reaction);
      });
    });
  }
}

// A widget that animates the flying emoji from the reaction popup to the button
class _FlyingEmoji extends StatefulWidget {
  final String emoji;
  final Offset startOffset;
  final Offset endOffset;
  final VoidCallback onComplete;

  const _FlyingEmoji({
    required this.emoji,
    required this.startOffset,
    required this.endOffset,
    required this.onComplete,
  });

  @override
  State<_FlyingEmoji> createState() => _FlyingEmojiState();
}

class _FlyingEmojiState extends State<_FlyingEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Offset controlPoint;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Control point for Bezier curve to create a natural arc
    controlPoint = Offset(
      (widget.startOffset.dx + widget.endOffset.dx) / 2,
      widget.startOffset.dy - 120,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate Bezier curve position
        double t = _progressAnimation.value;
        double x = (1 - t) * (1 - t) * widget.startOffset.dx +
            2 * (1 - t) * t * controlPoint.dx +
            t * t * widget.endOffset.dx;
        double y = (1 - t) * (1 - t) * widget.startOffset.dy +
            2 * (1 - t) * t * controlPoint.dy +
            t * t * widget.endOffset.dy;

        return Positioned(
          left: x,
          top: y,
          child: Transform.scale(
            scale: 1 - (0.4 * t), // Shrinks towards the button
            child: Opacity(
              opacity: 1 - (0.7 * t), // Fades out as it reaches the button
              child: RepaintBoundary(
                  child: SvgPicture.asset(widget.emoji, width: 38, height: 38)),
            ),
          ),
        );
      },
    );
  }
}
