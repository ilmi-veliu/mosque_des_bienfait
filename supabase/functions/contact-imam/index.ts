import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Échappe tous les caractères HTML pour éviter l'injection dans le corps de l'email
const escapeHtml = (s: string): string =>
  (s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')

// Nettoie les sauts de ligne pour éviter l'injection d'en-têtes email
const cleanLine = (s: string): string =>
  (s || '').replace(/[\r\n]/g, ' ').trim()

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const resendApiKey = Deno.env.get('RESEND_API_KEY')!
    const imamEmail = Deno.env.get('MOSQUE_EMAIL') || 'mosquee.perigueux@gmail.com'

    const body = await req.json()

    // Validation de présence
    if (!body.email?.trim() || !body.sujet?.trim() || !body.message?.trim()) {
      return new Response(JSON.stringify({ error: 'Champs requis manquants' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // Validation de longueur côté serveur
    const prenom = String(body.prenom || '').slice(0, 100)
    const email  = String(body.email).trim().slice(0, 255)
    const sujet  = String(body.sujet).trim().slice(0, 200)
    const message = String(body.message).trim().slice(0, 5000)

    // Validation format email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/
    if (!emailRegex.test(email)) {
      return new Response(JSON.stringify({ error: 'Email invalide' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    const expediteur = prenom ? `${cleanLine(prenom)} (${cleanLine(email)})` : cleanLine(email)

    const html = `
      <!DOCTYPE html>
      <html>
      <head><meta charset="utf-8"></head>
      <body style="font-family:sans-serif;color:#1f2937;margin:0;padding:0;background:#f9fafb;">
        <div style="max-width:600px;margin:0 auto;padding:32px 16px;">
          <div style="background:#030213;color:white;padding:20px 24px;border-radius:12px 12px 0 0;">
            <h1 style="margin:0;font-size:17px;font-weight:600;">Nouveau message pour l'Imam</h1>
            <p style="margin:4px 0 0;opacity:0.6;font-size:13px;">Via le site Mosquée des Bienfaisants</p>
          </div>
          <div style="background:white;padding:24px;border:1px solid #e5e7eb;border-top:none;border-radius:0 0 12px 12px;">
            <table style="width:100%;font-size:14px;border-collapse:collapse;margin-bottom:20px;">
              <tr style="border-bottom:1px solid #f3f4f6;">
                <td style="padding:10px 0;color:#6b7280;width:110px;font-weight:500;">De&nbsp;:</td>
                <td style="padding:10px 0;color:#111827;">${escapeHtml(expediteur)}</td>
              </tr>
              <tr style="border-bottom:1px solid #f3f4f6;">
                <td style="padding:10px 0;color:#6b7280;font-weight:500;">Sujet&nbsp;:</td>
                <td style="padding:10px 0;color:#111827;">${escapeHtml(sujet)}</td>
              </tr>
            </table>
            <div style="background:#f9fafb;border-radius:10px;padding:16px;font-size:15px;line-height:1.7;color:#374151;white-space:pre-wrap;">${escapeHtml(message)}</div>
            <div style="margin-top:20px;">
              <a href="mailto:${escapeHtml(email)}" style="display:inline-flex;align-items:center;gap:8px;background:#059669;color:white;padding:10px 20px;border-radius:8px;text-decoration:none;font-size:14px;font-weight:600;">
                Répondre à ${escapeHtml(prenom || email)}
              </a>
            </div>
          </div>
          <p style="text-align:center;font-size:12px;color:#9ca3af;margin-top:16px;">
            Mosquée des Bienfaisants · Périgueux
          </p>
        </div>
      </body>
      </html>
    `

    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${resendApiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        from: 'Site Mosquée <noreply@mosquee-perigueux.fr>',
        to: [imamEmail],
        reply_to: email,
        subject: `[Contact] ${cleanLine(sujet)} — ${cleanLine(expediteur)}`,
        html
      })
    })

    if (!res.ok) {
      const err = await res.text()
      throw new Error(`Resend error: ${err}`)
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (e) {
    return new Response(JSON.stringify({ error: (e as Error).message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})
