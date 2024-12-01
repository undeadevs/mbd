import type { MonsterSkill } from "@/routes/api/monsters/[id]/skills/types";
import type { PaginationInfo } from "@/routes/api/types";
import { callProc } from "@/services/db";
import { Hono } from "hono";

const router = new Hono();

router.get("/", async (c) => {
   const sid = c.req.header("X-Session-Id") ?? null;
   const { results } = await callProc<
      [PaginationInfo, Omit<MonsterSkill, "level_to_attain">]
   >(
      "get_turn_skills",
      sid,
      c.req.param("id") ?? null,
      c.req.query("tamed_id") ? Number(c.req.query("tamed_id")) : null,
      c.req.query("limit") ? Number(c.req.query("limit")) : null,
      c.req.query("page") ? Number(c.req.query("page")) : null,
   );

   const paginationData = results[0][0];
   const turnSkillsData = results[1];

   return c.json({ data: { ...paginationData, turnSkills: turnSkillsData } });
});

export { router as turnSkillsRouter };
