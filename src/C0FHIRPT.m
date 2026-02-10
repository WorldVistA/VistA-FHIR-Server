C0FHIRPT ;VAMC/JS-FHIR PATIENT RESOURCE ; 09-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 9, 2026;Build 2
 Q
GETPT(BNDL,CNT,DFN) ; Get Patient Data and return LRDFN
 ; BNDL: Passed by reference (JSON object)
 ; CNT:  Passed by reference (Entry counter)
 ; DFN:  Patient IEN
 ; RETURNS: LRDFN (from File #2, Field #63)
 ;
 N VADM,VAPA,ERR,RES,I,LRDFN
 D DEM^VADPT
 D ADD^VADPT
 ; I $D(ERR) Q 0 ; Commented out per local diff
 ;
 ; 1. Populate JSON Bundle
 S CNT=CNT+1
 S BNDL("entry",CNT,"fullUrl")="Patient/"_DFN
 S RES=$NA(BNDL("entry",CNT,"resource"))
 S @RES@("resourceType")="Patient"
 S @RES@("id")=DFN
 S @RES@("name",1,"family")=$P(VADM(1),",",1)
 S @RES@("name",1,"given",1)=$P(VADM(1),",",2)
 S @RES@("gender")=$S($P(VADM(5),U,1)="M":"male",1:"female")
 S @RES@("birthDate")=$$ISO8601^C0FHIRUTL($P(VADM(3),U,1))
 S @RES@("address",1,"line",1)=VAPA(1)
 S @RES@("address",1,"city")=VAPA(4)
 S @RES@("address",1,"state")=$P(VAPA(5),U,2)
 S @RES@("address",1,"postalCode")=VAPA(6)
 ;
 ; 2. Retrieve and return LRDFN for Lab modules
 S LRDFN=$G(^DPT(DFN,"LR"))
 Q LRDFN