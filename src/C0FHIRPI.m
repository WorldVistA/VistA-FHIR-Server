C0FHIRPI ;VAMC/JS-FHIR SUITE KIDS POST-INSTALL ; 30-JAN-2026
 ;;1.2;C0FHIR PROJECT;;Jan 30, 2026;Build 3
 Q
POST ; Entry point called by KIDS
 D BMES^XPDUTL("  Starting Post-Install Configuration for C0FHIR...")
 ;
 ; 1. Standard VistA Environment Setup (RPCs and Options)
 D EN^C0FHIRSET
 ;
 ; 2. Register Web Service Endpoint
 D BMES^XPDUTL("  Registering fhir Web Service endpoint...")
 D addService^%webutils("GET","fhir","WEB^C0FHIRWS")
 ;
 D BMES^XPDUTL("  Post-Install Configuration Complete.")
 Q