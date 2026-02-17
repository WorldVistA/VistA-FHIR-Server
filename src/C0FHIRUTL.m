C0FHIRUTL ;VAMC/JS-FHIR UTILITIES ; 16-FEB-2026
 ;;1.2;C0FHIR PROJECT;;Feb 16, 2026;Build 2
 Q
UCUM(VAL) ; Map VistA units to UCUM codes
 S VAL=$G(VAL) Q:VAL=""
 N U S U=$$UP^XLFSTR(VAL)
 ; Simple mapping table for common Vitals
 S VAL=$S(U="LB":"[lb_av]",U="KG":"kg",U="IN":"[in_i]",U="CM":"cm",U="F":"[degF]",U="C":"[degC]",U="MMHG":"mm[Hg]",U="BPM":"/min",1:VAL)
 Q
 ;
DATE(VDT) ; Convert VistA date to ISO8601
 Q $$DATE^VPRD(VDT) ; Utilize VPR date utility if available