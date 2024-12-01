import { callProc } from "@/services/db";
import { Hono } from "hono";
import type { BattleRequest } from "./types";
import { singleBattleRequestRouter } from "./[id]";
import type { PaginationInfo } from "../../types";

const router = new Hono();

router.get("/", async (c) => {
   const sid = c.req.header("X-Session-Id") ?? null;
   const { results } = await callProc<[PaginationInfo, BattleRequest]>(
      "get_battle_requests",
      sid,
      c.req.query("limit") ? Number(c.req.query("limit")) : null,
      c.req.query("page") ? Number(c.req.query("page")) : null,
      null,
   );
   const paginationInfo = results[0][0];
   const battleRequestsData = results[1];
   return c.json({
      data: { ...paginationInfo, battleRequests: battleRequestsData },
   });
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
