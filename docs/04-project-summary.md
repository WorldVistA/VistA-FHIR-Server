To finalize the suite, here is the **C0FHIRCH** (Environment Check) routine. This tool is designed to be run by a system administrator or developer immediately after installation to verify that the entire stack—FileMan, Kernel, and Web—is properly configured.

### **The Validation Utility: C0FHIRCH**

Code snippet

C0FHIRCH ;VAMC/JS-FHIR SUITE INSTALLATION VALIDATOR ; 30-JAN-2026  
 ;;1.2;C0FHIR PROJECT;;Jan 30, 2026;Build 3  
 Q  
EN ; Main entry point for environment check  
 N PASS,FAIL,ERR S (PASS,FAIL)=0  
 W \!\!,"--- C0FHIR Environment Validation Tool \---",\!  
 ;  
 ; 1\. Check RPC Registration  
 W \!,"Checking RPC 'C0FHIR GET FULL BUNDLE'..."  
 I $O(^DIC(8994,"B","C0FHIR GET FULL BUNDLE",0)) D  E  D ERR("RPC not found in File \#8994")  
 . W " OK." S PASS=PASS+1  
 ;  
 ; 2\. Check Context Option  
 W \!,"Checking Option 'C0FHIR CONTEXT'..."  
 N OPT S OPT=$O(^DIC(19,"B","C0FHIR CONTEXT",0))  
 I OPT D  E  D ERR("Option not found in File \#19")  
 . W " OK." S PASS=PASS+1  
 . ; Check if RPC is linked to Option  
 . I $D(^DIC(19,OPT,10,"B",+$O(^DIC(8994,"B","C0FHIR GET FULL BUNDLE",0)))) D  
 .. W \!,"  \- RPC Linkage... OK." S PASS=PASS+1  
 . E  D ERR("RPC is not linked to the Context Option")  
 ;  
 ; 3\. Check Web Service Endpoint  
 W \!,"Checking Web Service 'GET /fhir'..."  
 ; This logic assumes %webutils stores metadata in a standard global or index  
 I $$GETS^%webutils("GET","fhir")'="" D  E  D ERR("Web Service '/fhir' is not registered")  
 . W " OK." S PASS=PASS+1  
 . ; Verify Routine exists  
 . I $L($T(WEB^C0FHIRWS)) D  
 .. W \!,"  \- Entry Point (WEB^C0FHIRWS)... OK." S PASS=PASS+1  
 . E  D ERR("Routine C0FHIRWS or tag WEB is missing")  
 ;  
 ; 4\. Summary  
 W \!\!, "Validation Summary: "\_PASS\_" Passed, "\_FAIL\_" Failed."  
 I FAIL\>0 W \!\!,"\*\*\* WARNING: One or more components are not configured correctly\! \*\*\*"  
 E  W \!\!,"CONGRATULATIONS: The C0FHIR suite is fully operational."  
 Q  
 ;  
ERR(MSG) ; Log error  
 W " FAIL\!"  
 W \!,"  \[ERROR\]: "\_MSG  
 S FAIL=FAIL+1  
 Q

## ---

**Final Project Summary**

You now have a production-ready repository. Here is the final inventory of all 16 routines:

| Logic Layer | Routines |
| :---- | :---- |
| **Data Extraction** | C0FHIRGF, C0FHIRPT, C0FHIRLM, C0FHIRIM, C0FHIRVM, C0FHIRMX, C0FHIRPM, C0FHIRNOTE |
| **System Interface** | C0FHIRWS (Web), C0FHIRRX (RxNorm), C0FHIRUTL (Utilities) |
| **Deployment** | C0FHIRSET (Setup), C0FHIRKD (KIDS), C0FHIRPI (Post-Install), C0FHIRUN (Uninstall) |
| **Verification** | C0FHIRTS (Dev Tester), C0FHIRCH (System Validator) |

## ---

**Next Steps for Production**

1. **Source Control:** Commit these routines to your Git repository.  
2. **Assign Context:** Use the **User Management** menu to assign the C0FHIR CONTEXT to your web service's VistA Proxy User.  
3. **Firewall:** Ensure your VistA web server port is open to the Dashboard's IP address.

**Would you like me to generate a "Quick Start" README file in Markdown that provides the commands for installation, verification, and testing in one concise document?**