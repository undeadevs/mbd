import type { Monster } from "../monsters/types";
import type { Player } from "../players/types";

export type Battle = {
   id: number;
   started_at: Date;
   ended_at: Date | null;
   type: "pvp" | "pve";
   player1_id: Player["id"];
   player2_id: Player["id"] | null;
   enemy_monster_id: Monster["id"] | null;
   enemy_monster_xp: number | null;
   enemy_monster_health: number | null;
   status: "ongoing" | "player1" | "player2" | "enemy";
   xp_gain_percentage: number;
};
