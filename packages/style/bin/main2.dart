void main() {
  var regex = RegExp(r"\${([^}]*)}");

  print(regex.allMatches("heey : \${sss} , {merhaba}"));
}
