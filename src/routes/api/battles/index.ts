import { Hono } from "hono";
import { battleRequestsRouter } from "./requests";
import { randomEncounterRouter } from "./random-encounter";
import { singleBattleRouter } from "./[id]";
import { callProc } from "@/services/db";
import type { Battle } from "./types";
import type { PaginationInfo } from "../types";

const router = new Hono();

router.get("/", async (c) => {
   const { results } = await callProc<[PaginationInfo, Battle]>(
      "get_battles",
      c.req.query("limit") ?? null,
      c.req.query("page") ?? null,
      null,
      c.req.query("filter:player_id") ?? null,
      c.req.query("filter:status") ?? null,
   );
   const paginationInfo = results[0][0];
   const battlesData = results[1];

   return c.json({
      data: {
         ...paginationInfo,
         battles: battlesData,
      },
   });
});

router.route("/requests", battleRequestsRouter);
router.route("/random-encounter", randomEncounterRouter);
router.route("/:id", singleBattleRouter);

export { router as battlesRouter };
