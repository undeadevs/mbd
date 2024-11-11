import { Hono } from "hono";
import { singleMonsterSkillRouter } from "./[monster_skill_id]";
import { callProc } from "@/services/db";
import type { PaginationInfo } from "@/routes/api/types";
import type { RowDataPacket } from "mysql2/promise";
import type { MonsterSkill } from "./types";

const router = new Hono();

router.get("/", async (c) => {
   const monsterId = c.req.param("id") ?? null;
   const { results } = await callProc<[PaginationInfo, MonsterSkill]>(
      "get_monster_skills",
      monsterId,
      c.req.query("limit") ? Number(c.req.query("limit")) : null,
      c.req.query("page") ? Number(c.req.query("page")) : null,
      null,
      c.req.query("filter:name") ?? null,
      c.req.query("filter:element") ?? null,
   );
   const paginationInfo = results[0][0];
   const monsterSkillsData = results[1];

   return c.json({
      data: {
         ...paginationInfo,
         monsterSkills: monsterSkillsData,
      },
   });
});

interface AddedMonsterSkill extends RowDataPacket {
   added_id: number;
}

router.post("/", async (c) => {
   const sid = c.req.header("X-Session-Id") || null;
   const monsterId = c.req.param("id") ?? null;
   const body = await c.req.json();

   const { results } = await callProc<[AddedMonsterSkill]>(
      "add_monster_skill",
      sid,
      monsterId,
      body.skill_id,
      body.level_to_attain,
   );
   return c.json({
      data: {
         ...results[0][0],
      },
   });
});

router.route("/:monster_skill_id", singleMonsterSkillRouter);

export { router as monsterSkillsRouter };
