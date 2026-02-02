C0FHIRNOTE ;VAMC/JS-FHIR TIU NOTE EXTRACTOR ; 30-JAN-2026
 ;;1.1;C0FHIR PROJECT;;Jan 30, 2026;Build 2
 Q
GETNOTES(BNDL,CNT,ENCPTR,ENCID) ; Pull Notes for an Encounter
 ; File #8925: TIU DOCUMENT -> .01:DOC TYPE; .05:STATUS; 2:REPORT TEXT
 N TIUIEN,STAT,ERR,TEXTNM
 S TIUIEN=0 F  S TIUIEN=$O(^TIU(8925,"V",ENCPTR,TIUIEN)) Q:'TIUIEN  D
 . S STAT=$$GET1^DIQ(8925,TIUIEN_",",.05,"I") Q:STAT<7  ; Skip if not completed/signed
 . S TEXTNM=$$GET1^DIQ(8925,TIUIEN_",",.01,"E")
 . S CNT=CNT+1
 . S BNDL("entry",CNT,"resource","resourceType")="DocumentReference"
 . S BNDL("entry",CNT,"resource","status")="current"
 . S BNDL("entry",CNT,"resource","type","text")=TEXTNM
 . S BNDL("entry",CNT,"resource","context","encounter",1,"reference")="Encounter/"_ENCID
 . D GENWP(TIUIEN,.BNDL,CNT)
 Q
 ;
GENWP(TIUIEN,BNDL,CNT) ; Extract WP Text and Base64 Encode
 N TEXT,FULLTXT,I,ERR
 K TEXT D GET1^DIQ(8925,TIUIEN_",",2,"","TEXT","ERR") ; Field 2 is REPORT TEXT
 S FULLTXT="",I=0
 F  S I=$O(TEXT(I)) Q:'I  S FULLTXT=FULLTXT_TEXT(I)_$C(13,10)
 ; Attachment data must be Base64 per FHIR spec
 S BNDL("entry",CNT,"resource","content",1,"attachment","contentType")="text/plain"
 S BNDL("entry",CNT,"resource","content",1,"attachment","data")=$$BASE64^C0FHIRUTL(.FULLTXT)
 Q