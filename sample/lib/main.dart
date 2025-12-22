import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smile_id/generated/smileid_messages.g.dart';
import 'package:smile_id/products/biometric/smile_id_biometric_kyc.dart';
import 'package:smile_id/products/capture/smile_id_document_capture_view.dart';
import 'package:smile_id/products/capture/smile_id_smart_selfie_capture_view.dart';
import 'package:smile_id/products/document/smile_id_document_verification.dart';
import 'package:smile_id/products/enhanceddocv/smile_id_enhanced_document_verification.dart';
import 'package:smile_id/products/enhancedselfie/smile_id_smart_selfie_authentication_enhanced.dart';
import 'package:smile_id/products/enhancedselfie/smile_id_smart_selfie_enrollment_enhanced.dart';
import 'package:smile_id/products/models/model.dart';
import 'package:smile_id/products/selfie/smile_id_smart_selfie_authentication.dart';
import 'package:smile_id/products/selfie/smile_id_smart_selfie_enrollment.dart';
import 'package:smile_id/smile_id.dart';

// ignore_for_file: avoid_print

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    SmileID.initialize(useSandbox: false, enableCrashReporting: true);
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Smile ID",
      // MainContent requires its own BuildContext for Navigator to work, hence it is defined as its
      // own widget
      home: MainContent(),
    );
  }
}

class MyScaffold extends StatelessWidget {
  final Widget body;

