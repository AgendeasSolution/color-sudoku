import 'package:flutter/material.dart';
import '../../../services/connectivity_service.dart';
import 'no_internet_overlay.dart';

/// Wrapper widget that monitors connectivity and shows overlay when offline
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({
    super.key,
    required this.child,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _hasInternetConnection = true;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    await _connectivityService.initialize();
    setState(() {
      _hasInternetConnection = _connectivityService.hasInternetConnection;
    });
    
    _connectivityService.addListener(_onConnectivityChanged);
  }

  void _onConnectivityChanged() {
    if (mounted) {
      setState(() {
        _hasInternetConnection = _connectivityService.hasInternetConnection;
      });
    }
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_hasInternetConnection)
          const NoInternetOverlay(),
      ],
    );
  }
}


