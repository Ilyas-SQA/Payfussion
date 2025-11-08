import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';

import '../../../../core/utils/setting_utils/data_and_permission_utils/app_styles.dart';

class SwitchSetting extends StatefulWidget {
  final String title;
  final String description;
  final bool initialValue;
  final Function(bool)? onChanged;

  const SwitchSetting({
    super.key,
    required this.title,
    required this.description,
    required this.initialValue,
    this.onChanged,
  });

  @override
  State<SwitchSetting> createState() => _SwitchSettingState();
}

class _SwitchSettingState extends State<SwitchSetting> {
  late bool value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.title,
                  style: AppStyles.listItemTextStyle(context).copyWith(
                      fontWeight: FontWeight.w500
                  ),
                ),
                Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: MyTheme.primaryColor,
            onChanged: (bool newValue) {
              setState(() {
                value = newValue;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(newValue);
              }
            },
          ),
        ],
      ),
    );
  }
}