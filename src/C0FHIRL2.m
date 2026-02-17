C0FHIRL2 ;VAMC/JS-FHIR ENTITY LOADER LABS ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
EN ;
 N FDA,IEN,EIEN,LN
 S EIEN=$O(^DDE("B","C0FHIR LAB RESULT",0)) Q:'EIEN
 ; Logic snippet for WKLD -> LOINC
 S LN="N W,S S S=$O(^LAB(60,ID,1,0)),W=$$GET1^DIQ(60.01,S_"",""_ID_"","",2,""I""),VALUE=$$GET1^DIQ(64,W,25)"
 ;
 ; Item 1: The LOINC Code
 K FDA S FDA(1.51,"+1,"_EIEN_",",.01)="code.coding.0.code"
 S FDA(1.51,"+1,"_EIEN_",",1.2)=LN
 D UPDATE^DIE("","FDA")
 ;
 ; Item 2: The Display Name
 K FDA S FDA(1.51,"+2,"_EIEN_",",.01)="code.coding.0.display"
 S FDA(1.51,"+2,"_EIEN_",",.04)=60,FDA(1.51,"+2,"_EIEN_",",.05)=.01
 D UPDATE^DIE("","FDA")
 Q