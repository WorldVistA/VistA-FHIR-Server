C0FHIRWS ;VAMC/JS-FHIR WEB SERVICE ENTRY POINT ; 30-JAN-2026
 ;;1.2;C0FHIR PROJECT;;Jan 30, 2026;Build 3
 Q
WEB(RTN,TYPE,FILTER) ; Entry point for Web Service calls
 ; RTN:    Output Global Array (passed by reference)
 ; TYPE:   Output Mime-Type (passed by reference)
 ; FILTER: Input Array containing dfn, name, encounter, sdt, edt
 ;
 N DFN,NAME,ENCPTR,SDT,EDT,CNT,GLB
 K RTN S TYPE="application/json" ; Default to JSON
 S GLB=$NA(^TMP("C0FHIRWS",$J)) K @GLB
 ;
 ; 1. Extract Parameters
 S DFN=$G(FILTER("dfn"))
 S NAME=$G(FILTER("name"))
 S ENCPTR=$G(FILTER("encounter"))
 S SDT=$G(FILTER("sdt"))
 S EDT=$G(FILTER("edt"))
 ;
 ; 2. Mode Selection: Search by Name (HTML)
 I DFN="",NAME'="" D  Q
 . S TYPE="text/html"
 . D SEARCH(NAME,GLB)
 . M RTN=@GLB K @GLB
 ;
 ; 3. Fetch Mode: Requires DFN (JSON)
 I DFN="" D  Q
 . N ERRBNDL S CNT=0
 . S ERRBNDL("resourceType")="Bundle",ERRBNDL("type")="collection"
 . D LOGERR^C0FHIRGF("Web Service Request",.ERRBNDL,.CNT,"Missing DFN or Name")
 . D ENCODE^XLFJSON("ERRBNDL","RTN")
 ;
 ; 4. Invoke Core Aggregator for FHIR (JSON)
 D GENFULL^C0FHIRGF(.RTN,DFN,ENCPTR,SDT,EDT)
 Q
 ;
SEARCH(VAL,GLB) ; Internal HTML Patient Search Result Generator
 N PIEN,PNAME,L,SSN,DOB,COUNT
 S L=0,COUNT=0
 S @GLB@(L)="<html><head><style>",L=L+1
 S @GLB@(L)="body{font-family:Segoe UI,Tahoma,sans-serif; background-color:#f4f7f6; color:#333; padding:20px;}",L=L+1
 S @GLB@(L)=".card{background:white; border-radius:8px; padding:15px; margin-bottom:10px; box-shadow:0 2px 4px rgba(0,0,0,0.1); display:flex; justify-content:space-between; align-items:center;}",L=L+1
 S @GLB@(L)=".name{font-weight:bold; color:#005a9c; text-decoration:none; font-size:1.1em;}",L=L+1
 S @GLB@(L)=".meta{color:#666; font-size:0.9em;}",L=L+1
 S @GLB@(L)="</style></head><body>",L=L+1
 S @GLB@(L)="<h2 style='color:#005a9c;'>Patient Search Results for: "_VAL_"</h2>",L=L+1
 ;
 S PNAME=VAL I $D(^DPT("B",PNAME)) S PNAME=$O(^DPT("B",PNAME),-1)
 F  S PNAME=$O(^DPT("B",PNAME)) Q:PNAME=""!(PNAME'[VAL)  D
 . S PIEN=0 F  S PIEN=$O(^DPT("B",PNAME,PIEN)) Q:'PIEN  D
 .. S COUNT=COUNT+1
 .. S SSN=$$GET1^DIQ(2,PIEN_",",.09)
 .. S DOB=$$GET1^DIQ(2,PIEN_",",.03)
 .. S @GLB@(L)="<div class='card'>",L=L+1
 .. S @GLB@(L)="  <div><a class='name' href='?dfn="_PIEN_"'>"_PNAME_"</a><br>",L=L+1
 .. S @GLB@(L)="  <span class='meta'>DOB: "_DOB_" | SSN: "_SSN_"</span></div>",L=L+1
 .. S @GLB@(L)="  <a href='?dfn="_PIEN_"' style='background:#005a9c; color:white; padding:8px 12px; border-radius:4px; text-decoration:none; font-size:0.8em;'>SELECT</a>",L=L+1
 .. S @GLB@(L)="</div>",L=L+1
 ;
 I COUNT=0 S @GLB@(L)="<div class='card'>No patients found matching your search.</div>",L=L+1
 S @GLB@(L)="</body></html>",L=L+1
 Q