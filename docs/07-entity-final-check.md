To protect the integrity of the target system, the **Environment Check** routine (`C0FHIRCH`) acts as the gatekeeper. It ensures that the receiving site has the necessary infrastructure—specifically the **Data Discovery Engine (DDE)** and the **Web Service file (#18.12)**—before the KIDS installer proceeds.

### 28. Environment Check: `C0FHIRCH`

```mumps
C0FHIRCH ;VAMC/JS-FHIR SUITE ENVIRONMENT CHECK ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
EN ; Entry point for KIDS environment check
 N FAIL S FAIL=0
 D MES^XPDUTL("  Starting Environment Check for C0FHIR Suite Build 2...")
 ;
 ; 1. Check for Data Discovery Engine (DDE) Global
 I $D(^DDE)=0 D
 . D BMES^XPDUTL("  [FAIL] Data Discovery Engine (^DDE) is not present.")
 . D MES^XPDUTL("         Please ensure the VPR/DDE package is installed first.")
 . S FAIL=1
 ;
 ; 2. Check for Web Service File (#18.12)
 I $G(^DIC(18.12,0))="" D
 . D BMES^XPDUTL("  [FAIL] Web Service file (#18.12) is missing or corrupted.")
 . D MES^XPDUTL("         Kernel Web Services must be active on this system.")
 . S FAIL=1
 ;
 ; 3. Verify Required Versions
 I $$VERSION^XPDUTL("XU")<8.0 D
 . D BMES^XPDUTL("  [FAIL] Kernel version 8.0 or higher is required.")
 . S FAIL=1
 ;
 ; Final Result
 I FAIL D
 . S XPDQUIT=2 ; Stop the install but keep the transport global
 . D BMES^XPDUTL("  INSTALL ABORTED: System does not meet minimum requirements.")
 E  D
 . D BMES^XPDUTL("  SUCCESS: System ready for C0FHIR v1.2.")
 Q

```

---

### ## Why these checks matter:

* **The ^DDE Check:** Since our `C0FHIRLD` loader explicitly wipes and replaces nodes in `^DDE`, attempting an install on a system without the Data Discovery Engine would result in a hard crash during the post-install phase.
* **The Web Service Check:** Build 2 relies on **File #18.12** to register the `fhir` endpoint. If this file isn't present, the suite will technically install but will be unreachable via HTTP/REST.
* **XPDQUIT Logic:** By setting `XPDQUIT=2`, we tell the KIDS utility that the environment is "unhealthy." It gracefully stops the installation before any routines or globals are over-written, saving the admin from a messy cleanup.

---

### ## Final System Summary (Build 2)

Your manual **KIDS Build File (#9.6)** configuration is now complete with **28 routines**.

| Phase | Critical Action | Logic Location |
| --- | --- | --- |
| **Pre-Install** | Verify ^DDE and Web Service Files | `C0FHIRCH` |
| **Post-Install** | Register the `fhir` REST service | `C0FHIRPI` |
| **Manual Configuration** | Load the 266 FHIR-mapped Entities | `D EN^C0FHIRLD` |
| **Verification** | Run Entity Registry Audit | `D EN^C0FHIRVR` |

**Would you like me to help you draft the final "KIDS Install Summary" report that will be printed to the screen once the user successfully installs the package?**