import { callProc } from "@/services/db";
import { Hono } from "hono";
import type { RowDataPacket } from "mysql2/promise";
import { singleSkillRouter } from "./[id]";
import type { PaginationInfo } from "../types";
import type { Skill } from "./types";

const router = new Hono();

router.get("/", async (c) => {
   const { results } = await callProc<[PaginationInfo, Skill]>(
      "get_skills",
      c.req.query("limit") ? Number(c.req.query("limit")) : null,
      c.req.query("page") ? Number(c.req.query("page")) : null,
      null,
      c.req.query("filter:name") ?? null,
      c.req.query("filter:element") ?? null,
      c.req.query("filter:type") ?? null,
   );
   const paginationInfo = results[0][0];
   const skillsData = results[1];

   return c.json({
      data: {
         ...paginationInfo,
         skills: skillsData,
      },
   });
});

interface AddedSkill extends RowDataPacket {
   added_id: number;
}

router.post("/", async (c) => {
   const sid = c.req.header("X-Session-Id") || null;
   const body = await c.req.json();

   const { results } = await callProc<[AddedSkill]>(
      "add_skill",
      sid,
      body.name,
      body.element,
      body.type,
      body.value,
      body.turn_cooldown,
   );
   return c.json({
      data: {
         ...results[0][0],
      },
   });
});

router.route("/:id", singleSkillRouter);

export { router as skillsRouter };
