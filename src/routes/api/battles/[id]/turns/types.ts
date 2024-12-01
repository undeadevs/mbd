import type { TamedMonster } from "@/routes/api/players/[id]/tamed-monsters/types";
import type { Battle } from "../../types";
import type { MonsterSkill } from "@/routes/api/monsters/[id]/skills/types";

export type Turn = {
   id: number;
   battle_id: Battle["id"];
   type: "player1" | "player2" | "enemy";
   tamed_id: TamedMonster["id"];
   action: "skill" | "block" | "forfeit";
   monster_skill_id: MonsterSkill["id"] | null;
   created_at: Date;
};
