To ensure a smooth transition to the **FHIR Data Model**, site administrators should perform these checks prior to running the automated loaders. This ensures the underlying VistA data is "clean" enough for the high-fidelity extraction required by **Build 2**.

---

### ## Site Readiness Checklist: C0FHIR Build 2

#### **1. Database Integrity Checks**

* [ ] **LRDFN Verification:** Ensure chemistry results in **File #63** have corresponding entries in **File #2** (Field #63).
* *Why:* The `C0FHIRLM` logic uses the `LRDFN` gateway.


* [ ] **Medication Status:** Verify that active outpatient prescriptions in **File #52** have valid status codes (`0`, `6`, or `5`).
* *Why:* The `VPR MEDICATION` entity transform filters strictly on these codes.


* [ ] **AA Index Health:** Re-index the **Vital Measurement (#120.5)** file if the "AA" cross-reference is incomplete.
* *Why:* `C0FHIRVM` traverses this index for speed.



#### **2. Mapping Standards Compliance**

* [ ] **LOINC Coverage:** Run `D EN^C0FHIRLA` (Lab Auditor) to check mapping coverage.
* *Goal:* At least **85%** of active tests in **File #60** should point to **File #95.3**.


* [ ] **RxNorm Links:** Ensure standard outpatient drugs in **File #50** are linked to VA Products in **File #50.68**.
* *Why:* `C0FHIRRX` requires the NDF link to resolve standardized FHIR codes.


* [ ] **SNOMED Integration:** Verify the **Problem Selection (#125.1)** file is populated and pointing to SNOMED CT.

#### **3. System Configuration**

* [ ] **Web Service Port:** Ensure the REST port (typically **9080** or **8080**) is open and the `fhir` endpoint is not blocked by a firewall.
* [ ] **Registry Cleanup:** Ensure no legacy "VPR" entities from older versions remain that might conflict with the new FHIR model.
* *Action:* Running `D EN^C0FHIRLD` will perform this cleanup automatically.



---

### ## Post-Check: Final Environment Verification

After the loaders complete, run the following command to verify the **Data Model** has flipped from `SDA` to `FHIR`:

```mumps
W !,"Data Model Check: ",$$GET1^DIQ(1.1,$O(^DDE("B","VPR PATIENT",0))_",",1)

```

**Expected Result:** `Data Model Check: FHIR`

---

**Would you like me to create a "Troubleshooting Guide" routine (`C0FHIRTG`) that an admin can run to identify specific records that are causing FHIR validation errors?**