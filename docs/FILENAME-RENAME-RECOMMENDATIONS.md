# Docs Directory Filename Rename Recommendations

## Goals

1. **Cross-platform**: No spaces; use hyphens; lowercase for consistency (Linux/Windows safe)
2. **Content clarity**: Filenames reflect document purpose
3. **Sort order**: Numeric prefixes group related docs when viewed on GitHub

## Naming Convention

- **Prefix**: `NN-category-` (e.g., `01-spec-`, `02-arch-`) for sort order
- **Body**: Lowercase, hyphen-separated words
- **Extension**: `.md` (except `TechnicalFAQ.m` which is MUMPS)

## Current Issues

| Issue | Examples |
|-------|----------|
| Spaces in filenames | `Condition spec.md`, `Patient Entity spec.md` |
| Mixed case | `Container Gap Analysis.md`, `EntityLoad1.md` |
| Typos | `setpath explaination.md` → explanation |
| Inconsistent naming | `Encounter mapping.md` vs `FHIR Encounter spec.md` |
| No logical grouping | Specs, architecture, guides all mixed |

---

## Rename Mapping (Old → New)

### 01-spec-* — FHIR Entity & Resource Specifications

| Current | Proposed |
|---------|----------|
| `address spec.md` | `01-spec-address.md` |
| `Condition spec.md` | `01-spec-condition.md` |
| `Encounter mapping.md` | `01-spec-encounter-mapping.md` |
| `Entity editing spec.md` | `01-spec-entity-editing.md` |
| `FHIR Encounter spec.md` | `01-spec-encounter.md` |
| `FHIR R4 CodeableConcept solution.md` | `01-spec-codeable-concept.md` |
| `FHIR R4 implementation.md` | `01-spec-fhir-r4-implementation.md` |
| `Immunization spec.md` | `01-spec-immunization.md` |
| `MedicationRequest spec.md` | `01-spec-medication-request.md` |
| `Patient Entity spec.md` | `01-spec-patient.md` |
| `Procedure spec.md` | `01-spec-procedure.md` |
| `Utility specs.md` | `01-spec-utility.md` |

### 02-arch-* — Architecture & Design

| Current | Proposed |
|---------|----------|
| `architectural hierarchy.md` | `02-arch-hierarchy.md` |
| `Container Gap Analysis.md` | `02-arch-container-gap-analysis.md` |
| `VPR-container-list.md` | `02-arch-vpr-container-list.md` |
| `VPR entity reuse.md` | `02-arch-vpr-entity-reuse.md` |

### 03-impl-* — Implementation Details

| Current | Proposed |
|---------|----------|
| `crawl justification.md` | `03-impl-crawl-justification.md` |
| `dot notation verification.md` | `03-impl-dot-notation-verification.md` |
| `Editing Verification.md` | `03-impl-editing-verification.md` |
| `final driver.md` | `03-impl-final-driver.md` |
| `reference solution.md` | `03-impl-reference-solution.md` |
| `setpath explaination.md` | `03-impl-setpath-explanation.md` |

### 04-project-* — Project Documentation

| Current | Proposed |
|---------|----------|
| `C0FHIR PATIENT Entity Structure.md` | `04-project-patient-entity-structure.md` |
| `Final Documentation Architecture.md` | `04-project-doc-architecture.md` |
| `Final Project Inventory.md` | `04-project-inventory.md` |
| `Final Project Manifest (v1.2).md` | `04-project-manifest-v1.2.md` |
| `Final Project Summary.md` | `04-project-summary.md` |
| `Final Routine Manifest & Checksum Table (33 Total).md` | `04-project-routine-manifest.md` |
| `Final System Architecture Overview.md` | `04-project-system-architecture.md` |
| `Project Context Document.md` | `04-project-context.md` |
| `C0FHIR Suite Quick Start Guide.md` | `04-project-quick-start.md` |

### 05-guide-* — User & Admin Guides

