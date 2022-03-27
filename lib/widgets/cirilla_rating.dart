import 'package:cirilla/constants/color_block.dart';
import 'package:flutter/material.dart';
import 'package:awesome_icons/awesome_icons.dart';

class CirillaRating extends StatelessWidget {
  final double initialValue;
  final int count;
  final double size;
  final Color? color;
  final double pad;

  const CirillaRating({
    Key? key,
    this.initialValue = 0,
    this.count = 5,
    this.size = 12,
    this.color,
    this.pad = 4,
  })  : assert(count >= 0),
        assert(size > 0),
        assert(pad >= 0),
        assert(initialValue >= 0 && initialValue <= count),
        super(key: key);

  const factory CirillaRating.select({
    Key? key,
    int defaultRating,
    int count,
    double size,
    Color? color,
    Color? selectColor,
    double pad,
    Function(int value)? onFinishRating,
  }) = _CirillaRatingSelect;

  const factory CirillaRating.number({
    Key? key,
    double initialValue,
    double iconSize,
    double fontSize,
    Color? iconColor,
    Color? textColor,
    double pad,
  }) = _CirillaRatingNumber;

  @override
  Widget build(BuildContext context) {
    int visit = initialValue.toInt();
    int valueFloor = initialValue.ceil();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        IconData icon = index < visit
            ? FontAwesomeIcons.solidStar
            : index >= valueFloor
                ? FontAwesomeIcons.star
                : FontAwesomeIcons.starHalfAlt;
        double padRight = index <= count - 1 ? pad : 0;
        return Padding(
          padding: EdgeInsets.only(right: padRight),
          child: Icon(
            icon,
            size: size,
            color: color ?? ColorBlock.yellow,
          ),
        );
      }).toList(),
    );
  }
}

class _CirillaRatingSelect extends CirillaRating {
  final int defaultRating;
  final Function(int value)? onFinishRating;
  final Color? selectColor;

  const _CirillaRatingSelect({
    Key? key,
    this.onFinishRating,
    this.defaultRating = 3,
    int count = 5,
    double size = 20,
    Color? color,
    this.selectColor,
    double pad = 4,
  })  : assert(count > 0),
        assert(size > 0),
        assert(pad >= 0),
        assert(defaultRating >= 0 && defaultRating <= count),
        super(
          key: key,
          count: count,
          size: size,
          color: color,
          pad: pad,
        );

  @override
  Widget build(BuildContext context) {
    Color colorSelect = selectColor ?? ColorBlock.yellow;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        IconData icon = index < defaultRating ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star;
        Color? colorIcon = index < defaultRating ? colorSelect : color;
        double padRight = index <= count - 1 ? pad : 0;
        return Padding(
          padding: EdgeInsets.only(right: padRight),
          child: InkWell(
            onTap: () => onFinishRating!(index + 1),
            child: Icon(
              icon,
              size: size,
              color: colorIcon,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CirillaRatingNumber extends CirillaRating {
  final Color? iconColor;
  final Color? textColor;
  final double fontSize;
  final double iconSize;

  const _CirillaRatingNumber({
    Key? key,
    double initialValue = 2.5,
    this.iconSize = 12,
    this.fontSize = 14,
    this.iconColor,
    this.textColor,
    double pad = 4,
  })  : assert(initialValue >= 0),
        assert(iconSize > 0 && fontSize > 0),
        assert(pad >= 0),
        super(
          key: key,
          initialValue: initialValue,
          pad: pad,
        );

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: pad,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$initialValue',
          style: Theme.of(context).textTheme.subtitle2?.copyWith(fontSize: fontSize, color: textColor),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Icon(FontAwesomeIcons.solidStar, size: iconSize, color: iconColor ?? ColorBlock.yellow),
        ),
      ],
    );
  }
}
