package com.example.hl7bridge.routes;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.hl7v2.model.Message;
import ca.uhn.hl7v2.util.Terser;
import org.apache.camel.builder.RouteBuilder;
import org.hl7.fhir.r4.model.*;
import org.springframework.stereotype.Component;

import java.text.SimpleDateFormat;

@Component
public class Hl7ToFhirRoute extends RouteBuilder {

    @Override
    public void configure() {
        // Gestion globale des exceptions dans la route
        onException(Exception.class)
                .handled(true)
                .process(ex -> {
                    Exception cause = ex.getProperty(org.apache.camel.Exchange.EXCEPTION_CAUGHT, Exception.class);
                    String msg = (cause != null ? cause.getMessage() : "Erreur inconnue");
                    OperationOutcome oo = new OperationOutcome();
                    oo.addIssue().setDiagnostics("Erreur conversion HL7 v2 vers FHIR : " + msg);
                    String json = FhirContext.forR4().newJsonParser().setPrettyPrint(true).encodeResourceToString(oo);
                    ex.getMessage().setBody(json);
                    ex.getMessage().setHeader("Content-Type", "application/fhir+json");
                });
        // Reçoit un message HL7 et le convertit en FHIR
        from("direct:mapV2ToFhir")
                .routeId("hl7v2-to-fhir")
                .convertBodyTo(String.class)
                .process(ex -> {
                    // Normalisation des fins de ligne HL7
                    String v2 = ex.getMessage().getBody(String.class)
                            .replace("\r\n", "\r").replace("\n", "\r");
                    ex.getMessage().setBody(v2);
                })
                .unmarshal().hl7() // Parsing HL7 avec HAPI HL7
                .process(ex -> {
                    Message msg = ex.getMessage().getBody(Message.class);
                    Terser t = new Terser(msg);

                    String id = nz(t.get("/.PID-3(0)-1"));
                    String idSys = nz(t.get("/.PID-3(0)-4-1")); // HUG
                    String family = nz(t.get("/.PID-5(0)-1"));
                    String given = nz(t.get("/.PID-5(0)-2"));
                    String birth = nz(t.get("/.PID-7-1"));
                    String sex = nz(t.get("/.PID-8-1"));

                    Bundle bundle = new Bundle().setType(Bundle.BundleType.COLLECTION);
                    // Création d’une ressource Patient
                    Patient p = new Patient();
                    p.setId(id);
                    p.addIdentifier()
                            .setSystem(idSystemUri(idSys))
                            .setValue(id);
                    p.addName().setFamily(family).addGiven(given);
                    p.setGender("F".equalsIgnoreCase(sex) ? Enumerations.AdministrativeGender.FEMALE
                            : "M".equalsIgnoreCase(sex) ? Enumerations.AdministrativeGender.MALE
                                    : Enumerations.AdministrativeGender.UNKNOWN);
                    if (birth.length() == 8) {
                        p.setBirthDate(new SimpleDateFormat("yyyyMMdd").parse(birth));
                    }
                    bundle.addEntry().setResource(p);
                    // Extraction des observations (OBX)
                    for (int i = 0; i < 10; i++) {
                        String obx3_code = nz(t.get("/.OBX(" + i + ")-3-1"));
                        String obx3_display = nz(t.get("/.OBX(" + i + ")-3-2"));
                        String obx3_sys = nz(t.get("/.OBX(" + i + ")-3-3")); // LN, SCT, etc.

                        String obx5_code = nz(t.get("/.OBX(" + i + ")-5-1")); // ex: LA21325-8
                        String obx5_display = nz(t.get("/.OBX(" + i + ")-5-2")); // ex: A
                        String obx5_sys = nz(t.get("/.OBX(" + i + ")-5-3")); // ex: LN

                        if (obx3_code.isEmpty() && obx5_code.isEmpty() && obx5_display.isEmpty()) {
                            continue; // pas d’observation valide
                        }

                        Observation o = new Observation();
                        o.setStatus(Observation.ObservationStatus.FINAL);
                        // Code de l’observation LOINC
                        Coding codeCoding = new Coding()
                                .setSystem(codeSystemUri(obx3_sys))
                                .setCode(obx3_code)
                                .setDisplay(obx3_display);
                        // Ajustement de labels pour ABO/Rh si code LOINC reconnu
                        if ("http://loinc.org".equals(codeCoding.getSystem())) {
                            if ("883-9".equals(obx3_code)) {
                                codeCoding.setDisplay("ABO group [Type] in Blood");
                            } else if ("10331-7".equals(obx3_code)) {
                                codeCoding.setDisplay("Rh [Type] in Blood");
                            }
                        }
                        o.getCode().addCoding(codeCoding);
                        // Valeur de l’observation
                        CodeableConcept val = new CodeableConcept();
                        if (!obx5_code.isEmpty() || !obx5_display.isEmpty()) {
                            val.addCoding()
                                    .setSystem(codeSystemUri(obx5_sys))
                                    .setCode(obx5_code)
                                    .setDisplay(obx5_display);
                            if (!obx5_display.isEmpty()) {
                                val.setText(obx5_display);
                            }
                        }
                        o.setValue(val);
                        // Référence au patient
                        o.setSubject(new Reference("Patient/" + id));
                        bundle.addEntry().setResource(o);
                    }
                    // Sérialisation du Bundle en JSON
                    String json = FhirContext.forR4().newJsonParser().setPrettyPrint(true)
                            .encodeResourceToString(bundle);

                    ex.setProperty("FHIR_JSON", json);
                    ex.getMessage().setBody(json);
                    ex.getMessage().setHeader("Content-Type", "application/fhir+json");
                })
                .wireTap("direct:sendToWebhook");
        // Envoie le FHIR JSON vers le nextjs
        from("direct:sendToWebhook")
                .routeId("send-fhir-to-next")
                .setHeader("Content-Type", constant("application/json"))
                .setBody(exchangeProperty("FHIR_JSON"))
                .toD("{{next.webhook.url}}?httpMethod=POST")
                .log("Webhook POST → status=${header.CamelHttpResponseCode}");
    }

    private static String nz(String s) {
        return s == null ? "" : s;
    }

    private static String codeSystemUri(String hl7Id) {
        if (hl7Id == null)
            return null;
        hl7Id = hl7Id.trim().toUpperCase();
        return switch (hl7Id) {
            case "LN" -> "http://loinc.org";
            case "SCT" -> "http://snomed.info/sct";
            default -> (hl7Id.startsWith("http://") || hl7Id.startsWith("https://") || hl7Id.startsWith("urn:"))
                    ? hl7Id
                    : null;
        };
    }

    private static String idSystemUri(String assigningAuthority) {
        return (assigningAuthority != null && !assigningAuthority.isBlank())
                ? "http://example.hug.ch/id/patient/" + assigningAuthority.trim().toLowerCase()
                : "http://example.hug.ch/id/patient";
    }
}
