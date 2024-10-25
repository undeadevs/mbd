### DB

Users

- Username
- Password
- Role (Player, Admin)

Monsters

- Name
- Element (Fire, Nature, Water)
- Base Health
- Base Next XP
- Max XP

Tamed Monsters

- Monster Id
- Player Id
- Acquired At
- Level
- XP
- Max Health
- Current Health

Frontliners

- Tamed Monster 1 Id
- Tamed Monster 2 Id
- Tamed Monster 3 Id
- Tamed Monster 4 Id
- Tamed Monster 5 Id

Skills

- Name
- Element (Fire, Nature, Water)
- Type (Attack, Heal)
- Value
- Turn Cooldown

Monster Skills

- Monster Id
- Skill Id
- Level To Attain

Battles

- Started At
- Ended At
- Type (PvE, PvP)
- Player 1 Id
- Player 2 Id
- Enemy Monster Id
- Status (Ongoing, Player 1 Wins, Player 2 Wins, Enemy Wins)
- XP Gain Percentage

Turns

- Battle Id
- Type (P1ayer1, Player2, Enemy)
- Monster Id
- Action (Skill, Block, Forfeit)
- Monster Skill Id
- Created At

---

### Others

Battle Statistics

Leaderboards

- This week
- This month
- This year
- All time (default)
- By Max XP+Winning Battles (default)
- By Max XP
- By Winning Battles
- By Acquired Monsters
- By Attained Skills
