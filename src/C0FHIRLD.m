C0FHIRLD ;VAMC/JS-FHIR ENTITY LOADER MASTER ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
EN ;
Q  ; DO NOT USE DEPRECATED
 D CLEAN
 W !!,"--- Initializing C0FHIR Metadata Registry (Direct Mode) ---"
 D SHELLS
 W !,"  Loading Clinical Items via Direct Set..."
 D EN^C0FHIRL1,EN^C0FHIRL2
 ; Rebuild the "B" cross-reference so the aggregator can find them
 K DIK,DA S DIK="^DDE(",DIK(1)=".01^B" D ENALL^DIK
 W !!,"Registry Load Complete. Use D EN^C0FHIRVR to verify.",!
 Q
 ;
SHELLS ; Direct global sets for shells
 N I,L,N,F,R,IEN
 F I=1:1:3 S L=$P($T(SDATA+I),";;",2) Q:L=""  D
 . S N=$P(L,U),F=$P(L,U,2),R=$P(L,U,3)
 . S IEN=$O(^DDE("B",N,0)) I 'IEN S IEN=$O(^DDE(" "),-1)+1
 . S ^DDE(IEN,0)=N_U_F_U_U_R
 . S ^DDE(IEN,1)="FHIR"
 . S ^DDE("B",N,IEN)=""
 Q
SDATA ;;
 ;;C0FHIR PATIENT ID^2^Patient
 ;;C0FHIR VITAL MEASUREMENT^120.5^Observation
 ;;C0FHIR LAB RESULT^63.04^Observation
 ;
CLEAN ; Clean only C0FHIR namespace
 N DA,DIK,NAME S NAME="C0FHIR"
 F  S NAME=$O(^DDE("B",NAME)) Q:NAME=""!(NAME'["C0FHIR")  D
 . S DA=0 F  S DA=$O(^DDE("B",NAME,DA)) Q:'DA  S DIK="^DDE(" D ^DIK
 Q