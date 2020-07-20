import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_circular_text/circular_text.dart';
import 'package:provider/provider.dart';
import 'package:time_picker/notifiers/TimeStamp.dart';

class TimePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TimeStamp>(create: (_) => TimeStamp()),
      ],
      child: Transform.translate(
        offset: Offset(0, 140),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(),
            MultiDial(),
            SaveButton(),
          ],
        ),
      ),
    );
  }
}

class MultiDial extends StatelessWidget {
  MultiDial();
  final scale = 2.0;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.diagonal3Values(scale, scale, scale),
      alignment: Alignment.center,
      child: Stack(
          overflow: Overflow.clip,
          alignment: Alignment.center,
          children: <Dial>[
            Dial(size: 2, type: PartialType.hour),
            Dial(size: 1, type: PartialType.minute),
            Dial(size: 0, type: PartialType.amPm),
          ]),
    );
  }
}

class Dial extends StatefulWidget {
  final PartialType type;
  final int spacing;
  final int size;

  Dial({
    this.spacing = 48,
    this.size = 0,
    this.type = PartialType.hour,
  });

  @override
  _DialState createState() => _DialState();
}

class _DialState extends State<Dial> {
  final baseRadius = 50.0;
  var _angle = 0.0;
  var _theta;

  @override
  void initState() {
    super.initState();
    final partial = context.read<TimeStamp>().getPartial(widget.type);
    _angle = -partial.selectedIndex * _spacingRad;
  }

  double get _maxAngle =>
      (context.read<TimeStamp>().getPartial(widget.type).items.length - 1) *
      _spacingRad;

  int get _spacing => math.pow(2 - widget.size, 4) + widget.spacing ~/ 2;

  double get _spacingRad => _spacing * math.pi / 180;

  double get _space => 6.0 + math.pow(2 - widget.size, 3);

  double get _radiusOffset => 24;

  int get _curElem {
    final spacingRad = _spacing * math.pi / 180;
    final elem = (_angle / spacingRad) - 0.5;
    final elemIndex = elem.toInt().abs();
    return elemIndex;
  }

  String _text(int i, String text) {
    var delta = (i.abs() - _curElem.abs()).abs();
    final maxDelta = (0.8 * math.pi) / _spacingRad.abs();
    if (delta < maxDelta) {
      return text;
    }
    return "";
  }

  FontWeight _fontWeight(int i) {
    if (i == _curElem) {
      return FontWeight.bold;
    }
    return FontWeight.normal;
  }

  double _lineHeight(int i) {
    if (i == _curElem) {
      return 1.3;
    }
    return 1.5;
  }

  double _fontSize(int i) {
    if (i == _curElem) {
      return 14.0;
    }
    return 12.0;
  }

  Color _color(int i) {
    if (i == _curElem) {
      return Colors.blue;
    }
    return Colors.grey.shade800;
  }

  void _handlePanStart(DragStartDetails details) {
    RenderBox getBox = context.findRenderObject();
    var offset = getBox.globalToLocal(details.globalPosition);
    final size = context.size;
    final theta = _calculateTheta(offset, size);
    setState(() {
      _theta = theta;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    RenderBox getBox = context.findRenderObject();
    var offset = getBox.globalToLocal(details.globalPosition);
    final size = context.size;
    final theta = _calculateTheta(offset, size);
    var thetaDelta = 0.0;
    if (_theta != null) {
      thetaDelta = _theta - theta;
    }

    // When theta goes from +/-pi to -/+pi, we need to correct it.
    if (thetaDelta.abs() > math.pi) {
      if (thetaDelta > 0) {
        thetaDelta = thetaDelta - (2 * math.pi);
      } else {
        thetaDelta = thetaDelta + (2 * math.pi);
      }
    }

    setState(() {
      final newAngle = _angle + thetaDelta;
      if (newAngle.abs() <= _maxAngle && newAngle <= 0) {
        _angle = newAngle;
        context.read<TimeStamp>().getPartial(widget.type).selectedIndex =
            _curElem;
      }
      _theta = theta;
    });
  }

  double _calculateTheta(Offset offset, Size boxSize) {
    final x = -((boxSize.width / 2) - (offset.dx));
    final y = (boxSize.height / 2) - (offset.dy);
    return math.atan2(y, x);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _handlePanStart(details),
      onPanUpdate: (details) => _handlePanUpdate(details),
      child: Transform.rotate(
        angle: _angle,
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 1)]),
          child: CircularText(
            children: context
                .watch<TimeStamp>()
                .getPartial(widget.type)
                .items
                .mapIndexed(
                  (i, e) => TextItem(
                    text: Text(
                      _text(i, e),
                      style: TextStyle(
                        color: _color(i),
                        fontSize: _fontSize(i),
                        height: _lineHeight(i),
                        fontWeight: _fontWeight(i),
                      ),
                    ),
                    startAngle: (i.toDouble() * _spacing) - 90,
                    startAngleAlignment: StartAngleAlignment.center,
                    space: _space,
                  ),
                )
                .toList(),
            backgroundPaint: Paint()
              ..color = [
                Colors.grey.shade100,
                Colors.grey.shade200,
                Colors.grey.shade300,
                Colors.grey.shade400,
              ][widget.size],
            radius: baseRadius + (_radiusOffset * widget.size),
          ),
        ),
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 3,
          )
        ],
      ),
      child: RawMaterialButton(
        onPressed: () {
          var time = context.read<TimeStamp>().timeStamp;
          Navigator.pop(context, time);
        },
        elevation: 0,
        highlightElevation: 2,
        fillColor: Colors.white,
        child: Text(
          'SAVE',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 24,
          ),
        ),
        padding: EdgeInsets.all(36),
        shape: CircleBorder(),
      ),
    );
  }
}

extension ExtendedIterable<E> on Iterable<E> {
  /// Like Iterable<T>.map but callback have index as second argument
  Iterable<T> mapIndexed<T>(T f(int i, E e)) {
    var i = 0;
    return this.map((e) => f(i++, e));
  }

  void forEachIndex(void f(int i, E e)) {
    var i = 0;
    this.forEach((e) => f(i++, e));
  }
}
