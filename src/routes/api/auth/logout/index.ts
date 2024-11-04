import { callProc } from "@/services/db";
import { Hono } from "hono";

const router = new Hono();

router.delete("/", async (c) => {
   const sid = c.req.header("X-Session-Id") || null;

   await callProc("logout", sid);
   return c.json({ data: { message: "Logout berhasil" } });
});

export { router as logoutRouter };
