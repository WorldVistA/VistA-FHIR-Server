Mapping **MedicationRequest** is notoriously difficult because VistA splits the "intent" (Order #100) from the "fulfillment" (Pharmacy #52/55). The native DDE engine must handle these as a single FHIR Resource.

Here is the technical specification for building the **C0FHIR MEDICATIONREQUEST** entity.

---

### ## 1. Entity Profile: C0FHIR MEDICATIONREQUEST

* **Entity Name:** `C0FHIR MEDICATIONREQUEST`
* **Display Name:** `MedicationRequest`
* **Source File:** `100` (OR ORDERS)
* **Data Model:** `FHIR`

---

### ## 2. Item Mapping Specification (The "Copy & Paste" Guide)

| FHIR Path (Item Name) | Field # | Mumps Transform (Field #1.2) |
| --- | --- | --- |
| `status` | .02 | `N X S X=$$GET1^DIQ(100,ID,5,"I"),VALUE=$S(X=1:"cancelled",X=2:"discontinued",X=6:"active",X=7:"expired",1:"unknown")` |
| `intent` | N/A | `S VALUE="order"` (Hardcoded for this resource) |
| `category.0.coding.0.code` | .12 | `N X S X=$$GET1^DIQ(100,ID,12,"I"),VALUE=$S(X="O":"outpatient",1:"inpatient")` |
| `medicationCodeableConcept.coding.0.code` | N/A | `N OI S OI=$$OI^VPRSDAP(ID) S VALUE=$$RXNORM^C0FHIRUTL(+$P(OI,U,3))` |
| `medicationCodeableConcept.coding.0.system` | N/A | `S VALUE="http://www.nlm.nih.gov/research/umls/rxnorm"` |
| `subject.reference` | .02 | `S VALUE="Patient/"_$$GET1^DIQ(100,ID,.02,"I")` |
| `authoredOn` | 4 | `S VALUE=$$DATE^VPRSDA($$GET1^DIQ(100,ID,4,"I"))` |
| `requester.reference` | 1 | `N P S P=$$GET1^DIQ(100,ID,1,"I") S VALUE=$S(P:"Practitioner/"_P,1:"")` |
| `dosageInstruction.0.text` | N/A | `S VALUE=$$SIG^VPRSDAP(ID)` |

---

### ## 3. Handling Complex "Dose and Rate"

FHIR requires numeric values for quantities. If you want to include structured dose data, add these items to the same entity:

* **Item:** `dosageInstruction.0.doseAndRate.0.doseQuantity.value`
* **Transform:** ```mumps
N D S D=$$VALUE^ORX8(ID,"DOSE",1) S VALUE=+$P(D,"&")
```

```


* **Item:** `dosageInstruction.0.doseAndRate.0.doseQuantity.unit`
* **Transform:** ```mumps
N D S D=$$VALUE^ORX8(ID,"DOSE",1) S VALUE=$P(D,"&",2)
```




```



---

### ## 4. The Pharmacy "Hook"

Since the native DDE starts at File #100, you must pull the Pharmacy IEN (`ORPK`) to get fulfillment data (like Refills or actual Drug file pointers).

* **Logic Tip:** Use `GET ENTRY ACTION` in the top-level entity to set up the Pharmacy context:
```mumps
N ORPK S ORPK=$$GET1^DIQ(100,ID,33) D PS1^VPRSDAP(ID)

```


*This ensures variables like `PSOI` (Pharmacy Order Item) are available for your transforms.*

---

### ## 5. Implementation Summary

1. **Create Entity:** Set up `C0FHIR MEDICATIONREQUEST`.
2. **Add Items:** Use the exact "FHIR Path" names above.
3. **Update Container:** Go to **VPR CONTAINER (#1.1)**, entry **#13 (MEDICATION)**.
4. **Change Update Entity:** Set the `UPDATE ENTITY` to `C0FHIR MEDICATIONREQUEST` for Source File `100`.

**Would you like me to generate a similar "Deep Dive" spec for the ENCOUNTER sub-entities, specifically how to map the `class` (Ambulatory vs Inpatient) logic?**