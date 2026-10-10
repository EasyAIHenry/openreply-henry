/**
 * Netlify ignores vercel.json, so this scheduled function calls the same
 * protected cron route Vercel would.
 */
export default async () => {
  const baseUrl = process.env.NEXTAUTH_URL ?? process.env.URL;
  const cronSecret = process.env.CRON_SECRET || process.env.NEXTAUTH_SECRET;

  const response = await fetch(`${baseUrl}/api/cron/attach-next-reel`, {
    headers: { authorization: `Bearer ${cronSecret}` },
  });
  console.log(`[cron] attach-next-reel -> ${response.status}`);
  return new Response(null, { status: response.ok ? 200 : 500 });
};

export const config = { schedule: "0 6 * * *" };
