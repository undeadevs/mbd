import { callProc } from "@/services/db";
import { Hono } from "hono";
import type {
   FieldPacket,
   ResultSetHeader,
   RowDataPacket,
} from "mysql2/promise";

const router = new Hono();

router.post("/", async (c) => {
   const body = await c.req.json();

   const [procRes] = (await callProc(
      "login",
      body.username || null,
      body.password || null,
   )) as [[RowDataPacket[], ResultSetHeader], FieldPacket[]];

   if (!Bun.env.JWT_SECRET) {
      throw new Error("env: JWT_SECRET is unset");
   }

   const authUser = procRes[0][0] as {
      sid: string;
      id: number;
      username: string;
      password: string;
   };

   return c.json({ data: { message: "Login berhasil", sid: authUser.sid } });
});

export { router as loginRouter };
