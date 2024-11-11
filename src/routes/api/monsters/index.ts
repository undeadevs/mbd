import { callProc } from "@/services/db";
import { Hono } from "hono";
import type {
   FieldPacket,
   ResultSetHeader,
   RowDataPacket,
} from "mysql2/promise";
import { singleMonsterRouter } from "./[id]";
import type { PaginationInfo } from "../types";
import type { Monster } from "./types";

const router = new Hono();

router.get("/", async (c) => {
   const [procRes] = (await callProc(
      "get_monsters",
      c.req.query("limit") ? Number(c.req.query("limit")) : null,
      c.req.query("page") ? Number(c.req.query("page")) : null,
      null,
      c.req.query("filter:name") ?? null,
      c.req.query("filter:element") ?? null,
   )) as unknown as [
      [PaginationInfo[], Monster[], ResultSetHeader],
      FieldPacket[],
   ];
   const paginationInfo = procRes[0][0];
   const monstersData = procRes[1] as Monster[];

   return c.json({
      data: {
         ...paginationInfo,
         monsters: monstersData,
      },
   });
});

interface AddedMonster extends RowDataPacket {
   added_id: number;
}

router.post("/", async (c) => {
   const sid = c.req.header("X-Session-Id") || null;
   const body = await c.req.json();

   const [procRes] = (await callProc(
      "add_monster",
      sid,
      body.name,
      body.element,
      body.base_health,
      body.base_next_xp,
      body.max_xp,
   )) as unknown as [[AddedMonster[], ResultSetHeader], FieldPacket[]];
   return c.json({
      data: {
         ...procRes[0][0],
      },
   });
});

router.route("/:id", singleMonsterRouter);

export { router as monstersRouter };
