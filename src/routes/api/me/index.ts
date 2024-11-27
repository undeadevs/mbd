import { Hono } from "hono";
import { callProc } from "@/services/db";

const router = new Hono();

router.patch("/", async (c) => {
   const sid = c.req.header("X-Session-Id") || null;
   const body = await c.req.json();

   await callProc(
      "edit_profile",
      sid,
      body.username ?? null,
      body.password ?? null,
   );

   return c.json({
      data: {
         message: "Successfully edited profile",
      },
   });
});

export { router as meRouter };
