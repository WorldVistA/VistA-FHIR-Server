C0FHIRLD ;VAMC/JS-FHIR ENTITY LOADER MASTER ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
EN ;
 D CLEAN ; Wipe old C0FHIR entries
 W !!,"--- Initializing C0FHIR Metadata Registry (File #1.5) ---"
 ;
 ; 1. Create ALL Parent Shells first
 D SHELLS
 ;
 ; 2. Populate Items now that Parents exist
 W !,"  Loading Clinical Items..."
 D EN^C0FHIRL1 ; Vitals
 D EN^C0FHIRL2 ; Labs
 D EN^C0FHIRL3 ; Pharmacy
 ;
 W !!,"Registry Load Complete. Use D EN^C0FHIRVR to verify.",!
 Q
 ;
SHELLS ; Create the top-level Entity entries
 N FDA,IEN,ERR,NAME,FILE,RES
 F NAME="C0FHIR PATIENT ID^2^Patient","C0FHIR VITAL MEASUREMENT^120.5^Observation","C0FHIR LAB RESULT^63.04^Observation" D
 . K FDA,IEN,ERR
 . S FDA(1.5,"+1,",.01)=$P(NAME,U)
 . S FDA(1.5,"+1,",.02)=$P(NAME,U,2)
 . S FDA(1.5,"+1,",.04)=$P(NAME,U,3)
 . S FDA(1.5,"+1,",1)="FHIR"
 . D UPDATE^DIE("","FDA","IEN","ERR")
 . I $D(ERR) W !,"  [FAIL] Shell: ",$P(NAME,U)," - ",$G(ERR("DIERR",1,"TEXT",1))
 . E  W !,"  [OK] Created Shell: ",$P(NAME,U)
 Q
 ;
CLEAN ; Clear old C0FHIR namespace
 N DIK,DA,NAME S NAME="C0FHIR"
 F  S NAME=$O(^DDE("B",NAME)) Q:NAME=""!(NAME'["C0FHIR")  D
 . S DA=0 F  S DA=$O(^DDE("B",NAME,DA)) Q:'DA  D
 .. S DIK="^DDE(" D ^DIK
 Q