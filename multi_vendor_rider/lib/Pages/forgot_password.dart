import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:rider/Providers/auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String email = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  final RoundedLoadingButtonController _btnController1 =
      RoundedLoadingButtonController();

  void _doSomething(
    RoundedLoadingButtonController controller,
    String email,
    BuildContext context,
  ) async {
    AuthService().forgotPassword(context, email).then((value) {
      if (AuthService().forgotPasswordStatus == true) {
        controller.success();
      } else {
        controller.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text(
              'Login',
            ).tr(),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 5,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('Please type in your email Address'.tr(),
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Flexible(
                            flex: 1,
                            child: Icon(
                              Icons.email_outlined,
                              size: 40,
                              color: Colors.grey,
                            )),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          flex: 6,
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Required field'.tr();
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {
                              setState(() {
                                email = value;
                              });
                            },
                            decoration: InputDecoration(
                                hintText: 'Email'.tr(),
                                focusColor: Colors.orange),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 10),
                  RoundedLoadingButton(
                    color: Colors.blue,
                    successIcon: Icons.done,
                    failedIcon: Icons.error,
                    controller: _btnController1,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _doSomething(
                          _btnController1,
                          email,
                          context,
                        );
                      } else {
                        _btnController1.reset();
                      }
                    },
                    child: const Text('Submit',
                            style: TextStyle(color: Colors.white))
                        .tr(),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: ClipPath(
                clipper: OvalTopBorderClipper(),
                child: Container(
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
