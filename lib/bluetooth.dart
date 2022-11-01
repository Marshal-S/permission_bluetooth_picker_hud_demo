import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

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

  final FlutterBlue _bluetooth =  FlutterBlue.instance;
  BluetoothCharacteristic? _currentCharacteristic;

  String reviceText = "";

  @override
  void initState() {
    super.initState();
    //请求一下权限，某些机型蓝牙默认可以直接使用，无需权限，但是权限会反馈被拒绝状态
    //因此一些机型，可以请求后给出继续向后执行的弹窗，避免用户永远无法使用该功能，失败了注意反馈即可
    [Permission.bluetoothScan, Permission.bluetoothConnect, Permission.bluetooth].request().then((status) {
      print(status);
      //只会有一个弹窗，android端多个权限，但一般一般显示了一个就结束了，主要看ios的
      //android端注意定位权限, Permission.locationWhenInUse 即可
      if (status[Permission.bluetooth] != PermissionStatus.granted) {
        print("没有蓝牙权限"); //这一个是都有的，可以用这个判断，当然最好分平台判断
      }
    });
  }

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
  void startConnectDevice({isRepeat = false}) {
    bool isSearched = false; //为了避免连接过程中没有停止扫描导致的多次连接问题，但不得不连接后在取消扫描
    try {
      _bluetooth.scanResults.listen((results) async {
        //扫描回调，try-catch是统一处理里面的失败情况
        if (isSearched) return; //已经找到了就结束
        for (ScanResult res in results) {
          final device = res.device;
          //检查是否是我们需要的设备，device.name有时候不一定会有,最好使用advertisementData.localName
          final name = res.advertisementData.localName;
          if (name != "") print(name);
          if (!isSearched && name.contains("marshal_")) {
            print("找到了我们需要的设备");
            isSearched = true; //标记已经找到了
            //找到了我们要连接的设备,并连接,autoConnect需要设置为 false，默认为true其不会自动连接
            print("开始连接");
            //鸿蒙这个 autoConnect 会一次也连接不上，设置为 false 则会出现时而连得上时而连不上，支持不太好，根据情况选择
            await device.connect(timeout: const Duration(seconds: 10), autoConnect: true);
            print("连接成功");
            // 连接成功后停止扫描，据说有些android手机停止扫描会出现连接功能异常，连接成功后在停止扫描
            await _bluetooth.stopScan();
            //开始查找服务
            print("开始查找服务");
            List<BluetoothService> services = await device.discoverServices();
            //遍历服务使用我们想要的特征值
            print("遍历服务找特征值");
            print(services.length);
            services.forEach((service) async {
              var characteristics = service.characteristics;
              //找我们的特征值
              for(BluetoothCharacteristic char in characteristics) {
                print(char.uuid.toString());
                //通过uuid过滤出我们需要的特征值
                if (char.uuid.toString().substring(0, 2) == "12") {
                  print("找到我们特征值");
                  //假设我们用这个,获取到特征值后保存，可以用来读写
                  _currentCharacteristic = char;
                  await setNotifiy();//设置通知，可以接收传递过来的消息
                  await readMessage(); //随便读取一下消息吧
                }
              }
            });
          }
        }
      });
    }catch(error) {
      print(error);
      isSearched = false;
      print('一般连接失败后会走这里，然后停止扫描');
      _bluetooth.stopScan();
    }

    print("开始扫描");
    _bluetooth.startScan(scanMode: ScanMode.balanced, timeout: const Duration(seconds: 30),);
  }

  Future<void> setNotifiy() async {
    //可以监听外设端主动发送过来的消息
    await _currentCharacteristic!.setNotifyValue(true);
    _currentCharacteristic!.value.listen((event) {
      print(event);
    });
  }

  //读取外设消息
  Future<void> readMessage() async {
    if (_currentCharacteristic == null) return;

    List<int> value = await _currentCharacteristic!.read();
    print("value");
    print(value);
    final string = utf8.decode(value);
    setState(() {
      reviceText = string;
    });
    print(string);
  }

  //向外设发送消息
  void sendMessage(String text) {
    print(text);
    _controller.clear();
    _controller.text = '';
    _currentCharacteristic?.write(utf8.encode(text)).then((value) => print(value));
  }
}
