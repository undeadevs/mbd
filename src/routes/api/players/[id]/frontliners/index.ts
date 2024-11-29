import { callProc } from "@/services/db";
import { Hono } from "hono";
import type { Player } from "../../types";
import type { TamedMonster } from "../tamed-monsters/types";

const router = new Hono();

router.get("/", async (c) => {
   const { results } = await callProc<
      [
         {
            id: number;
            player_id: Player["id"];
            tamed1_id: TamedMonster["id"] | null;
            tamed2_id: TamedMonster["id"] | null;
            tamed3_id: TamedMonster["id"] | null;
            tamed4_id: TamedMonster["id"] | null;
            tamed5_id: TamedMonster["id"];
         },
      ]
   >("get_frontliners", c.req.param("id") ?? null);

   const frontlinersData = [null, null, null, null, null] as (number | null)[];

   const resultData = results[0][0];
   if (resultData) {
      frontlinersData[0] = resultData.tamed1_id;
      frontlinersData[1] = resultData.tamed2_id;
      frontlinersData[2] = resultData.tamed3_id;
      frontlinersData[3] = resultData.tamed4_id;
      frontlinersData[4] = resultData.tamed5_id;
   }

   return c.json({
      data: {
         frontliners: frontlinersData,
      },
   });
});

export { router as frontlinersRouter };
