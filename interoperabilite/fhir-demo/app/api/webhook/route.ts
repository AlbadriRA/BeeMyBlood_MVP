import { NextResponse } from "next/server";

let lastBundle: any | null = null;

export async function POST(req: Request) {
  try {
    const body = await req.json();
    // petite validation très basique
    if (!body || body.resourceType !== "Bundle") {
      return NextResponse.json(
        { ok: false, error: "Not a FHIR Bundle" },
        { status: 400 }
      );
    }
    lastBundle = body;
    return NextResponse.json({ ok: true });
  } catch (e: any) {
    return NextResponse.json(
      { ok: false, error: e?.message ?? "unknown" },
      { status: 400 }
    );
  }
}

export async function GET() {
  return NextResponse.json({ ok: true, lastBundle });
}

// endpoint pour le polling côté UI
export const dynamic = "force-dynamic";
