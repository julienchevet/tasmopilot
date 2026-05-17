import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/devices/devices_screen.dart';
import '../features/devices/device_control_screen.dart';
import '../features/devices/models/device.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DevicesScreen(),
      routes: [
        GoRoute(
          path: 'device',
          builder: (context, state) {
            final device = state.extra as Device;
            return DeviceControlScreen(device: device);
          },
        ),
      ],
    ),
  ],
);
