import 'package:flutter/material.dart';

class BluetoothTestWidget extends StatefulWidget {
  const BluetoothTestWidget({Key? key}) : super(key: key);

  @override
  State<BluetoothTestWidget> createState() => _BluetoothTestWidgetState();
}

class _BluetoothTestWidgetState extends State<BluetoothTestWidget> {
  //为TextField代理,可以用来清除数据，设置更新text等
  final TextEditingController _controller = TextEditingController();

  bool isAdvertise = false; //是否是广播端，默认为外设端
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
            child: isAdvertise ? getAdvertiseWidget() : getPeripheralWidget(),
          );
        },
      ),
    );
  }

  //开始广播
  void startAdvertise() {
    
  }

  //开始连接设备
  void startConnectDevice() {

  }

  void sendMessage(String text) {
    print(text);

    _controller.clear();
    _controller.text = '';
  }

  //获取广播端Widget
  Widget getAdvertiseWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("广播端(被连接端)", style: TextStyle(color: Colors.black, fontSize: 20)),
        Row(
          children: <Widget>[
            MaterialButton(
              onPressed: () {
                setState(() {
                  isAdvertise = true;
                });
              },
              child: const Text("点击切换外设端"),
            ),
            MaterialButton(
              onPressed: () {

              },
              child: const Text("开始广播"),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            TextField(
              controller: _controller,
              keyboardType: TextInputType.text,
              // textInputAction: TextInputAction.next,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: "请输入手机号",//占位符
                border: InputBorder.none, //去掉底部很丑的线条
                contentPadding: EdgeInsets.only(left: 5),//设置内边距
              ),
              onSubmitted: sendMessage,
            ),

            MaterialButton(
              onPressed: () {
                sendMessage(_controller.text);
              },
              child: const Text("发送消息"),
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
    );
  }

  //获取外设Widget
  Widget getPeripheralWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("外设端(连接别的蓝牙设备)", style: TextStyle(color: Colors.black, fontSize: 20)),

        Row(
          children: <Widget>[
            MaterialButton(
              onPressed: () {
                setState(() {
                  isAdvertise = true;
                });
              },
              child: const Text("点击切换广播端"),
            ),
            MaterialButton(
              onPressed: () {

              },
              child: const Text("连接设备"),
            ),
          ],
        ),

        Row(
          children: <Widget>[
            TextField(
              controller: _controller,
              keyboardType: TextInputType.text,
              // textInputAction: TextInputAction.next,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: "请输入手机号",//占位符
                border: InputBorder.none, //去掉底部很丑的线条
                contentPadding: EdgeInsets.only(left: 5),//设置内边距
              ),
              onSubmitted: sendMessage,
            ),

            MaterialButton(
              onPressed: () {
                sendMessage(_controller.text);
              },
              child: const Text("发送消息"),
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
    );
  }
}
