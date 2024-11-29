import { callProc } from "@/services/db";
import { Hono } from "hono";

const router = new Hono();

router.put("/", async (c) => {
   const body = await c.req.json();

   const frontliners = [null, null, null, null, null] as (number | null)[];
   frontliners[0] = body.frontliners[0] ?? null;
   frontliners[1] = body.frontliners[1] ?? null;
   frontliners[2] = body.frontliners[2] ?? null;
   frontliners[3] = body.frontliners[3] ?? null;
   frontliners[4] = body.frontliners[4] ?? null;

   const sid = c.req.header("X-Session-Id") || null;
   await callProc("set_frontliners_by_sid", sid, ...frontliners);

   return c.json({
      data: {
         message: "Successfully set frontliners",
      },
   });
});

export { router as setFrontlinersRouter };
