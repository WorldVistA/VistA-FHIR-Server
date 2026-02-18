C0FHIRLD ;VAMC/JS-FHIR ENTITY LOADER MASTER ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
EN ;
 D CLEAN
 W !!,"--- Initializing C0FHIR Metadata Registry (File #1.5) ---"
 D SHELLS
 W !,"  Loading Clinical Items..."
 D EN^C0FHIRL1,EN^C0FHIRL2,EN^C0FHIRL3
 W !!,"Registry Load Complete.",!
 Q
 ;
SHELLS ; Manual creation of shells to bypass UPDATE^DIE multiple error
 N NAME,FNUM,RES,IEN,I,LIST
 S LIST(1)="C0FHIR PATIENT ID^2^Patient"
 S LIST(2)="C0FHIR VITAL MEASUREMENT^120.5^Observation"
 S LIST(3)="C0FHIR LAB RESULT^63.04^Observation"
 ;
 F I=1:1:3 D
 . S NAME=$P(LIST(I),U),FNUM=$P(LIST(I),U,2),RES=$P(LIST(I),U,3)
 . ; Force creation in File 1.5
 . S IEN=$O(^DDE("B",NAME,0)) I IEN Q  ; Already exists
 . K FDA,ERR,NIEN S FDA(1.5,"+1,",.01)=NAME
 . S FDA(1.5,"+1,",.02)=FNUM,FDA(1.5,"+1,",.04)=RES,FDA(1.5,"+1,",1)="FHIR"
 . D UPDATE^DIE("","FDA","NIEN","ERR")
 . I $D(ERR) W !,"  [FAIL] Shell: ",NAME," - ",$G(ERR("DIERR",1,"TEXT",1))
 . E  W !,"  [OK] Created Shell: ",NAME
 Q
 ;
CLEAN ; Standard DIK cleanup
 N DIK,DA,NAME S NAME="C0FHIR"
 F  S NAME=$O(^DDE("B",NAME)) Q:NAME=""!(NAME'["C0FHIR")  D
 . S DA=0 F  S DA=$O(^DDE("B",NAME,DA)) Q:'DA  S DIK="^DDE(" D ^DIK
 Q