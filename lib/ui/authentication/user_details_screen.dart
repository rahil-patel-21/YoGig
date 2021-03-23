import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yogigg_users_app/bloc/user_details_bloc/user_details_bloc.dart';
import 'package:yogigg_users_app/constants/colors.dart';
import 'package:yogigg_users_app/constants/common_widget.dart';
import 'package:yogigg_users_app/constants/styles.dart';
import 'package:yogigg_users_app/models/user_model.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:yogigg_users_app/repository/user_repository.dart';
import 'package:yogigg_users_app/utils/router_constants.dart';
import 'package:yogigg_users_app/utils/service_locator.dart';

class UserDetailsScreen extends StatefulWidget {
  final UserModel userModel;
  UserDetailsScreen({this.userModel});
  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  DateTime pickedDate;

  final _formKey = GlobalKey<FormState>();

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  bool emailEnabled = true;
  bool phoneEnabled = true;

  UserRepository _userRepository = locator<UserRepository>();

  UserDetailsBloc _userDetailsBloc = UserDetailsBloc();

  String photoURL;

  @override
  void initState() {
    if (widget.userModel != null) {
      _firstNameController.text = widget.userModel.firstName ?? '';
      _lastNameController.text = widget.userModel.lastName ?? '';
      _emailController.text = widget.userModel.userEmail ?? '';
      if (widget.userModel.userEmail != null) emailEnabled = false;
      _phoneController.text = widget.userModel.userPhoneNumber ?? '';
      if (widget.userModel.userPhoneNumber != null) phoneEnabled = false;
      photoURL = widget.userModel.userPhotoURL;
    }

    super.initState();
  }

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
        body: BlocListener<UserDetailsBloc,UserDetailsState>(
          cubit: _userDetailsBloc,
          listener: (context, state) {
            if (state is UserDetailsUpdatedState) {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(MainScreenRoute);
            }
          },
          child: Container(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(
                color: Colors.red,
                gradient: LinearGradient(colors: [
                  accentColor1,
                  accentColor3,
                ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: ListView(
              padding: EdgeInsets.only(top: 24),
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                      right: 24,
                      left: 24,
                      bottom: 24 + MediaQuery.of(context).viewInsets.bottom),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                                                          child: Text(
                                'Tell us about yourself!',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              height: context.screenHeight * 0.07,
                              alignment: Alignment.topRight,
                              child: Hero(
                                  tag: 'logo_image',
                                  child: Image.asset(
                                      'assets/images/logo_shadow.png')),
                            ),
                            
                          ],
                        ),
                        SizedBox(height: 16,),
                        buildUserImageWidget(),
                        SizedBox(height: 16,),
                        buildUserDetailsForm(),
                        SizedBox(height: 8,),
                        buildSubmitButton()
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSubmitButton() {
    return Container(
      padding: EdgeInsets.only(top: 24),
      child: Row(
        children: <Widget>[
          Expanded(
            child: RaisedButton(
              elevation: elevation,
              padding: EdgeInsets.symmetric(vertical: 16),
              color: accentColor3,
              onPressed: () {
                if (photoURL == null) {
                  showSnackbar('Please Select Profile Photo!', context);
                } else if (pickedDate == null) {
                  showSnackbar('Please Fill your birthday!', context);
                } else if (_formKey.currentState.validate()) {
                  var userModel = UserModel(
                    widget.userModel.userId,
                    firstName: _firstNameController.text,
                    lastName: _lastNameController.text,
                    userEmail: _emailController.text,
                    userPhoneNumber: '+1${_phoneController.text}',
                    userAddress: _addressController.text,
                    userPhotoURL: photoURL,
                    userBirthday: pickedDate,
                  );
                  _userDetailsBloc.add(UpdateUserDetails(userModel));
                  showModalBottomSheet(
                      isDismissible: false,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12))),
                      context: context,
                      builder: (context) {
                        return BlocBuilder<UserDetailsBloc, UserDetailsState>(
                          cubit: _userDetailsBloc,
                          builder: (context, state) {
                            if (state is UserDetailsUpdatedState) {
                              return Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12)),
                                    gradient: LinearGradient(
                                        colors: [
                                          accentColor3,
                                          accentColor1,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter)),
                                height: context.screenHeight * 0.3,
                                child: Center(
                                    child: Icon(FontAwesomeIcons.checkCircle)),
                              );
                            } else if (state is UserDetailsErrorState) {
                              return Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12)),
                                    gradient: LinearGradient(
                                        colors: [
                                          accentColor3,
                                          accentColor1,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter)),
                                height: context.screenHeight * 0.3,
                                child: Column(
                                  children: <Widget>[
                                    Expanded(child: Icon(Icons.cancel)),
                                    RaisedButton(
                                      elevation: elevation,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      color: accentColor3,
                                      onPressed: () {
                                        var userModel = UserModel(
                                          widget.userModel.userId,
                                          firstName: _firstNameController.text,
                                          lastName: _lastNameController.text,
                                          userEmail: _emailController.text,
                                          userPhoneNumber:
                                              '+1${_phoneController.text}',
                                          userAddress: _addressController.text,
                                          userPhotoURL: photoURL,
                                          userBirthday: pickedDate,
                                        );
                                        _userDetailsBloc
                                            .add(UpdateUserDetails(userModel));
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Text(
                                        'Retry',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            } else {
                              return Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12)),
                                    gradient: LinearGradient(
                                        colors: [
                                          accentColor3,
                                          accentColor1,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter)),
                                height: context.screenHeight * 0.3,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                          },
                        );
                      });
                }
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Next ',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  Icon(FontAwesomeIcons.longArrowAltRight)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserDetailsForm() {
    return Container(
      child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Card(
                      elevation: elevation,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      color: accentColor3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.person,
                          color: accentColor1,
                        ),
                      )),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: TextFormField(
                      validator: (name) {
                        if (name.isNotEmpty) return null;

                        return 'Required!';
                      },
                      controller: _firstNameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(hintText: 'First Name'),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: TextFormField(
                      validator: (name) {
                        if (name.isNotEmpty) return null;

                        return 'Required!';
                      },
                      controller: _lastNameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(hintText: 'Last Name'),
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
                          borderRadius: BorderRadius.circular(12)),
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
                      enabled: emailEnabled,
                      validator: (email) {
                        if (email.contains('@') && email.contains('.com'))
                          return null;

                        return 'Please Enter Valid Email';
                      },
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(hintText: 'Email'),
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
                          borderRadius: BorderRadius.circular(12)),
                      color: accentColor3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.phone,
                          color: accentColor1,
                        ),
                      )),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: TextFormField(
                        enabled: phoneEnabled,
                        maxLength: 10,
                        buildCounter: (context,
                            {currentLength, isFocused, maxLength}) {
                          return null;
                        },
                        validator: (value) {
                          if (value.length < 10) return 'Invalid Phone Number';

                          return null;
                        },
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: 'Phone Number')),
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
                          borderRadius: BorderRadius.circular(12)),
                      color: accentColor3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.home,
                          color: accentColor1,
                        ),
                      )),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: TextFormField(
                      validator: (address) {
                        if (address.isNotEmpty) return null;

                        return 'Please Enter Address!';
                      },
                      controller: _addressController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(hintText: 'Address'),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              RaisedButton.icon(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: elevation,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                color: accentColor3,
                icon: Icon(
                  Icons.calendar_today,
                  color: accentColor1,
                ),
                onPressed: () async {
                  var date = DateTime.now();
                  if (Platform.isIOS) {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 216,
                            color: CupertinoColors.systemBackground
                                .resolveFrom(context),
                            child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.date,
                                initialDateTime:
                                    (pickedDate != null) ? pickedDate : date,
                                maximumDate: date,
                                minimumDate: DateTime.utc(
                                    date.year - 100, date.month, date.day),
                                onDateTimeChanged: (newDateTime) {
                                  setState(() {
                                    pickedDate = newDateTime;
                                  });
                                }),
                          );
                        });
                  } else {
                    pickedDate = await showDatePicker(
                        context: context,
                        initialDate: (pickedDate != null) ? pickedDate : date,
                        firstDate:
                            DateTime.utc(date.year - 100, date.month, date.day),
                        lastDate: date);
                  }
                  setState(() {});
                },
                label: (pickedDate != null)
                    ? Text(
                        '${pickedDate.day} / ${pickedDate.month} / ${pickedDate.year}')
                    : Text('Your Birthday'),
              ),
            ],
          )),
    );
  }

  Widget buildUserImageWidget() {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              alignment: Alignment.bottomRight,
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: (photoURL != null)
                          ? NetworkImage(photoURL)
                          : AssetImage('assets/images/user_placeholder.png')),
                  color: Colors.white),
              
            ),
            Positioned(
              bottom: 0,
              right: 0,
                          child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: GestureDetector(
                  onTap: ()async{
                  final picker = ImagePicker();
                        final pickedFile =
                            await picker.getImage(source: ImageSource.gallery);
                            if (pickedFile!=null) {
                              showSnackbar('Uploading Photo', context);
                        var url =
                            await _userRepository.uploadUserImage(File(pickedFile.path));
                        setState(() {
                          photoURL = url;
                        });
                            }
                        
                },
                  child: Icon(Icons.add)) 
                
              ),
            )
          ],
        ),
        SizedBox(width: 16,),
        Text('Add a Profile Picture',style: TextStyle(color: Colors.grey, fontSize: 18),)
      ],
    );
  }
}
