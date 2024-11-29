import { callProc } from "@/services/db";
import { Hono } from "hono";
import type { Battle } from "../../types";

const router = new Hono();

router.post("/", async (c) => {
   const sid = c.req.header("X-Session-Id") ?? null;
   const body = await c.req.json();
   const { results } = await callProc<[{ battle_id: Battle["id"] | null }]>(
      "reply_battle_request",
      sid,
      c.req.param("id") ?? null,
      body.reply ?? null,
   );

   return c.json({ data: { ...results[0][0] } });
});

export { router as singleBattleRequestRouter };
