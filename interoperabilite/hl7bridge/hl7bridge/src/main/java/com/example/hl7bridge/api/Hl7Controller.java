package com.example.hl7bridge.api;

import org.apache.camel.ProducerTemplate;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/hl7")
public class Hl7Controller {

    private final ProducerTemplate template;

    public Hl7Controller(ProducerTemplate template) {
        this.template = template;
    }

    // Recoit le message hl7 v2 et transmet le contenu à la route mapv2toFhir
    @PostMapping(value = "/v2", consumes = MediaType.TEXT_PLAIN_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> receiveV2(@RequestBody String hl7v2) {
        // Envoi du message HL7 à la route Camel "direct:mapV2ToFhir"
        String fhirJson = template.requestBody("direct:mapV2ToFhir", hl7v2, String.class);
        // Retourne le FHIR JSON au client HTTP
        return ResponseEntity.ok().contentType(MediaType.APPLICATION_JSON).body(fhirJson);
    }

    @GetMapping("/ping")
    public String ping() {
        return "ok";
    }
}
