import { callProc } from "@/services/db";
import { Hono } from "hono";
import type { Leaderboard } from "./types";
import type { PaginationInfo } from "../types";

const router = new Hono();

router.get("/", async (c) => {
   const type = c.req.query("type") ?? null;
   const { results } = await callProc<[PaginationInfo, Leaderboard]>(
      "get_leaderboard",
      type,
      c.req.query("limit") ? Number(c.req.query("limit")) : null,
      c.req.query("page") ? Number(c.req.query("page")) : null,
      c.req.query("filter:player_id") ?? null,
      c.req.query("filter:player_username") ?? null,
   );

   const paginationInfo = results[0][0];
   const leaderboardData = results[1];

   return c.json({ data: { ...paginationInfo, leaderboard: leaderboardData } });
});

export { router as leaderboardRouter };
