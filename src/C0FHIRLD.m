C0FHIRLD ;VAMC/JS-FHIR ENTITY LOADER MASTER ; 16-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 16, 2026;Build 2
 Q
EN ; Main Entry Point
 D CLEAN
 W !!,"--- Initializing C0FHIR Metadata Registry (File #1.5) ---"
 W !,"Loading Administrative..." D ADMIN
 W !,"Loading Vitals..." D EN^C0FHIRL1
 W !,"Loading Labs..." D EN^C0FHIRL2
 W !,"Loading Pharmacy..." D EN^C0FHIRL3
 W !!,"Registry Load Complete. Use D EN^C0FHIRVR to verify.",!
 Q
 ;
 ADMIN ; Core Patient/Organization Metadata
 N FDA,IEN,ERR ; Added ERR for safety
 ; 
 ; --- Entity: C0FHIR PATIENT ID ---
 S FDA(1.5,"+1,",.01)="C0FHIR PATIENT ID"
 S FDA(1.5,"+1,",.02)=2
 S FDA(1.5,"+1,",.04)="Patient"
 S FDA(1.5,"+1,",1)="FHIR"
 ;
 ; Use "E" flag for external or blank for internal. 
 ; Passing "ERR" stops the hard crash and gives us a diagnostic array.
 D UPDATE^DIE("","FDA","IEN","ERR")
 ;
 I $D(ERR) W !,"Error creating Entity: ",$G(ERR("DIERR",1,"TEXT",1)) Q
 ;
 ; --- Sub-Items: C0FHIR PATIENT ID (File #1.51) ---
 I $G(IEN(1)) D
 . K FDA,ERR
 . ; Note the "+2," syntax - this indicates a NEW entry in the multiple
 . S FDA(1.51,"+2,"_IEN(1)_",",.01)="identifier.0.value"
 . S FDA(1.51,"+2,"_IEN(1)_",",.02)=1 ; Sequence
 . S FDA(1.51,"+2,"_IEN(1)_",",.04)=2 ; File #2
 . S FDA(1.51,"+2,"_IEN(1)_",",.05)=.09 ; Field .09 (SSN)
 . D UPDATE^DIE("","FDA","","ERR")
 . I $D(ERR) W !,"Error creating Item: ",$G(ERR("DIERR",1,"TEXT",1))
 Q
 ;
CLEAN ; Safely clear only the C0FHIR namespace
 N DIK,DA,NAME S NAME="C0FHIR"
 F  S NAME=$O(^DDE("B",NAME)) Q:NAME=""!(NAME'["C0FHIR")  D
 . S DA=0 F  S DA=$O(^DDE("B",NAME,DA)) Q:'DA  D
 .. S DIK="^DDE(" D ^DIK
 Q