
import 'package:bellamarble/screen/categories/provider/categories_provider.dart';
import 'package:bellamarble/screen/categories/provider/titlelist_provider.dart';
import 'package:bellamarble/screen/categories/provider/product_detail_provider.dart';
import 'package:bellamarble/screen/contact_Screen/provider/contact_provider.dart';
import 'package:bellamarble/screen/favorites/provider/favorites_provider.dart';
import 'package:bellamarble/screen/favorites/provider/product_list_provider.dart';
import 'package:bellamarble/screen/gallery/provider/gallery_screen_provider.dart';
import 'package:bellamarble/screen/gallery/provider/image_provider.dart';
import 'package:bellamarble/screen/home/provider/home_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        // Base providers
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => TileListProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
        ChangeNotifierProvider(create: (_) => GalleryImagesProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ProductDetailProvider()),
        ChangeNotifierProvider(create: (_) => ProductListProvider()),


      ],
      child: const MyApp(),
    ),
  );
}


