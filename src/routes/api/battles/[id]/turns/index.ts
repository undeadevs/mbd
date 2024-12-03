import { callProc } from "@/services/db";
import { Hono } from "hono";
import { turnSkillsRouter } from "./available-skills";
import type { PaginationInfo } from "@/routes/api/types";
import type { Turn } from "./types";
import { singleTurnRouter } from "./[turn_id]";

const router = new Hono();

router.get("/", async (c) => {
   const { results } = await callProc<[PaginationInfo, Turn]>(
      "get_turns",
      c.req.param("id") ?? null,
      c.req.query("limit") ? Number(c.req.query("limit")) : null,
      c.req.query("page") ? Number(c.req.query("page")) : null,
      null,
      c.req.query("filter:type") ?? null,
   );
   const paginationInfo = results[0][0];
   const turnsData = results[1];

   return c.json({
      data: {
         ...paginationInfo,
         turns: turnsData,
      },
   });
});

router.post("/", async (c) => {
   const sid = c.req.header("X-Session-Id") ?? null;
   const body = await c.req.json();
   const { results } = await callProc<
      [{ action: Turn["action"]; value: number | null }]
   >(
      "take_turn",
      sid,
      c.req.param("id") ?? null,
      body.tamed_id ?? null,
      body.action ?? null,
      body.monster_skill_id ?? null,
   );

   return c.json({ data: { turn: results[0][0] } });
});

router.route("/available-skills", turnSkillsRouter);
router.route("/:id", singleTurnRouter);

export { router as turnsRouter };
