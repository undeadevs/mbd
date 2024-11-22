export type Skill = {
   id: number;
   name: string;
   element: "fire" | "nature" | "water";
   type: "attack" | "heal";
   value: number;
   turn_cooldown: number;
};
