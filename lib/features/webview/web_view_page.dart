
import 'package:flutter/material.dart';
import 'package:flutter_client_oi/services/version_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:flutter_client_oi/core/theme/app_theme.dart';
import 'package:flutter_client_oi/store/auth_store.dart';
import 'package:flutter_client_oi/features/auth/pin_mode.dart';
import 'package:flutter_client_oi/features/auth/pin_code_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_client_oi/shared/widgets/base_icon.dart';

import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

const kDemoUrl = 'https://dev.onayipoteka.kz/clientCabinet/main/';
const allowedBaseUrl = 'https://dev.onayipoteka.kz/clientCabinet/';

bool isAllowedUrl(String url) {
  final uri = Uri.tryParse(url);
  final base = Uri.parse(allowedBaseUrl);

  if (uri == null) return false;
  return uri.scheme == base.scheme && uri.host == base.host && uri.port == base.port
    && (uri.path == '/clientCabinet' || uri.path.startsWith('/clientCabinet/'));
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    super.key,
    required this.authStore,
    this.url = kDemoUrl,
  });

  final AuthStore authStore;
  final String url;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage>
    with WidgetsBindingObserver {
  late final WebViewController _controller;

  final _pinKey = GlobalKey<PinCodeScreenState>();

  int _progress = 0;
  bool _hasError = false;
  bool _pinLoading = false;
  bool _updatingWebView = false;
  bool _webViewReady = false;
  bool _mainPageFailed = false;

  String _pinError = '';
  String? _loadedVersion;
  String? _pendingVersion;

  bool _checkingVersion = false;

  // Completes when the current main page finishes loading.
  Future<void>? _loadingFuture;
  VoidCallback? _completeLoading;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    widget.authStore.addListener(_onAuthChanged);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
           onNavigationRequest: (request) {
            if (!isAllowedUrl(request.url)) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            debugPrint('🌐 Started: $url');
            _mainPageFailed = false;

            if (mounted) {
              setState(() {
                _hasError = false;
                _progress = 0;
              });
            }
          },
          onProgress: (progress) {
            if (mounted) {
              setState(() => _progress = progress);
            }
          },
          onWebResourceError: (error) {
            debugPrint('❌ Resource error: ${error.description}');
            debugPrint('URL: ${error.url}');
            debugPrint('Code: ${error.errorCode}');
            debugPrint('Main frame: ${error.isForMainFrame}');

            if (error.isForMainFrame ?? true) {
              _mainPageFailed = true;

              if (mounted) {
                setState(() => _hasError = true);
              }
            }
          },
          onHttpError: (error) {
            debugPrint('❌ HTTP: ${error.response?.statusCode}');
            debugPrint('URL: ${error.request?.uri}');

            final statusCode = error.response?.statusCode;
            final isMainFrame = error.request?.uri.toString() ==
              _versionedUri(_pendingVersion ?? _loadedVersion).toString();

            if (isMainFrame && statusCode != null && statusCode >= 400) {
              _mainPageFailed = true;

              if (mounted) setState(() => _hasError = true);
            }
          },
          onPageFinished: (url) {
            debugPrint('✅ Finished: $url');
            _completeLoading?.call();
            _completeLoading = null;
          },
        ),
      )
      ..addJavaScriptChannel(
        'CameraSettings',
        onMessageReceived: (message) async {
          if (message.message == 'open') {
            await openAppSettings();
          }
        },
      )
      ..addJavaScriptChannel(
        'AppReady',
        onMessageReceived: (message) {
          debugPrint('🌐 AppReady inside');
          if (message.message == 'ready' && mounted) {
            debugPrint('🌐 AppReady inside ready');
            setState(() => _webViewReady = true);
          }
        },
      );

    if (_controller.platform is AndroidWebViewController) {
      final androidController =
          _controller.platform as AndroidWebViewController;

      androidController.setOnPlatformPermissionRequest((request) async {
      var status = await Permission.camera.status;

      if (!status.isGranted) {
        _suppressLock = true; // диалог вызовет inactive/paused
        status = await Permission.camera.request();

        // Страховка: если resumed не пришёл, не оставляем флаг навсегда
        Future.delayed(const Duration(milliseconds: 500), () {
          _suppressLock = false;
        });
      }

      if (status.isGranted) {
        await request.grant();
      } else {
        await request.deny();
      }
    });
    }

    _initializeWebView();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.hidden ||
  //       state == AppLifecycleState.paused) {
  //     widget.authStore.lock();
  //   }
  // }

  bool _suppressLock = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        if (!_suppressLock) widget.authStore.lock();
        break;
      case AppLifecycleState.resumed:
        // Вернулись из системного диалога/внешнего экрана
        _suppressLock = false;
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  Uri _versionedUri(String? version) {
    final uri = Uri.parse(widget.url);

    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        if (version != null) 'v': version,
      },
    );
  }

  Future<void> _initializeWebView() async {
    setState(() => _updatingWebView = true);

    final prefs = await SharedPreferences.getInstance();
    _loadedVersion = prefs.getString('loaded_web_version');

    final latestVersion = await VersionService.getVersion();

    if (!mounted) return;

    // No saved version: force a fresh initial load.
    final needsUpdate = latestVersion != null &&
        latestVersion != _loadedVersion;

    await _loadWebView(
      version: latestVersion ?? _loadedVersion,
      clearCache: needsUpdate,
      saveVersion: needsUpdate ? latestVersion : null,
    );
  }

  Future<void> _loadWebView({
    required String? version,
    bool clearCache = false,
    String? saveVersion,
  }) async {
    if (!mounted) return;

    setState(() {
      _updatingWebView = true;
      _webViewReady = false;
      _hasError = false;
      _progress = 0;
    });

    _pendingVersion = saveVersion;
    _mainPageFailed = false;

    try {
      if (clearCache) {
        await _controller.clearCache();
      }

      // Create a completion signal before starting navigation.
      final completer = _PageLoadSignal();
      _loadingFuture = completer.future;
      _completeLoading = completer.complete;

      await _controller.loadRequest(_versionedUri(version));

      // Wait for the main page to finish, with a timeout.
      await _loadingFuture!.timeout(
        const Duration(seconds: 30),
      );

      if (_mainPageFailed) {
        throw Exception('WebView loading failed');
      }

      if (_pendingVersion != null) {
        final expectedVersion = _pendingVersion!;
        var actualVersion = await _getLoadedVersion();

        if (actualVersion != expectedVersion) {
          debugPrint(
            'Version mismatch: expected=$expectedVersion, actual=$actualVersion',
          );

          // Retry once with a cache-busting URL.
          final retryUri = _versionedUri(expectedVersion).replace(
            queryParameters: {
              ..._versionedUri(expectedVersion).queryParameters,
              '_refresh': DateTime.now().millisecondsSinceEpoch.toString(),
            },
          );

          await _controller.clearCache();

          final completer = _PageLoadSignal();
          _loadingFuture = completer.future;
          _completeLoading = completer.complete;
          _mainPageFailed = false;

          await _controller.loadRequest(retryUri);

          await _loadingFuture!.timeout(
            const Duration(seconds: 30),
          );

          if (_mainPageFailed) {
            throw Exception('WebView reload failed');
          }

          actualVersion = await _getLoadedVersion();
        }

        if (actualVersion == expectedVersion) {
          _loadedVersion = expectedVersion;
          await _saveVersion(expectedVersion);

          debugPrint('WebView updated: $expectedVersion');
        } else {
          debugPrint(
            'Version still differs: expected=$expectedVersion, actual=$actualVersion',
          );

          // Do not save an unconfirmed version.
          // Keep the WebView usable and retry on the next version check.
        }
      }

      // if (mounted) {
      //   setState(() => _webViewReady = true);
      // }
    } catch (e, stackTrace) {
      debugPrint('❌ WebView ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        setState(() => _hasError = true);
      }
    } finally {
      _pendingVersion = null;
      _completeLoading = null;
      _loadingFuture = null;

      if (mounted) {
        setState(() => _updatingWebView = false);
      }
    }
  }

  // Future<bool> _confirmLoadedVersion(String expected) async {
  //   try {
  //     final result = await _controller.runJavaScriptReturningResult(
  //       "document.querySelector('meta[name=\"app-version\"]')"
  //       "?.content ?? ''",
  //     );

  //     final actual = result.toString().replaceAll('"', '');

  //     return actual == expected;
  //   } catch (_) {
  //     return false;
  //   }
  // }
  Future<String?> _getLoadedVersion() async {
    try {
      final result = await _controller.runJavaScriptReturningResult(
        "document.querySelector('meta[name=\"app-version\"]')?.content ?? ''",
      );

      final version = result.toString().replaceAll('"', '').trim();

      return version.isEmpty ? null : version;
    } catch (e) {
      debugPrint('Version check failed: $e');
      return null;
    }
  }

  Future<void> _saveVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'loaded_web_version',
      version,
    );
  }

  Future<void> _checkVersion() async {
    if (_checkingVersion || _updatingWebView) return;

    _checkingVersion = true;

    try {
      final latestVersion = await VersionService.getVersion();

      if (!mounted || latestVersion == null) return;
      if (latestVersion == _loadedVersion) return;

      await _loadWebView(
        version: latestVersion,
        clearCache: true,
        saveVersion: latestVersion,
      );
    } finally {
      _checkingVersion = false;
    }
  }

  Future<void> _verifyPin(String pin) async {
    if (_pinLoading) return;

    setState(() {
      _pinLoading = true;
      _pinError = '';
    });

    try {
      await widget.authStore.verifyPin(pin);

      if (!mounted) return;

      // Keep PIN screen visible while checking for updates.
      while (_updatingWebView) {
        await Future.delayed(
          const Duration(milliseconds: 100),
        );
        if (!mounted) return;
      }

      await _checkVersion();

      if (!mounted) return;

      if (_hasError || !_webViewReady) {
        setState(() {
          _pinError = 'Не удалось загрузить приложение';
        });
        return;
      }

      widget.authStore.unlock();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _pinError = 'Неверный PIN-код';
      });

      _pinKey.currentState?.reset();
    } finally {
      if (mounted) {
        setState(() => _pinLoading = false);
      }
    }
  }

  void _reload() {
    _loadWebView(
      version: _loadedVersion,
      clearCache: true,
    );
  }

  void _recoverPin() {
    // TODO: Navigate to PIN recovery flow.
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.authStore.removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locked = !widget.authStore.isUnlocked;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || locked) return;

        final result = await _controller.runJavaScriptReturningResult(
          'window.handleAndroidBack?.() ?? false',
        );
        final canGoBack = await _controller.canGoBack();
        debugPrint('🌐 Go back: result=$result, canGoBack=$canGoBack');
        if (result == false && canGoBack) {
          await _controller.goBack();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
           SafeArea(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),

                  // Top progress bar
                  if (_progress < 100 && !_hasError && !locked)
                    LinearProgressIndicator(
                      value: _progress / 100,
                      minHeight: 2,
                      color: AppColors.primary,
                      backgroundColor: Colors.transparent,
                    ),

                  // Centered logo while loading
                  if (!_webViewReady && !_hasError && !locked)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: BaseIcon('logo-black', height: 32),
                      ),
                    ),

                  // Error screen
                  if (_hasError && !locked)
                    Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Не удалось загрузить страницу'),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _reload,
                            child: const Text('Повторить'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            if (locked)
              Positioned.fill(
                child: PinCodeScreen(
                  key: _pinKey,
                  mode: PinMode.enter,
                  userName: widget.authStore.userName,
                  loading: _pinLoading,
                  error: _pinError,
                  onComplete: _verifyPin,
                  onRecover: _recoverPin,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PageLoadSignal {
  final _completer = _CompleterWrapper();

  Future<void> get future => _completer.future;

  void complete() => _completer.complete();
}

class _CompleterWrapper {
  final _completer = Completer<void>();

  Future<void> get future => _completer.future;

  void complete() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }
}
