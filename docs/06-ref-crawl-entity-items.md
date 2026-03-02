# CRAWL ENTITY-Type Items Extension

This document describes the extension to `CRAWL^C0FHIRGF` that supports **ENTITY-type** DDE items. These items link to child entities (e.g., `participant`) whose resources are nested into the parent resource rather than added as separate bundle entries.

---

## 1. Overview

Previously, CRAWL only handled **simple** items:

- **GET ACTION (6):** M code that sets `VALUE`
- **OUTPUT TRANSFORM (4):** M code that transforms `VAL` → `VALUE`
- **Direct DIQ:** `$$GET1^DIQ(FILE,ID,FLD)` when no GET ACTION

Values were written to the parent MAP via `SETPATH^C0FHIRUTL(.MAP,TAG,VAL)`.

ENTITY-type items (`.03="E"` or `TYPE=2`) require different handling:

1. Read the linked child entity name from `^DDE(EIEN,1,IIEN,"E")`
2. Iterate the source subfile (e.g., 9000010.06 for participant)
3. For each subfile record, call CRAWL for the child entity with composite ID
4. Merge each child resource into the parent MAP at `TAG.0`, `TAG.1`, …

---

## 2. DDE Metadata for ENTITY Items

| Storage | Field | Purpose |
|--------|-------|---------|
| `^DDE(EIEN,1,IIEN,0)` | Item name (piece 1) | FHIR path tag (e.g., `participant`) |
| `^DDE(EIEN,1,IIEN,.03)` | Item type | `"E"` or `2` = ENTITY |
| `^DDE(EIEN,1,IIEN,.04)` | Source file | e.g., `9000010.06` |
| `^DDE(EIEN,1,IIEN,"E")` | Child entity | e.g., `C0FHIR ENCOUNTER PARTICIPANT` |

---

## 3. CRAWL Changes

### 3.1 Item Loop (CRAWL)

For each item, CRAWL now:

1. Reads `TYPE` from `^DDE(EIEN,1,IIEN,.03)` or `$P(ITEM,U,3)`
2. If `TYPE="E"` or `TYPE=2`:
   - Reads `CHILD` from `^DDE(EIEN,1,IIEN,"E")`
   - Calls `CRAWLENTITY(EIEN,IIEN,TAG,CHILD,FILE,ID,.MAP)`
   - Skips the simple-item path
3. Otherwise: continues with GET ACTION, OUTPUT TRANSFORM, SETPATH as before

### 3.2 CRAWLENTITY

`CRAWLENTITY(PARENT,IIEN,TAG,CHILD,FILE,PID,.MAP)` handles ENTITY-type items:

| Parameter | Description |
|-----------|-------------|
| `TAG` | FHIR path segment (e.g., `participant`) |
| `CHILD` | Child entity name (e.g., `C0FHIR ENCOUNTER PARTICIPANT`) |
| `FILE` | Source file (e.g., `9000010.06`) |
| `PID` | Parent ID (e.g., Visit IEN) |
| `MAP` | Parent resource MAP (by ref) |

**Participant (9000010.06):**

- Iterates `^AUPNVPOV(PID,6,SUBID)` for each V-Provider record
- For each `SUBID`, calls `CRAWL(CHILD,PID_","_SUBID,.SUBMAP,.CEIEN)`
- Merges each child into `MAP(TAG,PIDX)` via `MERGEPART^C0FHIRUTL(.MAP,TAG,PIDX,.SUBMAP)`
- `PIDX` is 0-based (0, 1, 2, …) for FHIR array indexing

**Generic (other ENTITY items):**

- Single child: calls `CRAWL(CHILD,PID,.SUBMAP,.CEIEN)` and merges at `TAG.0`

---

## 4. MERGEPART (C0FHIRUTL)

```mumps
MERGEPART(TARGET,TAG,PIDX,SUBMAP)
```

| Parameter | Description |
|-----------|-------------|
| `TARGET` | Parent MAP array (by ref) |
| `TAG` | FHIR path segment (e.g., `participant`) |
| `PIDX` | 0-based array index |
| `SUBMAP` | Child bundle from CRAWL |

**Behavior:**

- If `SUBMAP("entry",1,"resource")` is undefined, returns immediately
- Otherwise: `M TARGET(TAG,PIDX)=SUBMAP("entry",1,"resource")`

This copies the child resource (built by CRAWL) into the parent at `participant.0`, `participant.1`, etc., producing valid FHIR `participant[]` arrays.

---

## 5. Participant Flow (Example)

```
PROC(ENCPTR) → CRAWL("C0FHIR ENCOUNTER", VISIT, .BNDL, .CNT)
  │
  ├─ Simple items: identifier, status, class, period, subject, …
  │
  └─ ENTITY item "participant" (FILE=9000010.06)
       │
       └─ CRAWLENTITY(…,"participant","C0FHIR ENCOUNTER PARTICIPANT",9000010.06,VISIT,.MAP)
            │
            ├─ SUBID=1 → CRAWL("C0FHIR ENCOUNTER PARTICIPANT", "VISIT,1", .SUBMAP, .CEIEN)
            │              → SUBMAP("entry",1,"resource") = { individual, type }
            │              → MERGEPART(.MAP,"participant",0,.SUBMAP)
            │
            ├─ SUBID=2 → CRAWL(…,"VISIT,2",…)
            │              → MERGEPART(.MAP,"participant",1,.SUBMAP)
            │
            └─ …
```

Result: `MAP("participant",0,"individual","reference")="Practitioner/123"`, `MAP("participant",1,…)`, etc.

---

## 6. Global Structure Note

The participant iteration uses:

```mumps
^AUPNVPOV(PID,6,SUBID)
```

- `^AUPNVPOV` = Visit file 9000010 (typical VistA global root)
- Subscript `6` = V-Provider subfile (9000010.06)
- `SUBID` = Provider subfile IEN

If your site uses a different global for file 9000010 or 9000010.06, update line 109 in `C0FHIRGF.m` accordingly. Verify against the local VistA Data Dictionary.

---

## 7. Related Files

| File | Role |
|------|------|
| `src/C0FHIRGF.m` | CRAWL, CRAWLENTITY |
| `src/C0FHIRUTL.m` | MERGEPART, SETPATH |
| `src/C0FHIRLE.m` | Defines participant item with `.03="E"`, `"E"`=C0FHIR ENCOUNTER PARTICIPANT |
| `src/C0FHIRLP.m` | C0FHIR ENCOUNTER PARTICIPANT entity corrector (items for individual, type) |
