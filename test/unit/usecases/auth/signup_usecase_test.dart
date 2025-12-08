import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mukhlissmagasin/features/auth/domain/entities/user.dart';
import 'package:mukhlissmagasin/features/auth/domain/usecases/signup_usecase.dart';

// Import le mock généré (même mock que login)
import 'login_usecase_test.mocks.dart';

/// 🧪 TESTS USE CASE - SIGNUP
/// 
/// Tests complets du SignUpUseCase avec mocking du repository
/// Pattern AAA (Arrange, Act, Assert)
/// 
/// COUVERTURE:
/// - Signup succès avec données minimales
/// - Signup avec toutes les données
/// - Signup avec erreurs  
/// - Validation paramètres

void main() {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SETUP
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  late SignUpUseCase signUpUseCase;
  late MockAuthRepository mockAuthRepository;
  
  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signUpUseCase = SignUpUseCase(mockAuthRepository);
  });
  
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS SUCCÈS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  group('SignUp UseCase - Succès', () {
    
    // ✅ TEST 1: Signup avec données minimales (email + password)
    test('signup avec email et password valides retourne AppUser', () async {
      // ARRANGE
      const email = 'nouveau@mukhliss.com';
      const password = 'Password123!';
      final expectedUser = AppUser(
        id: 'new-user-123',
        email: email,
        name: null,
      );
      
      when(mockAuthRepository.signUp(
        email: email,
        password: password,
        firstName: null,
        lastName: null,
        phone: null,
        address: null,
        siret: null,
      )).thenAnswer((_) async => expectedUser);
      
      // ACT
      final result = await signUpUseCase.execute(
        email: email,
        password: password,
      );
      
      // ASSERT
      expect(result, isNotNull);
      expect(result?.id, equals('new-user-123'));
      expect(result?.email, equals(email));
      
      // Vérifier que signUp a été appelé avec bons params
      verify(mockAuthRepository.signUp(
        email: email,
        password: password,
        firstName: null,
        lastName: null,
        phone: null,
        address: null,
        siret: null,
      )).called(1);
    });
    
    // ✅ TEST 2: Signup avec toutes les données
    test('signup avec toutes les informations retourne user complet', () async {
      // ARRANGE
      const email = 'magasin@mukhliss.com';
      const password = 'SecurePass456!';
      const firstName = 'Mohamed';
      const lastName = 'Alami';
      const phone = '+212612345678';
      const address = '123 Rue Hassan II, Casablanca';
      const siret = '12345678901234';
      
      final expectedUser = AppUser(
        id: 'user-456',
        email: email,
        name: '$firstName $lastName',
      );
      
      when(mockAuthRepository.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        address: address,
        siret: siret,
      )).thenAnswer((_) async => expectedUser);
      
      // ACT
      final result = await signUpUseCase.execute(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        address: address,
        siret: siret,
      );
      
      // ASSERT
      expect(result, isNotNull);
      expect(result?.email, equals(email));
      expect(result?.name, contains(firstName));
      expect(result?.name, contains(lastName));
      
      // Vérifier tous les paramètres passés
      verify(mockAuthRepository.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
        phone: anyNamed('phone'),
        address: anyNamed('address'),
        siret: anyNamed('siret'),
      )).called(1);
    });
    
    // ✅ TEST 3: Signup avec seulement prénom
    test('signup avec firstName seulement fonctionne', () async {
      // ARRANGE
      const email = 'test@mukhliss.com';
      const password = 'Pass123';
      const firstName = 'Ahmed';
      
      final expectedUser = AppUser(
        id: 'user-789',
        email: email,
        name: firstName,
      );
      
      when(mockAuthRepository.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
        phone: anyNamed('phone'),
        address: anyNamed('address'),
        siret: anyNamed('siret'),
      )).thenAnswer((_) async => expectedUser);
      
      // ACT
      final result = await signUpUseCase.execute(
        email: email,
        password: password,
        firstName: firstName,
      );
      
      // ASSERT
      expect(result, isNotNull);
      expect(result?.name, equals(firstName));
    });
  });
  
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS ÉCHEC
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  group('SignUp UseCase - Échec', () {
    
    // ❌ TEST 4: Signup avec email existant retourne null
    test('signup avec email déjà utilisé retourne null', () async {
      // ARRANGE
      const existingEmail = 'existant@mukhliss.com';
      const password = 'Password123';
      
      // Repository retourne null si email existe
      when(mockAuthRepository.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
        phone: anyNamed('phone'),
        address: anyNamed('address'),
        siret: anyNamed('siret'),
      )).thenAnswer((_) async => null);
      
      // ACT
      final result = await signUpUseCase.execute(
        email: existingEmail,
        password: password,
      );
      
      // ASSERT
      expect(result, isNull);
    });
    
    // ❌ TEST 5: Signup avec exception réseau
    test('signup avec erreur réseau throw exception', () async {
      // ARRANGE
      const email = 'test@mukhliss.com';
      const password = 'Pass123';
      
      when(mockAuthRepository.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
        phone: anyNamed('phone'),
        address: anyNamed('address'),
        siret: anyNamed('siret'),
      )).thenThrow(Exception('Erreur réseau'));
      
      // ACT & ASSERT
      expect(
        () => signUpUseCase.execute(email: email, password: password),
        throwsException,
      );
    });
    
    // ❌ TEST 6: Signup avec timeout
    test('signup avec timeout throw exception', () async {
      // ARRANGE
      const email = 'test@mukhliss.com';
      const password = 'Pass123';
      
      when(mockAuthRepository.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
        phone: anyNamed('phone'),
        address: anyNamed('address'),
        siret: anyNamed('siret'),
      )).thenThrow(Exception('Timeout'));
      
      // ACT & ASSERT
      expect(
        () => signUpUseCase.execute(email: email, password: password),
        throwsA(isA<Exception>()),
      );
    });
  });
  
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS PARAMÈTRES OPTIONNELS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  group('SignUp UseCase - Paramètres Optionnels', () {
    
    // 🔍 TEST 7: Signup passe null pour paramètres non fournis
    test('signup avec params optionnels omis passe null au repository', () async {
      // ARRANGE
      const email = 'test@mukhliss.com';
      const password = 'Pass123';
      
      when(mockAuthRepository.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
        phone: anyNamed('phone'),
        address: anyNamed('address'),
        siret: anyNamed('siret'),
      )).thenAnswer((_) async => AppUser(id: 'test', email: email));
      
      // ACT
      await signUpUseCase.execute(
        email: email,
        password: password,
        // Tous les autres params omis = null
      );
      
      // ASSERT: Vérifier que firstName est null
      verify(mockAuthRepository.signUp(
        email: email,
        password: password,
        firstName: null, // Explicitement null
        lastName: null,
        phone: null,
        address: null,
        siret: null,
      )).called(1);
    });
  });
}
