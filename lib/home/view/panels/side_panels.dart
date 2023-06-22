import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum Direction {
  left,
  right,
}

class HorizontalOffset {
  final double left;
  final double right;

  const HorizontalOffset({
    this.left = 0.0,
    this.right = 0.0,
  }) : assert(left >= 0.0 && left <= 1.0 && right >= 0.0 && right <= 1.0);
}

const double _defaultWidth = 400;
const double _minFlingVelocity = 365.0;

class SidePanels extends StatefulWidget {
  const SidePanels({
    GlobalKey? key,
    required this.leftPanel,
    required this.rightPanel,
    required this.mainPanel,
    this.offset = const HorizontalOffset(left: 0.8, right: 0.8),
    this.borderRadius = 10,
    this.duration = 250,
    this.velocity = 1,
  }) : super(key: key);

  final Widget leftPanel;
  final Widget rightPanel;
  final Widget mainPanel;

  final HorizontalOffset offset;
  final double borderRadius;
  final int duration;
  final double velocity;

  @override
  SidePanelsState createState() => SidePanelsState();
}

class SidePanelsState extends State<SidePanels>
    with SingleTickerProviderStateMixin {
  double _width = _defaultWidth;
  Orientation _orientation = Orientation.portrait;
  Direction? _position;

  @override
  void initState() {
    _position = Direction.left;

    _controller = AnimationController(
      value: 1,
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    )
      ..addListener(_animationChanged)
      ..addStatusListener(_animationStatusChanged);
    super.initState();
  }

  @override
  void dispose() {
    _historyEntry?.remove();
    _controller.dispose();
    _focusScopeNode.dispose();
    super.dispose();
  }

  void _animationChanged() {
    setState(() {});
  }

  LocalHistoryEntry? _historyEntry;
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  void _ensureHistoryEntry() {
    if (_historyEntry == null) {
      final ModalRoute<dynamic>? route = ModalRoute.of(context);
      if (route != null) {
        _historyEntry = LocalHistoryEntry(onRemove: _handleHistoryEntryRemoved);
        route.addLocalHistoryEntry(_historyEntry!);
        FocusScope.of(context).setFirstFocus(_focusScopeNode);
      }
    }
  }

  void _animationStatusChanged(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.forward:
        break;
      case AnimationStatus.reverse:
        break;
      case AnimationStatus.dismissed:
        _ensureHistoryEntry();
        break;
      case AnimationStatus.completed:
        _historyEntry?.remove();
        _historyEntry = null;
    }
  }

  void _handleHistoryEntryRemoved() {
    _historyEntry = null;
    close();
  }

  late AnimationController _controller;

  void _handleDragDown(DragDownDetails details) {
    _controller.stop();
  }

  final GlobalKey _panelKey = GlobalKey();

  double get _velocity {
    return widget.velocity;
  }

  void _updateWidth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? box =
          _panelKey.currentContext?.findRenderObject() as RenderBox?;

      if (box != null) {
        setState(() {
          _width = box.size.width;
        });
      }
    });
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    double delta = details.primaryDelta! / _width;

    if (delta > 0 && _controller.value == 1) {
      _position = Direction.left;
    } else if (delta < 0 && _controller.value == 1) {
      _position = Direction.right;
    }

    double offset =
        _position == Direction.left ? widget.offset.left : widget.offset.right;

    offset = 1 - pow(offset, 1 / 2) as double;

    if (_position == Direction.left) delta = -delta;

    _controller.value += delta + (delta * offset);
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (_controller.isDismissed) return;

    if (details.velocity.pixelsPerSecond.dx.abs() >= _minFlingVelocity) {
      double visualVelocity =
          (details.velocity.pixelsPerSecond.dx + _velocity) / _width;

      if (_position == Direction.left) visualVelocity = -visualVelocity;

      _controller.fling(velocity: visualVelocity);
    } else if (_controller.value < 0.5) {
      open();
    } else {
      close();
    }
  }

  void open({Direction? direction}) {
    if (direction != null) _position = direction;
    _controller.fling(velocity: -_velocity);
  }

  void close({Direction? direction}) {
    if (direction != null) _position = direction;
    _controller.fling(velocity: _velocity);
  }

  final GlobalKey _gestureDetectorKey = GlobalKey();

  AlignmentDirectional get _mainPanelAlignment {
    return _position == Direction.left
        ? AlignmentDirectional.centerEnd
        : AlignmentDirectional.centerStart;
  }

  AlignmentDirectional get _sidePanelAlignment {
    return _position == Direction.left
        ? AlignmentDirectional.centerStart
        : AlignmentDirectional.centerEnd;
  }

  double get _offset {
    return _position == Direction.left
        ? widget.offset.left
        : widget.offset.right;
  }

  double get _widthWithOffset {
    return (_width / 2) - (_width / 2) * _offset;
  }

  Widget get _leftPanel {
    return widget.leftPanel;
  }

  Widget get _rightPanel {
    return widget.rightPanel;
  }

  Widget _mainPanel() {
    final Widget? cover = _invisibleCover();

    final Widget mainPanelChild = Stack(
      children: <Widget>[widget.mainPanel, if (cover != null) cover],
    );

    final Widget container = Container(
        key: _panelKey,
        child: widget.borderRadius != 0
            ? ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(widget.borderRadius),
                ),
                child: mainPanelChild)
            : mainPanelChild);

    return container;
  }

  Widget? _invisibleCover() {
    final Container container = Container(
      color: ColorTween(begin: Colors.black54, end: Colors.transparent)
          .evaluate(_controller),
    );

    if (_controller.value != 1.0) {
      return BlockSemantics(
        child: GestureDetector(
          excludeFromSemantics: defaultTargetPlatform == TargetPlatform.android,
          onTap: close,
          child: Semantics(
            label: MaterialLocalizations.of(context).modalBarrierDismissLabel,
            child: container,
          ),
        ),
      );
    }

    return null;
  }

  Widget _currentPanel() {
    final Widget child = _position == Direction.left ? _leftPanel : _rightPanel;

    final Widget container = Container(
      color: Colors.grey.shade300,
      width: _width - _widthWithOffset,
      child: GestureDetector(
        onHorizontalDragUpdate: _handleHorizontalDragUpdate,
        onHorizontalDragEnd: _handleHorizontalDragEnd,
        child: child,
      ),
    );

    return container;
  }

  @override
  Widget build(BuildContext context) {
    if (_width == _defaultWidth ||
        MediaQuery.of(context).orientation != _orientation) {
      _updateWidth();
      _orientation = MediaQuery.of(context).orientation;
    }

    final double offset = 0.5 - _offset * 0.5;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
      ),
      child: Stack(
        alignment: _sidePanelAlignment,
        children: <Widget>[
          FocusScope(node: _focusScopeNode, child: _currentPanel()),
          GestureDetector(
            key: _gestureDetectorKey,
            onTap: () {},
            onHorizontalDragDown: _handleDragDown,
            onHorizontalDragUpdate: _handleHorizontalDragUpdate,
            onHorizontalDragEnd: _handleHorizontalDragEnd,
            excludeFromSemantics: true,
            child: RepaintBoundary(
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: _mainPanelAlignment,
                    child: Align(
                      alignment: _sidePanelAlignment,
                      widthFactor: (_controller.value * (1 - offset)) + offset,
                      child: RepaintBoundary(
                        child: _mainPanel(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
