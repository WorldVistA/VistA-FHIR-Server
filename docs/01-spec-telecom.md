To complete the demographic core of your VPR model, we need the `C0FHIR TELECOM` entity. In FHIR, phone numbers and emails are not separate fields; they are entries in a `telecom` array, categorized by `system` (phone, email, fax) and `use` (home, work, mobile).

---

## ## C0FHIR TELECOM: Specification

**Entity Name:** `C0FHIR TELECOM`

**Parent Entity:** `C0FHIR PATIENT`

**Source File:** `2` (PATIENT)

### ### 1. Mapping the Phone Numbers

VistA stores phone numbers in fields `.131` (Home) and `.132` (Work).

| FHIR Path (Item Name) | VistA Field | Mumps Transform (Field #1.2) |
| --- | --- | --- |
| `telecom.0.system` | N/A | `S VALUE="phone"` |
| `telecom.0.use` | N/A | `S VALUE="home"` |
| `telecom.0.value` | `.131` | `S VALUE=$$GET1^DIQ(2,ID,.131)` |
| `telecom.1.system` | N/A | `S VALUE="phone"` |
| `telecom.1.use` | N/A | `S VALUE="work"` |
| `telecom.1.value` | `.132` | `S VALUE=$$GET1^DIQ(2,ID,.132)` |

### ### 2. Mapping the Email Address

Email is usually stored in field `.133` or in the Electronic Signature sub-file, but for standard Patient demographics, we use `.133`.

| FHIR Path (Item Name) | VistA Field | Mumps Transform (Field #1.2) |
| --- | --- | --- |
| `telecom.2.system` | N/A | `S VALUE="email"` |
| `telecom.2.value` | `.133` | `S VALUE=$$GET1^DIQ(2,ID,.133)` |

---

## ## 3. Architectural Integration: The Pointer Linkup

In your `C0FHIR PATIENT` entity, you must define the "Jump" to this sub-entity. This is what triggers your `CRAWL` engine to recurse.

**Item Entry in `C0FHIR PATIENT`:**

* **Item Name:** `telecom`
* **Item Type:** `2` (ENTITY)
* **Target Entity:** `C0FHIR TELECOM`
* **Pointer Linkup:** `S ID=DFN` (Passes the Patient IEN down to the child)

---

## ## 4. Final Output Visualization

When `SETPATH` processes these items for a patient with a home phone and an email, the resulting JSON array will look like this:

```json
"telecom": [
  {
    "system": "phone",
    "use": "home",
    "value": "555-0199"
  },
  {
    "system": "email",
    "value": "john.doe@example.com"
  }
]

```

---

## ## Summary of the "Full Patient" Build

You have now mapped the following for **Build 2**:

1. **Identifiers:** ICN and SSN in the `identifier` array.
2. **Demographics:** Name, Gender, BirthDate, and Deceased status.
3. **Address:** Nested lines, city, state, and zip.
4. **Telecom:** Phone and Email categorized by system.

### ### Next Step

With the demographic core defined, your `C0FHIRGF` driver is now capable of producing a production-grade **FHIR Patient Resource**.

**Would you like me to generate the "Final Assembly" Mumps code for the `C0FHIRPT` routine, which your engine calls as a fallback for the Patient ID?**