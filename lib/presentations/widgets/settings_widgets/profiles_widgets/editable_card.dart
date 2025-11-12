import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';

import '../../../../core/constants/fonts.dart';

class EditableCard extends StatefulWidget {
  final String title;
  final String initialValue;
  final Future<void> Function(String newValue) onSave;
  final IconData? leadingIcon;
  final TextInputType keyboardType;
  final String? hintText;
  final bool isShowTralingIcon;

  const EditableCard({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onSave,
    this.leadingIcon,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.isShowTralingIcon = true,
  });

  @override
  State<EditableCard> createState() => _EditableCardState();
}

class _EditableCardState extends State<EditableCard> {
  bool _isEditing = false;
  late TextEditingController _textController;
  late String _currentValue;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _textController = TextEditingController(text: _currentValue);
  }

  @override
  void didUpdateWidget(covariant EditableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue && !_isEditing) {
      _currentValue = widget.initialValue;
      _textController.text = _currentValue;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_textController.text == _currentValue) {
      setState(() => _isEditing = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await widget.onSave(_textController.text);
      setState(() {
        _currentValue = _textController.text;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.title} updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating ${widget.title}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final CardThemeData cardTheme = theme.cardTheme;
    final Color textColorOnCard =
    cardTheme.color != null && ThemeData.estimateBrightnessForColor(cardTheme.color!) == Brightness.dark ? Colors.white : Colors.black;
    final Color iconColor = theme.colorScheme.onSurface;
    final Color hintTextColor = theme.hintColor;

    return Card(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: _isEditing ?
        _buildEditView(
          theme,
          textTheme,
          textColorOnCard,
          hintTextColor,
          iconColor,
        ) :
        _buildDisplayView(
          theme,
          textTheme,
          textColorOnCard,
          hintTextColor,
          iconColor,
        ),
      ),
    );
  }

  Widget _buildDisplayView(
      ThemeData theme,
      TextTheme textTheme,
      Color textColor,
      Color hintColor,
      Color iconEditColor,
      ) {
    return InkWell(
      onTap: widget.isShowTralingIcon && !_isLoading ? () => setState(() => _isEditing = true) : null,
      child: Row(
        children: <Widget>[
          if (widget.leadingIcon != null) ...<Widget>[
            Icon(
              widget.leadingIcon,
              color: MyTheme.primaryColor,
              size: 30.r,
            ),
            SizedBox(width: 8.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.title,
                  style:
                  textTheme.bodySmall?.copyWith(
                    color: hintColor,
                    fontWeight: FontWeight.w500,
                  ) ??
                      Font.montserratFont(
                        fontSize: 12.sp,
                        color: hintColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _currentValue.isEmpty ? "Not set" : _currentValue,
                  style: textTheme.bodyLarge?.copyWith(color: textColor,fontSize: 14) ??
                      Font.montserratFont(
                        fontSize: 14.sp,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          if (!_isLoading)
            widget.isShowTralingIcon
                ? Icon(
              Icons.arrow_forward_ios,
              color: MyTheme.primaryColor,
              size: 20.r,
            )
                : const SizedBox.shrink()
          else
            SizedBox(
              width: 18.r,
              height: 18.r,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(iconEditColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditView(
      ThemeData theme,
      TextTheme textTheme,
      Color textColor,
      Color hintTextColor,
      Color iconActionColor,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Edit ${widget.title}",
          style:
          textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ) ??
              Font.montserratFont(
                fontSize: 14.sp,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 4.h),
        TextField(
          controller: _textController,
          autofocus: true,
          keyboardType: widget.keyboardType,
          style: textTheme.bodyLarge?.copyWith(color: textColor) ?? Font.montserratFont(fontSize: 16.sp, color: textColor),
          cursorColor: MyTheme.primaryColor,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Enter ${widget.title.toLowerCase()}',
            hintStyle:
            textTheme.bodyMedium?.copyWith(color: hintTextColor) ??
                Font.montserratFont(color: hintTextColor),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              vertical: 8.h,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: hintTextColor.withOpacity(0.5)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              onPressed: _isLoading ? null : () => setState(() {
                _isEditing = false;
                _textController.text = _currentValue;
              }),
              child: Text(
                'Cancel',
                style: Font.montserratFont(
                  fontSize: 14.sp,
                  color: _isLoading ? hintTextColor : iconActionColor,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyTheme.primaryColor,
                foregroundColor: Colors.white,
                textStyle: Font.montserratFont(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                width: 16.r,
                height: 16.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
                  : const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}