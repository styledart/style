```dart
class MyComponent {
  
  Component build(BuildContext context){
    return Gateway(
      children: [
        Auth.of(context).build(context),
        
      ]
    );
  }
}
```