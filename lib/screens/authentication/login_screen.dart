import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      Provider.of<AuthProviders>(context, listen: false).login(_email, _password);
      if (Provider.of<AuthProviders>(context, listen: false).isLoggedIn) {
        Navigator.of(context).pushNamed('/HomeScreen');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _trySubmit,
                child: Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/SignUpScreen');
                },
                child: Text('Don\'t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
