import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steady_streak/utils/colors.dart';
import 'package:steady_streak/utils/config.dart';

import '../utils/utils.dart';

class ProfileScreen extends StatefulWidget {
  final email;
  const ProfileScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool onTapNameEdit = false;
  bool onTapPasswordEdit = false;
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  String uname = "";

  Future<void> updateUsername(String newUsername) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8082/user/update-username/${widget.email}'),
      body: jsonEncode({"newUsername": newUsername}),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      showSnackBar(context, 'Username updated successfully');
      setState(() {
        uname = newUsername;
        onTapNameEdit = false;
        retrieveUserName();
      });
    } else {
      print('Failed to update username');
    }
  }

  Future<void> retrieveUserName() async {
    final response = await http.get(
      Uri.parse('$getUserNameByEmail/${widget.email}'),
    );
    final responseBody = json.decode(response.body);
    setState(() {
      uname = responseBody['name'];
    });
  }

  Future<void> updatePassword(String newPassword) async {
    final apiUrl = 'http://10.0.2.2:8082/user/update-password/${widget.email}';

    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"newPassword": newPassword}),
    );
    if (response.statusCode == 200) {
      setState(() {
        onTapPasswordEdit = false;
      });
      print('Password updated successfully');
    } else {
      print('Failed to update password');
    }
  }

  @override
  void initState() {
    super.initState();
    retrieveUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: tintWhite,
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0, left: 20.0, right: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello",
                  style: GoogleFonts.gabriela(
                      fontWeight: FontWeight.bold,
                      fontSize: 50,
                      color: Colors.grey),
                ),
                SizedBox(height: 10),
                TextIcon(uname, Icon(Icons.edit), 28),
                SizedBox(height: 10),
                if (onTapNameEdit)
                  EditBox("Username", Icon(Icons.person), username),
                Divider(
                  thickness: 0.5,
                  color: Colors.grey,
                ),
                TextIcon("Change Password ?", Icon(Icons.edit), 30),
                SizedBox(height: 10),
                if (onTapPasswordEdit)
                  EditBox("Password", Icon(Icons.password), password),
                Divider(
                  thickness: 0.5,
                  color: Colors.grey,
                ),
                SizedBox(height: 10),
                Text("Deactivate Account:",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
                Text(
                    "Once you deactivate your account, there is no going back. Please be certain.",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Center(
                  child: ElevatedButton.icon(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(
                              BorderSide(color: Colors.red)),
                          minimumSize:
                              MaterialStateProperty.all(Size.fromHeight(40)),
                          overlayColor:
                              MaterialStateColor.resolveWith((states) => bg),
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) => Colors.black)),
                      onPressed: () {},
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      label: Text(
                        "DeActivate",
                        style: TextStyle(color: Colors.red),
                      )),
                ),
              ],
            ),
          ),
        ));
  }

  Widget TextIcon(String text, Icon icon, double fontS) {
    var w = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Text(text,
            style: TextStyle(
                color: Colors.black,
                fontSize: fontS,
                fontWeight: FontWeight.bold)),
        SizedBox(
          width: w * 0.02,
        ),
        InkWell(
            onTap: () {
              setState(() {
                if (text == "Change Password ?") {
                  onTapPasswordEdit = !onTapPasswordEdit;
                } else
                  onTapNameEdit = !onTapNameEdit;
              });
            },
            child: icon)
      ],
    );
  }

  Widget EditBox(String text, Icon icon, TextEditingController controller) {
    return Column(
      children: [
        TextFormField(
          keyboardType: TextInputType.name,
          controller: controller,
          validator: (value) {
            if (value!.isEmpty) {
              return "Enter $text";
            } else {
              return null;
            }
          },
          decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              hintText: text,
              label: Text(
                text,
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
              prefixIcon: icon),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 40,
              width: 150,
              child: TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black)),
                  onPressed: () {
                    if (text == "Password") {
                      final newPassword = password.text;
                      updatePassword(newPassword);
                    } else {
                      final newUsername = username.text;
                      updateUsername(newUsername);
                    }
                  },
                  child: Text((text == "Email") ? "reset" : "save",
                      style: TextStyle(fontSize: 20, color: Colors.white))),
            ),
            Container(
              height: 40,
              width: 150,
              child: TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black)),
                  onPressed: () {
                    setState(() {
                      if (text == "Username") {
                        onTapNameEdit = false;
                      } else
                        onTapPasswordEdit = false;
                    });
                  },
                  child: Text("cancel",
                      style: TextStyle(fontSize: 20, color: Colors.white))),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
