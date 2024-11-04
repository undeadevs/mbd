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
      "register",
      body.username || null,
      body.password || null,
   )) as [[RowDataPacket[], ResultSetHeader], FieldPacket[]];

   return c.json({ data: { ...procRes[0][0] } });
});

export { router as registerRouter };
