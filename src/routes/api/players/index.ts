import { callProc } from "@/services/db";
import { Hono } from "hono";
import { singlePlayerRouter } from "./[id]";
import type { PaginationInfo } from "../types";
import type { Player } from "./types";

const router = new Hono();

router.get("/", async (c) => {
   const { results } = await callProc<[PaginationInfo, Player]>(
      "get_players",
      c.req.query("limit") ? Number(c.req.query("limit")) : null,
      c.req.query("page") ? Number(c.req.query("page")) : null,
      null,
      c.req.query("filter:username") ?? null,
   );
   const paginationInfo = results[0][0];
   const playersData = results[1];

   return c.json({
      data: {
         ...paginationInfo,
         players: playersData,
      },
   });
});

router.route("/:id", singlePlayerRouter);

export { router as playersRouter };
