import { callProc } from "@/services/db";
import { Hono } from "hono";
import type { Player } from "../types";
import { HTTPException } from "hono/http-exception";
import { tamedMonstersRouter } from "./tamed-monsters";
import { frontlinersRouter } from "./frontliners";

const router = new Hono();

router.get("/", async (c) => {
   const { results } = await callProc<[unknown, Player]>(
      "get_players",
      1,
      1,
      c.req.param("id") ?? null,
      null,
   );
   const playerData = results[1][0];

   if (!playerData) {
      throw new HTTPException(404, {
         message: "Player does not exist",
      });
   }

   return c.json({
      data: {
         player: playerData,
      },
   });
});

router.delete("/", async (c) => {
   const sid = c.req.header("X-Session-Id") || null;

   await callProc("delete_player", sid, c.req.param("id") ?? null);

   return c.json({
      data: {
         message: "Successfully deleted player",
      },
   });
});

router.route("/tamed-monsters", tamedMonstersRouter);
router.route("/frontliners", frontlinersRouter);

export { router as singlePlayerRouter };
