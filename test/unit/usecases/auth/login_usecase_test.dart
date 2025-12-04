import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mukhlissmagasin/features/auth/domain/entities/user.dart';
import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/auth/domain/usecases/login_usecase.dart';

// Génère le mock avec: flutter pub run build_runner build
@GenerateMocks([AuthRepository])
import 'login_usecase_test.mocks.dart';

/// 🧪 TESTS USE CASE - LOGIN
/// 
/// Tests complets du LoginUseCase avec mocking du repository
/// Pattern AAA (Arrange, Act, Assert)
/// 
/// COUVERTURE:
/// - Login succès
/// - Login avec erreurs
/// - Validation paramètres
/// - Gestion exceptions

void main() {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SETUP
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  late LoginUseCase loginUseCase;
  late MockAuthRepository mockAuthRepository;
  
  setUp(() {
    // Créer mock repository
    mockAuthRepository = MockAuthRepository();
    
    // Créer use case avec mock
    loginUseCase = LoginUseCase(mockAuthRepository);
  });
  
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS SUCCÈS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  group('Login UseCase - Succès', () {
    
    // ✅ TEST 1: Login avec credentials valides retourne user
    test('login avec email et password valides retourne AppUser', () async {
      // ARRANGE: Préparer
      const email = 'test@mukhliss.com';
      const password = 'Password123!';
      final expectedUser = AppUser(
        id: 'user-123',
        email: email,
        name: 'Test User',
      );
      
      // Configurer le mock pour retourner user
      when(mockAuthRepository.login(email, password))
          .thenAnswer((_) async => expectedUser);
      
      // ACT: Exécuter
      final result = await loginUseCase.call(email, password);
      
      // ASSERT: Vérifier
      expect(result, isNotNull);
      expect(result, equals(expectedUser));
      expect(result?.id, equals('user-123'));
      expect(result?.email, equals(email));
      
      // Vérifier que repository.login a été appelé une fois
      verify(mockAuthRepository.login(email, password)).called(1);
    });
    
    // ✅ TEST 2: Login appelle repository avec bons paramètres
    test('login passe les paramètres corrects au repository', () async {
      // ARRANGE
      const email = 'magasin@mukhliss.com';
      const password = 'SecurePass456';
      
      when(mockAuthRepository.login(any, any))
          .thenAnswer((_) async => AppUser(id: 'test', email: email));
      
      // ACT
      await loginUseCase.call(email, password);
      
      // ASSERT: Vérifier paramètres exacts
      verify(mockAuthRepository.login(email, password)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
    
    // ✅ TEST 3: Login avec user ayant metadata
    test('login retourne user avec toutes les métadonnées', () async {
      // ARRANGE
      const email = 'admin@mukhliss.com';
      const password = 'AdminPass789';
      final userWithMetadata = AppUser(
        id: 'admin-456',
        email: email,
        name: 'Admin Mukhliss',
      );
      
      when(mockAuthRepository.login(email, password))
          .thenAnswer((_) async => userWithMetadata);
      
      // ACT
      final result = await loginUseCase.call(email, password);
      
      // ASSERT
      expect(result, isNotNull);
      expect(result?.name, equals('Admin Mukhliss'));
    });
  });
  
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS ÉCHEC
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  group('Login UseCase - Échec', () {
    
    // ❌ TEST 4: Login avec credentials invalides retourne null
    test('login avec password incorrect retourne null', () async {
      // ARRANGE
      const email = 'test@mukhliss.com';
      const wrongPassword = 'WrongPassword';
      
      // Mock retourne null (échec login)
      when(mockAuthRepository.login(email, wrongPassword))
          .thenAnswer((_) async => null);
      
      // ACT
      final result = await loginUseCase.call(email, wrongPassword);
      
      // ASSERT
      expect(result, isNull);
      verify(mockAuthRepository.login(email, wrongPassword)).called(1);
    });
    
    // ❌ TEST 5: Login avec email inexistant retourne null
    test('login avec email inexistant retourne null', () async {
      // ARRANGE
      const nonExistentEmail = 'inexistant@mukhliss.com';
      const password = 'SomePassword';
      
      when(mockAuthRepository.login(nonExistentEmail, password))
          .thenAnswer((_) async => null);
      
      // ACT
      final result = await loginUseCase.call(nonExistentEmail, password);
      
      // ASSERT
      expect(result, isNull);
    });
    
    // ❌ TEST 6: Login avec exception repository throw error
    test('login propage exception du repository', () async {
      // ARRANGE
      const email = 'test@mukhliss.com';
      const password = 'Password123';
      
      // Mock throw une exception
      when(mockAuthRepository.login(email, password))
          .thenThrow(Exception('Erreur réseau'));
      
      // ACT & ASSERT: Vérifier que l'exception est propagée
      expect(
        () => loginUseCase.call(email, password),
        throwsException,
      );
    });
    
    // ❌ TEST 7: Login avec timeout exception
    test('login avec timeout throw exception', () async {
      // ARRANGE
      const email = 'test@mukhliss.com';
      const password = 'Password123';
      
      when(mockAuthRepository.login(email, password))
          .thenThrow(Exception('Timeout'));
      
      // ACT & ASSERT
      expect(
        () => loginUseCase.call(email, password),
        throwsA(isA<Exception>()),
      );
    });
  });
  
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS CAS LIMITES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  group('Login UseCase - Cas Limites', () {
    
    // 🔍 TEST 8: Login avec champs vides
    test('login avec email vide appelle quand même repository', () async {
      // ARRANGE
      const emptyEmail = '';
      const password = 'Password123';
      
      when(mockAuthRepository.login(emptyEmail, password))
          .thenAnswer((_) async => null);
      
      // ACT
      final result = await loginUseCase.call(emptyEmail, password);
      
      // ASSERT
      // Le UseCase ne valide pas, ça sera fait par le repository ou UI
      expect(result, isNull);
      verify(mockAuthRepository.login(emptyEmail, password)).called(1);
    });
  });
}
