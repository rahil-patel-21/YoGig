import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yogigg_users_app/bloc/sign_up_bloc/sign_up_bloc.dart';
import 'package:yogigg_users_app/constants/colors.dart';
import 'package:yogigg_users_app/constants/common_widget.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:yogigg_users_app/constants/styles.dart';
import 'package:yogigg_users_app/utils/router_constants.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool showPassword = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  final _emailPasswordFormKey = GlobalKey<FormState>();

  SignUpBloc _signUpBloc = SignUpBloc();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark
      ),
          child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: getNoAppBarTheme(context),
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        extendBody: true,
        
        body: Container(
          
          padding: EdgeInsets.only(left: 24, right:24, bottom: 24),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            accentColor1,
            accentColor3,
          ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: SafeArea(
            child: BlocConsumer<SignUpBloc,SignUpState>(
              cubit: _signUpBloc,
              builder: (context, state) {
                if (state is SignUpInitial || state is SignUpErrorState) {
                  return Container(
                    
                    height: context.screenHeight,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                                                child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    height: context.screenHeight * 0.07,
                                    alignment: Alignment.topRight,
                                    child: Hero(
                                        tag: 'logo_image',
                                        child: Image.asset(
                                            'assets/images/logo_shadow.png')),
                                  ),
                                  Text(
                                    'Welcome!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline3
                                        .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Best Brands. Best Ambassadors.',
                                    style:
                                        Theme.of(context).textTheme.bodyText1.copyWith(
                                              color: Colors.grey,
                                            ),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Form(
                                    key: _emailPasswordFormKey,
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Card(
                                                elevation: elevation,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(12)),
                                                color: accentColor3,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.email,
                                                    color: accentColor1,
                                                  ),
                                                )),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _emailController,
                                                validator: (email) {
                                                  if (email.contains('@') &&
                                                      email.contains('.com'))
                                                    return null;

                                                  return 'Please Enter Valid Email';
                                                },
                                                // controller: _emailController,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                decoration:
                                                    InputDecoration(hintText: 'Email'),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Card(
                                                elevation: elevation,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(12)),
                                                color: accentColor3,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.lock_open,
                                                    color: accentColor1,
                                                  ),
                                                )),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _passwordController,
                                                obscureText: !showPassword,
                                                keyboardType:
                                                    TextInputType.visiblePassword,
                                                validator: (password) {
                                                  if (password.length < 8)
                                                    return 'Password Too Short!!';
                                                  else if (password !=
                                                      _confirmPasswordController.text)
                                                    return 'Passwords Don\'t match!!';

                                                  return null;
                                                },
                                                decoration: InputDecoration(
                                                    suffixIcon: IconButton(
                                                        icon: (showPassword)
                                                            ? Icon(FontAwesomeIcons.eye)
                                                            : ImageIcon(Image.asset(
                                                                    'assets/images/password_hidden.png')
                                                                .image),
                                                        onPressed: () {
                                                          setState(() {
                                                            showPassword =
                                                                !showPassword;
                                                          });
                                                        }),
                                                    hintText: 'Password'),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Card(
                                                elevation: elevation,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(12)),
                                                color: accentColor3,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.lock,
                                                    color: accentColor1,
                                                  ),
                                                )),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _confirmPasswordController,
                                                obscureText: !showPassword,
                                                keyboardType:
                                                    TextInputType.visiblePassword,
                                                validator: (password) {
                                                  if (password.length < 8)
                                                    return 'Password Too Short!!';
                                                  else if (password !=
                                                      _passwordController.text)
                                                    return 'Passwords Don\'t match!!';

                                                  return null;
                                                },
                                                decoration: InputDecoration(
                                                    hintText: 'Confirm Password'),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 32,
                                  ),
                                  Container(
                                    width: context.screenWidth * 0.7,
                                    height: 136,
                                    child: Stack(
                                      children: <Widget>[
                                        Positioned(
                                          top: 24,
                                          bottom: 24,
                                          right: 0,
                                          left: 0,
                                          child: Card(
                                            elevation: elevation,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24)),
                                            color: accentColor1,
                                            child: Container(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'OR',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold),
                                                )),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          left: 64,
                                          right: 64,
                                          child: RaisedButton(
                                            elevation: elevation,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            color: accentColor3,
                                            onPressed: () {
                                              if (_emailPasswordFormKey.currentState
                                                  .validate()) {
                                                _signUpBloc.add(SignUpUser(
                                                    email: _emailController.text,
                                                    password:
                                                        _passwordController.text));
                                              }
                                            },
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            child: Text(
                                              'Sign Up',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Card(
                                                  elevation: elevation,
                                                  color: Colors.white,
                                                  child: IconButton(
                                                      icon: Icon(
                                                        FontAwesomeIcons.phoneAlt,
                                                        color: accentColor,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pushReplacementNamed(
                                                                PhoneLoginScreenRoute);
                                                      }),
                                                ),
                                                Card(
                                                    elevation: elevation,
                                                    color: Colors.white,
                                                    child: InkWell(
                                                      onTap: () {
                                                        _signUpBloc
                                                            .add(SignUpWithGoogle());
                                                      },
                                                      child: Container(
                                                          padding: EdgeInsets.all(8),
                                                          child: Image.asset(
                                                            'assets/images/gicon.png',
                                                            height: 32,
                                                          )),
                                                    )),
                                                Card(
                                                  elevation: elevation,
                                                  color: Colors.white,
                                                  child: IconButton(
                                                      icon: Icon(
                                                        FontAwesomeIcons.facebookF,
                                                        color: Color.fromRGBO(
                                                            59, 89, 152, 1.0),
                                                      ),
                                                      onPressed: () {
                                                        _signUpBloc
                                                            .add(SignUpWithFacebook());
                                                      }),
                                                ),
                                                Card(
                                                  elevation: elevation,
                                                  color: Colors.white,
                                                  child: IconButton(
                                                      icon: Icon(
                                                        FontAwesomeIcons.apple,
                                                        color: Colors.black,
                                                      ),
                                                      onPressed: () {}),
                                                )
                                              ],
                                            ))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                            ],
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Center(
                              child: SizedBox(
                                width: context.screenWidth * 0.7,
                                child: RaisedButton(
                                    elevation: elevation,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                    color: accentColor1,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0),
                                      child: Text('Log In',style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushReplacementNamed(LoginScreenRoute);
                                    }),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(children: [
                                  TextSpan(
                                      text:
                                          'I have read and agree to YoGigg\'s ',
                                      style: Theme.of(context).textTheme.caption.copyWith(fontSize: 8,)),
                                  TextSpan(
                                      text: 'Terms of Use ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .copyWith(
                                            fontSize: 10,
                                              color: accentColor,
                                              decoration:
                                                  TextDecoration.underline)),
                                  TextSpan(
                                      text: 'and ',
                                      style: Theme.of(context).textTheme.caption.copyWith(
                                        fontSize: 8
                                      )),
                                  TextSpan(
                                      text: 'Privacy Policy',
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .copyWith(
                                            fontSize: 10,
                                              color: accentColor,
                                              decoration:
                                                  TextDecoration.underline))
                                ]))
                          ],
                        ),
                      ],
                    ),
                  );
                } else
                  return Center(
                    child: CircularProgressIndicator(),
                  );
              },
              listener: (context, state) {
                if (state is LoggedInState) {
                  Navigator.of(context).pushReplacementNamed(MainScreenRoute);
                } else if (state is NewUserState) {
                  Navigator.of(context)
                      .pushReplacementNamed(UserDetailsScreenRoute,arguments: state.user);
                }else if (state is SignUpErrorState) {
                  _confirmPasswordController.clear();
                  showSnackbar(state.errorMessage, context);
                } 
              },
            ),
          ),
        ),
      ),
    );
  }
}
