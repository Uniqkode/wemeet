import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wemeet/allConstants/color_constants.dart';
import 'package:wemeet/allConstants/constants.dart';
import 'package:wemeet/allModels/user_chat.dart';
import 'package:wemeet/allProviders/settings_provider.dart';
import 'package:wemeet/allWidgets/widgets.dart';

import '../allConstants/app_constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.settingsTitle,
          style: TextStyle(color: ColorConstants.primaryColor),
        ),
        centerTitle: true,
      ),
      body: const SettingsPageState(),
    );
  }
}

class SettingsPageState extends StatefulWidget {
  const SettingsPageState({Key? key}) : super(key: key);

  @override
  State<SettingsPageState> createState() => _SettingsPageStateState();
}

class _SettingsPageStateState extends State<SettingsPageState> {
  TextEditingController? controllerNickname;
  TextEditingController? controllerAboutme;

  String dialCodeDigits = '+00';
  final TextEditingController _controller = TextEditingController();

  String id = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';
  String phoneNumber = '';

  bool isLoading = false;
  File? avatarImageFile;
  late SettingsProvider settingsProvider;

  final FocusNode focusNodeNickname = FocusNode();
  final FocusNode focusNodeAboutme = FocusNode();

  @override
  void initState() {
    super.initState();
    settingsProvider = context.read<SettingsProvider>();
    readLocal();
  }

  void readLocal() {
    setState(() {
      id = settingsProvider.getPref(FirestoreConstants.id) ?? '';
      nickname = settingsProvider.getPref(FirestoreConstants.nickname) ?? '';
      aboutMe = settingsProvider.getPref(FirestoreConstants.aboutMe) ?? '';
      photoUrl = settingsProvider.getPref(FirestoreConstants.photoUrl) ?? '';
      phoneNumber =
          settingsProvider.getPref(FirestoreConstants.phoneNumber) ?? '';
    });

    controllerNickname = TextEditingController(text: nickname);
    controllerAboutme = TextEditingController(text: aboutMe);
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile = await imagePicker
        .pickImage(source: ImageSource.gallery)
        .catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
    File? image;
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = id;
    UploadTask uploadTask =
        settingsProvider.uploadTask(avatarImageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      photoUrl = await snapshot.ref.getDownloadURL();
      UserChat updateInfo = UserChat(
          id: id,
          aboutMe: aboutMe,
          nickname: nickname,
          photoUrl: photoUrl,
          phoneNumber: phoneNumber);
      settingsProvider
          .updateDataFirestore(
              FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
          .then((data) async {
        await settingsProvider.setPref(FirestoreConstants.photoUrl, photoUrl);
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'Upload Successful');
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: err.toString());
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void handleUpdateData() {
    focusNodeAboutme.unfocus();
    focusNodeNickname.unfocus();

    setState(() {
      isLoading = true;
    });
    UserChat updateInfo = UserChat(
        id: id,
        aboutMe: aboutMe,
        nickname: nickname,
        photoUrl: photoUrl,
        phoneNumber: phoneNumber);
    settingsProvider
        .updateDataFirestore(
            FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
        .then((data) async {
      await settingsProvider.setPref(FirestoreConstants.nickname, nickname);
      await settingsProvider.setPref(FirestoreConstants.aboutMe, aboutMe);
      await settingsProvider.setPref(FirestoreConstants.photoUrl, photoUrl);
      await settingsProvider.setPref(
          FirestoreConstants.phoneNumber, phoneNumber);
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Upload Successful');
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              CupertinoButton(
                onPressed: getImage,
                child: Container(
                    margin: const EdgeInsets.all(20),
                    child: avatarImageFile == null
                        ? photoUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(45),
                                child: Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                  width: 90,
                                  height: 90,
                                  errorBuilder: (context, object, stackTrace) {
                                    return const Icon(
                                      Icons.account_circle,
                                      size: 90,
                                      color: ColorConstants.greyColor,
                                    );
                                  },
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(
                                      width: 90,
                                      height: 90,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            color: ColorConstants.themeColor,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.account_circle,
                                size: 90,
                                color: ColorConstants.greyColor,
                              )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(45),
                            child: Image.file(
                              avatarImageFile!,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          )),
              ),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 10, bottom: 5, top: 10),
                    child: const Text(
                      'Nickname',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.primaryColor),
                    ),
                  ),

                  // InputField
                  Container(
                    margin: const EdgeInsets.only(left: 30, right: 30),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: ColorConstants.primaryColor),
                      child: TextField(
                        decoration: const InputDecoration(
                            hintText: 'Sweetie',
                            contentPadding: EdgeInsets.all(5),
                            hintStyle:
                                TextStyle(color: ColorConstants.greyColor)),
                        controller: controllerNickname,
                        onChanged: (value) {
                          nickname = value;
                        },
                        focusNode: focusNodeNickname,
                      ),
                    ),
                  ),
                  // About me
                  Container(
                    margin: const EdgeInsets.only(
                      left: 10,
                      top: 5,
                      bottom: 10,
                    ),
                    child: const Text(
                      'About me',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.primaryColor),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 30, right: 30),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: ColorConstants.primaryColor),
                      child: TextField(
                        decoration: const InputDecoration(
                            hintText: 'Fun, like, travel, ....',
                            contentPadding: EdgeInsets.all(5),
                            hintStyle:
                                TextStyle(color: ColorConstants.greyColor)),
                        controller: controllerAboutme,
                        onChanged: (value) {
                          aboutMe = value;
                        },
                        focusNode: focusNodeAboutme,
                      ),
                    ),
                  ),

                  // Button

                  Container(
                    margin: const EdgeInsets.only(left: 15, right: 50),
                    child: TextButton(
                      onPressed: handleUpdateData,
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              ColorConstants.primaryColor),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.fromLTRB(
                            30,
                            10,
                            30,
                            10,
                          ))),
                      child: const Text(
                        'Update',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        // Loading
        Positioned(
          child: isLoading ? const LoadingView() : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
