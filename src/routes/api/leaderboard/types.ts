import type { TamedMonster } from "../players/[id]/tamed-monsters/types";
import type { Player } from "../players/types";

export type LeaderboardType =
   | "win_rate"
   | "highest_xp"
   | "win_rate_highest_xp"
   | "acquired_monsters"
   | "attained_skills";

export type LeaderboardWinRate = {
   id: Player["id"];
   username: Player["username"];
   win_count: number;
   lose_count: number;
   battle_count: number;
};

export type LeaderboardHighestXP = {
   id: Player["id"];
   username: Player["username"];
   tamed_monster_id: TamedMonster["id"];
   tamed_monster_xp: TamedMonster["xp"];
};

export type LeaderboardWinRateHighestXP = LeaderboardWinRate &
   LeaderboardHighestXP;

export type LeaderboardAcquiredMonsters = {
   id: Player["id"];
   username: Player["username"];
   acquired_monsters_count: number;
};

export type LeaderboardAttainedSkills = {
   id: Player["id"];
   username: Player["username"];
   attained_skills_count: number;
};

export type Leaderboard =
   | LeaderboardWinRate
   | LeaderboardHighestXP
   | LeaderboardWinRateHighestXP
   | LeaderboardAcquiredMonsters
   | LeaderboardAttainedSkills;

export type LeaderboardT<TType extends string> = TType extends "win_rate"
   ? LeaderboardWinRate
   : TType extends "highest_xp"
     ? LeaderboardHighestXP
     : TType extends "win_rate_highest_xp"
       ? LeaderboardWinRateHighestXP
       : TType extends "acquired_monsters"
         ? LeaderboardAcquiredMonsters
         : TType extends "attained_skills"
           ? LeaderboardAttainedSkills
           : never;
