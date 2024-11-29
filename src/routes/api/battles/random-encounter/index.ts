import { callProc } from "@/services/db";
import { Hono } from "hono";

const router = new Hono();

router.post("/", async (c) => {
   const sid = c.req.header("X-Session-Id") ?? null;
   const { results } = await callProc<[{ battle_id: number | null }]>(
      "random_encounter",
      sid,
   );

   return c.json({ data: { ...results[0][0] } });
});

export { router as randomEncounterRouter };
