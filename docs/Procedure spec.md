In FHIR, the **Procedure** resource is used to record actions performed on or with a patient. The complexity in VistA arises from the fact that a procedure can be a simple "event" (captured in **V CPT #9000010.18**) or a complex "duration" (captured in **Surgery #130**).

FHIR handles this by allowing either `performedDateTime` (a point in time) or `performedPeriod` (a start and end time).

---

### ## 1. Entity Profile: C0FHIR PROCEDURE

* **Entity Name:** `C0FHIR PROCEDURE`
* **Display Name:** `Procedure`
* **Data Model:** `FHIR`

---

### ## 2. Time Logic: `performedDateTime` vs. `performedPeriod`

The native DDE engine will include whichever property has a non-null value. You should configure your items to branch based on the source file.

#### **A. For V CPT (File #9000010.18)**

V CPTs are typically discrete events.

* **Item Name:** `performedDateTime`
* **M-Transform (Field #1.2):**
```mumps
; Use Event Date/Time, fall back to Visit Date/Time
N EDT S EDT=$$GET1^DIQ(9000010.18,ID,1201,"I")
S:'EDT EDT=$$GET1^DIQ(9000010.18,ID,.03,"I") ; Pointer to Visit Date
S VALUE=$$DATE^VPRSDA(EDT)

```



#### **B. For Surgery (File #130)**

Surgeries have a clear start and end time.

* **Item Name:** `performedPeriod.start`
* **M-Transform:** `S VALUE=$$DATE^VPRSDA($$GET1^DIQ(130,ID,.205,"I"))`
* **Item Name:** `performedPeriod.end`
* **M-Transform:** `S VALUE=$$DATE^VPRSDA($$GET1^DIQ(130,ID,.232,"I"))`

---

### ## 3. Item Mapping Specification

| FHIR Path (Item Name) | VistA Source | Mumps Transform (Field #1.2) |
| --- | --- | --- |
| `status` | N/A | `S VALUE="completed"` (Standard for historical records) |
| `code.coding.0.code` | .01 | `S VALUE=$$GET1^DIQ(FILE,ID,.01,"E") ; Usually a CPT code` |
| `code.coding.0.system` | N/A | `S VALUE="http://www.ama-assn.org/go/cpt"` |
| `subject.reference` | .02 | `S VALUE="Patient/"_$$GET1^DIQ(FILE,ID,.02,"I")` |
| `location.reference` | .22 | `N LOC S LOC=$$GET1^DIQ(9000010,+$G(VPRVST),.22,"I") S VALUE=$S(LOC:"Location/"_LOC,1:"")` |
| `outcome.text` | N/A | `I FILE=130 S VALUE=$$GET1^DIQ(130,ID,1.02,"E")` |

---

### ## 4. Handling Procedure "Modifiers"

VistA CPT entries often include modifiers. FHIR places these in the `note` array or as extensions, but for standard CPT billing, they are often appended to the code or mapped to `component`.

* **Item Name:** `note.0.text`
* **M-Transform:**
```mumps
; Combine CPT Modifiers if they exist
N MOD S MOD=$$GET1^DIQ(FILE,ID,.01,"I") ; Simplified modifier lookup
S VALUE=$S(MOD:"Modifier: "_MOD,1:"")

```



---

### ## 5. Strategic Implementation Note

When copying the **PROCEDURE** container, remember that VistA also uses **PTF 601 (#45.05)** for inpatient procedures. You will need a third branch in your logic if you want to capture ICD-10-PCS codes.

* **For PTF 601:**
* Set `code.coding.0.system` to `http://www.cms.gov/Medicare/Coding/ICD10`.
* Set `performedDateTime` to the Admission Date or Discharge Date provided in the PTF record.



---

### ## Summary Checklist for All Migrations

1. **Unique C0FHIR Names:** Ensure no item names overlap with legacy VPR names within the same entity.
2. **Explicit File References:** In your transforms, use the `FILE` variable if the entity handles multiple sources (like Surgery vs V CPT).
3. **Strict JSON Paths:** Double-check your dot-notation. `performedPeriod.start` (correct) vs `performedperiod.start` (incorrect casing).

**Would you like me to wrap up with the VACCINATION (Immunization) spec, focusing on how to handle the `lotNumber` and `site` coding?**