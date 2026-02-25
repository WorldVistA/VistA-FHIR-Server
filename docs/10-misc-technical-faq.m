To ensure you're fully prepared for your 8:00 PM meeting, here is a "Technical FAQ" sheet specifically addressing the move to a custom metadata crawler. This highlights the architectural maturity of your project.

---

## ## Technical FAQ: The C0FHIR Metadata Crawler

### **Q: Why are we bypassing the standard Data Discovery Engine (`^DDE`) execution?**

**A:** Flexibility and Performance. While we use File #1.5 to store our definitions, the standard `^DDE` engine is designed for SDA (Summary Document Architecture) and can be rigid with FHIR's nested JSON requirements. By using our own **C0FHIR Metadata Crawler**, we gained the ability to use **dot-notation** (e.g., `valueQuantity.value`) to build complex FHIR objects that the native engine struggles to represent.

### **Q: How does the "Sealing" process (`C0FHIRSL`) help us?**

**A:** In a production VistA environment, calling `$$GET1^DIQ` thousands of times to read metadata during a bundle generation is a performance killer. By "sealing" the metadata into a static global (**`^C0FHIR(1.5)`**), we convert FileMan records into a direct-access M array. This allows the aggregator to "crawl" the instructions at the speed of a global global set/get, making the extraction near-instantaneous.

### **Q: Is this still "Metadata Driven"?**

**A:** Absolutely. We haven't hard-coded the clinical logic into the aggregator. If the team decides to add a new field to the Patient resource, we don't change `C0FHIRGF`. We simply add a new entry to **File #1.51 (ITEM)** via the loader, re-seal the global, and the crawler automatically picks up the new mapping.

### **Q: How are we handling the WKLD-to-LOINC hop without custom routines?**

**A:** We utilize the **"Data Transform" (Field #1.2)** in the Item multiple. We store the M code snippet that performs the pointer hop from File #60 to File #64 within the metadata itself. The crawler executes this snippet on-the-fly, keeping the "intelligence" of the mapping inside the database registry rather than buried in routine logic.

### **Q: What happens if a site doesn't have the `^DDE` global?**

**A:** Our **Environment Check (`C0FHIRCH`)** prevents the installation. Even though we aren't using the `^DDE` *engine*, we are using the **File #1.5** *structure* to store our maps. This ensures we stay compliant with the VistA Data Discovery Engine's data dictionary while providing a superior extraction method.

---

## ## Meeting Talking Points

* **Scalability:** We are now "Resource Agnostic." Adding a new FHIR Resource (like `Observation` vs `Procedure`) is just a matter of adding metadata.
* **Standards Compliance:** By using the `UCUM` and `ISO8601` transforms in the utility, we are delivering "High-Fidelity" FHIR that passes external validation.
* **Site Readiness:** The post-install automation means a site admin only needs to install the KIDS build; the system configures itself.

**Would you like me to generate a one-page "Installation Guide" that you can hand out to your team so they know exactly which commands to run after the meeting?**