  const MyScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Smile ID"),
      ),
      body: body,
    );
  }
}

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        body: Center(
            child: Column(
      children: [
        enhancedKycAsyncButton(),
        documentVerificationButton(context),
        enhancedDocumentVerificationButton(context),
        smartSelfieEnrollmentButton(context),
        smartSelfieAuthenticationButton(context),
        smartSelfieEnrollmentButtonEnhanced(context),
        smartSelfieAuthenticationButtonEnhanced(context),
        biometricKycButton(context),
        selfieCaptureButton(context),
        documentCaptureButton(context)
      ],
    )));
  }

  Widget enhancedKycAsyncButton() {
    return ElevatedButton(
        child: const Text("Enhanced KYC (Async)"),
        onPressed: () {
          // replace with your own credentials
          // SmileID.initialize(useSandbox: false, enableCrashReporting: true);
          var config = FlutterConfig(
              partnerId: "partner-id-here",
              authToken: "auth-token-here",
              prodBaseUrl: "https://api.smileidentity.com/v1/",
              sandboxBaseUrl: "https://api.smileidentity.com/v1/");

          SmileID.initializeWithConfig(
            config: config,
            enableCrashReporting: true,
            useSandbox: false,
          );

          var userId = "<your user's user ID>";
          SmileID.api
              .authenticate(FlutterAuthenticationRequest(
                jobType: FlutterJobType.enhancedKyc,
                userId: userId,
              ))
              .then(
                  (authResponse) => {
                        SmileID.api.doEnhancedKycAsync(
                            FlutterEnhancedKycRequest(
                                country: "GH",
                                idType: "DRIVERS_LICENSE",
                                idNumber: "B0000000",
                                callbackUrl: "https://somedummyurl.com/demo",
                                partnerParams: FlutterPartnerParams(
                                    jobType: FlutterJobType.enhancedKyc,
                                    jobId: userId,
                                    userId: userId,
                                    extras: {
                                      "name": "Dummy Name",
                                      "work": "SmileID",
                                    }),
                                timestamp: authResponse!.timestamp,
                                signature: authResponse.signature,
                                consentInformation: FlutterConsentInformation(
                                    consentGrantedDate: "",
                                    personalDetailsConsentGranted: true,
                                    contactInfoConsentGranted: true,
                                    documentInfoConsentGranted: true)))
                      },
                  onError: (error) => {print("error: $error")});
        });
  }

  Widget documentVerificationButton(BuildContext context) {
    return ElevatedButton(
      child: const Text("Document Verification"),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => MyScaffold(
                body: SmileIDDocumentVerification(
              countryCode: "GH",
              documentType: "DRIVERS_LICENSE",
              autoCapture: AutoCaptureMode.autoCapture,
              autoCaptureTimeout: 10000,
              onSuccess: (String? result) {
                // Your success handling logic
                Map<String, dynamic> jsonResult = json.decode(result ?? '{}');
                String formattedResult = jsonEncode(jsonResult);
                final snackBar =
                    SnackBar(content: Text("Success: $formattedResult"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
              onError: (String errorMessage) {
                // Your error handling logic
                final snackBar =
                    SnackBar(content: Text("Error: $errorMessage"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
            )),
          ),
        );
      },
    );
  }

  Widget enhancedDocumentVerificationButton(BuildContext context) {
    return ElevatedButton(
      child: const Text("Enhanced Document Verification"),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => MyScaffold(
                body: SmileIDEnhancedDocumentVerification(
              countryCode: "GH",
              documentType: "DRIVERS_LICENSE",
              autoCapture: AutoCaptureMode.autoCapture,
              autoCaptureTimeout: 10000,
              onSuccess: (String? result) {
                // Your success handling logic
                Map<String, dynamic> jsonResult = json.decode(result ?? '{}');
                String formattedResult = jsonEncode(jsonResult);
                final snackBar =
                    SnackBar(content: Text("Success: $formattedResult"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
              onError: (String errorMessage) {
                // Your error handling logic
                final snackBar =
                    SnackBar(content: Text("Error: $errorMessage"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
            )),
          ),
        );
      },
    );
  }

  Widget smartSelfieEnrollmentButton(BuildContext context) {
    return ElevatedButton(
      child: const Text("SmartSelfie Enrollment"),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => MyScaffold(
                body: SmileIDSmartSelfieEnrollment(
              smileSensitivity: SmileSensitivity.normal,
              onSuccess: (String? result) {
                // Your success handling logic
                Map<String, dynamic> jsonResult = json.decode(result ?? '{}');
                String formattedResult = jsonEncode(jsonResult);
                final snackBar =
                    SnackBar(content: Text("Success: $formattedResult"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
              onError: (String errorMessage) {
                // Your error handling logic
                final snackBar =
                    SnackBar(content: Text("Error: $errorMessage"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
            )),
          ),
        );
      },
    );
  }

  Widget smartSelfieAuthenticationButton(BuildContext context) {
    return ElevatedButton(
      child: const Text("SmartSelfie Authentication"),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => MyScaffold(
                body: SmileIDSmartSelfieAuthentication(
              smileSensitivity: SmileSensitivity.normal,
              onSuccess: (String? result) {
                // Your success handling logic
                Map<String, dynamic> jsonResult = json.decode(result ?? '{}');
                String formattedResult = jsonEncode(jsonResult);
                final snackBar =
                    SnackBar(content: Text("Success: $formattedResult"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
              onError: (String errorMessage) {
                // Your error handling logic
                final snackBar =
                    SnackBar(content: Text("Error: $errorMessage"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
            )),
          ),
        );
      },
    );
  }

  Widget smartSelfieEnrollmentButtonEnhanced(BuildContext context) {
    return ElevatedButton(
      child: const Text("SmartSelfie Enrollment (Enhanced)"),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => MyScaffold(
                body: SmileIDSmartSelfieEnrollmentEnhanced(
              onSuccess: (String? result) {
                // Your success handling logic
                Map<String, dynamic> jsonResult = json.decode(result ?? '{}');
                String formattedResult = jsonEncode(jsonResult);
                final snackBar =
                    SnackBar(content: Text("Success: $formattedResult"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
              onError: (String errorMessage) {
                // Your error handling logic
                final snackBar =
                    SnackBar(content: Text("Error: $errorMessage"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
            )),
          ),
        );
      },
    );
  }

  Widget smartSelfieAuthenticationButtonEnhanced(BuildContext context) {
    return ElevatedButton(
      child: const Text("SmartSelfie Authentication (Enhanced)"),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => MyScaffold(
                body: SmileIDSmartSelfieAuthenticationEnhanced(
              onSuccess: (String? result) {
                // Your success handling logic
                Map<String, dynamic> jsonResult = json.decode(result ?? '{}');
                String formattedResult = jsonEncode(jsonResult);
                final snackBar =
                    SnackBar(content: Text("Success: $formattedResult"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
              onError: (String errorMessage) {
                // Your error handling logic
                final snackBar =
                    SnackBar(content: Text("Error: $errorMessage"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
            )),
          ),
        );
      },
    );
  }

  Widget biometricKycButton(BuildContext context) {
    return ElevatedButton(
      child: const Text("Biometric KYC"),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => MyScaffold(
                body: SmileIDBiometricKYC(
              country: "KE",
              idType: "NATIONAL_ID",
              idNumber: "12345678",
              onSuccess: (String? result) {
                // Your success handling logic
                Map<String, dynamic> jsonResult = json.decode(result ?? '{}');
                String formattedResult = jsonEncode(jsonResult);
                final snackBar =
                    SnackBar(content: Text("Success: $formattedResult"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
              onError: (String errorMessage) {
                // Your error handling logic
                final snackBar =
                    SnackBar(content: Text("Error: $errorMessage"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
            )),
          ),
        );
      },
    );
  }

  Widget selfieCaptureButton(BuildContext context) {
    return ElevatedButton(
      child: const Text("Selfie Capture"),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => MyScaffold(
                body: SmileIDSmartSelfieCaptureView(
              showConfirmationDialog: false,
              showInstructions: true,
              showAttribution: false,
              allowAgentMode: false,
              useStrictMode: false,
              smileSensitivity: SmileSensitivity.normal,
              onSuccess: (String? result) {
                // Your success handling logic
                Map<String, dynamic> jsonResult = json.decode(result ?? '{}');
                String formattedResult = jsonEncode(jsonResult);
                final snackBar =
                    SnackBar(content: Text("Success: $formattedResult"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
              onError: (String errorMessage) {
                // Your error handling logic
                final snackBar =
                    SnackBar(content: Text("Error: $errorMessage"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
            )),
          ),
        );
      },
    );
  }

  Widget documentCaptureButton(BuildContext context) {
    return ElevatedButton(
      child: const Text("Document Capture"),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => MyScaffold(
                body: SmileIDDocumentCaptureView(
              isDocumentFrontSide: false,
              showConfirmationDialog: true,
              showInstructions: true,
              showAttribution: false,
              allowGalleryUpload: false,
              onSuccess: (String? result) {
                // Your success handling logic
                Map<String, dynamic> jsonResult = json.decode(result ?? '{}');
                String formattedResult = jsonEncode(jsonResult);
                final snackBar =
                    SnackBar(content: Text("Success: $formattedResult"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
              onError: (String errorMessage) {
                // Your error handling logic
                final snackBar =
                    SnackBar(content: Text("Error: $errorMessage"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
            )),
          ),
        );
      },
    );
  }
}
