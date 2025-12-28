import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/network_service.dart';

/// Widget that shows a banner when the device is offline
class NetworkAwareWidget extends StatefulWidget {
  final Widget child;

  const NetworkAwareWidget({super.key, required this.child});

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget>
    with SingleTickerProviderStateMixin {
  late StreamSubscription<bool> _subscription;
  bool _isConnected = true;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _isConnected = NetworkService.instance.isConnected;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _subscription = NetworkService.instance.connectivityStream.listen((
      connected,
    ) {
      setState(() {
        _isConnected = connected;
      });
      if (!connected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    // Show banner if starting offline
    if (!_isConnected) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Offline banner
        SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.orange.shade700,
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'You are offline',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Using cached data',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Main content
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Mixin for screens that need to react to connectivity changes
mixin NetworkAwareMixin<T extends StatefulWidget> on State<T> {
  StreamSubscription<bool>? _networkSubscription;
  bool isOnline = true;

  @override
  void initState() {
    super.initState();
    isOnline = NetworkService.instance.isConnected;
    _networkSubscription = NetworkService.instance.connectivityStream.listen((
      connected,
    ) {
      if (mounted) {
        setState(() {
          isOnline = connected;
        });
        if (connected) {
          onConnected();
        } else {
          onDisconnected();
        }
      }
    });
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    super.dispose();
  }

  /// Called when network becomes available
  void onConnected() {}

  /// Called when network becomes unavailable
  void onDisconnected() {}
}
