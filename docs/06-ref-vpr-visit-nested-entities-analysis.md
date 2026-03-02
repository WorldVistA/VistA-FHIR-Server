# VPR VISIT Nested Entities: Reuse vs Duplicate Analysis

This document analyzes the **nested entities** (ITEM TYPE = ENTITY) used by or applicable to **VPR VISIT** and **C0FHIR ENCOUNTER**, and recommends which should be **reused** vs **duplicated and modified**.

---

## 1. Overview

VPR VISIT maps to the FHIR Encounter resource. It may nest child entities for:

| VPR Item (SDA) | FHIR Path | Typical Nested Entity | Source |
|----------------|-----------|----------------------|--------|
| **HealthCareFacility** | `location.0.location` | VPR LOCATION | Visit .22 → File #44 |
| **ConsultingClinicians** | `participant` | Provider entity | Visit 9000010.06 (V-Provider) |
| *(implicit)* | `serviceProvider` | VPR FACILITY | Visit .21 → File #4 |

The decision to **reuse** or **duplicate** depends on:

1. **Display Name** – Does it match the FHIR resource type?
2. **Item Names** – Do internal items use FHIR paths or SDA names?
3. **Source File** – Same file and context, or different?
4. **Namespace Isolation** – Risk of breaking legacy SDA feeds?

---

## 2. Entity-by-Entity Analysis

### 2.1 VPR LOCATION (HealthCareFacility → location.0.location)

| Criterion | Assessment |
|-----------|------------|
| **Source File** | 44 (HOSPITAL LOCATION) |
| **Display Name** | `Location` |
| **FHIR Alignment** | ✓ Matches FHIR `Location` resource |
| **Item Names** | Likely SDA (e.g., `ClinicName`, `StationNumber`) |
| **Used By** | Visit .22 (Location pointer) |

**Recommendation: REUSE (with verification)**

**Rationale:**
- Display Name `Location` matches FHIR R4 exactly.
- If internal items use generic names (`name`, `address`) or can be mapped via transforms, reuse is viable.
- **Verify:** Inspect `^DDE` for VPR LOCATION item names. If they use SDA names (`ClinicName`, `FacilityName`), either:
  - **Option A:** Reuse and add OUTPUT TRANSFORM to map to FHIR paths at the parent (C0FHIR ENCOUNTER) level.
  - **Option B:** Duplicate as `C0FHIR LOCATION` with FHIR item names if transforms are insufficient.

**Alternative:** C0FHIR ENCOUNTER currently uses **simple reference** (`location.0.location.reference`, `location.0.location.display`) without nesting. No nested entity required unless you need a full Location resource inline.

---

### 2.2 VPR FACILITY (serviceProvider)

| Criterion | Assessment |
|-----------|------------|
| **Source File** | 4 (INSTITUTION) |
| **Display Name** | `Organization` |
| **FHIR Alignment** | ✓ Matches FHIR `Organization` resource |
| **Item Names** | Likely SDA (e.g., `StationNumber`, `Name`) |
| **Used By** | Visit .21 (Hospital Location) |

**Recommendation: REUSE**

**Rationale:**
- Display Name `Organization` matches FHIR R4.
- Per [02-arch-vpr-entity-reuse.md](02-arch-vpr-entity-reuse.md): "Reuse leaf entities like VPR FACILITY IF their display names are generic."
- C0FHIR ENCOUNTER currently uses a **simple reference** (`serviceProvider.reference`) without nesting. If you later need a full Organization resource, reuse VPR FACILITY.

---

### 2.3 VPR USER / VPR PROVIDER (ConsultingClinicians → participant)

| Criterion | Assessment |
|-----------|------------|
| **Source File** | 200 (NEW PERSON) |
| **Display Name** | `Practitioner` |
| **FHIR Alignment** | ✓ Matches FHIR `Practitioner` resource |
| **Item Names** | Likely SDA (e.g., `ProviderName`, `ProviderId`) |
| **Used By** | participant.0.individual (via 9000010.06 .01) |

**Recommendation: REUSE (for individual reference only)**

**Rationale:**
- Display Name `Practitioner` matches FHIR.
- VPR USER/VPR PROVIDER returns Practitioner data from File #200.
- **Caveat:** participant also needs `type.0.coding.0.code` (PPRF/SPRF) from 9000010.06.04. VPR USER does not provide this. So:
  - **Reuse** VPR USER for the Practitioner payload when you need a full nested Practitioner.
  - **Or** use a simple reference (`participant.0.individual.reference`) with a transform—no nesting.

