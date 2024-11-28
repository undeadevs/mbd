import type { Monster } from "@/routes/api/monsters/types";
import type { Player } from "../../types";

export type TamedMonster = {
   id: number;
   monster_id: Monster["id"];
   player_id: Player["id"];
   acquired_at: Date;
   level: number;
   xp: Monster["base_next_xp"];
   max_health: Monster["base_health"];
   current_health: Monster["base_health"];
   name: Monster["name"];
   element: Monster["element"];
};
