C0FHIRWS ;VAMC/JS-FHIR WEB SERVICE ENTRY POINT ; 03-FEB-2026
 ;;1.3;C0FHIR PROJECT;;Feb 3, 2026;Build 4
 Q
WEB(RTN,FILTER) ; Entry point for Web Service calls
 ; RTN:    Output Global Array (passed by reference)
 ; FILTER: Input/Output Array
 ;         Input:  FILTER("dfn"), FILTER("name"), etc.
 ;         Output: FILTER("type") = Mime-Type
 ;
 N DFN,NAME,ENCPTR,SDT,EDT,CNT,GLB
 K RTN S FILTER("type")="application/json" ; Default to JSON
 S GLB=$NA(^TMP("C0FHIRWS",$J)) K @GLB
 ;
 S DFN=$G(FILTER("dfn"))
 S NAME=$G(FILTER("name"))
 S ENCPTR=$G(FILTER("encounter"))
 S SDT=$G(FILTER("sdt"))
 S EDT=$G(FILTER("edt"))
 ;
 ; Mode 1: Search by Name (HTML)
 I DFN="",NAME'="" D  Q
 . S FILTER("type")="text/html"
 . D SEARCH(NAME,GLB)
 . M RTN=@GLB K @GLB
 ;
 ; Mode 2: Fetch by DFN (JSON)
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
SEARCH(VAL,GLB) ; [HTML Generation Logic remains as previously defined]
 ; ... logic to populate GLB with HTML ...
 Q