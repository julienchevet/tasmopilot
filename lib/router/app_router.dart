import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../features/sites/sites_screen.dart';
import '../features/devices/devices_screen.dart';
import '../features/devices/device_control_screen.dart';
import '../features/devices/models/device.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SitesScreen(),
      routes: [
        GoRoute(
          path: 'site/:siteId',
          builder: (context, state) {
            final siteId = int.parse(state.pathParameters['siteId']!);
            final siteName = state.uri.queryParameters['name'] ?? 'Site';
            return DevicesScreen(siteId: siteId, siteName: siteName);
          },
          routes: [
            GoRoute(
              path: 'device',
              builder: (context, state) {
                // We pass the device object via extra
                final device = state.extra as Device;
                return DeviceControlScreen(device: device);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
