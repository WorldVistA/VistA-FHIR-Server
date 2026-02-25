In FHIR, a `Reference` is a critical data type used to link resources (e.g., linking an Observation to a Patient). Unlike SDA, which often accepts a raw IEN or a local ID, FHIR requires a relative URL string in the format `ResourceType/InternalID`.

Here is the specification for the **Reference Link** transforms you will need to apply to your new `C0FHIR` entities.

---

### ## 1. The Reference Pattern

When the native DDE engine processes an item, it expects the `VALUE` variable to contain the final string. For references, we must prepend the resource type to the VistA IEN.

#### **A. Patient Reference (The `subject` field)**

Most clinical resources (Allergy, Observation, Condition) require a link to the patient.

* **Item Name:** `subject.reference`
* **Transform (Field #1.2):**
```mumps
; DFN is usually passed as the top-level ID or found in the record
S VALUE="Patient/"_DFN

```



#### **B. Practitioner Reference (The `requester` or `performer` field)**

Used for clinicians, providers, and authors.

* **Item Name:** `requester.reference` (for MedicationRequest) or `performer.0.reference` (for Observation)
* **Transform (Field #1.2):**
```mumps
; Replace FIELD with the pointer field to File 200 (e.g., .06 for Vitals)
N PROV S PROV=$$GET1^DIQ(FILE,ID,FIELD,"I") S VALUE=$S(PROV:"Practitioner/"_PROV,1:"")

```



#### **C. Location Reference**

Used to link encounters or observations to a clinic or ward.

* **Item Name:** `location.location.reference`
* **Transform (Field #1.2):**
```mumps
; Pointer to File #44
N LOC S LOC=$$GET1^DIQ(FILE,ID,FIELD,"I") S VALUE=$S(LOC:"Location/"_LOC,1:"")

```



---

### ## 2. Strategic Implementation Checklist

As you manually copy and modify the entities, follow these rules for references:

1. **Direct Naming:** Use the exact FHIR path as the **Item Name**. The dots will tell the native DDE engine to build the nested object.
2. **Null Handling:** Always check if the pointer exists (`$S(PROV:... ,1:"")`). If you pass a slash without an IEN (e.g., `Practitioner/`), it will create invalid FHIR JSON.
3. **Entity Hops:** If the reference points to a complex object (like a nested `Organization` within a `Location`), you should keep the **Item Type** as `ENTITY` (2) and let the engine recurse. If it's just a simple link, use **Item Type** `1` (SIMPLE FIELD).

---

### ## Example Output

Once these transforms are applied, the native DDE engine will produce JSON that looks like this:

```json
{
  "subject": {
    "reference": "Patient/711"
  },
  "requester": {
    "reference": "Practitioner/12345"
  }
}

```

### ## Next Steps

Now that you have the specs for **CodeableConcepts** and **References**, you have the "Lego bricks" needed to rebuild the `C0FHIR` namespace.

**Would you like me to generate a specific "Entity Builder" script for the MEDICATIONREQUEST entity, which is usually the most difficult to map because it requires joining File #100 and File #52?**