| Current | Proposed |
|---------|----------|
| `DeploymentLifecycle.md` | `05-guide-deployment-lifecycle.md` |
| `How the Workflow Changes.md` | `05-guide-workflow-changes.md` |
| `How this appears to the Admin.md` | `05-guide-admin-view.md` |
| `How to export the project.md` | `05-guide-export.md` |
| `InstallationGuide.md` | `05-guide-installation.md` |
| `kidsManualGuide.md` | `05-guide-kids-manual.md` |

### 06-ref-* — Reference & Metadata

| Current | Proposed |
|---------|----------|
| `context.md` | `06-ref-context.md` |
| `DDEasMetadata.md` | `06-ref-dde-as-metadata.md` |
| `DotNotation.md` | `06-ref-dot-notation.md` |
| `VistA Data Discovery Engine (DDE) Entity Registry.md` | `06-ref-dde-entity-registry.md` |
| `VistA Entity Registry Metadata (File #1.5).md` | `06-ref-entity-registry-metadata.md` |

### 07-entity-* — Entity Loading & Management

| Current | Proposed |
|---------|----------|
| `EntityDDECheck.md` | `07-entity-dde-check.md` |
| `EntityFileAnalysis.md` | `07-entity-file-analysis.md` |
| `EntityFinalCheck.md` | `07-entity-final-check.md` |
| `EntityItems.md` | `07-entity-items.md` |
| `EntityLoad1.md` | `07-entity-load-01.md` |
| `EntityLoad2.md` | `07-entity-load-02.md` |
| `EntityLoad3.md` | `07-entity-load-03.md` |
| `EntityLoad4.md` | `07-entity-load-04.md` |
| `EntityLoad5.md` | `07-entity-load-05.md` |
| `EntityLoad6.md` | `07-entity-load-06.md` |
| `EntityLoadLetter.md` | `07-entity-load-letter.md` |
| `EntityNextSteps.md` | `07-entity-next-steps.md` |
| `EntitySiteReadiness.md` | `07-entity-site-readiness.md` |
| `EntityTroubleShootingGuide.md` | `07-entity-troubleshooting.md` |

### 08-routine-* — Routine-Specific Docs

| Current | Proposed |
|---------|----------|
| `C0FHIR2.md` | `08-routine-c0fhir2.md` |
| `C0FHIR3.md` | `08-routine-c0fhir3.md` |
| `C0FHIR4.md` | `08-routine-c0fhir4.md` |
| `C0FHIR5.md` | `08-routine-c0fhir5.md` |
| `C0FHIR6.md` | `08-routine-c0fhir6.md` |
| `C0FHIR7.md` | `08-routine-c0fhir7.md` |
| `RegistrySealer.md` | `08-routine-registry-sealer.md` |
| `RoutineManifest.md` | `08-routine-manifest.md` |
| `Tester.md` | `08-routine-tester.md` |

### 09-lab-* — Lab-Specific

| Current | Proposed |
|---------|----------|
| `LabAudit.md` | `09-lab-audit.md` |
| `LabLogic.md` | `09-lab-logic.md` |
| `labEntity.md` | `09-lab-entity.md` |

### 10-misc-* — Miscellaneous

| Current | Proposed |
|---------|----------|
| `BACKDOOR.md` | `10-misc-backdoor.md` |
| `CREEPY.md` | `10-misc-creepy.md` |
| `demo.md` | `10-misc-demo.md` |
| `demo2.md` | `10-misc-demo2.md` |
| `dotMap2.md` | `10-misc-dot-map-2.md` |
| `dotMap3.md` | `10-misc-dot-map-3.md` |
| `Feb16-Summary.md` | `10-misc-feb16-summary.md` |
| `GEMINI.md` | `10-misc-gemini.md` |
| `Gold Standard.md` | `10-misc-gold-standard.md` |
| `Implementation for Middleware.md` | `10-misc-middleware-implementation.md` |
| `Reversion.md` | `10-misc-reversion.md` |
| `Unit Tests.md` | `10-misc-unit-tests.md` |
| `Unit Tests2.md` | `10-misc-unit-tests-2.md` |

