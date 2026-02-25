To address the complexity of **Entity #13 (VPR LAB ORDER)**, we need to ensure that your lab extraction logic follows the exact dependency chain defined in your Entity List: **Order (#100) -> Patient (#2) -> Lab Data (#63)**.

In Build 2, if you attempt to pull labs by encounter without verifying the `LRDFN` link, the process will fail. The logic below implements the "Get Action" from your report to safely bridge these files.

### 19. Lab Extraction Logic: `C0FHIRLM` (Reconciled)

```mumps
C0FHIRLM ;VAMC/JS-FHIR LAB DATA RESOURCE ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
GETLABS(BNDL,CNT,DFN,ENCPTR) ; Extract Labs for a Patient/Encounter
 ; DFN: Patient IEN
 ; ENCPTR: Encounter IEN (File #409.68)
 ;
 N LRDFN,IDT,LR0,RES,VAL,TST,LOINC
 ;
 ; 1. Follow "GET ENTRY ACTION" from Entity #13
 ; We must have LRDFN to access File #63
 S LRDFN=$G(^DPT(DFN,"LR"))
 I 'LRDFN Q  ; No Lab record for this patient
 ;
 ; 2. Traverse Lab Data File #63 (Chemistry node "CH")
 ; Note: VistA stores labs in reverse chronological order (IDT)
 S IDT=0 F  S IDT=$O(^LR(LRDFN,"CH",IDT)) Q:'IDT  D
 . S LR0=$G(^LR(LRDFN,"CH",IDT,0))
 . ; Filter by Encounter if provided (links via Field #.06 or Visit)
 . I ENCPTR,$P(LR0,U,6)'=ENCPTR Q 
 . ;
 . ; 3. Process each Lab Test on this Date/Time
 . S TST=1 F  S TST=$O(^LR(LRDFN,"CH",IDT,TST)) Q:'TST  D
 .. S VAL=$P($G(^LR(LRDFN,"CH",IDT,TST)),U)
 .. Q:VAL=""  ; Skip null results
 .. ;
 .. ; 4. Map to FHIR Observation
 .. S CNT=CNT+1
 .. S RES=$NA(BNDL("entry",CNT,"resource"))
 .. S @RES@("resourceType")="Observation"
 .. S @RES@("status")="final"
 .. S @RES@("category",1,"coding",1,"code")="laboratory"
 .. S @RES@("subject","reference")="Patient/"_DFN
 .. S @RES@("effectiveDateTime")=$$ISO8601^C0FHIRUTL(9999999-IDT)
 .. S @RES@("valueQuantity","value")=VAL
 .. ; LOINC mapping logic would go here based on File #60/95.3
 Q

```

---

### Why this logic is "No-Nonsense":

1. **LRDFN Guard:** The report for Entity #13 makes it clear: `LRDFN` is the gateway. Without it, you aren't even looking at File #63.
2. **IDT Reversal:** Because VistA uses `9999999-DATE` for Lab subscripts, we must "un-reverse" the date before passing it to your `ISO8601` utility to ensure the FHIR `effectiveDateTime` is accurate.
3. **Encounter Filtering:** By checking `$P(LR0,U,6)`, we respect the link between the clinical result and the specific visit, preventing "data leakage" from other encounters.

### Verification of the Data Chain

To ensure this routine works with your Build 2 architecture, the data must flow like this:

| Step | File | Key Field | Purpose |
| --- | --- | --- | --- |
| **1** | **ORDER (#100)** | `.02` (Patient) | Locates the Patient. |
| **2** | **PATIENT (#2)** | `63` (LRDFN) | Locates the Lab Entry. |
| **3** | **LAB DATA (#63)** | `"CH"` node | Retrieves the actual result. |

Would you like me to add the **LOINC mapping logic** to this routine, which uses **Entity #12 (VPR LOINC)** to pull the standardized codes from File #95.3?