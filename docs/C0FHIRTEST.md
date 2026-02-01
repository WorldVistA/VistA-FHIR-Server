This **README.md** acts as the technical manual for your DevOps and Clinical Informatics teams. It explains the "plumbing" of the C0FHIR suite, how to maintain it, and how to verify data integrity between VistA and your dashboard.

---

# C0FHIR: VistA-to-FHIR Encounter Suite

## Overview

C0FHIR is a modular M-based middleware suite designed to extract clinical data from **VistA** and package it into **FHIR (Fast Healthcare Interoperability Resources)** Collection Bundles. It is optimized for high-performance clinical decision support dashboards.

---

## Technical Architecture

The suite uses a **hub-and-spoke model**. A master aggregator (`C0FHIRGF`) orchestrates specialized clinical modules to gather data, then uses the VistA JSON utilities to encode the results.

### Core Components

* **Protocol:** HL7 FHIR (JSON over RPC Broker)
* **Namespace:** `C0FHIR*`
* **Memory Management:** Uses `^TMP` and Global Array returns to handle payloads exceeding 32KB.
* **Error Handling:** Implements `OperationOutcome` resources for FileMan/Global errors.

---

## Routine Directory

| Routine | Role | Source VistA Files |
| --- | --- | --- |
| **`C0FHIRGF`** | **Master Aggregator** | #409.68 (Outpatient Encounter) |
| **`C0FHIRPT`** | Patient Identity | #2 (Patient) |
| **`C0FHIRLM`** | Lab Results | #63 (Lab Data), #60 (Lab Test) |
| **`C0FHIRIM`** | Immunizations | #9000010.11 (V Immunization) |
| **`C0FHIRVM`** | Vitals | #120.5 (Vitals/Measurements) |
| **`C0FHIRMX`** | Medications | #52 (Prescription), #50 (Drug) |
| **`C0FHIRPM`** | Procedures | #9000010.18 (V Procedure) |
| **`C0FHIRRX`** | RxNorm Mapper | #50.68 (VA Product) |
| **`C0FHIRNOTE`** | Clinical Notes | #8925 (TIU Document) |
| **`C0FHIRUTL`** | Utilities | N/A (ISO8601 & Base64 Helpers) |

---

## Endpoint Specification (RPC)

**Name:** `C0FHIR GET FULL BUNDLE`

**Tag/Routine:** `GENFULL^C0FHIRGF`

**Context:** `C0FHIR CONTEXT` (or `OR CPRS GUI CHART`)

### Input Parameters

1. **DFN** (Literal): The Internal Entry Number of the patient (File #2).
2. **ENCPTR** (Literal): The Internal Entry Number of the Outpatient Encounter (File #409.68).

### Output

A JSON `Bundle` of type `collection` containing:

* `Patient`
* `Encounter`
* `Observation` (Labs and Vitals)
* `MedicationStatement` (with RxNorm coding)
* `Procedure` (with CPT coding)
* `DocumentReference` (Base64 encoded TIU Notes)

---

## Setup & Configuration

1. **Installation:** Load the `C0FHIR*` routines into the target VistA UCI.
2. **Environment Setup:** Run `D EN^C0FHIRSET` at the M prompt. This automatically:
* Registers the RPC in the Remote Procedure file (#8994).
* Creates the `C0FHIR CONTEXT` option in the Option file (#19).


3. **Security:** Assign the `C0FHIR CONTEXT` option as a secondary menu to the dashboard's VistA Proxy/Service user.

---

## Troubleshooting

### Verification Command

Run the interactive tester to verify local data:

```mumps
D EN^C0FHIRTS

```

### Common Issues

* **Missing Labs:** Ensure the patient has an `LRDFN` (Field .63 in File #2) and that the encounter timestamp matches a `"CH"` subscript entry in File #63.
* **No RxNorm:** Verify that the drug in the Prescription file (#52) is linked to a VA Product (#50.68) that contains a value in the RxNorm field (99.9).
* **RPC Errors:** Check the VistA Error Trap (`D ^%ZTER`) for `<MAXSTRING>` or `<STORE>` errors, though these are mitigated by the Global Array return type.

---

## Data Mapping Reference

> **Note:** All dates are converted to ISO 8601 UTC format () using the `C0FHIRUTL` module to ensure compatibility with modern JavaScript frameworks.

---

**This completes the C0FHIR project hand-off.** Your VistA instance is now ready to serve high-fidelity clinical data to your dashboard. Is there any other specific VistA file or clinical domain you would like to integrate before we wrap up?