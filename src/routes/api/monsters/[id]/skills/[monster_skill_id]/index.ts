import { callProc } from "@/services/db";
import { Hono } from "hono";
import type { MonsterSkill } from "../types";
import type { FieldPacket, ResultSetHeader } from "mysql2/promise";
import { HTTPException } from "hono/http-exception";

const router = new Hono();

router.get("/", async (c) => {
   const [procRes] = (await callProc(
      "get_monster_skills",
      c.req.param("id") ?? null,
      1,
      1,
      c.req.param("monster_skill_id") ?? null,
      null,
      null,
   )) as unknown as [
      [unknown[], MonsterSkill[], ResultSetHeader],
      FieldPacket[],
   ];
   const monsterSkillData = procRes[1][0] as MonsterSkill;

   if (!monsterSkillData) {
      throw new HTTPException(404, {
         message: "Monster skill does not exist",
      });
   }

   return c.json({
      data: {
         monsterSkill: monsterSkillData,
      },
   });
});

router.patch("/", async (c) => {
   const sid = c.req.header("X-Session-Id") || null;
   const body = await c.req.json();

   await callProc(
      "edit_monster_skill",
      sid,
      c.req.param("monster_skill_id") ?? null,
      c.req.param("id") ?? null,
      body.skill_id ?? null,
      body.level_to_attain ?? null,
   );

   return c.json({
      data: {
         message: "Successfully edited monster skill",
      },
   });
});

router.delete("/", async (c) => {
   const sid = c.req.header("X-Session-Id") || null;

   await callProc(
      "delete_monster_skill",
      sid,
      c.req.param("monster_skill_id") ?? null,
   );

   return c.json({
      data: {
         message: "Successfully deleted monster skill",
      },
   });
});

export { router as singleMonsterSkillRouter };
