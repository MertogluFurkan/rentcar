// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'signin.dart';

class MyCustomLogin extends StatefulWidget {
  const MyCustomLogin({super.key});

  @override
  _MyCustomLoginState createState() => _MyCustomLoginState();
}

class _MyCustomLoginState extends State<MyCustomLogin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordAgainController =
      TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: .7, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    )
      ..addListener(
        () {
          setState(() {});
        },
      )
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed) {
            _controller.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _controller.forward();
          }
        },
      );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters';
    } else if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least 1 uppercase letter';
    } else if (value.replaceAll(RegExp(r'[0-9]'), '').length <= 2) {
      return 'Password must contain at least 2 special characters';
    } else if (value.replaceAll(RegExp(r'[^0-9]'), '').length < 3) {
      return 'Password must contain at least 3 digits';
    }
    return null;
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.grey),
              SizedBox(height: 20),
              Text(
                "SIGN UP...",
                style: TextStyle(fontFamily: "kanitm"),
              ),
            ],
          ),
        );
      },
    );
  }

  void hideLoadingDialog() {
    Navigator.of(context).pop();
  }

  Future<void> kayitOl() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;
      final adSoyad = _nameController.text;

      try {
        showLoadingDialog(); 

        final auth = FirebaseAuth.instance;
        final UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final User? user = userCredential.user;

        final kullaniciUid = user?.uid;

        final usersCollection = FirebaseFirestore.instance.collection('users');

        if (!(await usersCollection.doc(kullaniciUid).get()).exists) {
          await usersCollection.doc(kullaniciUid).set({
            'adSoyad': adSoyad,
            'email': email,
            'kullaniciUid': kullaniciUid,
          });
        }

        hideLoadingDialog(); // Yüklenme göstergesini gizle

        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (_) => const MyCustomLoginUI(),
          ),
        );
      } catch (e) {
        hideLoadingDialog();
        debugPrint(e.toString());
        Fluttertoast.showToast(
            msg:
                "The registration has failed. Please check your internet connection and make sure to enter a valid email address",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xff292C31),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: SingleChildScrollView(
          child: SizedBox(
            height: height,
            child: Form(
              autovalidateMode: _autovalidateMode,
              key: _formKey,
              child: Column(
                children: [
                  const Expanded(child: SizedBox()),
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(),
                        const Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: Color(0xffA9DED8),
                            fontFamily: "degularb"
                          ),
                        ),
                        const SizedBox(),
                        component1(Icons.email_outlined, 'Name-Surname', false,
                            true, _nameController, (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your Name-Surname';
                          }
                          return null;
                        }),
                        component1(Icons.email_outlined, 'Email...', false,
                            true, _emailController, (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        }),
                        component1(Icons.lock_outline, 'Password...', true,
                            false, _passwordController, passwordValidator),
                        component1(Icons.lock_outline, 'Password Again', true,
                            false, _passwordAgainController, (value) {
                          if (value!.isEmpty) {
                            return 'Please re-enter your password';
                          } else if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Have a Account Log In',
                                style:
                                    const TextStyle(color: Color(0xffA9DED8)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushReplacement(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              const MyCustomLoginUI()),
                                    );
                                  },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(bottom: width * .07),
                            height: width * .7,
                            width: width * .7,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  Color(0xff09090A),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Transform.scale(
                            scale: _animation.value,
                            child: Consumer(builder: (context, ref, child) {
                              return InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  if (_formKey.currentState != null &&
                                      _formKey.currentState!.validate()) {
                                    await kayitOl();
                                  } else {
                                    setState(() {
                                      _autovalidateMode =
                                          AutovalidateMode.always;
                                    });
                                  }
                                },
                                child: Container(
                                  height: width * .2,
                                  width: width * .2,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Color(0xffA9DED8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    'SIGN-UP',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget component1(
      IconData icon,
      String hintText,
      bool isPassword,
      bool isEmail,
      TextEditingController controller,
      String? Function(String?)? validator) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      height: width / 8,
      width: width / 1.22,
      alignment: Alignment.center,
      padding: EdgeInsets.only(right: width / 30),
      decoration: BoxDecoration(
        color: const Color(0xff212428),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.white.withOpacity(.9)),
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(.7),
          ),
          border: InputBorder.none,
          hintMaxLines: 1,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(.5),
          ),
        ),
      ),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
