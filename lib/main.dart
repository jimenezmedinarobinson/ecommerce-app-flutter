import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/cart_provider.dart';
import 'screens/product_list_screen.dart';
import 'services/local_storage_service.dart';
//import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  await LocalStorageService.init();

  //final notificationService = NotificationService();
  //await notificationService.initialize();
  //notificationService.setupBackgroundHandler();
  //notificationService.listenTokenChanges();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider()..loadCart(),
      child: MaterialApp(
        title: 'Mi Tienda E-commerce',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: ProductListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
