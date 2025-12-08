/// Pattern Result pour gestion d'erreurs fonctionnelle.
///
/// Inspiré de Rust, Kotlin et Swift, ce pattern permet
/// de gérer les succès et échecs de manière explicite.
///
/// ### Pourquoi Result Pattern?
/// - Pas d'exceptions silencieuses
/// - Gestion d'erreur explicite
/// - Code plus lisible
/// - Meilleure testabilité
///
/// ### Exemple d'utilisation:
/// ```dart
/// // Dans un Repository
/// Future<Result<User>> getUser(String id) async {
///   try {
///     final user = await api.getUser(id);
///     return Success(user);
///   } catch (e) {
///     return Failure('Utilisateur non trouvé');
///   }
/// }
///
/// // Utilisation
/// final result = await userRepo.getUser('123');
/// result.when(
///   success: (user) => print('User: ${user.name}'),
///   failure: (error) => print('Error: $error'),
/// );
/// ```
library;

/// Type de résultat: Succès ou Échec.
///
/// Sealed class garantissant que toutes les possibilités
/// sont gérées par le compilateur.
sealed class Result<T> {
  const Result();

  /// Vérifie si le résultat est un succès.
  bool get isSuccess => this is Success<T>;

  /// Vérifie si le résultat est un échec.
  bool get isFailure => this is Failure<T>;

  /// Récupère la valeur ou null si échec.
  T? get valueOrNull {
    return switch (this) {
      Success(value: final v) => v,
      Failure() => null,
    };
  }

  /// Récupère le message d'erreur ou null si succès.
  String? get errorOrNull {
    return switch (this) {
      Success() => null,
      Failure(message: final m) => m,
    };
  }

  /// Pattern matching sur le résultat.
  ///
  /// [success] - Callback appelé si succès avec la valeur
  /// [failure] - Callback appelé si échec avec le message
  ///
  /// ```dart
  /// result.when(
  ///   success: (value) => emit(Loaded(value)),
  ///   failure: (error) => emit(Error(error)),
  /// );
  /// ```
  R when<R>({
    required R Function(T value) success,
    required R Function(String message) failure,
  }) {
    return switch (this) {
      Success(value: final v) => success(v),
      Failure(message: final m) => failure(m),
    };
  }

  /// Transforme la valeur si succès.
  ///
  /// ```dart
  /// final result = Success(10);
  /// final doubled = result.map((v) => v * 2); // Success(20)
  /// ```
  Result<R> map<R>(R Function(T value) mapper) {
    return switch (this) {
      Success(value: final v) => Success(mapper(v)),
      Failure(message: final m) => Failure(m),
    };
  }

  /// Chaîne un autre résultat si succès.
  ///
  /// ```dart
  /// final result = Success(10);
  /// final chained = result.flatMap((v) =>
  ///   v > 0 ? Success(v * 2) : Failure('Valeur négative')
  /// );
  /// ```
  Result<R> flatMap<R>(Result<R> Function(T value) mapper) {
    return switch (this) {
      Success(value: final v) => mapper(v),
      Failure(message: final m) => Failure(m),
    };
  }

  /// Récupère la valeur ou une valeur par défaut.
  ///
  /// ```dart
  /// final value = result.getOrElse(() => defaultValue);
  /// ```
  T getOrElse(T Function() defaultValue) {
    return switch (this) {
      Success(value: final v) => v,
      Failure() => defaultValue(),
    };
  }

  /// Récupère la valeur ou lance une exception.
  ///
  /// À utiliser avec précaution!
  T getOrThrow() {
    return switch (this) {
      Success(value: final v) => v,
      Failure(message: final m) => throw Exception(m),
    };
  }
}

/// Résultat de succès contenant une valeur.
class Success<T> extends Result<T> {
  /// La valeur encapsulée
  final T value;

  /// Crée un résultat de succès.
  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Résultat d'échec contenant un message d'erreur.
class Failure<T> extends Result<T> {
  /// Message d'erreur descriptif
  final String message;

  /// Exception originale (optionnelle)
  final Exception? exception;

  /// Stack trace pour debugging
  final StackTrace? stackTrace;

  /// Crée un résultat d'échec.
  const Failure(
    this.message, {
    this.exception,
    this.stackTrace,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'Failure($message)';
}

/// Extensions pour conversion facile.
extension ResultExtensions<T> on Future<T> {
  /// Convertit un Future en Result automatiquement.
  ///
  /// ```dart
  /// final result = await api.getUser(id).toResult('Erreur réseau');
  /// ```
  Future<Result<T>> toResult([String? defaultErrorMessage]) async {
    try {
      final value = await this;
      return Success(value);
    } catch (e, stack) {
      return Failure(
        defaultErrorMessage ?? e.toString(),
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stack,
      );
    }
  }
}

/// Helper pour exécuter une fonction et retourner un Result.
///
/// ```dart
/// final result = await runCatching(() async {
///   return await api.fetchData();
/// });
/// ```
Future<Result<T>> runCatching<T>(Future<T> Function() action) async {
  try {
    final value = await action();
    return Success(value);
  } catch (e, stack) {
    return Failure(
      e.toString(),
      exception: e is Exception ? e : Exception(e.toString()),
      stackTrace: stack,
    );
  }
}
