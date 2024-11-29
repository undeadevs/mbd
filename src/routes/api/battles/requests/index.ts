import { callProc } from "@/services/db";
import { Hono } from "hono";
import type { BattleRequest } from "./types";
import { singleBattleRequestRouter } from "./[id]";

const router = new Hono();

router.get("/", async (c) => {
   const sid = c.req.header("X-Session-Id") ?? null;
   const { results } = await callProc<[BattleRequest]>(
      "get_battle_requests",
      sid,
   );
   const battleRequestsData = results[0];
   return c.json({ data: { battleRequests: battleRequestsData } });
});

router.post("/", async (c) => {
   const sid = c.req.header("X-Session-Id") ?? null;
   const body = await c.req.json();

   const { results } = await callProc<[{ request_id: number }]>(
      "request_battle",
      sid,
      body.player2_id,
   );

   return c.json({ data: { ...results[0][0] } });
});

router.route("/:id", singleBattleRequestRouter);

export { router as battleRequestsRouter };
