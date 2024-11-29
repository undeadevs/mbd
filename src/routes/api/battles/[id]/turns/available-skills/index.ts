import type { MonsterSkill } from "@/routes/api/monsters/[id]/skills/types";
import { callProc } from "@/services/db";
import { Hono } from "hono";

const router = new Hono();

router.get("/", async (c) => {
   const sid = c.req.header("X-Session-Id") ?? null;
   const { results } = await callProc<[Omit<MonsterSkill, "level_to_attain">]>(
      "get_turn_skills",
      sid,
      c.req.param("id") ?? null,
      c.req.query("tamed_id") ? Number(c.req.query("tamed_id")) : null,
   );

   const turnSkillsData = results[0];

   return c.json({ data: { turnSkills: turnSkillsData } });
});

export { router as turnSkillsRouter };
