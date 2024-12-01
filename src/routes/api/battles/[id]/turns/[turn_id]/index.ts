import { callProc } from "@/services/db";
import { Hono } from "hono";
import type { Turn } from "../types";

const router = new Hono();

router.get("/", async (c) => {
   const { results } = await callProc<[unknown, Turn]>(
      "get_turns",
      c.req.param("id") ?? null,
      1,
      1,
      c.req.param("turn_id") ?? null,
      null,
   );
   const turnData = results[1][0];

   return c.json({
      data: {
         turn: turnData,
      },
   });
});

export { router as singleTurnRouter };
