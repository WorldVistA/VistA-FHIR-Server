C0FHIRUTL ;VAMC/JS-FHIR UTILITY HELPERS ; 19-JAN-2026
 ;;1.0;C0FHIR PROJECT;;Jan 19, 2026;Build 1
 Q
ISO8601(FDT) ;Convert FileMan Date to ISO 8601 String
 Q:FDT="" ""
 N ISO S ISO=$$FMTHL7^XLFDT(FDT)
 Q $E(ISO,1,4)_"-"_$E(ISO,5,6)_"-"_$E(ISO,7,8)_"T"_$E(ISO,9,10)_":"_$E(ISO,11,12)_":"_$E(ISO,13,14)_"Z"
 ;
BASE64(STR) ;Convert String to Base64 (Requires XLFUTL)
 Q $$B64ENCD^XLFUTL(.STR)