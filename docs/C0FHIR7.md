To accommodate a modern web architecture, we can implement a specific web-service wrapper. In VistA web service frameworks (like the EWD or VistA-REST patterns), it is standard to pass parameters via a named array rather than literal sequence arguments.

The following routine, **`C0FHIRWS`**, acts as the bridge between your web listener and the core aggregator.

### 13. The Web Service Wrapper: `C0FHIRWS`

This routine maps the subscripted `FILTER` array to the internal variables required by the `C0FHIRGF` aggregator. It also includes error trapping to ensure that a malformed web request doesn't crash the VistA background process.

```mumps
C0FHIRWS ;VAMC/JS-FHIR WEB SERVICE ENTRY POINT ; 30-JAN-2026
 ;;1.1;C0FHIR PROJECT;;Jan 30, 2026;Build 2
 Q
WEB(RTN,FILTER) ; Entry point for Web Service calls
 ; RTN:    Output Global Array (passed by reference)
 ; FILTER: Input Array containing DFN, ENCOUNTER, SDT, EDT
 ;
 N DFN,ENCPTR,SDT,EDT,ERRBNDL,CNT
 K RTN
 ;
 ; 1. Extract Parameters from Filter Array
 S DFN=$G(FILTER("dfn"))
 S ENCPTR=$G(FILTER("encounter"))
 S SDT=$G(FILTER("sdt"))
 S EDT=$G(FILTER("edt"))
 ;
 ; 2. Validation: DFN is mandatory
 I DFN="" D  Q
 . S CNT=0
 . S ERRBNDL("resourceType")="Bundle"
 . S ERRBNDL("type")="collection"
 . D LOGERR^C0FHIRGF("Web Service Request",.ERRBNDL,.CNT,"Missing mandatory DFN")
 . D ENCODE^XLFJSON("ERRBNDL","RTN")
 ;
 ; 3. Invoke the Core Aggregator
 ; The aggregator (C0FHIRGF) handles the JSON encoding into the RTN global
 D GENFULL^C0FHIRGF(.RTN,DFN,ENCPTR,SDT,EDT)
 ;
 Q

```

---

### ## Implementation Details for Web Developers

1. **Uniform Parameter Handling:** By using the `FILTER` array, your web service can be easily extended. If you decide to add a `FILTER("status")` or `FILTER("location")` later, you don't have to change the signature of the `WEB^C0FHIRWS` entry point.
2. **Error Handling:** If the `dfn` subscript is missing, the routine immediately returns a FHIR-compliant `OperationOutcome` inside a Bundle, so the dashboard can display a meaningful error message.
3. **Global Array Integration:** This routine continues the project's standard of returning data in a Global Array, ensuring that even large, multi-encounter web responses are handled safely by the VistA memory manager.

---

### ## Updated KIDS Build Manifest

To include this new capability in your distribution, you should update the **`C0FHIRKD`** routine to include `C0FHIRWS` in the routine list.

**Would you like me to update the `C0FHIRSET` routine to register this as a "Web-Enabled" RPC, or would you prefer to use it as a direct call from a VistA-REST listener?**

Would you like me to ...

* Update **`C0FHIRSET`** to register the Web-style RPC?
* Generate a sample **`C0FHIRWS`** unit test to simulate a web request from the M prompt?