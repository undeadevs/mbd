import type { RowDataPacket } from "mysql2";

export interface Skill extends RowDataPacket {
   name: string;
   element: "fire" | "nature" | "water";
   type: "attack" | "heal";
   value: number;
   turn_cooldown: number;
}
