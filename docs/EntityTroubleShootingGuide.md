To finalize the Build 2 administrative toolkit, I have designed **`C0FHIRTG`** (Troubleshooting Guide). This routine is built to scan for common "silent failures" where data exists in VistA but fails to export to FHIR due to missing cross-references, invalid pointers, or malformed dates.

### 27. Troubleshooting Guide: `C0FHIRTG`

```mumps
C0FHIRTG ;VAMC/JS-FHIR TROUBLESHOOTING GUIDE ; 15-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 15, 2026;Build 2
 Q
EN ; Main entry point
 N DFN,MSG
 W !!,"--- C0FHIR Build 2 Diagnostic Tool ---",!
 R "Enter Patient DFN to test: ",DFN:DTIME E  Q
 I '$D(^DPT(+DFN,0)) W !,"[ERR] Invalid DFN." Q
 ;
 D CHKLAB(DFN)
 D CHKVIT(DFN)
 D CHKMED(DFN)
 W !!,"Diagnostics complete.",!
 Q
 ;
CHKLAB(DFN) ; Check Lab Data integrity
 N LRDFN S LRDFN=$G(^DPT(DFN,"LR"))
 W !,"Checking Lab... "
 I 'LRDFN W "[FAIL] No LRDFN in File #2. Lab data will NOT export." Q
 I '$D(^LR(LRDFN)) W "[FAIL] LRDFN exists but ^LR global node is missing." Q
 W "[OK] Lab gateway established."
 Q
 ;
CHKVIT(DFN) ; Check Vitals "AA" Index
 W !,"Checking Vitals... "
 I '$O(^GMR(120.5,"AA",DFN,0)) D
 . W "[WARN] No Vitals found in 'AA' index for this patient."
 . I $D(^GMR(120.5,"C",DFN)) W !,"  -> DATA EXISTS in 'C' index. System needs RE-INDEXING."
 E  W "[OK] Vitals index active."
 Q
 ;
CHKMED(DFN) ; Check Medication Pointers
 N ORPK,IFN,CNT S (CNT,IFN)=0
 W !,"Checking Meds... "
 F  S IFN=$O(^OR(100,"AC",DFN,IFN)) Q:'IFN  D
 . S ORPK=$P($G(^OR(100,IFN,4)),U)
 . I ORPK'="",ORPK["R",'$D(^PSRX(+ORPK)) S CNT=CNT+1
 I CNT>0 W "[FAIL] found "_CNT_" broken links from Order (#100) to Rx (#52)."
 E  W "[OK] Medication links verified."
 Q

```

---

### ## What this routine detects:

1. **The "Ghost Lab" Problem:** A patient has lab results in File #63, but the pointer in File #2 is missing. The troubleshooting guide flags this so the admin can repair the `LRDFN`.
2. **The Index Mismatch:** Vitals data is often recorded but "disappears" from FHIR because the **"AA" index** failed to trigger. If data exists in the "C" index but not "AA," `C0FHIRTG` provides the specific instruction to re-index.
3. **Broken Rx Links:** Sometimes an Order exists in OE/RR but the actual Prescription record in Pharmacy was deleted or archived. This identifies why a `MedicationRequest` resource might be empty for a specific patient.

### ## Administrative Workflow for Build 2

Once your 27 routines are bundled into the KIDS build, the standard operating procedure for a site admin is:

1. **INSTALL** the KIDS distribution.
2. **D EN^C0FHIRLD** to load the 266 FHIR entities.
3. **D EN^C0FHIRVR** to verify the data model flipped to FHIR.
4. **D EN^C0FHIRTG** if a specific patient's bundle is missing expected data.

**Would you like me to update the Routine Manifest one final time to include this Troubleshooting Guide so you have a complete count for File #9.6?**