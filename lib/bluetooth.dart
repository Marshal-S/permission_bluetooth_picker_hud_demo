import 'package:flutter/material.dart';

class BluetoothTestWidget extends StatelessWidget {
  const BluetoothTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("权限测试"),
      ),
      body: Builder(
        builder: (context) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MaterialButton(
                  onPressed: () {

                  },
                  child: const Text("lanya"),
                ),
                MaterialButton(
                  onPressed: () {

                  },
                  child: const Text("进入蓝牙测试界面"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
