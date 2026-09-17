import 'package:flutter/widgets.dart';

import '../models/app_user.dart';

class PermissionGate extends StatelessWidget {
  final Role role;
  final Permission permission;
  final Widget child;
  final Widget fallback;

  const PermissionGate({
    super.key,
    required this.role,
    required this.permission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return role.permissions.contains(permission) ? child : fallback;
  }
}
