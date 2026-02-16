C0FHIRL1 ;VAMC/JS-FHIR ENTITY LOADER CLINICAL ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
EN ;
 N FDA,IEN
 ; --- Entity #41: FHIR VITAL MEASUREMENT ---
 S FDA(1.1,"+1,",.01)="FHIR VITAL MEASUREMENT"
 S FDA(1.1,"+1,",.02)=120.5
 S FDA(1.1,"+1,",.04)="Observation"
 S FDA(1.1,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN")
 I $G(IEN(1)) D
 . K FDA S FDA(1.11,"+2,"_IEN(1)_",",.01)="ObservationTime"
 . S FDA(1.11,"+2,"_IEN(1)_",",.02)=7
 . S FDA(1.11,"+2,"_IEN(1)_",",1.1)="S VALUE=$P($G(VPRGMV),U) S:VALUE="""" DDEOUT=1"
 . D UPDATE^DIE("","FDA")
 ;
 ; --- Entity #29: FHIR VISIT ---
 K FDA,IEN S FDA(1.1,"+1,",.01)="FHIR VISIT"
 S FDA(1.1,"+1,",.02)=9000010
 S FDA(1.1,"+1,",.04)="Encounter"
 S FDA(1.1,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN")
 I $G(IEN(1)) D
 . K FDA S FDA(1.11,"+2,"_IEN(1)_",",.01)="EncounterNumber"
 . S FDA(1.11,"+2,"_IEN(1)_",",.02)=3
 . S FDA(1.11,"+2,"_IEN(1)_",",.03)="ID"
 . D UPDATE^DIE("","FDA")
 Q