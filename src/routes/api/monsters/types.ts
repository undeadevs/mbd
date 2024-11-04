import type { RowDataPacket } from "mysql2/promise";

export interface Monster extends RowDataPacket {
   id: number;
   name: string;
   base_health: number;
   base_next_xp: number;
   max_xp: number;
}
