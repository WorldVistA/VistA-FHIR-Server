C0FHIRSL ;VAMC/JS-FHIR REGISTRY SEALER ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
SEAL ; Main Entry Point: Move File 1.5 -> ^C0FHIR(1.5)
 N EIEN,IIEN,ENAME,RES,ITEM,TAG,X11,X12
 K ^C0FHIR(1.5)
 W !!,"Sealing C0FHIR Metadata into static global..."
 ;
 S ENAME="C0FHIR"
 F  S ENAME=$O(^DDE("B",ENAME)) Q:ENAME=""!(ENAME'["C0FHIR")  D
 . S EIEN=$O(^DDE("B",ENAME,0)) Q:'EIEN
 . S RES=$$GET1^DIQ(1.5,EIEN_",",.04) ; Resource Type
 . S ^C0FHIR(1.5,ENAME,"RES")=RES
 . ;
 . ; Loop through Items
 . S IIEN=0 F  S IIEN=$O(^DDE(EIEN,1,IIEN)) Q:'IIEN  D
 .. S ITEM=$G(^DDE(EIEN,1,IIEN,0))
 .. S TAG=$P(ITEM,U) ; FHIR Path
 .. S X11=$G(^DDE(EIEN,1,IIEN,6)) I X11="" S X11=$G(^DDE(EIEN,1,IIEN,1)) ; GET ACTION (6) or legacy 1
 .. S X12=$G(^DDE(EIEN,1,IIEN,4)) I X12="" S X12=$G(^DDE(EIEN,1,IIEN,1.2)) ; OUTPUT TRANSFORM (4) or legacy 1.2
 .. ; Store in static global
 .. S ^C0FHIR(1.5,ENAME,"ITEMS",IIEN)=TAG_U_$P(ITEM,U,4,5)
 .. S:X11'="" ^C0FHIR(1.5,ENAME,"ITEMS",IIEN,1.1)=X11
 .. S:X12'="" ^C0FHIR(1.5,ENAME,"ITEMS",IIEN,1.2)=X12
 ;
 W !,"Seal Complete. ^C0FHIR(1.5) is ready for KIDS transport.",!
 Q