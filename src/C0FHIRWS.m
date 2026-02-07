C0FHIRWS ;VAMC/JS-FHIR WEB SERVICE ENTRY POINT ; 07-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 7, 2026;Build 2
 Q
WEB(RTN,FILTER) ; Entry point for Web Service calls
 ; RTN:    Output Global Array (passed by reference)
 ; FILTER: Input/Output Array (passed by reference)
 ;
 N DFN,NAME,ENCPTR,SDT,EDT,CNT,GLB
 K RTN S FILTER("type")="application/json" ; Default Mime-Type
 S GLB=$NA(^TMP("C0FHIRWS",$J)) K @GLB
 ;
 S DFN=$G(FILTER("dfn"))
 S NAME=$G(FILTER("name"))
 S ENCPTR=$G(FILTER("encounter"))
 S SDT=$G(FILTER("sdt"))
 S EDT=$G(FILTER("edt"))
 I EDT="" S EDT=$$NOW^XLFDT ; Ceiling fix
 ;
 ; Mode 1: Search by Name (HTML)
 I DFN="",NAME'="" D  Q
 . S FILTER("type")="text/html"
 . D SEARCH(NAME,GLB)
 . M RTN=@GLB K @GLB
 ;
 ; Mode 2: Missing Identifiers
 I DFN="" D  Q
 . N ERRBNDL S CNT=0
 . S ERRBNDL("resourceType")="Bundle",ERRBNDL("type")="collection"
 . D LOGERR^C0FHIRGF("Web Service Request",.ERRBNDL,.CNT,"Missing DFN or Name")
 . D ENCODE^XLFJSON("ERRBNDL","RTN")
 ;
 ; Mode 3: Core FHIR Aggregator (JSON)
 D GENFULL^C0FHIRGF(.RTN,DFN,ENCPTR,SDT,EDT)
 Q
 ;
SEARCH(VAL,GLB) ; Generate HTML Search Results
 N DFN,VADM,LN,CNT S CNT=0
 S @GLB@(1)="<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0'>"
 S @GLB@(2)="<style>body{font-family:sans-serif;padding:20px;} .pat{display:block;padding:15px;margin-bottom:10px;background:#f0f0f0;text-decoration:none;color:#333;border-radius:5px;}</style>"
 S @GLB@(3)="</head><body><h2>Patient Results for: "_VAL_"</h2>"
 S LN=3
 ;
 S DFN=0 F  S DFN=$O(^DPT("B",VAL,DFN)) Q:'DFN  D
 . D DEM^VADPT
 . S LN=LN+1
 . S @GLB@(LN)="<a class='pat' href='?dfn="_DFN_"'><b>"_VADM(1)_"</b><br>SSN: "_$P(VADM(2),U,2)_" | DOB: "_$P(VADM(3),U,2)_"</a>"
 ;
 I LN=3 S @GLB@(4)="<p>No patients found matching '"_VAL_"'.</p>" S LN=4
 ;
 S @GLB@(LN+1)="</body></html>"
 Q