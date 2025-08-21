"use client";

import { useEffect, useState } from "react";

// Types FHIR simplifiés
type Coding = { system?: string; code?: string; display?: string };
type CodeableConcept = { coding?: Coding[]; text?: string };
type FhirResource = any;

/**
 * Retourne un texte lisible pour un champ "code"
 * en utilisant d'abord display, puis text, puis code
 */
function pickCodeDisplay(code?: { coding?: Coding[]; text?: string }): string {
  if (!code) return "";
  const first = code.coding?.[0];
  return first?.display || code.text || first?.code || "";
}

/**
 * Retourne un texte lisible pour une "valueCodeableConcept"
 */
function pickValueDisplay(val?: CodeableConcept): string {
  if (!val) return "";
  const first = val.coding?.[0];
  return first?.display || val.text || first?.code || "";
}

export default function Home() {
  const [bundle, setBundle] = useState<any | null>(null);

  useEffect(() => {
    const tick = async () => {
      try {
        const res = await fetch("/api/webhook", { cache: "no-store" });
        const json = await res.json();
        if (json?.lastBundle) setBundle(json.lastBundle);
      } catch {}
    };
    tick();
    const id = setInterval(tick, 1000);
    return () => clearInterval(id);
  }, []);

  const patient: FhirResource | undefined = bundle?.entry?.find(
    (e: any) => e?.resource?.resourceType === "Patient"
  )?.resource;

  const observations: FhirResource[] =
    bundle?.entry
      ?.map((e: any) => e?.resource)
      ?.filter((r: any) => r?.resourceType === "Observation") ?? [];

  return (
    <main
      style={{
        maxWidth: 740,
        margin: "40px auto",
        padding: 16,
        fontFamily: "system-ui, sans-serif",
      }}
    >
      <h1>📄 Données patient reçues</h1>

      {!bundle && <p>Aucune donnée reçue pour l’instant</p>}

      {patient && (
        <section
          style={{
            border: "1px solid #ddd",
            borderRadius: 8,
            padding: 16,
            marginTop: 12,
          }}
        >
          <h2>Patient</h2>
          <p>
            <b>ID:</b> {patient.id}
          </p>
          <p>
            <b>Nom:</b> {patient.name?.[0]?.family}{" "}
            {patient.name?.[0]?.given?.[0]}
          </p>
          <p>
            <b>Sexe:</b> {patient.gender}
          </p>
          <p>
            <b>Date de naissance:</b> {patient.birthDate}
          </p>
        </section>
      )}

      {observations.length > 0 && (
        <section
          style={{
            border: "1px solid #ddd",
            borderRadius: 8,
            padding: 16,
            marginTop: 12,
          }}
        >
          <h2>Observations</h2>
          {observations.map((o, idx) => (
            <div
              key={idx}
              style={{
                padding: "8px 0",
                borderTop: idx ? "1px solid #eee" : "none",
              }}
            >
              <div>
                <b>Type:</b> {pickCodeDisplay(o.code)}
              </div>
              <div>
                <b>Valeur:</b> {pickValueDisplay(o.valueCodeableConcept)}
              </div>
            </div>
          ))}
        </section>
      )}
    </main>
  );
}
