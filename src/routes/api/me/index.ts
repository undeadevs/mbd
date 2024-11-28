import { Hono } from "hono";
import { callProc } from "@/services/db";
import type { User } from "./types";
import { HTTPException } from "hono/http-exception";

const router = new Hono();

router.get("/", async (c) => {
   const sid = c.req.header("X-Session-Id") || null;

   const { results } = await callProc<[User]>("get_profile", sid);
   const profileData = results[0][0];

   if (!profileData) {
      throw new HTTPException(404, {
         message: "User does not exist",
      });
   }

   return c.json({
      data: {
         profile: profileData,
      },
   });
});

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

router.delete("/", async (c) => {
   const sid = c.req.header("X-Session-Id") || null;

   await callProc("delete_self", sid);

   return c.json({
      data: {
         message: "Successfully deleted account",
      },
   });
});

export { router as meRouter };
