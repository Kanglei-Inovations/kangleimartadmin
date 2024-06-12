import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kangleimartadmin/firebase_options.dart';
import 'package:kangleimartadmin/providers/auth_provider.dart';
import 'package:kangleimartadmin/providers/product_provider.dart';
import 'package:kangleimartadmin/screens/category/category_screen.dart';
import 'package:kangleimartadmin/screens/home_screen.dart';
import 'package:kangleimartadmin/screens/authentication/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/brand_provider.dart';
import 'providers/category_provider.dart';
import 'screens/brands/add_brand_screen.dart';
import 'screens/brands/brand_screen.dart';
import 'screens/category/add_category_screen.dart';
import 'screens/product/add_product_screen.dart';
import 'screens/product/product_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.deepPurpleAccent, // Change this to your desired color
  ));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));

}

class MyApp extends StatelessWidget {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage =  FirebaseStorage.instance;
  final SharedPreferences prefs;
  MyApp({super.key, required this.prefs});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProviders()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => BrandProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: GetMaterialApp(
        title: 'KangleiMart Admin',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
        routes: {
          '/home': (ctx) => HomeScreen(),
          '/login': (ctx) => LoginScreen(),
          '/brands': (ctx) => BrandScreen(),
          '/products': (ctx) => ProductScreen(),
          '/categories' : (ctx) => CategoryScreen(),
          AddBrandScreen.routeName: (ctx) => AddBrandScreen(),
          AddProductScreen.routeName: (ctx) => AddProductScreen(),
          AddCategoryScreen.routeName: (ctx) => AddCategoryScreen(),
        },
      ),
    );
  }
}

class AuthChecker extends StatefulWidget {
  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProviders>(context);
    return FutureBuilder<bool>(
      future: authProvider.checkAuthStatus(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          return snapshot.data == true ? HomeScreen() : LoginScreen();
        }
      },
    );
  }
}
