import { callProc } from "@/services/db";
import { Hono } from "hono";
import type { TamedMonster } from "../types";
import { HTTPException } from "hono/http-exception";

const router = new Hono();

router.get("/", async (c) => {
   const playerId = c.req.param("id") ?? null;
   const { results } = await callProc<[unknown, TamedMonster]>(
      "get_tamed_monsters",
      playerId,
      1,
      1,
      c.req.param("tamed_id") ?? null,
      null,
      null,
   );
   const tamedMonsterData = results[1][0];

   if (!tamedMonsterData) {
      throw new HTTPException(404, {
         message: "Tamed monster does not exist",
      });
   }

   return c.json({
      data: {
         tamedMonster: tamedMonsterData,
      },
   });
});

export { router as singleTamedMonsterRouter };
