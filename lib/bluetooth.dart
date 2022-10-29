import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

const String serviceUUID = "11000000-0000-0000-0000-818282828282";
const String characterUUID = "12000000-0000-0000-0000-000000000000";
const String writeCharacterUUID = "13000000-0000-0000-0000-000000000000";

class BluetoothTestWidget extends StatefulWidget {
  const BluetoothTestWidget({Key? key}) : super(key: key);

  @override
  State<BluetoothTestWidget> createState() => _BluetoothTestWidgetState();
}

class _BluetoothTestWidgetState extends State<BluetoothTestWidget> {
  //为TextField代理,可以用来清除数据，设置更新text等
  final TextEditingController _controller = TextEditingController();

  final FlutterBlue _bluetooth = FlutterBlue.instance;
  BluetoothCharacteristic? _currentCharacteristic;

  String reviceText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("权限测试"),
      ),
      body: Builder(
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("中心设备(连接别的蓝牙设备)", style: TextStyle(color: Colors.black, fontSize: 20)),
                  Row(
                    children: <Widget>[
                      MaterialButton(
                        onPressed: startConnectDevice,
                        child: const Text("扫描并连接设备"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _controller,
                            keyboardType: TextInputType.text,
                            // textInputAction: TextInputAction.next,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              hintText: "请输入手机号", //占位符
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ), //去掉底部很丑的线条
                              contentPadding: EdgeInsets.only(left: 5), //设置内边距
                            ),
                            onSubmitted: sendMessage,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      MaterialButton(
                        onPressed: () {
                          sendMessage(_controller.text);
                        },
                        child: const Text("发送消息"),
                      ),
                      MaterialButton(
                        onPressed: readMessage,
                        child: const Text("读取消息"),
                      ),
                    ],
                  ),
                  const Text("接收到的消息", style: TextStyle(color: Colors.black, fontSize: 20)),
                  Text(
                    reviceText,
                    softWrap: true,
                    style: const TextStyle(color: Colors.black38, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  //开始扫描并连接设备
  void startConnectDevice() {
    print("开始扫描");
    _bluetooth.startScan(scanMode: ScanMode.balanced, timeout: const Duration(seconds: 30),);
    bool isSearched = false; //为了避免连接过程中没有停止扫描导致的多次连接问题，但不得不连接后在取消扫描
    _bluetooth.scanResults.listen((results) async {
      //扫描回调，try-catch是统一处理里面的失败情况
      if (isSearched) return; //已经找到了就结束
      try {
        for (ScanResult res in results) {
          final device = res.device;
          //检查是否是我们需要的设备
          if (device.name != "") print(device.name);
          if (!isSearched && device.name.contains("marshal_")) {
            print("找到了我们需要的设备");
            isSearched = true; //标记已经找到了
            //找到了我们要连接的设备,并连接
            await device.connect(timeout: const Duration(seconds: 10),);
            print("连接成功");
            //连接成功后停止扫描，有些手机停止扫描会出现功能异常，连接成功后在断开连接
            _bluetooth.stopScan();
            //开始查找服务
            print("开始查找服务");
            List<BluetoothService> services = await device.discoverServices();
            //遍历服务使用我们想要的特征值
            print("遍历服务找特征值");
            services.forEach((service) async {
              var characteristics = service.characteristics;
              //找我们的特征值
              for(BluetoothCharacteristic char in characteristics) {
                //通过uuid过滤出我们需要的特征值
                if (char.uuid.toString().contains("12")) {
                  print("找到特征值");
                  //假设我们用这个,获取到特征值后保存，可以用来读写
                  _currentCharacteristic = char;
                  readMessage();
                }
              }
            });
          }
        }
      }catch(error) {
        print(error);
      }
    });
  }

  Future<void> readMessage() async {
    if (_currentCharacteristic == null) return;

    List<int> value = await _currentCharacteristic!.read();
    final string = String.fromCharCodes(value);
    _controller.text = string;
    print(string);
  }

  //发送消息
  void sendMessage(String text) {
    print(text);
    _controller.clear();
    _controller.text = '';
    _currentCharacteristic?.write(utf8.encode(text));
  }
}
