C0FHIRL3 ;VAMC/JS-FHIR ENTITY LOADER SAFETY & HISTORY ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
EN ; Entry point called by Master Loader
 N FDA,IEN,ERR
 ;
 ; --- Entity #31: FHIR ALLERGY ---
 S FDA(1.1,"+1,",.01)="FHIR ALLERGY"
 S FDA(1.1,"+1,",.02)=120.8 ; PATIENT ALLERGIES file
 S FDA(1.1,"+1,",.04)="Allergy"
 S FDA(1.1,"+1,",1)="FHIR"
 ; Use the "Get ID Action" from your report to setup GMRA variables
 S FDA(1.1,"+1,",1.1)="D ALG1^VPRSDAL(DIEN)"
 D UPDATE^DIE("","FDA","IEN")
 I $G(IEN(1)) D
 . K FDA S FDA(1.11,"+2,"_IEN(1)_",",.01)="Certainty"
 . S FDA(1.11,"+2,"_IEN(1)_",",.02)=8
 . S FDA(1.11,"+2,"_IEN(1)_",",.03)="ENTITY"
 . S FDA(1.11,"+2,"_IEN(1)_",",1.2)="S VALUE=$S(VALUE:""Confirmed"",1:"""")"
 . D UPDATE^DIE("","FDA")
 ;
 ; --- Entity #11: FHIR PROBLEM ---
 K FDA,IEN S FDA(1.1,"+1,",.01)="FHIR PROBLEM"
 S FDA(1.1,"+1,",.02)=9000011 ; PROBLEM file
 S FDA(1.1,"+1,",.04)="Problem"
 S FDA(1.1,"+1,",1)="FHIR"
 ; Output Transform to map VistA status (A/I) to SNOMED codes
 D UPDATE^DIE("","FDA","IEN")
 I $G(IEN(1)) D
 . K FDA S FDA(1.11,"+2,"_IEN(1)_",",.01)="Status"
 . S FDA(1.11,"+2,"_IEN(1)_",",.02)=9
 . S FDA(1.11,"+2,"_IEN(1)_",",1.2)="S VALUE=$S(VALUE=""A"":""55561003^Active^SNOMED CT"",VALUE=""I"":""73425007^Inactive^SNOMED CT"",1:"""")"
 . D UPDATE^DIE("","FDA")
 ;
 ; --- Entity #11: FHIR VACCINATION ---
 K FDA,IEN S FDA(1.1,"+1,",.01)="FHIR VACCINATION"
 S FDA(1.1,"+1,",.02)=9000010.11 ; V IMMUNIZATION file
 S FDA(1.1,"+1,",.04)="Vaccination"
 S FDA(1.1,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN")
 Q