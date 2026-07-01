import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/app/theme/dark_theme.dart';
import 'package:task_manager/app/theme/light_theme.dart';

final themeProvider = NotifierProvider ( (){
return ThemeNotifier();
});

class ThemeNotifier extends Notifier<ThemeData>{
  bool isDark = true;
  ThemeData build() => KineticNoirTheme.darkTheme;
  void toggle(){
      if(isDark) {
        isDark = !isDark;
        state = KineticLightTheme.lightTheme;
      }else{ 
        isDark = !isDark;
        state = KineticNoirTheme.darkTheme;
      }
  }

} 