---

### 2.4 Participant Entity (ConsultingClinicians → participant)

| Criterion | Assessment |
|-----------|------------|
| **Source File** | 9000010.06 (V-Provider subfile) |
| **Display Name** | N/A (no direct VPR equivalent) |
| **FHIR Alignment** | `participant` = array of { individual, type } |
| **VPR Equivalent** | None; VPR may use a different pattern |

**Recommendation: DUPLICATE (create C0FHIR ENCOUNTER PARTICIPANT)**

**Rationale:**
- Source is **9000010.06**, not File #200. Each participant record has:
  - .01 = Provider (pointer to 200)
  - .04 = Role (P=Primary, etc.) → maps to `type.0.coding.0.code` (PPRF, SPRF)
- No VPR entity is keyed by 9000010.06. You need a **new entity** that:
  - Takes ID = 9000010.06 IEN (or VisitIEN,ProviderIEN)
  - Returns `individual.reference` = "Practitioner/"_provider
  - Returns `type.0.coding.0.code` = PPRF or SPRF
- Per [01-spec-encounter.md](01-spec-encounter.md): Create **C0FHIR ENCOUNTER PARTICIPANT** as a sub-entity.

---

### 2.5 Extension / AccountNumber / EnteredOn (Audit)

| Criterion | Assessment |
|-----------|------------|
| **Source** | Various (Visit, audit fields) |
| **Nested Entity** | Usually none; simple items or transforms |

**Recommendation: NO NESTED ENTITY**

**Rationale:**
- These are typically simple items or transforms, not nested entities.
- If Extension requires a complex structure, consider a small `C0FHIR EXTENSION` entity; otherwise use GET ACTION or OUTPUT TRANSFORM.

---

## 3. Summary Table

| Nested Entity | VPR Equivalent | Recommendation | Notes |
|---------------|----------------|----------------|-------|
| **Location** | VPR LOCATION | **Reuse** | Display Name matches; verify item names. Alternative: keep simple reference. |
| **Organization** | VPR FACILITY | **Reuse** | Display Name matches. Alternative: keep simple reference. |
| **Practitioner** | VPR USER / VPR PROVIDER | **Reuse** | For full nested Practitioner; participant type comes from elsewhere. |
| **Participant** | None | **Duplicate** | Create C0FHIR ENCOUNTER PARTICIPANT (source 9000010.06). |

---

## 4. Implementation Strategy

### Phase 1: Current State (No Nesting)
C0FHIR ENCOUNTER uses **simple references** for location and serviceProvider. No nested entities. This is valid FHIR and keeps the model simple.

### Phase 2: Add Participant (Duplicate)
1. Create **C0FHIR ENCOUNTER PARTICIPANT** entity.
2. Source: 9000010.06 (V-Provider).
3. Items: `individual.reference`, `type.0.coding.0.code`.
4. Add `participant` item to C0FHIR ENCOUNTER with ITEM TYPE=ENTITY, Entity=C0FHIR ENCOUNTER PARTICIPANT.
5. Pointer linkup: `D VPRV^VPRSDAV(ID)` or iterate 9000010.06.

### Phase 3: Optional – Nest Location/Organization (Reuse)
If you need **full** Location or Organization resources inline (vs. references):
1. Add item `location.0.location` with ITEM TYPE=ENTITY, Entity=**VPR LOCATION**.
2. GET ACTION or pointer: set ID = Visit .22 (Location IEN).
3. Add item `serviceProvider` with ITEM TYPE=ENTITY, Entity=**VPR FACILITY**.
4. GET ACTION: set ID = Visit .21 (Hospital Location IEN).
5. **Verify** VPR LOCATION and VPR FACILITY item names produce valid FHIR. If not, duplicate as C0FHIR LOCATION / C0FHIR ORGANIZATION.

---

## 5. References

- [01-spec-encounter.md](01-spec-encounter.md) – C0FHIR ENCOUNTER spec, participant sub-entity
- [02-arch-vpr-entity-reuse.md](02-arch-vpr-entity-reuse.md) – Reuse criteria (Display Name, leaf entities)
- [06-ref-vpr-visit-reference.md](06-ref-vpr-visit-reference.md) – VPR VISIT structure
- [01-spec-encounter-mapping.md](01-spec-encounter-mapping.md) – SDA → FHIR mapping

---

*Analysis date: Feb 2026. Based on DDE entity registry, VPR VISIT B-index, and FHIR R4 Encounter spec.*
