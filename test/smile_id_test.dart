import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:smile_id/generated/smileid_messages.g.dart';
import 'package:smile_id/smile_id.dart';

@GenerateNiceMocks([MockSpec<SmileIDApi>()])
@GenerateNiceMocks([MockSpec<FlutterAuthenticationRequest>()])
@GenerateNiceMocks([MockSpec<FlutterEnhancedKycRequest>()])
import 'smile_id_test.mocks.dart';

void main() {
  setUp(() {
    final SmileIDApi platformInterface = MockSmileIDApi();
    SmileID.platformInterface = platformInterface;
  });

  test("initialize call is proxied", () {
    SmileID.initialize(useSandbox: true, enableCrashReporting: true);
    verify(SmileID.platformInterface.initialize(true, true));
  });

  test("initialize completes when native initialization succeeds", () async {
    when(SmileID.platformInterface.initialize(true, true))
        .thenAnswer((_) => Future.value());
    await expectLater(
        SmileID.initialize(useSandbox: true, enableCrashReporting: true),
        completes);
  });

  test("initialize propagates a native initialization failure", () async {
    when(SmileID.platformInterface.initialize(true, true)).thenAnswer(
        (_) => Future.error(PlatformException(code: "initialization_failed")));
    await expectLater(
        SmileID.initialize(useSandbox: true, enableCrashReporting: true),
        throwsA(isA<PlatformException>()));
  });

  test("initializeWithConfig propagates a native initialization failure",
      () async {
    final FlutterConfig config = FlutterConfig(
        partnerId: "partner-id",
        authToken: "auth-token",
        prodBaseUrl: "https://prod.example.com",
        sandboxBaseUrl: "https://sandbox.example.com");
    when(SmileID.platformInterface.initializeWithConfig(config, false, true))
        .thenAnswer((_) =>
            Future.error(PlatformException(code: "initialization_failed")));
    await expectLater(
        SmileID.initializeWithConfig(
            config: config, useSandbox: false, enableCrashReporting: true),
        throwsA(isA<PlatformException>()));
  });

  test("initializeWithApiKey propagates a native initialization failure",
      () async {
    final FlutterConfig config = FlutterConfig(
        partnerId: "partner-id",
        authToken: "auth-token",
        prodBaseUrl: "https://prod.example.com",
        sandboxBaseUrl: "https://sandbox.example.com");
    when(SmileID.platformInterface
            .initializeWithApiKey("api-key", config, false, true))
        .thenAnswer((_) =>
            Future.error(PlatformException(code: "initialization_failed")));
    await expectLater(
        SmileID.initializeWithApiKey(
            apiKey: "api-key",
            config: config,
            useSandbox: false,
            enableCrashReporting: true),
        throwsA(isA<PlatformException>()));
  });

  test("authenticate call is proxied", () {
    final FlutterAuthenticationRequest request =
        MockFlutterAuthenticationRequest();
    SmileID.api.authenticate(request);
    verify(SmileID.platformInterface.authenticate(request));
  });

  test("enhanced kyc async is proxied", () {
    final FlutterEnhancedKycRequest request = MockFlutterEnhancedKycRequest();
    SmileID.api.doEnhancedKycAsync(request);
    verify(SmileID.api.platformInterface.doEnhancedKycAsync(request));
  });
}
