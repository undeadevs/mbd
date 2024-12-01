import { callProc } from "@/services/db";
import { Hono } from "hono";
import type { Battle } from "../../types";
import type { BattleRequest } from "../types";
import { HTTPException } from "hono/http-exception";

const router = new Hono();

router.get("/", async (c) => {
   const sid = c.req.header("X-Session-Id") ?? null;
   const { results } = await callProc<[unknown, BattleRequest]>(
      "get_battle_requests",
      sid,
      1,
      1,
      c.req.param("id") ?? null,
   );
   const battleRequestData = results[1][0];

   if (!battleRequestData) {
      throw new HTTPException(404, {
         message: "Battle request does not exist",
      });
   }

   return c.json({
      data: {
         battleRequest: battleRequestData,
      },
   });
});

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
