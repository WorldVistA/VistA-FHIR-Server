C0FHIRLD ;VAMC/JS-FHIR ENTITY LOADER MASTER ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
EN ; Main Entry Point
 D CLEAN
 W !!,"--- Initializing C0FHIR Metadata Registry (File #1.5) ---"
 D ADMIN
 D EN^C0FHIRL1 ; Vitals
 D EN^C0FHIRL2 ; Labs
 D EN^C0FHIRL3 ; Pharmacy
 W !!,"Registry Load Complete. Use D EN^C0FHIRVR to verify.",!
 Q
 ;
ADMIN ; Core Patient Metadata
 N FDA,IEN,ERR,EIEN
 W !,"  Loading Administrative..."
 ;
 ; STEP 1: Create the Parent Entity Shell first
 S FDA(1.5,"+1,",.01)="C0FHIR PATIENT ID"
 S FDA(1.5,"+1,",.02)=2
 S FDA(1.5,"+1,",.04)="Patient"
 S FDA(1.5,"+1,",1)="FHIR"
 D UPDATE^DIE("","FDA","IEN","ERR")
 ;
 I $D(ERR) W !,"  [FAIL] Entity Creation: ",$G(ERR("DIERR",1,"TEXT",1)) Q
 S EIEN=$G(IEN(1))
 W " [Entity Created]"
 ;
 ; STEP 2: Add Items to the Multiple now that the Parent IEN is known
 K FDA,ERR
 S FDA(1.51,"+2,"_EIEN_",",.01)="identifier.0.value"
 S FDA(1.51,"+2,"_EIEN_",",.02)=1
 S FDA(1.51,"+2,"_EIEN_",",.04)=2
 S FDA(1.51,"+2,"_EIEN_",",.05)=.09
 D UPDATE^DIE("","FDA","","ERR")
 I $D(ERR) W !,"  [FAIL] Item Creation: ",$G(ERR("DIERR",1,"TEXT",1))
 E  W " [Items Loaded]"
 Q
 ;
CLEAN ; Clear old C0FHIR entries
 N DIK,DA,NAME S NAME="C0FHIR"
 F  S NAME=$O(^DDE("B",NAME)) Q:NAME=""!(NAME'["C0FHIR")  D
 . S DA=0 F  S DA=$O(^DDE("B",NAME,DA)) Q:'DA  D
 .. S DIK="^DDE(" D ^DIK
 Q