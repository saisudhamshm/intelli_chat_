import 'package:intelli_chat/screens/login_screen.dart';
import 'package:intelli_chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:intelli_chat/components/rounded_button.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';

  const WelcomeScreen({super.key});
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);
    controller.forward();

    controller.addListener(() {
      setState(() {});
    });
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: <Widget>[
                          Hero(
                            tag: 'logo',
                            child: SizedBox(
                              height: 85.0,
                              child: Image.asset('images/split.jpg'),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          FittedBox(
                            fit:  BoxFit.fitWidth,
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  'IntelliChat',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .copyWith(
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                  speed: const Duration(milliseconds: 300),
                                ),
                              ],
                              totalRepeatCount: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 48.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.04),
                      child: RoundedButton(
                        text: 'Login',
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.7),
                        onClick: () {
                          Navigator.pushNamed(context, LoginScreen.id);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.04),
                      child: RoundedButton(
                          text: 'Register',
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.7),
                          onClick: () {
                            //Go to registration screen.
                            Navigator.pushNamed(context, RegistrationScreen.id);
                          }),
                    ),
                  ]))),
    );
  }
}
