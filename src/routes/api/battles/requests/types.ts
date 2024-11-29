import type { Player } from "../../players/types";

export type BattleRequest = {
   id: number;
   requested_at: Date;
   expires_at: Date | null;
   player1_id: Player["id"];
   player2_id: Player["id"] | null;
   status: "pending" | "accepted" | "rejected" | "expired";
};
