import 'package:flutter/material.dart';

class SpecificRewardScreen extends StatefulWidget {
  const SpecificRewardScreen({super.key, this.title});
  final String? title;
  @override
  State<SpecificRewardScreen> createState() => _SpecificRewardScreenState();
}

class _SpecificRewardScreenState extends State<SpecificRewardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title.toString()),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(child: Text("${widget.title.toString()} Coming song .... ",style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),))
        ],
      ),
    );
  }
}
