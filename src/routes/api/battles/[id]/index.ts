import { Hono } from "hono";
import type { Battle } from "../types";
import { callProc } from "@/services/db";
import { HTTPException } from "hono/http-exception";
import { turnsRouter } from "./turns";

const router = new Hono();

router.get("/", async (c) => {
   const { results } = await callProc<[unknown, Battle]>(
      "get_battles",
      1,
      1,
      c.req.param("id") ?? null,
      null,
      null,
   );
   const battleData = results[1][0];

   if (!battleData) {
      throw new HTTPException(404, {
         message: "Battle does not exist",
      });
   }

   return c.json({
      data: {
         battle: battleData,
      },
   });
});

router.route("/turns", turnsRouter);

export { router as singleBattleRouter };
