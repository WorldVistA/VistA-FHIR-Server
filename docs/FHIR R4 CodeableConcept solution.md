To implement the **FHIR R4 CodeableConcept** structure using the native VistA DDE engine, you need a Mumps transform that converts local VistA pointers or codes into a JSON-friendly object.

Because the native engine maps the **Item Name** directly to the JSON key, you should create child items within your entities using **dot notation** (e.g., `code.coding.0.code`).

### 1. The Logic Pattern

In FHIR, a `CodeableConcept` typically requires at least two pieces of data: the **Code** and the **System URI**.

### 2. The Universal Transform Spec

When you create your new `C0FHIR` entities in **File #1.5**, use the following M-code in the **DATA TRANSFORM (Field #1.2)** for your coding items.

#### **A. For Vitals (LOINC)**

* **Item Name:** `code.coding.0.code`
* **Transform:**
```mumps
S VALUE=$$GET1^DIQ(120.5,ID,.03,"I") S VALUE=$$LOINC^C0FHIRUTL(VALUE)

```


* **Item Name:** `code.coding.0.system`
* **Transform:**
```mumps
S VALUE="http://loinc.org"

```



#### **B. For Problems/Conditions (SNOMED CT)**

* **Item Name:** `code.coding.0.code`
* **Transform:**
```mumps
N SCT S SCT=$$GET1^DIQ(9000011,ID,80001,"I") S VALUE=$S(SCT:SCT,1:$$ICD9SCT^C0FHIRUTL(ID))

```


* **Item Name:** `code.coding.0.system`
* **Transform:**
```mumps
S VALUE="http://snomed.info/sct"

```



#### **C. For Medications (RxNorm)**

* **Item Name:** `medicationCodeableConcept.coding.0.code`
* **Transform:**
```mumps
N DRUG S DRUG=$$VALUE^ORX8(ID,"DRUG") S VALUE=$$RXNORM^C0FHIRUTL(DRUG)

```


* **Item Name:** `medicationCodeableConcept.coding.0.system`
* **Transform:**
```mumps
S VALUE="http://www.nlm.nih.gov/research/umls/rxnorm"

```



---

### 3. Handling the "Display" Property

FHIR also prefers a human-readable label. You should always include a `.display` item to make the JSON useful for clinicians.

* **Item Name:** `code.coding.0.display`
* **Transform:**
```mumps
S VALUE=$$GET1^DIQ(FILE,ID,FIELD,"E")

```



---

### 4. Implementation Checklist for Manual Copying

When you copy the `VPR` entities to `C0FHIR`, follow this specific sequence for every "Code" field:

1. **Delete** the old flat item (e.g., `Allergy`).
2. **Create** three new items using these exact names:
* `code.coding.0.code`
* `code.coding.0.system`
* `code.coding.0.display`


3. **Set Item Type** to `1` (SIMPLE FIELD) for all three.
4. **Paste** the corresponding M-logic from the spec above into the **Field #1.2**.

### Why this works:

The native DDE engine will see the dots in the names and automatically create the nested JSON structure:

```json
"code": {
  "coding": [
    {
      "code": "8480-6",
      "system": "http://loinc.org",
      "display": "Systolic blood pressure"
    }
  ]
}

```

**Would you like me to generate a "Reference Link" transform for the `Patient` and `Practitioner` fields so they follow the `Resource/IEN` format required by FHIR?**