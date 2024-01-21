// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/controller/auth_controller.dart';
import '../homepage.dart';
import 'singup.dart';

class MyCustomLoginUI extends StatefulWidget {
  const MyCustomLoginUI({super.key});

  @override
  _MyCustomLoginUIState createState() => _MyCustomLoginUIState();
}

class _MyCustomLoginUIState extends State<MyCustomLoginUI>
    with SingleTickerProviderStateMixin {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late Animation<double> _animation;
  late AnimationController _controller;
  final _formkey = GlobalKey<FormState>();
  late bool _rememberMe;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    emailController = TextEditingController();
    passwordController = TextEditingController();
    _rememberMe = false;
    _checkRememberMe();
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
                "LOG IN...",
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

  Widget component1(
    IconData icon,
    String hintText,
    bool isPassword,
    bool isEmail,
    TextEditingController controller,
  ) {
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
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white.withOpacity(.9)),
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
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

  void _checkRememberMe() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool rememberMe = prefs.getBool('rememberMe') ?? false;
    if (rememberMe) {
      final String? email = prefs.getString('email');
      final String? password = prefs.getString('password');
      if (email != null && password != null) {
        emailController.text = email;
        passwordController.text = password;
        _rememberMe = true;
      }
    }
  }

  Future<void> _saveRememberMe() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', _rememberMe);
    if (_rememberMe) {
      await prefs.setString('email', emailController.text);
      await prefs.setString('password', passwordController.text);
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
                        'LOG IN',
                        style: TextStyle(
                          fontFamily: "degularb",
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Color(0xffA9DED8),
                        ),
                      ),
                      const SizedBox(),
                      Form(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        key: _formkey,
                        child: component1(Icons.email_outlined, 'Email...',
                            false, true, emailController),
                      ),
                      component1(Icons.lock_outline, 'Password...', true, false,
                          passwordController),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: CheckboxListTile(
                          title: const Text(
                            "Remember Me",
                            style: TextStyle(
                                fontFamily: "josefin", color: Colors.white54),
                          ),
                          value: _rememberMe,
                          onChanged: (newValue) {
                            setState(() {
                              _rememberMe = newValue!;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Create a new Account',
                              style: const TextStyle(color: Color(0xffA9DED8)),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            const MyCustomLogin()),
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
                                if (_formkey.currentState!.validate()) {
                                  try {
                                    showLoadingDialog();
                                    await ref
                                        .read(authControllerProvider)
                                        .signInWithEmailAndPassword(
                                            email: emailController.text,
                                            password: passwordController.text);

                                    _saveRememberMe();
                                    hideLoadingDialog();
                                    // ignore: use_build_context_synchronously
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (_) => const Discover()),
                                        (route) => false);
                                  } catch (e) {
                                    debugPrint(e.toString());
                                    hideLoadingDialog();
                                    // Hata durumunda FlutterToast ile uyarı göster
                                    Fluttertoast.showToast(
                                        msg: "Kullanıcı adı veya şifre hatalı",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  }
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
                                  'LOG-IN',
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
    );
  }
}

class MyBehavior extends ScrollBehavior {
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
