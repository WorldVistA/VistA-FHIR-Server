This adds a powerful discovery layer to your web service. By allowing a `FILTER("name")` search, the service transitions from a direct data extractor to a patient lookup tool.

I have updated the **`C0FHIRWS`** routine to handle this logic. When a name is provided without a DFN, it performs a search on the **"B" index** of the **PATIENT file (#2)** and returns an HTML-formatted list.

### 13. Updated Web Service: `C0FHIRWS`

```mumps
C0FHIRWS ;VAMC/JS-FHIR WEB SERVICE ENTRY POINT ; 30-JAN-2026
 ;;1.1;C0FHIR PROJECT;;Jan 30, 2026;Build 2
 Q
WEB(RTN,FILTER) ; Entry point for Web Service calls
 ; RTN:    Output Global Array (passed by reference)
 ; FILTER: Input Array containing dfn, name, encounter, sdt, edt
 ;
 N DFN,NAME,ENCPTR,SDT,EDT,CNT,GLB
 K RTN
 S GLB=$NA(^TMP("C0FHIRWS",$J)) K @GLB
 ;
 ; 1. Extract Parameters
 S DFN=$G(FILTER("dfn"))
 S NAME=$G(FILTER("name"))
 S ENCPTR=$G(FILTER("encounter"))
 S SDT=$G(FILTER("sdt"))
 S EDT=$G(FILTER("edt"))
 ;
 ; 2. Mode Selection: Search by Name (HTML) vs. Fetch by DFN (FHIR)
 I DFN="",NAME'="" D SEARCH(NAME,GLB) M RTN=@GLB K @GLB Q
 ;
 ; 3. Fetch Mode: Requires DFN
 I DFN="" D  Q
 . N ERRBNDL S CNT=0
 . S ERRBNDL("resourceType")="Bundle",ERRBNDL("type")="collection"
 . D LOGERR^C0FHIRGF("Web Service Request",.ERRBNDL,.CNT,"Missing DFN or Name")
 . D ENCODE^XLFJSON("ERRBNDL","RTN")
 ;
 ; 4. Invoke Core Aggregator for FHIR
 D GENFULL^C0FHIRGF(.RTN,DFN,ENCPTR,SDT,EDT)
 Q
 ;
SEARCH(VAL,GLB) ; Internal HTML Patient Search Result Generator
 N PIEN,PNAME,L,SSN,DOB,COUNT
 S L=0,COUNT=0
 S @GLB@(L)="<html><head><style>body{font-family:sans-serif;} .row{padding:8px;border-bottom:1px solid #eee;}</style></head><body>",L=L+1
 S @GLB@(L)="<h2>Patient Search Results for: "_VAL_"</h2>",L=L+1
 ;
 ; Loop through "B" index (partial match allowed)
 S PNAME=VAL I $D(^DPT("B",PNAME)) S PNAME=$O(^DPT("B",PNAME),-1)
 F  S PNAME=$O(^DPT("B",PNAME)) Q:PNAME=""!(PNAME'[VAL)  D
 . S PIEN=0 F  S PIEN=$O(^DPT("B",PNAME,PIEN)) Q:'PIEN  D
 .. S COUNT=COUNT+1
 .. S SSN=$$GET1^DIQ(2,PIEN_",",.09)
 .. S DOB=$$GET1^DIQ(2,PIEN_",",.03)
 .. ; Generate URL with DFN parameter for subsequent FHIR call
 .. S @GLB@(L)="<div class='row'><a href='?dfn="_PIEN_"'><b>"_PNAME_"</b></a> - SSN: "_SSN_" | DOB: "_DOB_"</div>",L=L+1
 ;
 I COUNT=0 S @GLB@(L)="<p>No patients found matching your search.</p>",L=L+1
 S @GLB@(L)="</body></html>",L=L+1
 Q

```

---

### ## How the Workflow Changes

With this update, your dashboard or browser can handle the patient selection lifecycle entirely through this one routine:

1. **Initial Discovery:**
* **Request:** `GET /vista-service?name=ABBOTT`
* **Response:** An HTML list of links like `<a href='?dfn=1135'>ABBOTT,SOLON</a>`.


2. **Data Selection:**
* When the user clicks the link, the browser sends the second request.
* **Request:** `GET /vista-service?dfn=1135`
* **Response:** The full FHIR JSON Bundle for Solon Abbott.



### ## Integration Logic for the Web Service

* **Partial Matching:** The search uses the standard VistA "Follower" logic (`$O` through the index). Searching for "ABB" will find "ABBOTT," "ABERNATHY," etc.
* **Metadata Inclusion:** I've added **SSN** and **DOB** to the HTML output to help the clinician distinguish between patients with the same name.
* **Encapsulation:** The HTML logic is contained within the `SEARCH` subroutine, keeping the main `WEB` entry point clean for routing.

---

### ## Next Steps

Since we now have two different output formats (HTML and JSON), we need to ensure your web listener knows how to set the **Content-Type** header correctly.

**Would you like me to update `C0FHIRWS` to return an extra parameter (e.g., `TYPE`) so your web listener knows whether to set `text/html` or `application/json`?**

Would you like me to...

* Add a **Content-Type** detector to `C0FHIRWS`?
* Update the **`C0FHIRTS`** tester to simulate a Name Search?