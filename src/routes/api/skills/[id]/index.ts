import { callProc } from "@/services/db";
import { Hono } from "hono";
import type { FieldPacket, ResultSetHeader } from "mysql2/promise";
import type { Skill } from "../types";
import { HTTPException } from "hono/http-exception";

const router = new Hono();

router.get("/", async (c) => {
   const [procRes] = (await callProc(
      "get_skills",
      1,
      1,
      c.req.param("id") ?? null,
      null,
      null,
      null,
   )) as unknown as [[unknown[], Skill[], ResultSetHeader], FieldPacket[]];
   const skillData = procRes[1][0] as Skill;

   if (!skillData) {
      throw new HTTPException(404, {
         message: "Skill does not exist",
      });
   }

   return c.json({
      data: {
         monster: skillData,
      },
   });
});

router.patch("/", async (c) => {
   const sid = c.req.header("X-Session-Id") || null;
   const body = await c.req.json();

   await callProc(
      "edit_skill",
      sid,
      c.req.param("id") ?? null,
      body.name ?? null,
      body.element ?? null,
      body.type ?? null,
      body.value ?? null,
      body.turn_cooldown ?? null,
   );

   return c.json({
      data: {
         message: "Successfully edited skill",
      },
   });
});

router.delete("/", async (c) => {
   const sid = c.req.header("X-Session-Id") || null;

   await callProc("delete_skill", sid, c.req.param("id") ?? null);

   return c.json({
      data: {
         message: "Successfully skill monster",
      },
   });
});

export { router as singleSkillRouter };
