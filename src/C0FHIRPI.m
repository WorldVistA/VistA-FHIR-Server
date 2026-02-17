C0FHIRPI ;VAMC/JS-FHIR BUNDLE POST-INSTALL ; 17-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 17, 2026;Build 2
 Q
EN ; KIDS Post-Install Entry Point
 D MES^XPDUTL("  Starting Post-Install for C0FHIR Build 2...")
 ;
 ; 1. Load the File #1.5 Entities (Manual Loader)
 D MES^XPDUTL("  - Populating C0FHIR Metadata Registry (File #1.5)...")
 D EN^C0FHIRLD
 ;
 ; 2. Seal the Metadata for Performance
 D MES^XPDUTL("  - Sealing Metadata into Static Global ^C0FHIR(1.5)...")
 D SEAL^C0FHIRSL
 ;
 ; 3. Register Web Service (Optional check for File #18.12)
 D REG
 ;
 D MES^XPDUTL("  Post-Install Complete. System is FHIR-ready.")
 Q
 ;
REG ; Register the 'fhir' REST endpoint if not present
 N FDA,IEN,NAME S NAME="C0FHIR REST SERVICE"
 I $D(^DIC(18.12,"B",NAME)) Q
 S FDA(18.12,"+1,",.01)=NAME
 S FDA(18.12,"+1,",.03)=8080 ; Default Port
 S FDA(18.12,"+1,",.04)="fhir" ; The URL path
 D UPDATE^DIE("","FDA")
 Q