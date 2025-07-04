
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'viewmodels/bill_splitting_viewmodel.dart';
import 'views/home_screen.dart';


void main() {
  runApp(const Splitense());
}

class Splitense extends StatelessWidget {
  const Splitense({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BillSplittingViewModel(),
      child: MaterialApp(
        title: 'Splitense',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}

