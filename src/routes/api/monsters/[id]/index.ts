import { callProc } from "@/services/db";
import { Hono } from "hono";
import type { Monster } from "../types";
import { HTTPException } from "hono/http-exception";
import { monsterSkillsRouter } from "./skills";

const router = new Hono();

router.get("/", async (c) => {
   const { results } = await callProc<[unknown, Monster]>(
      "get_monsters",
      1,
      1,
      c.req.param("id") ?? null,
      null,
      null,
   );
   const monsterData = results[1][0];

   if (!monsterData) {
      throw new HTTPException(404, {
         message: "Monster does not exist",
      });
   }

   return c.json({
      data: {
         monster: monsterData,
      },
   });
});

router.patch("/", async (c) => {
   const sid = c.req.header("X-Session-Id") || null;
   const body = await c.req.json();

   await callProc(
      "edit_monster",
      sid,
      c.req.param("id") ?? null,
      body.name ?? null,
      body.element ?? null,
      body.base_health ?? null,
      body.base_next_xp ?? null,
      body.max_xp ?? null,
   );

   return c.json({
      data: {
         message: "Successfully edited monster",
      },
   });
});

router.delete("/", async (c) => {
   const sid = c.req.header("X-Session-Id") || null;

   await callProc("delete_monster", sid, c.req.param("id") ?? null);

   return c.json({
      data: {
         message: "Successfully deleted monster",
      },
   });
});

router.route("/skills", monsterSkillsRouter);

export { router as singleMonsterRouter };
