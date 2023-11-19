import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lets_chat/services/database_service.dart';
import 'package:lets_chat/services/navigation_service.dart';
import 'package:lets_chat/widgets/rounded_image.dart';
import 'package:provider/provider.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';
import '../providers/authentication_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  File? _profileImage;
  late AuthenticationProvider _auth;
  late DatabaseService _db;
  late CloudStorageService _cloudStorage;
  late NavigationService _navigation;
  String? _email;
  String? _password;
  String? _name;
  final _registerFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _db = GetIt.instance.get<DatabaseService>();
    _auth = Provider.of<AuthenticationProvider>(context);
    _cloudStorage = GetIt.instance.get<CloudStorageService>();
    _navigation = GetIt.instance.get<NavigationService>();
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: _deviceWidth * 0.03, vertical: _deviceHeight * 0.02),
          height: _deviceHeight * 0.98,
          width: _deviceWidth * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _profileImageField(),
              SizedBox(
                height: _deviceHeight * 0.05,
              ),
              _registerForm(),
              SizedBox(
                height: _deviceHeight * 0.05,
              ),
              _registerButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileImageField() {
    return GestureDetector(
      onTap: () async {
        GetIt.instance
            .get<MediaService>()
            .pickImageFromLibrary()
            .then((_file) => {
          setState(() {
            _profileImage = _file;
          })
        });
      },
      child: _buildProfileImage(),
    );
  }

  Widget _buildProfileImage() {
    if (_profileImage != null) {
      return RoundedImageFile(
        key: UniqueKey(),
        image: _profileImage!,
        size: _deviceHeight * 0.15,
      );
    } else {
      return RoundedImageNetwork(
        key: UniqueKey(),
        imagePath: "https://i.pravatar.cc/150?img=65",
        size: _deviceHeight * 0.15,
      );
    }
  }

  Widget _registerForm() {
    return Container(
      height: _deviceHeight * 0.35,
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextFormField(
                onSaved: (_value) {
                  setState(() {
                    _name = _value;
                  });
                },
                regEx: r'.{8,}',
                hintText: "Name",
                obscureText: false),
            CustomTextFormField(
                onSaved: (_value) {
                  setState(() {
                    _email = _value;
                  });
                },
                regEx:
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                hintText: "Email",
                obscureText: false),
            CustomTextFormField(
                onSaved: (_value) {
                  setState(() {
                    _password = _value;
                  });
                },
                regEx: r'.{8,}',
                hintText: "Password",
                obscureText: true),
          ],
        ),
      ),
    );
  }

  // Updated _registerButton method
  Widget _registerButton() {
    return FutureBuilder(
      future: _registerUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return RoundedButton(
            name: "Register",
            height: _deviceHeight * 0.065,
            width: _deviceWidth * 0.65,
            onPressed: () async {
              // Check if registration is already in progress
              if (snapshot.connectionState != ConnectionState.waiting) {
                await _registerUser();
              }
            },
          );
        }
      },
    );
  }

  // Updated _registerUser method
  Future<void> _registerUser() async {
    if (_registerFormKey.currentState!.validate() && _profileImage != null) {
      _registerFormKey.currentState!.save();
      // Show loading state
      setState(() {});

      try {
        String? _uid =
        await _auth.registerUserUsingEmailAndPassword(_email!, _password!);
        String? _imageURL =
        await _cloudStorage.saveUserImageToStorage(_uid!, _profileImage!);
        await _db.createUser(_uid, _email!, _name!, _imageURL!);
        await _auth.logout();
        await _auth.loginUsingEmailAndPassword(_email!, _password!);
        _navigation.goBack();
      } catch (error) {
        // Handle registration error
        print(error);
        // Optionally show an error message or handle the error in UI
      }
    }
  }
}
