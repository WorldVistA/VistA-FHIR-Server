In FHIR, the **Condition** resource requires a clear distinction between **Clinical Status** (is the problem active or resolved?) and **Verification Status** (is it a confirmed diagnosis or a provisional one?). In VistA, this data is primarily stored in the **Problem List (#9000011)** and **V POV (#9000010.07)** files.

Here is the specification for the **C0FHIR CONDITION** entity.

---

### ## 1. Entity Profile: C0FHIR CONDITION

* **Entity Name:** `C0FHIR CONDITION`
* **Display Name:** `Condition`
* **Data Model:** `FHIR`

---

### ## 2. The `clinicalStatus` Logic

FHIR R4 requires `clinicalStatus` to be a `CodeableConcept`. You must map VistA's internal status codes (Active, Inactive) to the FHIR value set.

* **Item Name:** `clinicalStatus.coding.0.code`
* **M-Transform (Field #1.2):**
```mumps
; Logic for File #9000011 (Problem List)
N VSTAT S VSTAT=$$GET1^DIQ(9000011,ID,.12,"I")
S VALUE=$S(VSTAT="A":"active",VSTAT="I":"inactive",1:"active")

```


* **Item Name:** `clinicalStatus.coding.0.system`
* **M-Transform:** `S VALUE="http://terminology.hl7.org/CodeSystem/condition-clinical"`

---

### ## 3. Item Mapping Specification (VistA to FHIR)

| FHIR Path (Item Name) | VistA Field | Mumps Transform (Field #1.2) |
| --- | --- | --- |
| `code.coding.0.code` | .01 | `S VALUE=$$GET1^DIQ(FILE,ID,.01,"I") ; Should be ICD-10 or SCT` |
| `code.coding.0.display` | .01 | `S VALUE=$$GET1^DIQ(FILE,ID,.01,"E")` |
| `category.0.coding.0.code` | N/A | `S VALUE=$S(FILE=9000011:"problem-list-item",1:"encounter-diagnosis")` |
| `category.0.coding.0.system` | N/A | `S VALUE="http://terminology.hl7.org/CodeSystem/condition-category"` |
| `subject.reference` | .02 | `S VALUE="Patient/"_$$GET1^DIQ(FILE,ID,.02,"I")` |
| `onsetDateTime` | .13 | `N ODT S ODT=$$GET1^DIQ(FILE,ID,.13,"I") S VALUE=$S(ODT:$$DATE^VPRSDA(ODT),1:"")` |
| `recordedDate` | .08 | `S VALUE=$$DATE^VPRSDA($$GET1^DIQ(FILE,ID,.08,"I"))` |
| `asserter.reference` | 1.05 | `N PROV S PROV=$$GET1^DIQ(FILE,ID,1.05,"I") S VALUE=$S(PROV:"Practitioner/"_PROV,1:"")` |

---

### ## 4. Handling Verification Status

If you are pulling from **V POV (#9000010.07)**, the diagnosis is usually considered "confirmed" once it's on the encounter, but "provisional" during the active visit.

* **Item Name:** `verificationStatus.coding.0.code`
* **M-Transform:** ```mumps
; If from Problem List, it's usually confirmed.
; If V POV, check if the visit is closed.
S VALUE=$S(FILE=9000011:"confirmed",1:"provisional")
```


```



---

### ## 5. Manual Implementation Tips

1. **Duplicate the Delete Logic:** Ensure you also copy the `DELETE ENTITY` logic. If a Problem is deleted in VistA, FHIR needs to see `clinicalStatus` as `resolved` or the resource removed entirely.
2. **SNOMED vs. ICD:** FHIR prefers SNOMED CT for `Condition.code`. If your VistA site has the **Lexicon** installed, try to pull the SNOMED code from field **#80001** in File #9000011 instead of the ICD-10 code.
3. **Context Switching:** Remember that `ID` in your transforms refers to the IEN of whichever file is being processed (9000011 or 9000010.07).

**Would you like me to generate the spec for the PROCEDURE entity next, specifically how to handle the `performedPeriod` vs `performedDateTime` logic?**