import type { Skill } from "@/routes/api/skills/types";

export type MonsterSkill = {
   id: number;
   skill_id: Skill["id"];
   name: Skill["name"];
   element: Skill["element"];
   value: Skill["value"];
   turn_cooldown: Skill["turn_cooldown"];
   level_to_attain: number;
};
