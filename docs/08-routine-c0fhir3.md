This documentation provides a comprehensive overview of the **C0FHIR Suite**, a professional-grade VistA-to-FHIR middleware solution.

---

## 1. Project Overview & Architecture

The C0FHIR suite is a modular M-based system designed to extract clinical data from VistA and package it into **HL7 FHIR R4** compliant JSON. It is optimized for high-performance clinical dashboards using a **hub-and-spoke** modular design.

### Core Architecture

* **Protocol:** HL7 FHIR (JSON over RPC Broker)
* **Namespace:** `C0FHIR*`
* **Output Type:** Global Array (`^TMP`) to support payloads exceeding the 32KB string limit.
* **Security:** Context-based security via the `C0FHIR CONTEXT` Option (#19).

---

## 2. Routine Directory

The suite consists of 15 routines. Each routine handles a specific clinical or system domain.

| Routine | Role | Primary VistA File Source |
| --- | --- | --- |
| **`C0FHIRGF`** | **Master Aggregator** | #409.68 (Outpatient Encounter) |
| **`C0FHIRPT`** | Patient Demographics | #2 (Patient) |
| **`C0FHIRLM`** | Lab Results | #63 (Lab Data), #60 (Lab Test) |
| **`C0FHIRIM`** | Immunizations | #9000010.11 (V Immunization) |
| **`C0FHIRVM`** | Vitals | #120.5 (Vitals/Measurements) |
| **`C0FHIRMX`** | Medications | #52 (Prescription), #50 (Drug) |
| **`C0FHIRPM`** | Procedures | #9000010.18 (V Procedure) |
| **`C0FHIRRX`** | RxNorm Mapper | #50.68 (VA Product) |
| **`C0FHIRNOTE`** | Clinical Notes | #8925 (TIU Document) |
| **`C0FHIRUTL`** | Utilities | N/A (ISO8601 & Base64 Helpers) |
| **`C0FHIRTS`** | Interactive Tester | Developer Tool |
| **`C0FHIRSET`** | Environment Setup | Configures File #8994 and #19 |
| **`C0FHIRKD`** | KIDS Creator | Builds the .KID distribution file |
| **`C0FHIRPI`** | Post-Install | Automates setup during installation |
| **`C0FHIRUN`** | Uninstaller | Removes RPC and Option configurations |

---

## 3. Remote Procedure Call (RPC) Specification

**Name:** `C0FHIR GET FULL BUNDLE`

**Tag/Routine:** `GENFULL^C0FHIRGF`

**Return Type:** `GLOBAL ARRAY`

### Parameters

| Name | Sequence | Required | Type | Description |
| --- | --- | --- | --- | --- |
| `DFN` | 1 | Yes | Literal | Internal Patient IEN from File #2 |
| `ENCPTR` | 2 | No | Literal | Internal Encounter IEN from File #409.68 |
| `SDT` | 3 | No | Literal | Start Date (FileMan format). Default: 0 |
| `EDT` | 4 | No | Literal | End Date (FileMan format). Default: T |

---

## 4. Technical Sign-off & Security Certification

### Security Audit

* **Broker Authentication:** Relies on standard VistA authentication.
* **Context Control:** The RPC is bound to the `C0FHIR CONTEXT` Option. Unauthorized users cannot invoke the data extraction logic.
* **Sensitivity:** The `C0FHIRPT` module respects standard demographics retrieval protocols, and `C0FHIRNOTE` filters for signed/completed documents only.

### Data Integrity

* **State Mapping:** Uses the `GET1^DIQ` "E" flag to resolve State pointers from File #5.
* **Date Precision:** All timestamps are converted to ISO 8601 format using the `C0FHIRUTL` module to ensure interoperability with modern JavaScript engines.
* **Lab Linking:** Validates the presence of `LRDFN` in the Patient file before attempting to traverse the Lab Data global (`^LR`).

---

## 5. Deployment Guide (KIDS Workflow)

### To Package (Dev System)

1. Run `D EN^C0FHIRSET` to build local descriptions.
2. Run `D EN^C0FHIRKD` to create the Build entry in File #9.6.
3. Use the **KIDS Menu** -> **Transport a Build** to generate the `.KID` file.

### To Install (Production System)

1. Use the **KIDS Menu** -> **Load a Distribution**.
2. Select **Install Package(s)**.
3. The **Post-Install Routine (`C0FHIRPI`)** will automatically register the RPC and Context Option.

---

## 6. Decommissioning Instructions

Should the suite need to be removed from the VistA instance, run the uninstaller:

```mumps
D EN^C0FHIRUN

```

This will safely remove the RPC and Option entries from the system while leaving the routines intact for audit purposes.

---

**Would you like me to generate a "Release Notes" document for your end-users, highlighting what clinical data is now available on their dashboard?**