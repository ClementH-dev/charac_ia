import 'package:flutter/material.dart';
import '../controller/user_controller.dart';
import '../models/user.dart';
import 'package:provider/provider.dart';
import 'bottom_nav_bar.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserController(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[850],
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.grey[300]),
        ),
      ),
      home: AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Container(
          width: screenWidth * 0.85,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedPositioned(
                duration: Duration(milliseconds: 400),
                left: isLogin ? 0 : -screenWidth,
                right: isLogin ? 0 : screenWidth,
                child: Align(
                  alignment: Alignment.center,
                  child: LoginForm(toggleForm: toggleForm),
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 400),
                left: isLogin ? screenWidth : 0,
                right: isLogin ? -screenWidth : 0,
                child: Align(
                  alignment: Alignment.center,
                  child: SignupForm(toggleForm: toggleForm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final VoidCallback toggleForm;

  LoginForm({required this.toggleForm});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userController = Provider.of<UserController>(context, listen: false);
    String username = usernameController.text;
    String password = passwordController.text;

    await userController.loginUser(username, password);

    if (userController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userController.errorMessage!)),
      );
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => BottomNavBar(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    return Container(
      width: 350,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "Bienvenue",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                )
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: usernameController,
              decoration: inputDecoration("Username", Icons.person),
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Veuillez entrer votre username";
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: inputDecoration("Mot de passe", Icons.lock),
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Veuillez entrer votre mot de passe";
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: userController.isLoading ? null : login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: userController.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                    "Se connecter",
                    style: TextStyle(fontSize: 18, color: Colors.white)
                ),
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: GestureDetector(
                onTap: widget.toggleForm,
                child: Text(
                    "Créer un compte",
                    style: TextStyle(color: Colors.orangeAccent, fontSize: 16)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[300]),
      filled: true,
      fillColor: Colors.grey[700],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(icon, color: Colors.grey[300]),
      errorStyle: TextStyle(color: Colors.redAccent),
    );
  }
}

class SignupForm extends StatefulWidget {
  final VoidCallback toggleForm;

  SignupForm({required this.toggleForm});

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userController = Provider.of<UserController>(context, listen: false);

    User newUser = User(
      username: usernameController.text,
      password: passwordController.text,
      email: emailController.text,
      firstname: firstnameController.text,
      lastname: lastnameController.text,
    );

    await userController.registerUser(newUser);

    if (userController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userController.errorMessage!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Inscription réussie! Vous pouvez maintenant vous connecter.")),
      );
      // Basculer vers le formulaire de connexion après l'inscription réussie
      widget.toggleForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    return Container(
      width: 350,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "Créer un compte",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                )
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: usernameController,
              decoration: inputDecoration("Username", Icons.person),
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Veuillez entrer un nom d'utilisateur";
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: firstnameController,
              decoration: inputDecoration("Firstname", Icons.account_circle),
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Veuillez entrer votre prénom";
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: lastnameController,
              decoration: inputDecoration("Lastname", Icons.person_outline),
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Veuillez entrer votre nom";
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: emailController,
              decoration: inputDecoration("Email", Icons.email),
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Veuillez entrer votre email";
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return "Veuillez entrer un email valide";
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: inputDecoration("Mot de passe", Icons.lock),
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Veuillez entrer un mot de passe";
                }
                if (value.length < 6) {
                  return "Le mot de passe doit contenir au moins 6 caractères";
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: userController.isLoading ? null : register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: userController.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                    "S'inscrire",
                    style: TextStyle(fontSize: 18, color: Colors.white)
                ),
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: GestureDetector(
                onTap: widget.toggleForm,
                child: Text(
                    "Se connecter",
                    style: TextStyle(color: Colors.orangeAccent, fontSize: 16)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[300]),
      filled: true,
      fillColor: Colors.grey[700],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(icon, color: Colors.grey[300]),
      errorStyle: TextStyle(color: Colors.redAccent),
    );
  }
}