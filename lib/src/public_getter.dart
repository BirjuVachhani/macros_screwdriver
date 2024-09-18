// Copyright © 2024 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:macros/macros.dart';

/// A macro that generates a public getter for a private field in a class.
/// This is useful for exposing a field to the public API without making it
/// publicly mutable.
///
/// NOTE:
/// This macro can only be used on private fields (fields that start with `_`).
///
/// Example:
/// ```dart
/// class User {
///   @PublicGetter()
///   final String _username;
///
///   User(this._username);
///
/// }
///
/// void main() {
///   final user = User('john');
///   print(user.username); // john
/// }
/// ```
///
/// This macro will generate a getter for the private field `_username` that
/// returns the value of the field. The generated getter will be named `username`.
///
/// If the field is nullable, the generated getter will also be nullable. If you
/// want to force the getter to be non-nullable, you can pass [forceNonNull] as
/// `true`.
///
/// This also works with static fields. A static private field will generate a
/// public static getter.
macro class PublicGetter
    implements FieldDeclarationsMacro {

  /// If `true`, the generated getter will be non-nullable even if the field is
  /// nullable.
  final bool? forceNonNull;

  /// Creates a new [PublicGetter] macro.
  const PublicGetter({this.forceNonNull});

  @override
  FutureOr<void> buildDeclarationsForField(FieldDeclaration field,
      MemberDeclarationBuilder builder) async {
    final String fieldName = field.identifier.name;

    if (!fieldName.startsWith('_')) {
      // If the field does not start with `_`, it is not a private field.
      builder.report(Diagnostic(DiagnosticMessage(
          'PublicGetter should only be used on private declarations',
          target: DeclarationDiagnosticTarget(field)),
          Severity.error));
    }

    // Remove the `_` from the field name to get the public field name.
    final String publicFieldName = fieldName.substring(1);

    final bool isNullable = field.type.isNullable;

    final bool shouldForceNonNull = forceNonNull == true && isNullable;

    builder.declareInType(DeclarationCode.fromParts([
      if(field.hasStatic) 'static ',
      shouldForceNonNull ?
      field.type.code.asNonNullable : field.type.code,
      ' get ',
      publicFieldName,
      ' => ',
      fieldName,
      if(shouldForceNonNull) '!',
      ';',
    ]));
  }
}