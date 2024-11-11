import { callProc } from "@/services/db";
import { Hono } from "hono";

const router = new Hono();

router.post("/", async (c) => {
   const body = await c.req.json();

   const { results } = await callProc<[{ user_id: number }]>(
      "register",
      body.username || null,
      body.password || null,
   );

   return c.json({ data: { ...results[0][0] } });
});

export { router as registerRouter };
