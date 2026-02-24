To finalize the **C0FHIR PATIENT** entity, we need to move away from the flat VPR/SDA structure and adopt the FHIR **Identifier** array. In FHIR R4, a patient’s SSN and ICN are not separate top-level fields; they are entries in an `identifier` list, distinguished by a `system` URI.

---

## ## C0FHIR PATIENT: Identifier Specification

**Entity Name:** `C0FHIR PATIENT`

**Display Name:** `Patient`

### ### 1. Mapping the ICN (National ID)

The ICN is the primary join key for VistA systems. In FHIR, this is categorized under the VA's specific namespace.

| FHIR Path (Item Name) | VistA Field | Mumps Transform (Field #1.2) |
| --- | --- | --- |
| `identifier.0.use` | N/A | `S VALUE="official"` |
| `identifier.0.system` | N/A | `S VALUE="http://va.gov/viers/icn"` |
| `identifier.0.value` | 991.01 | `S VALUE=$$GET1^DIQ(2,ID,991.01)` |

### ### 2. Mapping the SSN

The Social Security Number should be marked as a specific identifier type (`SB` for Social Security Number).

| FHIR Path (Item Name) | VistA Field | Mumps Transform (Field #1.2) |
| --- | --- | --- |
| `identifier.1.use` | N/A | `S VALUE="usual"` |
| `identifier.1.system` | N/A | `S VALUE="http://hl7.org/fhir/sid/us-ssn"` |
| `identifier.1.value` | .09 | `S VALUE=$$GET1^DIQ(2,ID,.09)` |

---

## ## 3. Core Demographic Mapping

These fields are simpler but must match the camelCase requirements of the R4 spec.

| FHIR Path (Item Name) | VistA Field | Mumps Transform (Field #1.2) |
| --- | --- | --- |
| `active` | N/A | `S VALUE="true"` |
| `gender` | .02 | `N G S G=$$GET1^DIQ(2,ID,.02,"I") S VALUE=$S(G="M":"male",G="F":"female",1:"unknown")` |
| `birthDate` | .03 | `S VALUE=$$FHIRDT^C0FHIRUTL($$GET1^DIQ(2,ID,.03,"I"))` |
| `deceasedBoolean` | .351 | `S VALUE=$S($$GET1^DIQ(2,ID,.351):"true",1:"false")` |

---

## ## 4. Nested Name Logic

Rather than a flat "Name" string, FHIR expects a structured object. Using your `SETPATH` logic, we create this nesting easily.

| FHIR Path (Item Name) | VistA Field | Mumps Transform (Field #1.2) |
| --- | --- | --- |
| `name.0.family` | .01 | `S VALUE=$P($$GET1^DIQ(2,ID,.01),",",1)` |
| `name.0.given.0` | .01 | `S VALUE=$P($$GET1^DIQ(2,ID,.01),",",2)` |
| `name.0.use` | N/A | `S VALUE="official"` |

---

### ## Implementation Note: The "ID" Variable

In your `CRAWL` engine, the variable `ID` is passed into the loop. For the Patient entity, this is the `DFN`. Ensure that when you are manually entering these into **File #1.5**, you specify **File #2** as the Source File for each item.

### ## Final Step: Registry Check

Once these items are added, run your auditor:

```mumps
D EN^C0FHIRVR

```

Look for `C0FHIR PATIENT` to show `[PASS: FHIR Structured]`. This confirms that `identifier.0.system` and `name.0.family` are present and ready for `SETPATH` to build the tree.

**Would you like me to generate the Mumps logic for the `C0FHIR ADDRESS` sub-entity, which handles the transition from VistA's Street Address 1-3 to the FHIR `address.line` array?**