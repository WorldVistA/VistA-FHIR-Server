C0FHIRCH ;VAMC/JS-FHIR SUITE INSTALLATION VALIDATOR ; 30-JAN-2026
 ;;1.2;C0FHIR PROJECT;;Jan 30, 2026;Build 3
 Q
EN ; Main entry point for environment check
 N PASS,FAIL,ERR S (PASS,FAIL)=0
 W !!,"--- C0FHIR Environment Validation Tool ---",!
 ;
 ; 1. Check RPC Registration
 W !,"Checking RPC 'C0FHIR GET FULL BUNDLE'..."
 I $O(^DIC(8994,"B","C0FHIR GET FULL BUNDLE",0)) D  E  D ERR("RPC not found in File #8994")
 . W " OK." S PASS=PASS+1
 ;
 ; 2. Check Context Option
 W !,"Checking Option 'C0FHIR CONTEXT'..."
 N OPT S OPT=$O(^DIC(19,"B","C0FHIR CONTEXT",0))
 I OPT D  E  D ERR("Option not found in File #19")
 . W " OK." S PASS=PASS+1
 . ; Check if RPC is linked to Option
 . I $D(^DIC(19,OPT,10,"B",+$O(^DIC(8994,"B","C0FHIR GET FULL BUNDLE",0)))) D
 .. W !,"  - RPC Linkage... OK." S PASS=PASS+1
 . E  D ERR("RPC is not linked to the Context Option")
 ;
 ; 3. Check Web Service Endpoint
 W !,"Checking Web Service 'GET /fhir'..."
 ; This logic assumes %webutils stores metadata in a standard global or index
 I $$GETS^%webutils("GET","fhir")'="" D  E  D ERR("Web Service '/fhir' is not registered")
 . W " OK." S PASS=PASS+1
 . ; Verify Routine exists
 . I $L($T(WEB^C0FHIRWS)) D
 .. W !,"  - Entry Point (WEB^C0FHIRWS)... OK." S PASS=PASS+1
 . E  D ERR("Routine C0FHIRWS or tag WEB is missing")
 ;
 ; 4. Summary
 W !!, "Validation Summary: "_PASS_" Passed, "_FAIL_" Failed."
 I FAIL>0 W !!,"*** WARNING: One or more components are not configured correctly! ***"
 E  W !!,"CONGRATULATIONS: The C0FHIR suite is fully operational."
 Q
 ;
ERR(MSG) ; Log error
 W " FAIL!"
 W !,"  [ERROR]: "_MSG
 S FAIL=FAIL+1
 Q