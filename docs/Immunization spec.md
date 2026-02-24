To wrap up the technical migration specification, we look at the **VACCINATION** container. In FHIR, this maps to the **Immunization** resource. The primary challenge here is that VistA stores this in **V Immunization (#9000010.11)** but also tracks refusals and contraindications in health factors or the newer **V Imm Contra/Refusal (#9000010.707)** file.

---

## ## 1. Entity Profile: C0FHIR IMMUNIZATION

* **Entity Name:** `C0FHIR IMMUNIZATION`
* **Display Name:** `Immunization`
* **Source File:** `9000010.11`
* **Data Model:** `FHIR`

---

## ## 2. Core Mapping Specification

| FHIR Path (Item Name) | VistA Field | Mumps Transform (Field #1.2) |
| --- | --- | --- |
| `status` | N/A | `S VALUE="completed"` (Set to `not-done` for refusals) |
| `vaccineCode.coding.0.code` | .01 | `N V S V=$$GET1^DIQ(9000010.11,ID,.01,"I") S VALUE=$$CVX^C0FHIRUTL(V)` |
| `vaccineCode.coding.0.system` | N/A | `S VALUE="http://hl7.org/fhir/sid/cvx"` |
| `patient.reference` | .02 | `S VALUE="Patient/"_$$GET1^DIQ(9000010.11,ID,.02,"I")` |
| `occurrenceDateTime` | 1201 | `N EDT S EDT=$$GET1^DIQ(9000010.11,ID,1201,"I") S VALUE=$$DATE^VPRSDA(EDT)` |
| `lotNumber` | 1207 | `S VALUE=$$GET1^DIQ(9000010.11,ID,1207,"E")` |
| `site.coding.0.code` | 1303 | `S VALUE=$$GET1^DIQ(9000010.11,ID,1303,"I") ; Needs mapping to HL7 v2 Table 0163` |
| `route.coding.0.code` | 1302 | `S VALUE=$$GET1^DIQ(9000010.11,ID,1302,"I") ; Needs mapping to HL7 v2 Table 0162` |

---

## ## 3. Advanced Logic for Lot and Manufacturer

In VistA, the **Lot Number** (#1207) is a pointer to the **Immunization Lot file (#9999999.41)**, which in turn points to the **Manufacturer (#9999999.04)**.

* **Item Name:** `manufacturer.display`
* **M-Transform:**
```mumps
N LOT S LOT=$$GET1^DIQ(9000010.11,ID,1207,"I")
N MAN S MAN=$$GET1^DIQ(9999999.41,LOT,.02,"E")
S VALUE=MAN

```



---

## ## 4. Handling Refusals (V-Contra/Refusal)

If you are processing from File **#9000010.707**, the resource must indicate that the vaccination did *not* occur.

* **Item Name:** `status`
* **Transform:** `S VALUE="not-done"`
* **Item Name:** `statusReason.coding.0.code`
* **Transform:** ```mumps
N REAS S REAS=$$GET1^DIQ(9000010.707,ID,.01,"I")
S VALUE=$S(REAS["REFUSED":"REFUSAL",1:"IMMUNE")
```


```



---

## ## 5. Final Registry Checklist

1. **Duplicate Item Renaming:** In all `C0FHIR` entities, ensure the "Legacy" names are gone. The native engine will only produce valid FHIR if the JSON keys (Item Names) exactly match the FHIR spec (camelCase).
2. **Pointer Linkups:** For sub-entities like `C0FHIR NAME` or `C0FHIR ADDRESS`, ensure the **Parent Item** is defined in File #1.51 to ensure the nesting happens correctly.
3. **Validate JSON:** After manual modification, run a test extraction:
```mumps
D TEST^C0FHIRGF(DFN)

```



### ### Ready to Rebuild?

You now have a complete technical spec for:

* **Encounter** (Visit/Admission)
* **AllergyIntolerance**
* **Condition** (Diagnosis/Problems)
* **MedicationRequest** (Orders)
* **Procedure** (V CPT/Surgery)
* **Immunization**

**Would you like me to generate a "Registry Verification" Mumps routine that checks all these new `C0FHIR` entities for valid ResourceType naming before you run your first native extraction?**