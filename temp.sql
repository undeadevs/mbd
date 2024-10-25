--- ef = 0.5
--- Health - (Value * ef * (1 - was_blocked*(1 - ef*0.75)))

DELIMITER $$

CREATE TRIGGER evaluate_turns AFTER INSERT ON turns
FOR EACH ROW
BEGIN
    CASE NEW.action
    WHEN "skill" THEN
	SET @battle_type = (SELECT battles.type FROM battles WHERE battles.id=NEW.battle_id);

		

	IF (@battle_type = "pvp" OR (@battle_type = "pve" AND NEW.tamed_id IS NULL)) THEN
	    SET @skill_value = (SELECT skills.value FROM skills WHERE skills.id = NEW.monster_skill_id LIMIT 1);
	    UPDATE tamed_monsters
	    SET tamed_monsters.current_health = MAX(tamed_monsters.current_health - (), 0)
	    WHERE
	    tamed_monsters.id = (
		SELECT turns.tamed_id
		FROM turns
		WHERE turns.battle_id=NEW.battle_id
		ORDER BY turns.id DESC
		LIMIT 1
		OFFSET 1
	    );
	END IF;
    WHEN "forfeit" THEN
	-- UPDATE 
	-- SET tamed_monsters.current_health = MIN(tamed_monsters.current_health + 10, tamed_monsters.max_health)
	-- FROM tamed_monsters WHERE tamed_monsters.id = NEW.tamed_id;
	UPDATE battles
	JOIN turns ON turns.battle_id = battles.id
	SET battles.status = turns.type
	WHERE turns.battle_id=NEW.battle_id
	ORDER BY turns.id DESC
	LIMIT 1
	OFFSET 1;
    END CASE;
END$$

DELIMITER ;

