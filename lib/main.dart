import 'package:flutter/material.dart';
import 'package:permission_bluetooth_picker_hud_demo/bluetooth.dart';
import 'package:permission_bluetooth_picker_hud_demo/permission.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("权限与蓝牙"),
      ),
      body: Builder(
        builder: (context) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => PermissionTestWidget()));
                  },
                  child: const Text("进入测试权限界面",),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const BluetoothTestWidget()));
                  },
                  child: const Text("进入蓝牙测试界面",),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
