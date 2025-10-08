import 'package:flutter/material.dart';

class RadioGroup<T> extends StatefulWidget {
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final List<RadioOption<T>> options;
  final Color? activeColor;
  final Color? textColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? spacing;
  final double? textSize;
  final String? label;

  const RadioGroup({
    super.key,
    this.initialValue,
    this.onChanged,
    required this.options,
    this.activeColor,
    this.textColor,
    this.margin,
    this.padding,
    this.spacing,
    this.textSize,
    this.label,
  });

  @override
  State<RadioGroup<T>> createState() => _RadioGroupState<T>();
}

class _RadioGroupState<T> extends State<RadioGroup<T>> {
  T? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _handleValueChanged(T? value) {
    setState(() {
      _value = value;
    });
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveActiveColor = widget.activeColor ?? theme.primaryColor;
    final effectiveTextColor = widget.textColor ??
        (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87);
    final effectiveTextSize = widget.textSize ?? 16.0;

    return Container(
      margin: widget.margin,
      padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                widget.label!,
                style: TextStyle(
                  color: effectiveTextColor,
                  fontSize: effectiveTextSize + 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          Wrap(
            spacing: widget.spacing ?? 16.0,
            runSpacing: 8.0,
            children: widget.options.map((option) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<T>(
                    value: option.value,
                    groupValue: _value,
                    onChanged:
                        widget.onChanged != null ? _handleValueChanged : null,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    fillColor:
                        WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return effectiveActiveColor;
                      }
                      return Colors.grey; // your unselected color
                    }),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    option.label,
                    style: TextStyle(
                      color: effectiveTextColor,
                      fontSize: effectiveTextSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Helper class for radio options
class RadioOption<T> {
  final T value;
  final String label;

  const RadioOption({
    required this.value,
    required this.label,
  });
}