### Unchanged / Special

| Current | Note |
|---------|------|
| `C0FHIRTEST.md` | Consider `08-routine-c0fhir-test.md` |
| `EntityDDECheck.md` | Listed above |
| `FHIR Native Metadata Engine (Feature List).md` | Consider `02-arch-dde-feature-list.md` |
| `KidsRoutinesDeprecated.md` | Consider `10-misc-kids-routines-deprecated.md` |
| `TechnicalFAQ.m` | MUMPS file; consider `10-misc-technical-faq.m` or keep as-is |

### Additional Files to Include

| Current | Proposed |
|---------|----------|
| `FHIR Native Metadata Engine (Feature List).md` | `02-arch-dde-feature-list.md` |
| `KidsRoutinesDeprecated.md` | `10-misc-kids-routines-deprecated.md` |
| `TechnicalFAQ.m` | `10-misc-technical-faq.m` |

---

## Expected Sort Order on GitHub

```
01-spec-address.md
01-spec-codeable-concept.md
01-spec-condition.md
01-spec-encounter.md
01-spec-encounter-mapping.md
01-spec-entity-editing.md
01-spec-fhir-r4-implementation.md
01-spec-immunization.md
01-spec-medication-request.md
01-spec-patient.md
01-spec-procedure.md
01-spec-utility.md
02-arch-container-gap-analysis.md
02-arch-dde-feature-list.md
02-arch-hierarchy.md
02-arch-vpr-container-list.md
02-arch-vpr-entity-reuse.md
03-impl-crawl-justification.md
03-impl-dot-notation-verification.md
03-impl-editing-verification.md
03-impl-final-driver.md
03-impl-reference-solution.md
03-impl-setpath-explanation.md
04-project-context.md
04-project-doc-architecture.md
04-project-inventory.md
04-project-manifest-v1.2.md
04-project-patient-entity-structure.md
04-project-quick-start.md
04-project-routine-manifest.md
04-project-summary.md
04-project-system-architecture.md
05-guide-admin-view.md
05-guide-deployment-lifecycle.md
05-guide-export.md
05-guide-installation.md
05-guide-kids-manual.md
05-guide-workflow-changes.md
06-ref-context.md
06-ref-dde-as-metadata.md
06-ref-dde-entity-registry.md
06-ref-dot-notation.md
06-ref-entity-registry-metadata.md
07-entity-dde-check.md
07-entity-file-analysis.md
07-entity-final-check.md
07-entity-items.md
07-entity-load-01.md
... (through 07-entity-load-06)
07-entity-load-letter.md
07-entity-next-steps.md
07-entity-site-readiness.md
07-entity-troubleshooting.md
08-routine-c0fhir2.md
... (through 08-routine-c0fhir7)
08-routine-c0fhir-test.md
08-routine-manifest.md
08-routine-registry-sealer.md
08-routine-tester.md
09-lab-audit.md
09-lab-entity.md
09-lab-logic.md
10-misc-backdoor.md
10-misc-creepy.md
10-misc-demo.md
10-misc-demo2.md
10-misc-dot-map-2.md
10-misc-dot-map-3.md
10-misc-feb16-summary.md
10-misc-gemini.md
10-misc-gold-standard.md
10-misc-kids-routines-deprecated.md
10-misc-middleware-implementation.md
10-misc-reversion.md
10-misc-technical-faq.m
10-misc-unit-tests.md
10-misc-unit-tests-2.md
```

---

## Implementation Notes

1. **Git**: Use `git mv` to preserve history: `git mv "old name.md" "new-name.md"`
2. **References**: Search codebase and other docs for links to old filenames; update after rename
3. **README**: If docs/ has an index, update it
4. **Typos**: `explaination` → `explanation` in `03-impl-setpath-explanation.md`
