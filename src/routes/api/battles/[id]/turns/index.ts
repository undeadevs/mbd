import { callProc } from "@/services/db";
import { Hono } from "hono";
import { turnSkillsRouter } from "./available-skills";

const router = new Hono();

router.post("/", async (c) => {
   const sid = c.req.header("X-Session-Id") ?? null;
   const body = await c.req.json();
   await callProc(
      "take_turn",
      sid,
      c.req.param("id") ?? null,
      body.tamed_id ?? null,
      body.action ?? null,
      body.monster_skill_id ?? null,
   );

   return c.json({ data: { message: "Successfully take turn" } });
});

router.route("available-skills", turnSkillsRouter);

export { router as turnsRouter };
