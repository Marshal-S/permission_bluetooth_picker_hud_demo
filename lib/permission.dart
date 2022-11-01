import 'dart:typed_data';

import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionTestWidget extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();
  PermissionTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("蓝牙测试"),
      ),
      body: ProgressHUD(
        child: Builder(
          builder: (context) {
            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MaterialButton(
                    onPressed: () async {
                      //常见的有下面几种状态
                      /*
                      denied, //没授权默认是这个，也保不准特殊情况是表示拒绝的，最好是先请求权限后用于判断
                      granted, //正常使用
                      restricted, //被操作系统拒绝，例如家长控制等
                      limited, //被限制了部分功能，适用于部分权限，例如相册的
                      permanentlyDenied, //这个权限表示永久拒绝，不显示弹窗，用户可以手动调节（也有可能是系统关闭了该权限导致的）
                      */
                      //提前请求权限，如果没给过权限，可以触发权限，以便于获取权限信息
                      final status = await Permission.camera.request();
                      //可以同时请求多个 await
                      if (status != PermissionStatus.granted) {
                        //无相机权限，请前往设置打开
                        //openAppSettings();
                        return;
                      }
                      print(status);
                      _picker.pickImage(source: ImageSource.camera).then((value) {
                        print(value);
                      }).catchError((error) {
                        print(error);
                        //可以请求用失败的时候在提示权限问题，或者打开授权页面
                        Permission.camera.status.then((status) {
                          print(status);
                          if (status == PermissionStatus.denied || status == PermissionStatus.permanentlyDenied) {
                            //拒绝，可以跳转权限页面
                            showToast(context, "相机权限被拒绝");
                          }else if (status == PermissionStatus.granted) {
                            //正常访问
                            showToast(context, "相机权限可以正常使用");
                          }
                        });
                      });
                    },
                    child: const Text("测试相机权限"),
                  ),
                  MaterialButton(
                    onPressed: () {
                      //也可以先访问，失败后在查看权限，不是所有库都能这么做，最好先判断
                      _picker.pickImage(source: ImageSource.gallery).then((value) {
                        print(value);
                      }).catchError((error) {
                        //注意相册使用的是这个权限，而不是媒体库
                        Permission.photos.status.then((status) {
                          print(status);
                          if (status == PermissionStatus.denied || status == PermissionStatus.permanentlyDenied) {
                            //拒绝，可以跳转权限页面
                            showToast(context, "相册权限被拒绝");
                          }else if (status == PermissionStatus.granted) {
                            //正常访问
                            showToast(context, "相册权限可以正常使用");
                          }
                        });
                      });
                    },
                    child: const Text("测试写入图片权限"),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      //查看相册，如果只是添加，可以采用 photosAddOnly(这里测试同时请求多个的方法)
                      Map<Permission, PermissionStatus> statuses = await [
                        Permission.photosAddOnly,
                        Permission.photos
                      ].request();
                      print(statuses);
                      if (statuses[Permission.photosAddOnly] != PermissionStatus.granted) {
                        //写入相册权限被拒绝
                        print("写入相册权限被拒绝");
                        return;
                      }
                      // final data = await http.get('imgurl')
                      // final result = await ImageGallerySaver.saveImage(
                      //     Uint8List.fromList(data), //data图片字节数组
                      //     quality: 60, //压缩质量 0~100
                      //     name: "hello"//名字
                      // );
                      Permission.photosAddOnly.status.then((status) {
                        print(status);
                        if (status == PermissionStatus.denied || status == PermissionStatus.permanentlyDenied) {
                          //拒绝，可以跳转权限页面
                          showToast(context, "写入相册权限被拒绝");
                        }else if (status == PermissionStatus.granted) {
                          //正常访问
                          showToast(context, "可以正常使用写入相册");
                        }
                      });
                    },
                    child: const Text("写入相册权限"),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      await Permission.locationWhenInUse.request();

                      Permission.locationWhenInUse.status.then((status) {
                        print(status);
                        if (status == PermissionStatus.denied) {
                          //拒绝
                          showToast(context, "定位权限被拒绝");
                        }else if (status == PermissionStatus.granted) {
                          //正常访问
                          showToast(context, "定位权限可以正常使用");
                        }
                      });
                    },
                    child: const Text("测试定位权限"),
                  ),
                  MaterialButton(
                    onPressed: () {
                      //在android蓝牙分为多个权限，都要动态申请,因此就一起申请了即可
                      [Permission.bluetoothScan, Permission.bluetoothConnect, Permission.bluetooth].request().then((status) {
                        print(status);
                      });
                    },
                    child: const Text("进入蓝牙测试界面"),
                  ),
                  MaterialButton(
                    onPressed: () {
                      openAppSettings();
                    },
                    child: const Text("跳转权限页面"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void showToast(BuildContext context, String text) {
    ProgressHUD.of(context)?.showWithText(text);
    Future.delayed(const Duration(seconds: 2), () {
      ProgressHUD.of(context)?.dismiss();
    });
  }
}
