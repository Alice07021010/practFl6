import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SessionWatcher extends StatefulWidget {
  final Widget child;
  final VoidCallback onTimeout;
  final Duration inactivityTimeout;
  final Duration warningBefore;
  final Duration absoluteTimeout;
  final DateTime? sessionStartedAt;

  const SessionWatcher({
    super.key,
    required this.child,
    required this.onTimeout,
    required this.sessionStartedAt,
    this.inactivityTimeout = const Duration(minutes: 3),
    this.warningBefore = const Duration(seconds: 30),
    this.absoluteTimeout = const Duration(minutes: 30),
  });

  @override
  State<SessionWatcher> createState() => _SessionWatcherState();
}

class _SessionWatcherState extends State<SessionWatcher> {
  Timer? _warningTimer;
  Timer? _logoutTimer;
  Timer? _countdownTimer;
  Timer? _absoluteTimer;
  int? _secondsLeft;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    _restartInactivity();
    _startAbsoluteTimer();
  }

  @override
  void didUpdateWidget(covariant SessionWatcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionStartedAt != widget.sessionStartedAt) {
      _startAbsoluteTimer();
    }
  }

  bool _onKey(KeyEvent event) {
    _restartInactivity();
    return false;
  }

  void _restartInactivity() {
    _warningTimer?.cancel();
    _logoutTimer?.cancel();
    _countdownTimer?.cancel();
    if (mounted && _secondsLeft != null) setState(() => _secondsLeft = null);

    final warningDelay = widget.inactivityTimeout - widget.warningBefore;
    _warningTimer = Timer(warningDelay, _beginWarning);
    _logoutTimer = Timer(widget.inactivityTimeout, widget.onTimeout);
  }

  void _beginWarning() {
    if (!mounted) return;
    setState(() => _secondsLeft = widget.warningBefore.inSeconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _secondsLeft == null) return;
      setState(() => _secondsLeft = (_secondsLeft! - 1).clamp(0, 999).toInt());
    });
  }

  void _startAbsoluteTimer() {
    _absoluteTimer?.cancel();
    final started = widget.sessionStartedAt;
    if (started == null) return;
    final elapsed = DateTime.now().difference(started);
    final remaining = widget.absoluteTimeout - elapsed;
    if (remaining <= Duration.zero) {
      scheduleMicrotask(widget.onTimeout);
    } else {
      _absoluteTimer = Timer(remaining, widget.onTimeout);
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _warningTimer?.cancel();
    _logoutTimer?.cancel();
    _countdownTimer?.cancel();
    _absoluteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _restartInactivity(),
      onPointerMove: (_) => _restartInactivity(),
      onPointerSignal: (_) => _restartInactivity(),
      child: Stack(
        children: [
          widget.child,
          if (_secondsLeft != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(14),
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Нет активности. Выход через $_secondsLeft сек. Нажмите или начните печатать, чтобы продолжить.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
