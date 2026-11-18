import 'package:flutter/foundation.dart';
import 'package:mini_reseau_social/core/constants/app_strings.dart';
import 'package:mini_reseau_social/core/errors/app_exception.dart';

/// Contrôleur de base : état « occupé », message d'erreur et protection contre
/// les notifications envoyées après `dispose` (réponses asynchrones tardives).
abstract class BaseController extends ChangeNotifier {
  bool _isDisposed = false;
  bool _isBusy = false;
  String? _errorMessage;

  bool get isBusy => _isBusy;

  String? get errorMessage => _errorMessage;

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Exécute [action] en capturant les erreurs. Retourne `true` en cas de
  /// succès ; sinon [errorMessage] contient un message affichable.
  Future<bool> runGuarded(
    Future<void> Function() action, {
    bool showBusy = true,
  }) async {
    if (showBusy) _isBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AppException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = AppStrings.unexpectedError;
      return false;
    } finally {
      if (showBusy) _isBusy = false;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
