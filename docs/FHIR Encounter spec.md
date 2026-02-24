Mapping the **FHIR Encounter** resource requires a precise translation of VistA’s visit types (Ambulatory, Inpatient, Emergency) into the FHIR **ActCode** system. In VistA, this distinction is usually buried in the `.07` field of File #9000010 (Visit) or the movement type in File #405 (Admission).

Here is the specification for the **C0FHIR ENCOUNTER** sub-entities and the logic for the `class` property.

---

### ## 1. Entity Profile: C0FHIR ENCOUNTER

* **Entity Name:** `C0FHIR ENCOUNTER`
* **Display Name:** `Encounter`
* **Data Model:** `FHIR`

---

### ## 2. The "Class" Logic (Ambulatory vs. Inpatient)

FHIR requires the `class` element to identify the type of setting. You should create an item specifically for the **ActCode** coding system.

* **Item Name:** `class.code`
* **M-Transform (Field #1.2):**
```mumps
; Logic to determine Setting
N VTYPE S VTYPE=$$GET1^DIQ(FILE,ID,.07,"I")
; VistA codes: A=Ambulatory, I=Inpatient, E=Emergency
S VALUE=$S(VTYPE="A":"AMB",VTYPE="I":"IMP",VTYPE="E":"EMER",1:"NONAC")

```


* **Item Name:** `class.system`
* **M-Transform:** `S VALUE="http://terminology.hl7.org/CodeSystem/v3-ActCode"`

---

### ## 3. Item Mapping Specification

| FHIR Path (Item Name) | VistA Field | Mumps Transform (Field #1.2) |
| --- | --- | --- |
| `status` | N/A | `S VALUE="finished"` (Or logic based on check-out date) |
| `type.0.text` | .07 | `S VALUE=$$GET1^DIQ(FILE,ID,.07,"E")` |
| `subject.reference` | .05 | `S VALUE="Patient/"_$$GET1^DIQ(FILE,ID,.05,"I")` |
| `period.start` | .01 | `S VALUE=$$DATE^VPRSDA($$GET1^DIQ(FILE,ID,.01,"I"))` |
| `period.end` | .18 | `N EDT S EDT=$$GET1^DIQ(FILE,ID,.18,"I") S VALUE=$S(EDT:$$DATE^VPRSDA(EDT),1:"")` |
| `location.0.location.reference` | .22 | `N LOC S LOC=$$GET1^DIQ(FILE,ID,.22,"I") S VALUE=$S(LOC:"Location/"_LOC,1:"")` |

---

### ## 4. Handling Participants (Providers)

VistA visits often have multiple providers (Primary, Attending, etc.). To map this to the FHIR `participant` array, you should use the **V-Provider (#9000010.06)** sub-file.

**Item Name:** `participant`

* **Item Type:** `ENTITY` (2)
* **Entity Name:** `C0FHIR ENCOUNTER PARTICIPANT`
* **Pointer Linkup:** `D VPRV^VPRSDAV(ID)` (Uses the legacy VPR utility to find providers for the visit).

#### **Sub-Entity: C0FHIR ENCOUNTER PARTICIPANT**

| FHIR Path | Transform |
| --- | --- |
| `individual.reference` | `S VALUE="Practitioner/"_$$GET1^DIQ(9000010.06,ID,.01,"I")` |
| `type.0.coding.0.code` | `S VALUE=$S($$GET1^DIQ(9000010.06,ID,.04,"I")="P":"PPRF",1:"SPRF")` |

---

### ## 5. Strategic Tips for the Reversion

* **Avoid Variable Collisions:** The native DDE engine preserves some local variables. Always use unique prefixes if you set temporary variables in your `GET ACTION` (e.g., `C0VTYPE` instead of `X`).
* **Clean References:** If the `location` or `subject` pointer is missing, ensure the transform returns an empty string (`""`). The native engine will omit the JSON key entirely if the value is null, which keeps your FHIR bundle valid.

**Would you like me to prepare the spec for the CONDITION (Diagnosis) entity next, specifically how to handle the critical `clinicalStatus` field?**