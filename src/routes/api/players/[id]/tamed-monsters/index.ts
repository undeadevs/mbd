import { callProc } from "@/services/db";
import { Hono } from "hono";
import type { PaginationInfo } from "../../../types";
import { singleTamedMonsterRouter } from "./[tamed_id]";
import type { TamedMonster } from "./types";

const router = new Hono();

router.get("/", async (c) => {
   const playerId = c.req.param("id") ?? null;
   const { results } = await callProc<[PaginationInfo, TamedMonster]>(
      "get_tamed_monsters",
      playerId,
      c.req.query("limit") ? Number(c.req.query("limit")) : null,
      c.req.query("page") ? Number(c.req.query("page")) : null,
      null,
      c.req.query("filter:name") ?? null,
      c.req.query("filter:element") ?? null,
   );
   const paginationInfo = results[0][0];
   const tamedMonstersData = results[1];

   return c.json({
      data: {
         ...paginationInfo,
         tamedMonsters: tamedMonstersData,
      },
   });
});

router.route("/:tamed_id", singleTamedMonsterRouter);

export { router as tamedMonstersRouter };
