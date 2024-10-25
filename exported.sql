-- STRUCTURES
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` text NOT NULL,
  `role` enum('player','admin') NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `monsters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `element` enum('fire','nature','water') NOT NULL,
  `base_health` int(11) NOT NULL,
  `base_next_xp` int(11) NOT NULL,
  `max_xp` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `skills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `element` enum('fire','nature','water') NOT NULL,
  `type` enum('attack','heal') NOT NULL,
  `value` int(11) NOT NULL,
  `turn_cooldown` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `monster_skills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `monster_id` int(11) NOT NULL,
  `skill_id` int(11) NOT NULL,
  `level_to_attain` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ms_monster_fk` (`monster_id`),
  KEY `ms_skill_fk` (`skill_id`),
  CONSTRAINT `ms_monster_fk` FOREIGN KEY (`monster_id`) REFERENCES `monsters` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ms_skill_fk` FOREIGN KEY (`skill_id`) REFERENCES `skills` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `tamed_monsters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `monster_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `acquired_at` datetime NOT NULL DEFAULT current_timestamp(),
  `level` int(11) NOT NULL,
  `xp` int(11) NOT NULL,
  `max_health` int(11) NOT NULL,
  `current_health` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `tm_monster` (`monster_id`),
  KEY `tm_player` (`player_id`),
  CONSTRAINT `tm_monster` FOREIGN KEY (`monster_id`) REFERENCES `monsters` (`id`) ON DELETE CASCADE,
  CONSTRAINT `tm_player` FOREIGN KEY (`player_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `frontliners` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` int(11) NOT NULL,
  `tamed1_id` int(11) DEFAULT NULL,
  `tamed2_id` int(11) DEFAULT NULL,
  `tamed3_id` int(11) DEFAULT NULL,
  `tamed4_id` int(11) DEFAULT NULL,
  `tamed5_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fr_player` (`player_id`),
  KEY `fr_m1` (`tamed1_id`),
  KEY `fr_m2` (`tamed2_id`),
  KEY `fr_m3` (`tamed3_id`),
  KEY `fr_m4` (`tamed4_id`),
  KEY `fr_m5` (`tamed5_id`),
  CONSTRAINT `fr_m1` FOREIGN KEY (`tamed1_id`) REFERENCES `tamed_monsters` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fr_m2` FOREIGN KEY (`tamed2_id`) REFERENCES `tamed_monsters` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fr_m3` FOREIGN KEY (`tamed3_id`) REFERENCES `tamed_monsters` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fr_m4` FOREIGN KEY (`tamed4_id`) REFERENCES `tamed_monsters` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fr_m5` FOREIGN KEY (`tamed5_id`) REFERENCES `tamed_monsters` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fr_player` FOREIGN KEY (`player_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `battle_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `requested_at` datetime DEFAULT current_timestamp(),
  `expires_at` datetime DEFAULT (current_timestamp() + interval 5 minute),
  `player1_id` int(11) NOT NULL,
  `player2_id` int(11) NOT NULL,
  `status` enum('pending','accepted','rejected','expired') NOT NULL,
  PRIMARY KEY (`id`),
  KEY `br_player1` (`player1_id`),
  KEY `br_player2` (`player2_id`),
  CONSTRAINT `br_player1` FOREIGN KEY (`player1_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `br_player2` FOREIGN KEY (`player2_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `battles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `started_at` datetime NOT NULL DEFAULT current_timestamp(),
  `ended_at` datetime DEFAULT NULL,
  `type` enum('pve','pvp') NOT NULL,
  `player1_id` int(11) NOT NULL,
  `player2_id` int(11) DEFAULT NULL,
  `enemy_monster_id` int(11) DEFAULT NULL,
  `enemy_monster_xp` int(11) DEFAULT NULL,
  `enemy_monster_health` int(11) DEFAULT NULL,
  `status` enum('ongoing','player1','player2','enemy') NOT NULL,
  `xp_gain_percentage` FLOAT NOT NULL,
  PRIMARY KEY (`id`),
  KEY `bt_p1` (`player1_id`),
  KEY `bt_p2` (`player2_id`),
  KEY `bt_monster` (`enemy_monster_id`),
  CONSTRAINT `bt_monster` FOREIGN KEY (`enemy_monster_id`) REFERENCES `monsters` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bt_p1` FOREIGN KEY (`player1_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bt_p2` FOREIGN KEY (`player2_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `turns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `battle_id` int(11) NOT NULL,
  `type` enum('player1','player2','enemy') NOT NULL,
  `tamed_id` int(11) DEFAULT NULL,
  `action` enum('skill','block','forfeit') NOT NULL,
  `monster_skill_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  KEY `tr_battle` (`battle_id`),
  KEY `tr_ms` (`monster_skill_id`),
  KEY `tr_tamed` (`tamed_id`),
  CONSTRAINT `tr_battle` FOREIGN KEY (`battle_id`) REFERENCES `battles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `tr_ms` FOREIGN KEY (`monster_skill_id`) REFERENCES `monster_skills` (`id`) ON DELETE CASCADE,
  CONSTRAINT `tr_tamed` FOREIGN KEY (`tamed_id`) REFERENCES `tamed_monsters` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TRIGGERS
DELIMITER $$
CREATE OR REPLACE TRIGGER sync_level BEFORE UPDATE ON tamed_monsters
FOR EACH ROW
BEGIN
    IF NEW.xp!=OLD.xp THEN
    SET NEW.level = get_level_from_xp(NEW.monster_id, NEW.xp);
    SET NEW.max_health = (SELECT (monsters.base_health * NEW.level) FROM monsters WHERE monsters.id = NEW.monster_id);
    SET NEW.current_health = NEW.max_health;
    END IF;
END$$
DELIMITER ;

-- PROCEDURES
DELIMITER $$
CREATE OR REPLACE PROCEDURE register(_username VARCHAR(255), _password TEXT)
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;
    INSERT INTO users (username, password, role) VALUES (_username, PASSWORD(_password), 'player');

    CALL tame_monster(1, (SELECT LAST_INSERT_ID()), 1);
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE login(IN _username VARCHAR(255), IN _password TEXT)
BEGIN
    DECLARE l_id INT;
    DECLARE l_username VARCHAR(255);
    DECLARE l_role ENUM("player", "admin");

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;
    SELECT users.id, users.username, users.role INTO l_id, l_username, l_role
    FROM users
    WHERE users.username=_username AND users.password=PASSWORD(_password);

    IF(l_id IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'username or password is incorrect';
    END IF;

    COMMIT;
    SELECT l_id, l_username, l_role;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_skills(
    IN _limit INT(11), 
    IN _page INT(11), 
    IN f_name TEXT, 
    IN f_element TEXT, 
    IN f_type TEXT
)
BEGIN
    DECLARE l_limit INT DEFAULT 10;
    DECLARE l_page INT DEFAULT 1;
    DECLARE l_count INT DEFAULT 0;
    DECLARE l_total_pages INT DEFAULT 0;
    DECLARE l_offset INT DEFAULT 0;
    DECLARE l_has_prev BOOLEAN DEFAULT FALSE;
    DECLARE l_has_next BOOLEAN DEFAULT FALSE;

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    SET l_limit = IFNULL(_limit, 10);
    SET l_page = IFNULL(_page, 1);

    SELECT COUNT(skills.id) INTO l_count
    FROM skills
    WHERE
    IF(f_name IS NULL, TRUE, skills.name LIKE f_name) AND
    IF(f_element IS NULL, TRUE, skills.element LIKE f_element) AND
    IF(f_type IS NULL, TRUE, skills.type LIKE f_type);

    SET l_total_pages = IF(l_limit=0, 1, CEIL(l_count / l_limit));
    IF(l_total_pages = 0) THEN
	SET l_page = 0;
    END IF;

    SET l_offset = IF(l_page <= 0, 0, (l_page - 1) * l_limit);

    SET l_has_prev = l_page > 1;
    SET l_has_next = l_page < l_total_pages;

    SELECT l_total_pages, l_has_prev, l_has_next;

    IF(l_limit = 0) THEN
	SELECT skills.*
	FROM skills
	WHERE
	IF(f_name IS NULL, TRUE, skills.name LIKE f_name) AND
	IF(f_element IS NULL, TRUE, skills.element LIKE f_element) AND
	IF(f_type IS NULL, TRUE, skills.type LIKE f_type);
    ELSE
	SELECT skills.*
	FROM skills
	WHERE
	IF(f_name IS NULL, TRUE, skills.name LIKE f_name) AND
	IF(f_element IS NULL, TRUE, skills.element LIKE f_element) AND
	IF(f_type IS NULL, TRUE, skills.type LIKE f_type)
	LIMIT l_limit
	OFFSET l_offset;
    END IF;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_monsters(
    IN _limit INT(11), 
    IN _page INT(11), 
    IN f_name TEXT, 
    IN f_element TEXT 
)
BEGIN
    DECLARE l_limit INT DEFAULT 10;
    DECLARE l_page INT DEFAULT 1;
    DECLARE l_count INT DEFAULT 0;
    DECLARE l_total_pages INT DEFAULT 0;
    DECLARE l_offset INT DEFAULT 0;
    DECLARE l_has_prev BOOLEAN DEFAULT FALSE;
    DECLARE l_has_next BOOLEAN DEFAULT FALSE;

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    SET l_limit = IFNULL(_limit, 10);
    SET l_page = IFNULL(_page, 1);

    SELECT COUNT(monsters.id) INTO l_count
    FROM monsters
    WHERE
    IF(f_name IS NULL, TRUE, monsters.name LIKE f_name) AND
    IF(f_element IS NULL, TRUE, monsters.element LIKE f_element);

    SET l_total_pages = IF(l_limit=0, 1, CEIL(l_count / l_limit));
    IF(l_total_pages = 0) THEN
	SET l_page = 0;
    END IF;

    SET l_offset = IF(l_page <= 0, 0, (l_page - 1) * l_limit);

    SET l_has_prev = l_page > 1;
    SET l_has_next = l_page < l_total_pages;

    SELECT l_total_pages, l_has_prev, l_has_next;

    IF(l_limit = 0) THEN
	SELECT monsters.*
	FROM monsters
	WHERE
	IF(f_name IS NULL, TRUE, monsters.name LIKE f_name) AND
	IF(f_element IS NULL, TRUE, monsters.element LIKE f_element);
    ELSE
	SELECT monsters.*
	FROM monsters
	WHERE
	IF(f_name IS NULL, TRUE, monsters.name LIKE f_name) AND
	IF(f_element IS NULL, TRUE, monsters.element LIKE f_element)
	LIMIT l_limit
	OFFSET l_offset;
    END IF;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_monster_skills(
    IN _monster_id INT(11),
    IN _limit INT(11), 
    IN _page INT(11), 
    IN f_name TEXT, 
    IN f_element TEXT
)
BEGIN
    DECLARE l_limit INT DEFAULT 10;
    DECLARE l_page INT DEFAULT 1;
    DECLARE l_count INT DEFAULT 0;
    DECLARE l_total_pages INT DEFAULT 0;
    DECLARE l_offset INT DEFAULT 0;
    DECLARE l_has_prev BOOLEAN DEFAULT FALSE;
    DECLARE l_has_next BOOLEAN DEFAULT FALSE;

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    SET l_limit = IFNULL(_limit, 10);
    SET l_page = IFNULL(_page, 1);

    SELECT COUNT(monster_skills.id) INTO l_count
    FROM monster_skills
    JOIN skills ON skills.id=monster_skills.skill_id
    WHERE
    monster_skills.monster_id = _monster_id AND
    IF(f_name IS NULL, TRUE, skills.name LIKE f_name) AND
    IF(f_element IS NULL, TRUE, skills.element LIKE f_element);

    SET l_total_pages = IF(l_limit=0, 1, CEIL(l_count / l_limit));
    IF(l_total_pages = 0) THEN
	SET l_page = 0;
    END IF;

    SET l_offset = IF(l_page <= 0, 0, (l_page - 1) * l_limit);

    SET l_has_prev = l_page > 1;
    SET l_has_next = l_page < l_total_pages;

    SELECT l_total_pages, l_has_prev, l_has_next;

    IF(l_limit = 0) THEN
	SELECT monster_skills.id, monster_skills.skill_id, skills.name, skills.element, skills.value, skills.turn_cooldown
	FROM monster_skills
	JOIN skills ON skills.id=monster_skills.skill_id
	WHERE
	monster_skills.monster_id = _monster_id AND
	IF(f_name IS NULL, TRUE, skills.name LIKE f_name) AND
	IF(f_element IS NULL, TRUE, skills.element LIKE f_element);
    ELSE
	SELECT monster_skills.id, monster_skills.skill_id, skills.name, skills.element, skills.value, skills.turn_cooldown
	FROM monster_skills
	JOIN skills ON skills.id=monster_skills.skill_id
	WHERE
	monster_skills.monster_id = _monster_id AND
	IF(f_name IS NULL, TRUE, skills.name LIKE f_name) AND
	IF(f_element IS NULL, TRUE, skills.element LIKE f_element)
	LIMIT l_limit
	OFFSET l_offset;
    END IF;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_users(
    IN _limit INT(11), 
    IN _page INT(11), 
    IN f_username TEXT, 
    IN f_role TEXT 
)
BEGIN
    DECLARE l_limit INT DEFAULT 10;
    DECLARE l_page INT DEFAULT 1;
    DECLARE l_count INT DEFAULT 0;
    DECLARE l_total_pages INT DEFAULT 0;
    DECLARE l_offset INT DEFAULT 0;
    DECLARE l_has_prev BOOLEAN DEFAULT FALSE;
    DECLARE l_has_next BOOLEAN DEFAULT FALSE;

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    SET l_limit = IFNULL(_limit, 10);
    SET l_page = IFNULL(_page, 1);

    SELECT COUNT(users.id) INTO l_count
    FROM users
    WHERE
    IF(f_username IS NULL, TRUE, users.username LIKE f_username) AND
    IF(f_role IS NULL, TRUE, users.role LIKE f_role);

    SET l_total_pages = IF(l_limit=0, 1, CEIL(l_count / l_limit));
    IF(l_total_pages = 0) THEN
	SET l_page = 0;
    END IF;

    SET l_offset = IF(l_page <= 0, 0, (l_page - 1) * l_limit);

    SET l_has_prev = l_page > 1;
    SET l_has_next = l_page < l_total_pages;

    SELECT l_total_pages, l_has_prev, l_has_next;

    IF(l_limit = 0) THEN
	SELECT users.*
	FROM users
	WHERE
	IF(f_username IS NULL, TRUE, users.username LIKE f_username) AND
	IF(f_role IS NULL, TRUE, users.role LIKE f_role);
    ELSE
	SELECT users.*
	FROM users
	WHERE
	IF(f_username IS NULL, TRUE, users.username LIKE f_username) AND
	IF(f_role IS NULL, TRUE, users.role LIKE f_role)
	LIMIT l_limit
	OFFSET l_offset;
    END IF;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_tamed_monsters(
    IN _player_id INT(11),
    IN _limit INT(11), 
    IN _page INT(11), 
    IN f_name TEXT, 
    IN f_element TEXT
)
BEGIN
    DECLARE l_limit INT DEFAULT 10;
    DECLARE l_page INT DEFAULT 1;
    DECLARE l_count INT DEFAULT 0;
    DECLARE l_total_pages INT DEFAULT 0;
    DECLARE l_offset INT DEFAULT 0;
    DECLARE l_has_prev BOOLEAN DEFAULT FALSE;
    DECLARE l_has_next BOOLEAN DEFAULT FALSE;

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    IF((SELECT users.id FROM users WHERE users.id = _player_id AND users.role = "player") IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'user is not player';
    END IF;

    SET l_limit = IFNULL(_limit, 10);
    SET l_page = IFNULL(_page, 1);

    SELECT COUNT(tamed_monsters.id) INTO l_count
    FROM tamed_monsters
    JOIN monsters ON monsters.id = tamed_monsters.monster_id
    WHERE
    tamed_monsters.player_id = _player_id AND
    IF(f_name IS NULL, TRUE, monsters.name LIKE f_name) AND
    IF(f_element IS NULL, TRUE, monsters.element LIKE f_element);

    SET l_total_pages = IF(l_limit=0, 1, CEIL(l_count / l_limit));
    IF(l_total_pages = 0) THEN
	SET l_page = 0;
    END IF;

    SET l_offset = IF(l_page <= 0, 0, (l_page - 1) * l_limit);

    SET l_has_prev = l_page > 1;
    SET l_has_next = l_page < l_total_pages;

    SELECT l_total_pages, l_has_prev, l_has_next;

    IF(l_limit = 0) THEN
	SELECT tamed_monsters.*, monsters.name, monsters.element
	FROM tamed_monsters
	JOIN monsters ON monsters.id = tamed_monsters.monster_id
	WHERE
	tamed_monsters.player_id = _player_id AND
	IF(f_name IS NULL, TRUE, monsters.name LIKE f_name) AND
	IF(f_element IS NULL, TRUE, monsters.element LIKE f_element);
    ELSE
	SELECT tamed_monsters.*, monsters.name, monsters.element
	FROM tamed_monsters
	JOIN monsters ON monsters.id = tamed_monsters.monster_id
	WHERE
	tamed_monsters.player_id = _player_id AND
	IF(f_name IS NULL, TRUE, monsters.name LIKE f_name) AND
	IF(f_element IS NULL, TRUE, monsters.element LIKE f_element)
	LIMIT l_limit
	OFFSET l_offset;
    END IF;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_frontliners(
    IN _player_id INT(11)
)
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    IF((SELECT users.id FROM users WHERE users.id = _player_id AND users.role = "player") IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'user is not player';
    END IF;

    SELECT * FROM frontliners WHERE frontliners.player_id = _player_id;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_battles(
    IN _limit INT(11), 
    IN _page INT(11)
)
BEGIN
    DECLARE l_limit INT DEFAULT 10;
    DECLARE l_page INT DEFAULT 1;
    DECLARE l_count INT DEFAULT 0;
    DECLARE l_total_pages INT DEFAULT 0;
    DECLARE l_offset INT DEFAULT 0;
    DECLARE l_has_prev BOOLEAN DEFAULT FALSE;
    DECLARE l_has_next BOOLEAN DEFAULT FALSE;

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    SET l_limit = IFNULL(_limit, 10);
    SET l_page = IFNULL(_page, 1);

    SELECT COUNT(battles.id) INTO l_count
    FROM battles;

    SET l_total_pages = IF(l_limit=0, 1, CEIL(l_count / l_limit));
    IF(l_total_pages = 0) THEN
	SET l_page = 0;
    END IF;

    SET l_offset = IF(l_page <= 0, 0, (l_page - 1) * l_limit);

    SET l_has_prev = l_page > 1;
    SET l_has_next = l_page < l_total_pages;

    SELECT l_total_pages, l_has_prev, l_has_next;

    IF(l_limit = 0) THEN
	SELECT battles.*, p1.username player1_username, p2.username player2_username
	FROM battles
	LEFT JOIN users p1 ON p1.id=battles.player1_id
	LEFT JOIN users p2 ON p2.id=battles.player2_id;
    ELSE
	SELECT battles.*, p1.username player1_username, p2.username player2_username
	FROM battles
	LEFT JOIN users p1 ON p1.id=battles.player1_id
	LEFT JOIN users p2 ON p2.id=battles.player2_id
	LIMIT l_limit
	OFFSET l_offset;
    END IF;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_turns(
    IN _battle_id INT(11),
    IN _limit INT(11), 
    IN _page INT(11)
)
BEGIN
    DECLARE l_limit INT DEFAULT 10;
    DECLARE l_page INT DEFAULT 1;
    DECLARE l_count INT DEFAULT 0;
    DECLARE l_total_pages INT DEFAULT 0;
    DECLARE l_offset INT DEFAULT 0;
    DECLARE l_has_prev BOOLEAN DEFAULT FALSE;
    DECLARE l_has_next BOOLEAN DEFAULT FALSE;

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    SET l_limit = IFNULL(_limit, 10);
    SET l_page = IFNULL(_page, 1);

    SELECT COUNT(turns.id) INTO l_count
    FROM turns
    WHERE turns.battle_id = _battle_id;

    SET l_total_pages = IF(l_limit=0, 1, CEIL(l_count / l_limit));
    IF(l_total_pages = 0) THEN
	SET l_page = 0;
    END IF;

    SET l_offset = IF(l_page <= 0, 0, (l_page - 1) * l_limit);

    SET l_has_prev = l_page > 1;
    SET l_has_next = l_page < l_total_pages;

    SELECT l_total_pages, l_has_prev, l_has_next;

    IF(l_limit = 0) THEN
	SELECT * 
	FROM turns
	WHERE turns.battle_id = _battle_id;
    ELSE
	SELECT *
	FROM turns
	WHERE turns.battle_id = _battle_id
	LIMIT l_limit
	OFFSET l_offset;
    END IF;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_player_battle_stats(
    IN _player_id INT(11),
    IN _limit INT(11), 
    IN _page INT(11)
)
BEGIN
    DECLARE l_limit INT DEFAULT 10;
    DECLARE l_page INT DEFAULT 1;
    DECLARE l_count INT DEFAULT 0;
    DECLARE l_total_pages INT DEFAULT 0;
    DECLARE l_offset INT DEFAULT 0;
    DECLARE l_has_prev BOOLEAN DEFAULT FALSE;
    DECLARE l_has_next BOOLEAN DEFAULT FALSE;

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    IF((SELECT users.id FROM users WHERE users.id = _player_id AND users.role = "player") IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'user is not player';
    END IF;


    SET l_limit = IFNULL(_limit, 10);
    SET l_page = IFNULL(_page, 1);

    SELECT COUNT(battles.id) INTO l_count
    FROM battles
    WHERE 
    _player_id=battles.player1_id OR
    _player_id=battles.player2_id;

    SET l_total_pages = IF(l_limit=0, 1, CEIL(l_count / l_limit));
    IF(l_total_pages = 0) THEN
	SET l_page = 0;
    END IF;

    SET l_offset = IF(l_page <= 0, 0, (l_page - 1) * l_limit);

    SET l_has_prev = l_page > 1;
    SET l_has_next = l_page < l_total_pages;

    SELECT l_total_pages, l_has_prev, l_has_next;

    IF(l_limit = 0) THEN
	SELECT battles.*, p1.username player1_username, p2.username player2_username
	FROM battles
	LEFT JOIN users p1 ON p1.id=battles.player1_id
	LEFT JOIN users p2 ON p2.id=battles.player2_id
	WHERE
	_player_id=battles.player1_id OR
	_player_id=battles.player2_id;
    ELSE
	SELECT battles.*, p1.username player1_username, p2.username player2_username
	FROM battles
	LEFT JOIN users p1 ON p1.id=battles.player1_id
	LEFT JOIN users p2 ON p2.id=battles.player2_id
	WHERE
	_player_id=battles.player1_id OR
	_player_id=battles.player2_id
	LIMIT l_limit
	OFFSET l_offset;
    END IF;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_leaderboard(
    IN _limit INT(11), 
    IN _page INT(11)
)
BEGIN
    DECLARE l_limit INT DEFAULT 10;
    DECLARE l_page INT DEFAULT 1;
    DECLARE l_count INT DEFAULT 0;
    DECLARE l_total_pages INT DEFAULT 0;
    DECLARE l_offset INT DEFAULT 0;
    DECLARE l_has_prev BOOLEAN DEFAULT FALSE;
    DECLARE l_has_next BOOLEAN DEFAULT FALSE;

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    SET l_limit = IFNULL(_limit, 10);
    SET l_page = IFNULL(_page, 1);

    SELECT COUNT(users.id) INTO l_count
    FROM users;

    SET l_total_pages = IF(l_limit=0, 1, CEIL(l_count / l_limit));
    IF(l_total_pages = 0) THEN
	SET l_page = 0;
    END IF;

    SET l_offset = IF(l_page <= 0, 0, (l_page - 1) * l_limit);

    SET l_has_prev = l_page > 1;
    SET l_has_next = l_page < l_total_pages;

    SELECT l_total_pages, l_has_prev, l_has_next;

    IF(l_limit = 0) THEN
	SELECT 
	users.id, 
	users.username, 
	(SELECT COUNT(battles.id) FROM battles 
	WHERE 
	IF(battles.player1_id=users.id, battles.status="player1", IF(battles.player2_id=users.id, battles.status="player2", FALSE))
	) win_count,
	(SELECT COUNT(battles.id) FROM battles 
	WHERE 
	IF(battles.player1_id=users.id, battles.status="player2" OR battles.status="enemy", IF(battles.player2_id=users.id, battles.status="player1", TRUE))
	) lose_count
	FROM users
	ORDER BY win_count DESC;
    ELSE
	SELECT
	users.id, 
	users.username, 
	(SELECT COUNT(battles.id) FROM battles 
	WHERE 
	IF(battles.player1_id=users.id, battles.status="player1", IF(battles.player2_id=users.id, battles.status="player2", FALSE))
	) win_count,
	(SELECT COUNT(battles.id) FROM battles 
	WHERE 
	IF(battles.player1_id=users.id, battles.status="player2" OR battles.status="enemy", IF(battles.player2_id=users.id, battles.status="player1", TRUE))
	) lose_count
	FROM users
	ORDER BY win_count DESC
	LIMIT l_limit
	OFFSET l_offset;
    END IF;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE add_monster(_name VARCHAR(255), _element ENUM('fire', 'nature', 'water'), _base_health INT(11), _base_next_xp INT(11), _max_xp INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;
    INSERT INTO monsters (name, element, base_health, base_next_xp, max_xp) VALUES(_name, _element, _base_health, _base_next_xp, _max_xp);
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE add_skill(_name VARCHAR(255), _element ENUM('fire', 'nature', 'water'), _type ENUM('attack', 'heal', 'block'), _value INT(11), _turn_cooldown INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;
    INSERT INTO skills (name, element, type, value, turn_cooldown) VALUES(_name, _element, _type, _value, _turn_cooldown);
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE add_monster_skill(_monster_id INT(11), _skill_id INT(11), _level_to_attain INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    IF((SELECT monsters.element FROM monsters WHERE monsters.id=_monster_id LIMIT 1)!=(SELECT skills.element FROM skills WHERE skills.id=_skill_id)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'skill element does not matched monster element';
    END IF;

    INSERT INTO monster_skills (monster_id, skill_id, level_to_attain) VALUES(_monster_id, _skill_id, _level_to_attain);
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE edit_monster(_id INT(11),_name VARCHAR(255), _element ENUM('fire', 'nature', 'water'), _base_health INT(11), _base_next_xp INT(11), _max_xp INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;
    UPDATE monsters 
    SET 
    name = IFNULL(_name, name), 
    element = IFNULL(_element, element), 
    base_health = IFNULL(_base_health, base_health), 
    base_next_xp = IFNULL(_base_next_xp, base_next_xp), 
    max_xp = IFNULL(_max_xp, max_xp)
    WHERE monsters.id=_id;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE edit_skill(_id INT(11), _name VARCHAR(255), _element ENUM('fire', 'nature', 'water'), _type ENUM('attack', 'heal'), _value INT(11), _turn_cooldown INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;
    UPDATE skills 
    SET
    name = IFNULL(_name, name), 
    element = IFNULL(_element, element), 
    type = IFNULL(_type, type), 
    value = IFNULL(_value, value), 
    turn_cooldown = IFNULL(_turn_cooldown, turn_cooldown)
    WHERE skills.id=_id;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE edit_monster_skill(_id INT(11), _monster_id INT(11), _skill_id INT(11), _level_to_attain INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    IF((SELECT monsters.element FROM monsters WHERE monsters.id=_monster_id LIMIT 1)!=(SELECT skills.element FROM skills WHERE skills.id=_skill_id)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'skill element does not matched monster element';
    END IF;

    UPDATE monster_skills 
    SET
    monster_id = IFNULL(_monster_id, monster_id), 
    skill_id = IFNULL(_skill_id, skill_id), 
    level_to_attain = IFNULL(_level_to_attain, level_to_attain)
    WHERE monster_skills.id=_id;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE delete_monster(_id INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;
    DELETE FROM monsters WHERE monsters.id=_id;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE delete_skill(_id INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;
    DELETE FROM skills WHERE skills.id=_id;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE delete_monster_skill(_id INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;
    DELETE FROM monster_skills WHERE monster_skills.id=_id;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE tame_monster(IN _monster_id INT(11), IN _player_id INT(11), IN _xp INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

	IF((SELECT users.id FROM users WHERE users.id = _player_id AND users.role = "player") IS NULL) THEN
	    SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'user is not player';
	END IF;

	SET @hp = NULL;
	SET @lv = NULL;
	SET @lv = (SELECT get_level_from_xp(_monster_id, _xp));
	SET @hp = (SELECT monsters.base_health*@lv FROM monsters WHERE monsters.id=_monster_id);
	INSERT INTO tamed_monsters(monster_id, player_id, level, xp, max_health, current_health)
	VALUES(_monster_id, _player_id, @lv, _xp, @hp, @hp);
	SET @hp = NULL;
	SET @lv = NULL;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE random_encounter(IN _player_id INT(11), OUT battle_id INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    IF((SELECT users.id FROM users WHERE users.id = _player_id AND users.role = "player") IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'user is not player';
    END IF;


    IF((SELECT COUNT(battles.id) > 0 FROM battles WHERE (battles.player1_id = _player_id OR battles.player2_id = _player_id) AND battles.status="ongoing")) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'you already have an ongoing battle';
    END IF;

    SELECT AVG(monsters.base_next_xp), MAX(monsters.base_next_xp), AVG(tamed_monsters.xp), MAX(tamed_monsters.xp) INTO @avg_next_xp, @max_next_xp, @avg_xp, @max_xp
    FROM tamed_monsters
    JOIN monsters ON monsters.id = tamed_monsters.monster_id
    JOIN frontliners ON tamed_monsters.id IN (frontliners.tamed1_id, frontliners.tamed2_id, frontliners.tamed3_id, frontliners.tamed4_id, frontliners.tamed5_id)
    WHERE tamed_monsters.player_id=_player_id;

    SET @rand1 = RAND();
    SET @rand2 = RAND();
    INSERT INTO battles (type, player1_id, enemy_monster_id, enemy_monster_xp, enemy_monster_health, status, xp_gain_percentage)
    SELECT 
    "pve",
    _player_id,
    monsters.id,
    CAST(ROUND(@rand1*(monsters.base_next_xp + @avg_xp) + @rand2*@max_next_xp*0.01) AS INT),
    monsters.base_health * CAST(ROUND(@rand1*(monsters.base_next_xp + @avg_xp) + @rand2*@max_next_xp*0.01) AS INT),
    "ongoing",
    (CAST(ROUND(@rand1*(monsters.base_next_xp + @avg_xp) + @rand2*@max_next_xp*0.01) AS INT) + @avg_xp) / (CAST(ROUND(@rand1*(monsters.base_next_xp + @avg_xp) + @rand2*@max_next_xp*0.01) AS INT) + @max_xp)
    FROM monsters 
    WHERE 
    monsters.base_next_xp < (@avg_next_xp + @max_next_xp) 
    ORDER BY RAND()*monsters.base_next_xp LIMIT 1;

    SELECT LAST_INSERT_ID() INTO battle_id;

    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE request_battle(IN _player1_id INT(11), IN _player2_id INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    INSERT INTO battle_requests (player1_id, player2_id, status) VALUES(_player1_id, _player2_id, "pending");

    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_battle_requests(IN _player_id INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    IF((SELECT users.id FROM users WHERE users.id = _player_id AND users.role = "player") IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'user is not player';
    END IF;


    UPDATE battle_requests SET status="expired" WHERE (player1_id=_player_id OR player2_id=_player_id) AND status="pending" AND CURRENT_TIMESTAMP() >= expires_at;

    SELECT * FROM battle_requests WHERE (player1_id=_player_id OR player2_id=_player_id);

    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE reply_battle_request(IN _request_id INT(11), IN _reply ENUM("accepted", "rejected"), OUT battle_id INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    UPDATE battle_requests SET status="expired" WHERE id=_request_id AND status="pending" AND CURRENT_TIMESTAMP() >= expires_at;

    SELECT player1_id, player2_id, status INTO @player1_id, @player2_id, @status FROM battle_requests WHERE id=_request_id;
    IF(@status = "expired") THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'request expired';
    ELSEIF(@status != "pending") THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'request was already accepted/rejected';
    END IF;

    UPDATE battle_requests SET status=_reply WHERE id=_request_id AND status="pending";
    IF(_reply = "rejected") THEN
	SET battle_id = NULL;
    ELSE
	SELECT AVG(tamed_monsters.xp), MAX(tamed_monsters.xp) INTO @avg1_xp, @max1_xp
	FROM tamed_monsters
	JOIN monsters ON monsters.id = tamed_monsters.monster_id
	JOIN frontliners ON tamed_monsters.id IN (frontliners.tamed1_id, frontliners.tamed2_id, frontliners.tamed3_id, frontliners.tamed4_id, frontliners.tamed5_id)
	WHERE tamed_monsters.player_id=@player1_id;

	SELECT AVG(tamed_monsters.xp), MAX(tamed_monsters.xp) INTO @avg2_xp, @max2_xp
	FROM tamed_monsters
	JOIN monsters ON monsters.id = tamed_monsters.monster_id
	JOIN frontliners ON tamed_monsters.id IN (frontliners.tamed1_id, frontliners.tamed2_id, frontliners.tamed3_id, frontliners.tamed4_id, frontliners.tamed5_id)
	WHERE tamed_monsters.player_id=@player2_id;

	INSERT INTO battles (type, player1_id, player2_id, status, xp_gain_percentage)
	VALUES ("pvp", @player1_id, @player2_id, "ongoing", (@avg1_xp + @avg2_xp) / (@max1_xp + @max2_xp));

	SELECT LAST_INSERT_ID() INTO battle_id;
    END IF;
    
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE set_frontliners(IN _player_id INT(11), IN _tamed1_id INT(11), IN _tamed2_id INT(11), IN _tamed3_id INT(11), IN _tamed4_id INT(11), IN _tamed5_id INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    IF((SELECT users.id FROM users WHERE users.id = _player_id AND users.role = "player") IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'user is not player';
    END IF;

    IF(
	(
	    SELECT battles.id 
	    FROM battles 
	    WHERE 
	    battles.status="ongoing" AND 
	    (battles.player1_id=_player_id OR battles.player2_id=_player_id)
	    LIMIT 1
	) 
	IS NOT NULL
    ) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'frontliners cannot change while in battle';
    END IF;

    IF(_tamed1_id IS NOT NULL AND (SELECT tamed_monsters.player_id != _player_id FROM tamed_monsters WHERE tamed_monsters.id=_tamed1_id)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = '1st frontliner doesn''t belong to player';
    END IF;
    IF(_tamed2_id IS NOT NULL AND (SELECT tamed_monsters.player_id != _player_id FROM tamed_monsters WHERE tamed_monsters.id=_tamed2_id)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = '2nd frontliner doesn''t belong to player';
    END IF;
    IF(_tamed4_id IS NOT NULL AND (SELECT tamed_monsters.player_id != _player_id FROM tamed_monsters WHERE tamed_monsters.id=_tamed3_id)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = '3rd frontliner doesn''t belong to player';
    END IF;
    IF(_tamed4_id IS NOT NULL AND (SELECT tamed_monsters.player_id != _player_id FROM tamed_monsters WHERE tamed_monsters.id=_tamed4_id)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = '4th frontliner doesn''t belong to player';
    END IF;
    IF(_tamed5_id IS NOT NULL AND (SELECT tamed_monsters.player_id != _player_id FROM tamed_monsters WHERE tamed_monsters.id=_tamed5_id)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = '5th frontliner doesn''t belong to player';
    END IF;

    IF(
	(_tamed1_id=_tamed2_id OR _tamed1_id=_tamed3_id OR _tamed1_id=_tamed4_id OR _tamed1_id=_tamed5_id) OR
	(_tamed2_id=_tamed3_id OR _tamed2_id=_tamed4_id OR _tamed2_id=_tamed5_id) OR
	(_tamed3_id=_tamed4_id OR _tamed3_id=_tamed5_id) OR
	(_tamed4_id=_tamed5_id)
    ) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'the same tamed monster cannot be in 2 or more frontliner slots';
    END IF;

    IF ((SELECT COUNT(frontliners.id)>0 FROM frontliners WHERE frontliners.player_id=_player_id)) THEN
	UPDATE frontliners 
	SET 
	tamed1_id=_tamed1_id, 
	tamed2_id=_tamed2_id, 
	tamed3_id=_tamed3_id,
	tamed4_id=_tamed4_id,
	tamed5_id=_tamed5_id
	WHERE player_id=_player_id;
    ELSE
	INSERT INTO 
	frontliners (player_id, tamed1_id, tamed2_id, tamed3_id, tamed4_id, tamed5_id)
	VALUES (_player_id, _tamed1_id, _tamed2_id, _tamed3_id, _tamed4_id, _tamed5_id);
    END IF;

    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE _initiate_enemy_turn(IN _battle_id INT(11), IN _player_id INT(11), IN _player_tamed_id INT(11), IN _was_blocked BOOLEAN)
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    IF((SELECT users.id FROM users WHERE users.id = _player_id AND users.role = "player") IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'user is not player';
    END IF;

    SET @enemon_id = NULL;
    SET @enemon_xp = NULL;
    SET @enemon_lv = NULL;
    SET @enemon_action = IF(RAND() > 0.3, "skill", "block");
    SET @enemon_ms_id = NULL;
    SET @enemon_skill_id = NULL;
    SET @enemon_skill_type = NULL;
    SET @enemon_skill_value = NULL;
    SET @enemon_skill_damage = NULL;

    SELECT battles.enemy_monster_id, battles.enemy_monster_xp INTO @enemon_id, @enemon_xp
    FROM battles WHERE battles.id = _battle_id;

    SET @enemon_lv = (SELECT get_level_from_xp(@enemon_id, @enemon_xp));

    IF(@enemon_action = "skill") THEN
	SELECT 
	monster_skills.id, monster_skills.skill_id, skills.type, skills.value 
	INTO @enemon_ms_id, @enemon_skill_id, @enemon_skill_type, @enemon_skill_value
	FROM monster_skills 
	JOIN skills ON skills.id = monster_skills.skill_id
	WHERE monster_skills.monster_id=@enemon_id AND 
	@enemon_lv >= monster_skills.level_to_attain 
	ORDER BY RAND()
	LIMIT 1;

	IF(@enemon_skill_type = "attack") THEN 
	    SET @enemon_skill_damage = (
		SELECT 
		calculate_skill_damage(
		    @enemon_skill_id,
		    (
			SELECT monsters.element 
			FROM monsters 
			WHERE 
			monsters.id=(
			    SELECT tamed_monsters.monster_id FROM tamed_monsters WHERE tamed_monsters.id=_player_tamed_id
			)
			LIMIT 1
		    ),
		    _was_blocked
		)
	    );
	END IF;

    END IF;

    INSERT INTO turns (battle_id, type, tamed_id, action, monster_skill_id)
    VALUES (_battle_id, "enemy", NULL, @enemon_action, @enemon_ms_id);

    IF(@enemon_action = "skill") THEN
	IF(@enemon_skill_type = "attack") THEN
	    UPDATE tamed_monsters SET current_health=GREATEST(0, current_health - CEIL(@enemon_skill_damage)) WHERE tamed_monsters.id = _player_tamed_id;
	    IF(
		(
		    SELECT 
		    (
			IFNULL(tamed1.current_health,0)+
			IFNULL(tamed2.current_health,0)+
			IFNULL(tamed3.current_health,0)+
			IFNULL(tamed4.current_health,0)+
			IFNULL(tamed5.current_health,0)
		    ) <= 0
		    FROM frontliners
		    LEFT JOIN tamed_monsters tamed1 ON tamed1.id = frontliners.tamed1_id
		    LEFT JOIN tamed_monsters tamed2 ON tamed2.id = frontliners.tamed2_id
		    LEFT JOIN tamed_monsters tamed3 ON tamed3.id = frontliners.tamed3_id
		    LEFT JOIN tamed_monsters tamed4 ON tamed4.id = frontliners.tamed4_id
		    LEFT JOIN tamed_monsters tamed5 ON tamed5.id = frontliners.tamed5_id
		    WHERE frontliners.player_id=_player_id
		    LIMIT 1
		)
	    ) THEN
		UPDATE battles 
		SET 
		ended_at = CURRENT_TIMESTAMP(),
		status = "enemy"
		WHERE battles.id = _battle_id;

		UPDATE tamed_monsters
		SET current_health=max_health
		WHERE
		tamed_monsters.id = (SELECT tamed1_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1) OR
		tamed_monsters.id = (SELECT tamed2_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1) OR
		tamed_monsters.id = (SELECT tamed3_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1) OR
		tamed_monsters.id = (SELECT tamed4_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1) OR
		tamed_monsters.id = (SELECT tamed5_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1);

	    END IF;
	ELSEIF(@enemon_skill_type = "heal") THEN
	    UPDATE battles 
	    SET 
	    enemy_monster_health=LEAST(
		(SELECT monsters.base_health FROM monsters WHERE monsters.id=@enemon_id)*@enemon_lv, 
		enemy_monster_health + @enemon_skill_value
	    ) 
	    WHERE battles.id = _battle_id;
	ELSE
	    SELECT NULL;
	END IF;
    END IF;

    SET @enemon_id = NULL;
    SET @enemon_xp = NULL;
    SET @enemon_lv = NULL;
    SET @enemon_action = NULL;
    SET @enemon_ms_id = NULL;
    SET @enemon_skill_id = NULL;
    SET @enemon_skill_type = NULL;
    SET @enemon_skill_value = NULL;
    SET @enemon_skill_damage = NULL;

    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_turn_skills(IN _battle_id INT(11), IN _player_id INT(11), IN _tamed_id INT(11))
BEGIN
	DECLARE l_is_player1 BOOLEAN DEFAULT FALSE;

	declare exit handler for sqlexception
	begin
	    rollback;
	    RESIGNAL;
	end;
	START TRANSACTION;

	IF((SELECT users.id FROM users WHERE users.id = _player_id AND users.role = "player") IS NULL) THEN
	    SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'user is not player';
	END IF;

	SELECT 
	battles.player1_id=_player_id 
	INTO l_is_player1
	FROM battles WHERE battles.id = _battle_id;

	SELECT monster_skills.id, monster_skills.skill_id, skills.name, skills.element, skills.value, skills.turn_cooldown
	FROM monster_skills
	JOIN tamed_monsters ON tamed_monsters.monster_id=monster_skills.monster_id
	JOIN skills ON skills.id=monster_skills.skill_id
	WHERE
	tamed_monsters.id = _tamed_id AND
	get_level_from_xp(monster_skills.monster_id, tamed_monsters.xp) >= monster_skills.level_to_attain AND
	NOT(
	    IFNULL(
		(SELECT 
		    SUBSTRING(GROUP_CONCAT(turns.monster_skill_id=monster_skills.id ORDER BY turns.created_at DESC SEPARATOR ""), 1, skills.turn_cooldown)
		    FROM turns
		    WHERE
		    turns.battle_id=_battle_id AND 
		    type=IF(l_is_player1, "player1", "player2")),
		"0"
	    )
	    LIKE "%1%"
	);

	COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE take_turn(IN _battle_id INT(11), IN _player_id INT(11), IN _tamed_id INT(11), IN _action ENUM("skill", "block", "forfeit"), IN _monster_skill_id INT(11))
proc_turn:BEGIN
    DECLARE l_battle_type ENUM("pve", "pvp") DEFAULT "pve";
    DECLARE l_is_player1 BOOLEAN DEFAULT FALSE;
    DECLARE l_against_tamed_id INT(11) DEFAULT NULL;
    DECLARE l_against_monster_id INT(11) DEFAULT NULL;
    DECLARE l_against_element ENUM("fire", "nature", "water") DEFAULT NULL;
    DECLARE l_was_blocked BOOLEAN DEFAULT FALSE;
    DECLARE l_skill_type ENUM("attack", "heal");
    DECLARE l_skill_cooldown INT(11);
    DECLARE l_skill_value INT(11);
    DECLARE l_skill_damage FLOAT;

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    IF((SELECT users.id FROM users WHERE users.id = _player_id AND users.role = "player") IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'user is not player';
    END IF;

    IF((SELECT battles.id FROM battles WHERE battles.id=_battle_id) IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'battle does not exist';
    END IF;
    IF((SELECT battles.id FROM battles WHERE battles.id=_battle_id AND (battles.player1_id = _player_id OR battles.player2_id = _player_id)) IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'player is not in this battle';
    END IF;
    IF((SELECT battles.status != "ongoing" FROM battles WHERE battles.id=_battle_id)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'battle is already done';
    END IF;
    IF((SELECT tamed_monsters.id FROM tamed_monsters WHERE tamed_monsters.id=_tamed_id AND tamed_monsters.player_id = _player_id) IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'player does not own this tamed monster';
    END IF;
    IF(
	(
	    SELECT frontliners.id
	    FROM frontliners 
	    WHERE 
	    frontliners.player_id=_player_id AND 
	    (
		frontliners.tamed1_id=_tamed_id OR 
		frontliners.tamed2_id=_tamed_id OR 
		frontliners.tamed3_id=_tamed_id OR 
		frontliners.tamed4_id=_tamed_id OR 
		frontliners.tamed5_id=_tamed_id
	    )
	) IS NULL
    ) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'tamed monster is not in frontliners';
    END IF;

    IF(
	IFNULL(
	(
	    SELECT tamed_monsters.current_health <= 0
	    FROM tamed_monsters 
	    WHERE tamed_monsters.id=_tamed_id
	),
	TRUE)
    ) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'tamed monster is not alive';
    END IF;

    IF(
	_action="skill" AND
	(
	    SELECT monsters.id 
	    FROM monsters 
	    JOIN tamed_monsters ON tamed_monsters.monster_id = monsters.id 
	    JOIN monster_skills ON monster_skills.monster_id = monsters.id
	    WHERE
	    tamed_monsters.id = _tamed_id AND
	    monster_skills.id = _monster_skill_id AND
	    get_level_from_xp(monsters.id, tamed_monsters.xp) >= monster_skills.level_to_attain
	) IS NULL
    ) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'tamed monster has/does not own this skill';
    END IF;

    SELECT 
    battles.player1_id=_player_id, battles.type, IF(battles.type="pve", battles.enemy_monster_id, NULL) 
    INTO l_is_player1, l_battle_type, l_against_monster_id
    FROM battles WHERE battles.id = _battle_id;

    IF(IFNULL((SELECT 
	turns.type=IF(l_is_player1, "player1", "player2")
	FROM turns
	WHERE
	turns.battle_id = _battle_id
	ORDER BY turns.created_at DESC
	LIMIT 1), !l_is_player1)) 
    THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'not player''s turn';
    END IF;

    IF(_action="block") THEN
	INSERT INTO turns (battle_id, type, tamed_id, action, monster_skill_id)
	VALUES (_battle_id, IF(l_is_player1, "player1", "player2"), _tamed_id, "block", NULL);

	SELECT SLEEP(1);
	CALL _initiate_enemy_turn(_battle_id, _player_id, _tamed_id, TRUE);
	LEAVE proc_turn;
    END IF;

    IF(_action="forfeit") THEN
	INSERT INTO turns (battle_id, type, tamed_id, action, monster_skill_id)
	VALUES (_battle_id, IF(l_is_player1, "player1", "player2"), _tamed_id, "forfeit", NULL);

	UPDATE battles 
	SET 
	ended_at = CURRENT_TIMESTAMP(),
	status = IF(!l_is_player1, "player1", IF(l_battle_type="pvp", "player2", "enemy"))
	WHERE battles.id = _battle_id;

	UPDATE tamed_monsters
	SET current_health=max_health
	WHERE
	tamed_monsters.id = (SELECT tamed1_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1) OR
	tamed_monsters.id = (SELECT tamed2_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1) OR
	tamed_monsters.id = (SELECT tamed3_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1) OR
	tamed_monsters.id = (SELECT tamed4_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1) OR
	tamed_monsters.id = (SELECT tamed5_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1);

	IF(l_battle_type="pvp") THEN
	    SET @otherp_id = NULL;
	    SET @otherp_id = (
		    SELECT IF(l_is_player1, battles.player2_id, battles.player1_id)
		    FROM battles
		    WHERE battles.id=_battle_id
		);

	    UPDATE tamed_monsters
	    SET 
	    current_health=max_health,
	    xp=xp*(SELECT 1+battles.xp_gain_percentage FROM battles WHERE battles.id=_battle_id LIMIT 1)
	    WHERE
	    tamed_monsters.id = (SELECT tamed1_id FROM frontliners WHERE frontliners.player_id=@otherp_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed2_id FROM frontliners WHERE frontliners.player_id=@otherp_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed3_id FROM frontliners WHERE frontliners.player_id=@otherp_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed4_id FROM frontliners WHERE frontliners.player_id=@otherp_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed5_id FROM frontliners WHERE frontliners.player_id=@otherp_id LIMIT 1);

	    SET @otherp_id = NULL;
	END IF;

	LEAVE proc_turn;
    END IF;

    SELECT skills.type, skills.value, skills.turn_cooldown 
    INTO l_skill_type, l_skill_value, l_skill_cooldown
    FROM monster_skills
    JOIN skills ON skills.id=monster_skills.skill_id
    WHERE monster_skills.id = _monster_skill_id;

    IF(l_skill_cooldown > 0) THEN
	IF(
	     (
		IFNULL(
		    (SELECT 
		    SUBSTRING(GROUP_CONCAT(turns.monster_skill_id=_monster_skill_id ORDER BY turns.created_at DESC SEPARATOR ""), 1, l_skill_cooldown)
		    FROM turns
		    WHERE
		    turns.battle_id=_battle_id AND 
		    type=IF(l_is_player1, "player1", "player2")),
		    "0"
		)
		LIKE "%1%"
	    )
	) THEN
	    SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'skill is in cooldown';
	END IF;
    END IF;

    IF(l_skill_type="heal") THEN
	INSERT INTO turns (battle_id, type, tamed_id, action, monster_skill_id)
	VALUES (_battle_id, IF(l_is_player1, "player1", "player2"), _tamed_id, "skill", _monster_skill_id);

	UPDATE tamed_monsters SET current_health=LEAST(max_health, current_health+l_skill_value) WHERE tamed_monsters.id=_tamed_id;

	SELECT SLEEP(1);
	CALL _initiate_enemy_turn(_battle_id, _player_id, _tamed_id, TRUE);
	LEAVE proc_turn;
    END IF;

    IF(l_battle_type="pvp") THEN
	SELECT 
	turns.tamed_id, tamed_monsters.monster_id INTO l_against_tamed_id, l_against_monster_id
	FROM turns
	JOIN tamed_monsters ON tamed_monsters.id = turns.tamed_id
	WHERE
	turns.battle_id = _battle_id AND
	IF(
	    l_is_player1, 
	    turns.type = "player2",
	    turns.type = "player1"
	)
	ORDER BY turns.created_at DESC
	LIMIT 1;

	IF(l_against_tamed_id IS NULL) THEN
	    SELECT tamed_monsters.id, tamed_monsters.monster_id INTO l_against_tamed_id, l_against_monster_id
	    FROM frontliners
	    JOIN tamed_monsters ON tamed_monsters.id = frontliners.tamed1_id
	    WHERE
	    frontliners.player_id = (
		SELECT IF(l_is_player1, battles.player2_id, battles.player1_id)
		FROM battles
		WHERE
		battles.id=_battle_id
	    ) LIMIT 1;
	END IF;
    END IF;

    SELECT monsters.element INTO l_against_element
    FROM monsters
    WHERE monsters.id = l_against_monster_id;

    SET l_was_blocked = IFNULL(
	(SELECT 
	turns.action="block"
	FROM turns
	WHERE
	turns.battle_id = _battle_id AND
	IF(
	    l_is_player1, 
	    turns.type != "player1",
	    turns.type = "player1"
	)
	ORDER BY turns.created_at DESC
	LIMIT 1),
	FALSE
    );

    SET l_skill_damage = (
	SELECT 
	calculate_skill_damage(
	    (SELECT monster_skills.skill_id 
	    FROM monster_skills
	    WHERE monster_skills.id = _monster_skill_id),
	    l_against_element,
	    l_was_blocked
	)
    );

    INSERT INTO turns (battle_id, type, tamed_id, action, monster_skill_id)
    VALUES (_battle_id, IF(l_is_player1, "player1", "player2"), _tamed_id, _action, _monster_skill_id);

    IF (l_battle_type="pvp") THEN
	UPDATE tamed_monsters SET current_health=GREATEST(0, current_health - CEIL(l_skill_damage)) WHERE tamed_monsters.id = l_against_tamed_id;

	IF(
	    (
		SELECT 
		(
		    IFNULL(tamed1.current_health,0)+
		    IFNULL(tamed2.current_health,0)+
		    IFNULL(tamed3.current_health,0)+
		    IFNULL(tamed4.current_health,0)+
		    IFNULL(tamed5.current_health,0)
		) <= 0
		FROM frontliners
		LEFT JOIN tamed_monsters tamed1 ON tamed1.id = frontliners.tamed1_id
		LEFT JOIN tamed_monsters tamed2 ON tamed2.id = frontliners.tamed2_id
		LEFT JOIN tamed_monsters tamed3 ON tamed3.id = frontliners.tamed3_id
		LEFT JOIN tamed_monsters tamed4 ON tamed4.id = frontliners.tamed4_id
		LEFT JOIN tamed_monsters tamed5 ON tamed5.id = frontliners.tamed5_id
		WHERE frontliners.player_id=(
		    SELECT IF(l_is_player1, battles.player2_id, battles.player1_id)
		    FROM battles
		    WHERE battles.id=_battle_id
		) LIMIT 1
	    )
	) THEN
	    UPDATE battles 
	    SET 
	    ended_at = CURRENT_TIMESTAMP(),
	    status = IF(l_is_player1, "player1", "player2")
	    WHERE battles.id = _battle_id;

	    UPDATE tamed_monsters
	    SET 
	    current_health=max_health,
	    xp=xp*(SELECT 1+battles.xp_gain_percentage FROM battles WHERE battles.id=_battle_id LIMIT 1)
	    WHERE
	    tamed_monsters.id = (SELECT tamed1_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed2_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed3_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed4_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed5_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1);

	    SET @otherp_id = NULL;
	    SET @otherp_id = (
		    SELECT IF(l_is_player1, battles.player2_id, battles.player1_id)
		    FROM battles
		    WHERE battles.id=_battle_id
		);

	    UPDATE tamed_monsters
	    SET current_health=max_health
	    WHERE
	    tamed_monsters.id = (SELECT tamed1_id FROM frontliners WHERE frontliners.player_id=@otherp_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed2_id FROM frontliners WHERE frontliners.player_id=@otherp_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed3_id FROM frontliners WHERE frontliners.player_id=@otherp_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed4_id FROM frontliners WHERE frontliners.player_id=@otherp_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed5_id FROM frontliners WHERE frontliners.player_id=@otherp_id LIMIT 1);

	    SET @otherp_id = NULL;

	END IF;
    ELSE
	UPDATE battles SET enemy_monster_health=GREATEST(0, enemy_monster_health - CEIL(l_skill_damage)) WHERE battles.id = _battle_id;

	IF(SELECT battles.enemy_monster_health=0 FROM battles WHERE battles.id=_battle_id) THEN
	    UPDATE battles 
	    SET 
	    ended_at = CURRENT_TIMESTAMP(),
	    status = "player1" 
	    WHERE battles.id = _battle_id;

	    UPDATE tamed_monsters
	    SET xp=xp*(SELECT 1+battles.xp_gain_percentage FROM battles WHERE battles.id=_battle_id LIMIT 1)
	    WHERE
	    tamed_monsters.id = (SELECT tamed1_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed2_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed3_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed4_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed5_id FROM frontliners WHERE frontliners.player_id=_player_id LIMIT 1);

	    CALL tame_monster(
		(SELECT battles.enemy_monster_id FROM battles WHERE battles.id=_battle_id), 
		_player_id, 
		(SELECT battles.enemy_monster_xp FROM battles WHERE battles.id=_battle_id)
	    );
	ELSE
	    SELECT SLEEP(1);
	    CALL _initiate_enemy_turn(_battle_id, _player_id, _tamed_id, FALSE);
	END IF;
    END IF;
    COMMIT;
END$$
DELIMITER ;

-- FUNCTIONS
DELIMITER $$
CREATE OR REPLACE FUNCTION `calculate_tamed_next_xp`(IN tamed_id INT) RETURNS int(11)
RETURN (
SELECT 
monsters.base_next_xp * ((tamed_monsters.level * tamed_monsters.level + tamed_monsters.level) / 2) as next_xp
FROM tamed_monsters
JOIN monsters ON monsters.id = tamed_monsters.monster_id
WHERE tamed_monsters.id = tamed_id
)$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE FUNCTION `get_level_from_xp`(IN _monster_id INT, IN _xp INT) RETURNS int(11)
RETURN (
    FLOOR(
	(
	    -1 + 
	    SQRT(
		1 + 
		(8*_xp / (SELECT monsters.base_next_xp FROM monsters WHERE monsters.id = _monster_id))
	    )
	) / 2
    ) + 1
)$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE FUNCTION `calculate_skill_damage`(
    _skill_id INT, 
    _against_element ENUM("fire", "nature", "water"), 
    _was_blocked BOOLEAN)
RETURNS FLOAT
BEGIN
    DECLARE l_skill_element ENUM("fire", "nature", "water") DEFAULT NULL;
    DECLARE l_skill_value INT(11) DEFAULT NULL;
    DECLARE l_effectiveness FLOAT DEFAULT 0.5;

    SELECT skills.element, skills.value INTO l_skill_element, l_skill_value
    FROM skills
    WHERE skills.id = _skill_id;
    
    IF(
	(l_skill_element="fire" AND _against_element="nature") OR
	(l_skill_element="nature" AND _against_element="water") OR
	(l_skill_element="water" AND _against_element="fire")
    ) THEN
	SET l_effectiveness = 1;
    END IF;

    -- (value * ef * (1 - was_blocked*(1 - ef*0.75)))
    RETURN l_skill_value * l_effectiveness * (1 - _was_blocked * (1 - l_effectiveness * 0.75));

END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE FUNCTION check_battle_status(
    IN _battle_id INT(11)
) RETURNS ENUM("ongoing", "player1", "player2", "enemy") 
BEGIN
    RETURN (SELECT battles.status FROM battles WHERE battles.id=_battle_id);  
END$$
DELIMITER ;

-- DUMMY DATA
INSERT INTO `users` (`id`, `username`, `password`, `role`) VALUES
(15, 'admin1', PASSWORD('adminpass1'), 'admin'),
(16, 'admin2', PASSWORD('adminpass2'), 'admin'),
(17, 'admin3', PASSWORD('adminpass3'), 'admin'),
(18, 'player1', PASSWORD('playerpass1'), 'player'),
(19, 'player2', PASSWORD('playerpass2'), 'player'),
(20, 'player3', PASSWORD('playerpass3'), 'player'),
(21, 'player4', PASSWORD('playerpass4'), 'player'),
(22, 'player5', PASSWORD('playerpass5'), 'player');

INSERT INTO `monsters` (`id`, `name`, `element`, `base_health`, `base_next_xp`, `max_xp`) VALUES
(1, 'Firamon', 'fire', 10, 5, 300),
(2, 'Naterrain', 'nature', 20, 6, 300),
(3, 'Waterfoul', 'water', 15, 5, 300),
(15, 'Fire Dragon', 'fire', 100, 50, 1000),
(16, 'Water Serpent', 'water', 90, 45, 900),
(17, 'Nature Golem', 'nature', 110, 55, 1100),
(18, 'Flame Phoenix', 'fire', 95, 48, 950),
(19, 'Aqua Turtle', 'water', 105, 52, 1050);

INSERT INTO `skills` (`id`, `name`, `element`, `type`, `value`, `turn_cooldown`) VALUES
(1, 'Fireball', 'fire', 'attack', 5, 0),
(2, 'Thorny Leaves', 'nature', 'attack', 5, 0),
(3, 'Water Spit', 'water', 'attack', 5, 0),
(4, 'Burning Claw', 'fire', 'attack', 10, 1),
(5, 'Call of Nature', 'nature', 'attack', 11, 1),
(6, 'Soak', 'nature', 'attack', 9, 1),
(7, 'Basic Heal', 'nature', 'heal', 20, 3),
(15, 'Fire Blast', 'fire', 'attack', 30, 2),
(16, 'Flame Shield', 'fire', 'heal', 15, 2),
(17, 'Water Splash', 'water', 'attack', 25, 1),
(18, 'Tsunami', 'water', 'attack', 35, 3),
(19, 'Nature Heal', 'nature', 'heal', 20, 3),
(20, 'Leaf Slash', 'nature', 'attack', 25, 2);

INSERT INTO `monster_skills` (`id`, `monster_id`, `skill_id`, `level_to_attain`) VALUES
(1, 1, 1, 1),      -- Firamon learns Fireball at level 1
(2, 2, 2, 1),      -- Naterrain learns Thorny Leaves at level 1
(3, 3, 3, 1),      -- Waterfoul learns Water Spit at level 1
(4, 1, 4, 2),      -- Firamon learns Burning Claw at level 2
(5, 2, 5, 2),      -- Naterrain learns Call of Nature at level 2
(6, 3, 6, 2),      -- Waterfoul learns Soak at level 2
(7, 2, 7, 2),      -- Naterrain learns Basic Heal at level 2
(15, 15, 15, 1),   -- Fire Dragon learns Fire Blast at level 1
(16, 15, 16, 5),   -- Fire Dragon learns Flame Shield at level 5
(17, 16, 17, 1),   -- Water Serpent learns Water Splash at level 1
(18, 16, 18, 7),   -- Water Serpent learns Tsunami at level 7
(19, 17, 19, 1),   -- Nature Golem learns Nature Heal at level 1
(20, 17, 20, 1),   -- Nature Golem learns Leaf Slash at level 1
(21, 18, 15, 1),   -- Flame Phoenix learns Fire Blast at level 1
(22, 18, 16, 6),   -- Flame Phoenix learns Flame Shield at level 6
(23, 19, 17, 1),   -- Aqua Turtle learns Water Splash at level 1
(24, 19, 19, 4);   -- Aqua Turtle learns Nature Heal at level 4

-- Tamed monsters for player1 (user_id = 18)
INSERT INTO `tamed_monsters` (`id`, `monster_id`, `player_id`, `acquired_at`, `level`, `xp`, `max_health`, `current_health`) VALUES
(15, 15, 18, '2023-09-01 10:00:00', 5, 250, 120, 120),  -- Fire Dragon
(16, 17, 18, '2023-09-05 12:00:00', 3, 100, 130, 100),  -- Nature Golem
(17, 18, 18, '2023-09-10 14:00:00', 2, 60, 110, 80);    -- Flame Phoenix

-- Tamed monsters for player2 (user_id = 19)
INSERT INTO `tamed_monsters` VALUES
(18, 16, 19, '2023-09-02 11:00:00', 4, 200, 100, 90),   -- Water Serpent
(19, 19, 19, '2023-09-06 13:00:00', 3, 120, 115, 115),  -- Aqua Turtle
(20, 15, 19, '2023-09-11 15:00:00', 2, 70, 120, 120);   -- Fire Dragon

-- Tamed monsters for player3 (user_id = 20)
INSERT INTO `tamed_monsters` VALUES
(21, 17, 20, '2023-09-03 09:00:00', 5, 250, 130, 130),  -- Nature Golem
(22, 16, 20, '2023-09-07 11:30:00', 3, 130, 100, 80),   -- Water Serpent
(23, 19, 20, '2023-09-12 16:00:00', 2, 50, 115, 90);    -- Aqua Turtle

-- Tamed monsters for player4 (user_id = 21)
INSERT INTO `tamed_monsters` VALUES
(24, 18, 21, '2023-09-04 08:00:00', 4, 190, 110, 110), -- Flame Phoenix
(25, 15, 21, '2023-09-08 12:30:00', 3, 110, 120, 110), -- Fire Dragon
(26, 17, 21, '2023-09-13 17:00:00', 2, 80, 130, 70);   -- Nature Golem

-- Tamed monsters for player5 (user_id = 22)
INSERT INTO `tamed_monsters` VALUES
(27, 16, 22, '2023-09-05 07:00:00', 5, 240, 100, 100), -- Water Serpent
(28, 19, 22, '2023-09-09 13:30:00', 3, 140, 115, 115), -- Aqua Turtle
(29, 18, 22, '2023-09-14 18:00:00', 2, 60, 110, 85);   -- Flame Phoenix

-- For player1 (user_id = 18)
INSERT INTO `frontliners` (`id`, `player_id`, `tamed1_id`, `tamed2_id`, `tamed3_id`, `tamed4_id`, `tamed5_id`) VALUES
(15, 18, 15, 16, 17, NULL, NULL);

-- For player2 (user_id = 19)
INSERT INTO `frontliners` VALUES
(16, 19, 18, 19, 20, NULL, NULL);

-- For player3 (user_id = 20)
INSERT INTO `frontliners` VALUES
(17, 20, 21, 22, 23, NULL, NULL);

-- For player4 (user_id = 21)
INSERT INTO `frontliners` VALUES
(18, 21, 24, 25, 26, NULL, NULL);

-- For player5 (user_id = 22)
INSERT INTO `frontliners` VALUES
(19, 22, 27, 28, 29, NULL, NULL);
