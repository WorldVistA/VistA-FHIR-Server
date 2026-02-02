C0FHIRUT ;VAMC/JS-FHIR SUITE M-UNIT TESTS ; 30-JAN-2026
 ;;1.2;C0FHIR PROJECT;;Jan 30, 2026;Build 3
 ;
EN ; Run all tests
 D EN^XTMUNIT("C0FHIRUT")
 Q
 ;
SETUP ; Create Mock Data before EACH test
 ; We use a high IEN (999999) to avoid colliding with real patients
 S ^DPT(999999,0)="TESTPATIENT,MUNIT^M^2800101^^^999001111"
 S ^DPT(999999,.11)="123 Unit Test Way^^^Gaithersburg^MD^20877"
 Q
 ;
TEARDOWN ; Clean up Mock Data after EACH test
 K ^DPT(999999)
 Q
 ;
UTDATE ; Test Case: ISO8601 Date Conversion
 N ISO S ISO=$$ISO8601^C0FHIRUTL(3260130.1230)
 D CHKEQ^XTMUNIT(ISO,"2026-01-30T12:30:00Z","Date conversion failed")
 Q
 ;
UTBNDL ; Test Case: FHIR Bundle with Mock Patient
 N RES,DFN S DFN=999999
 D GENFULL^C0FHIRGF(.RES,DFN,"","","")
 ; Check that the aggregator found our mock patient
 D CHKTF^XTMUNIT($D(RES)>0,"Aggregator failed to find mock patient")
 D CHKTF^XTMUNIT(RES(1)["TESTPATIENT","JSON did not contain mock patient name")
 Q
 ;
UTSRCH ; Test Case: Name Search for Mock Patient
 N FILTER,RTN,TYPE
 S FILTER("name")="TESTPATIENT"
 D WEB^C0FHIRWS(.RTN,.TYPE,.FILTER)
 D CHKEQ^XTMUNIT(TYPE,"text/html","Search mode should return HTML")
 D CHKTF^XTMUNIT(RTN(2)["TESTPATIENT","Search result did not find mock patient")
 Q