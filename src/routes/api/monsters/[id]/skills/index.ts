import { Hono } from "hono";
import { singleMonsterSkillRouter } from "./[monster_skill_id]";
import { callProc } from "@/services/db";
import type { PaginationInfo } from "@/routes/api/types";
import type {
   FieldPacket,
   ResultSetHeader,
   RowDataPacket,
} from "mysql2/promise";
import type { MonsterSkill } from "./types";

const router = new Hono();

router.get("/", async (c) => {
   const monsterId = c.req.param("id") ?? null;
   const [procRes] = (await callProc(
      "get_monster_skills",
      monsterId,
      c.req.query("limit") ? Number(c.req.query("limit")) : null,
      c.req.query("page") ? Number(c.req.query("page")) : null,
      null,
      c.req.query("filter:name") ?? null,
      c.req.query("filter:element") ?? null,
   )) as unknown as [
      [PaginationInfo[], MonsterSkill[], ResultSetHeader],
      FieldPacket[],
   ];
   const paginationInfo = procRes[0][0];
   const monsterSkillsData = procRes[1] as MonsterSkill[];

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

   const [procRes] = (await callProc(
      "add_monster_skill",
      sid,
      monsterId,
      body.skill_id,
      body.level_to_attain,
   )) as unknown as [[AddedMonsterSkill[], ResultSetHeader], FieldPacket[]];
   console.log(procRes);
   return c.json({
      data: {
         ...procRes[0][0],
      },
   });
});

router.route("/:monster_skill_id", singleMonsterSkillRouter);

export { router as monsterSkillsRouter };
