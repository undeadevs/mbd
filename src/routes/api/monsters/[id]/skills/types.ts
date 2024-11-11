import type { Skill } from "@/routes/api/skills/types";
import type { RowDataPacket } from "mysql2/promise";

export interface MonsterSkill extends RowDataPacket {
   id: number;
   skill_id: Skill["id"];
   name: Skill["name"];
   element: Skill["element"];
   value: Skill["value"];
   turn_cooldown: Skill["turn_cooldown"];
   level_to_attain: number;
}
