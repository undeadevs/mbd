import { callProc } from "@/services/db";
import { Hono } from "hono";

const router = new Hono();

router.post("/", async (c) => {
   const body = await c.req.json();

   const { results } = await callProc<
      [{ sid: string; id: number; username: string; password: string }]
   >("login", body.username || null, body.password || null);

   if (!Bun.env.JWT_SECRET) {
      throw new Error("env: JWT_SECRET is unset");
   }

   const authUser = results[0][0];

   return c.json({ data: { message: "Login berhasil", sid: authUser.sid } });
});

export { router as loginRouter };
