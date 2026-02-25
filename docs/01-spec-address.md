Mapping the address is a perfect use case for your `SETPATH` logic because FHIR treats the street address as an array of strings (`line`), while VistA stores them as discrete fields (Street Address 1, 2, and 3).

By using the index notation in your **Item Names**, you can collapse these separate VistA fields into a single FHIR array.

---

## ## C0FHIR ADDRESS: Specification

**Entity Name:** `C0FHIR ADDRESS`

**Parent Entity:** `C0FHIR PATIENT`

**Source File:** `2` (PATIENT)

### ### 1. Mapping the Street Address (The `line` array)

FHIR uses `address.line` to hold all street-level data. In VistA, these are fields `.111`, `.112`, and `.113`.

| FHIR Path (Item Name) | VistA Field | Mumps Transform (Field #1.2) |
| --- | --- | --- |
| `address.0.line.0` | `.111` | `S VALUE=$$GET1^DIQ(2,ID,.111)` |
| `address.0.line.1` | `.112` | `S VALUE=$$GET1^DIQ(2,ID,.112)` |
| `address.0.line.2` | `.113` | `S VALUE=$$GET1^DIQ(2,ID,.113)` |

### ### 2. City, State, and Zip

These are straightforward, but the State should ideally be the 2-letter abbreviation.

| FHIR Path (Item Name) | VistA Field | Mumps Transform (Field #1.2) |
| --- | --- | --- |
| `address.0.city` | `.114` | `S VALUE=$$GET1^DIQ(2,ID,.114)` |
| `address.0.state` | `.115` | `S VALUE=$$GET1^DIQ(2,ID,.115,"E") ; Get Abbreviation` |
| `address.0.postalCode` | `.116` | `S VALUE=$$GET1^DIQ(2,ID,.116)` |
| `address.0.use` | N/A | `S VALUE="home"` |
| `address.0.type` | N/A | `S VALUE="both"` (Postal and Physical) |

---

## ## 3. How SETPATH Handles the Arrays

When your `CRAWL` engine hits these items, `SETPATH` will execute the following logic:

1. **For `address.0.line.0**`: It creates `MAP("address",0,"line",0)="123 Main St"`.
2. **For `address.0.line.1**`: It creates `MAP("address",0,"line",1)="Apt 4B"`.

**Final JSON Output:**

```json
"address": [
  {
    "line": [
      "123 Main St",
      "Apt 4B"
    ],
    "city": "Anytown",
    "state": "NY",
    "postalCode": "12345",
    "use": "home",
    "type": "both"
  }
]

```

---

## ## 4. Technical Tip: Handling Null Lines

VistA addresses often have a blank "Street Address 2". To prevent your JSON from having a null entry like `"line": ["123 Main St", ""]`, your `CRAWL` routine's check `I $G(VAL)'=""` will automatically skip the `SETPATH` call for that specific index.

However, since JSON arrays should be contiguous, if Address Line 2 is blank but Address Line 3 is populated, you might get an array like `[0, 2]`.

**Refined Transform for Line 2/3:**
If you want to ensure a tight array, you can use this in Field #1.2 for the address lines:

```mumps
; Only set VALUE if the field has data, otherwise stay null to skip SETPATH
S VALUE=$$GET1^DIQ(2,ID,FIELD) I VALUE="" S VALUE=""

```

---

### ## Final Driver Verification

Once the Address items are added to your `C0FHIR PATIENT` entity, run a full test:

```mumps
D TEST^C0FHIRGF(DFN)

```

**Would you like me to move on to the TELECOM (Phone/Email) items, or are you ready to run the first full Bundle export to a host file?**