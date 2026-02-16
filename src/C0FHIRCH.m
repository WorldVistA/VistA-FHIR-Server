C0FHIRCH ;VAMC/JS-FHIR SUITE ENVIRONMENT CHECK ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
EN ; Entry point for KIDS environment check
 N FAIL S FAIL=0
 D MES^XPDUTL("  Starting Environment Check for C0FHIR Suite Build 2...")
 ;
 ; 1. Check for Data Discovery Engine (DDE) Global
 I $D(^DDE)=0 D
 . D BMES^XPDUTL("  [FAIL] Data Discovery Engine (^DDE) is not present.")
 . D MES^XPDUTL("         Please ensure the VPR/DDE package is installed first.")
 . S FAIL=1
 ;
 ; 2. Check for Web Service File (#18.12)
 I $G(^DIC(18.12,0))="" D
 . D BMES^XPDUTL("  [FAIL] Web Service file (#18.12) is missing or corrupted.")
 . D MES^XPDUTL("         Kernel Web Services must be active on this system.")
 . S FAIL=1
 ;
 ; 3. Verify Required Versions
 I $$VERSION^XPDUTL("XU")<8.0 D
 . D BMES^XPDUTL("  [FAIL] Kernel version 8.0 or higher is required.")
 . S FAIL=1
 ;
 ; Final Result
 I FAIL D
 . S XPDQUIT=2 ; Stop the install but keep the transport global
 . D BMES^XPDUTL("  INSTALL ABORTED: System does not meet minimum requirements.")
 E  D
 . D BMES^XPDUTL("  SUCCESS: System ready for C0FHIR v1.2.")
 Q