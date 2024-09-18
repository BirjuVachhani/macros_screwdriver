## Using macros


### PublicGetter Macro

Generates a public getter for a private field.

#### Declaration
```dart
class User {
  @PublicGetter()
  final String _name;
  
  User(this._name);
}
```

#### Usage
```dart
final User user = User('John');

// Using the generated getter.
print(user.name); // John
```