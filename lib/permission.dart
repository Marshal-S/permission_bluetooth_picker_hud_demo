import 'package:flutter_progress_hud/flutter_progress_hud.dart';
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
                      denied, //没授权默认是这个，也保不准那个是表示拒绝的，最好是先请求权限后用于判断
                      granted, //正常使用
                      restricted, //被操作系统拒绝，例如家长控制等
                      limited, //被限制了部分功能，适用于部分权限，例如相册的
                      permanentlyDenied, //这个权限表示永久拒绝，不显示弹窗，用户可以手动调节（也有可能是系统关闭了该权限导致的）
                      */
                      //提前请求权限，如果没给过权限，可以触发权限，以便于获取权限信息
                      final status = await Permission.camera.request();
                      //可以同时请求多个 await
                      print(status);
                      //直接
                      final statuss = await Permission.camera.status;
                      print(statuss);
                      return;
                      _picker.pickImage(source: ImageSource.camera).then((value) {
                        print(value);
                      }).catchError((error) {
                        print(error);
                        //可以请求用失败的时候在提示权限问题，或者打开授权页面
                        Permission.camera.status.then((status) {
                          print(status);
                          if (status == PermissionStatus.denied) {
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
                    onPressed: () async {
                      _picker.pickImage(source: ImageSource.gallery).then((value) {
                        print(value);
                      }).catchError((error) {
                        //注意相册使用的是这个权限，而不是媒体库
                        Permission.photos.status.then((status) {
                          print(status);
                          if (status == PermissionStatus.denied) {
                            //拒绝，可以跳转权限页面
                            showToast(context, "相册权限被拒绝");
                          }else if (status == PermissionStatus.granted) {
                            //正常访问
                            showToast(context, "相册权限可以正常使用");
                          }
                        });
                      });
                    },
                    child: const Text("测试媒体库相册权限"),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      //查看相册，如果只是添加，可以采用 photosAddOnly
                      Map<Permission, PermissionStatus> statuses = await [
                        Permission.mediaLibrary,
                      ].request();
                      print(statuses);

                      Permission.mediaLibrary.status.then((status) {
                        print(status);
                        if (status == PermissionStatus.denied) {
                          //拒绝，可以跳转权限页面
                          showToast(context, "媒体库权限被拒绝");
                        }else if (status == PermissionStatus.granted) {
                          //正常访问
                          showToast(context, "媒体库权限可以正常使用");
                        }
                      });
                      //查看相册，如果只是添加，可以采用 photosAddOnly
                      // Permission.photos.status.then((status) {
                      //   print(status);
                      //   if (status == PermissionStatus.denied) {
                      //     //拒绝
                      //     showToast(context, "相册权限被拒绝");
                      //   }else if (status == PermissionStatus.granted) {
                      //     //正常访问
                      //     showToast(context, "相机权限可以正常使用");
                      //   }
                      // });
                    },
                    child: const Text("测试图片资源权限(和媒体库不是一个，这个访问全部,可以写入照片)"),
                  ),
                  MaterialButton(
                    onPressed: () {
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
                      Permission.bluetooth.status.then((status) {
                        print(status);
                        if (status == PermissionStatus.denied) {
                          //拒绝
                          showToast(context, "蓝牙权限被拒绝");
                        }else if (status == PermissionStatus.granted) {
                          //正常访问
                          showToast(context, "蓝牙权限可以正常使用");
                        }
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
