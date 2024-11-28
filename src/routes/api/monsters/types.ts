import type { Skill } from "../skills/types";

export type Monster = {
   id: number;
   name: string;
   element: Skill["element"];
   base_health: number;
   base_next_xp: number;
   max_xp: number;
};
