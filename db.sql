-- STRUCTURES
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` text NOT NULL,
  `role` enum('player','admin') NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `sessions` (
  `id` VARCHAR(36) NOT NULL DEFAULT UUID(),
  `user_id` INT(11) NOT NULL,
  `expires_at` DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP() + INTERVAL 1 HOUR),
  PRIMARY KEY (`id`),
  KEY `s_user` (`user_id`),
  CONSTRAINT `s_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
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
CREATE OR REPLACE PROCEDURE check_authenticated(_sid VARCHAR(36))
BEGIN
    DECLARE l_user_id INT(11) DEFAULT NULL;

    START TRANSACTION;

    SELECT is_authenticated(_sid) INTO l_user_id;
    IF(l_user_id IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'User not authenticated';
    END IF;

    -- SELECT l_user_id user_id;

    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE check_admin(_sid VARCHAR(36))
BEGIN
    START TRANSACTION;

    CALL check_authenticated(_sid);

    IF(SELECT !is_admin(_sid)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'User is not admin';
    END IF;

    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE check_player(_sid VARCHAR(36))
BEGIN
    START TRANSACTION;

    CALL check_authenticated(_sid);

    IF(SELECT is_admin(_sid)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'User is not player';
    END IF;

    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE register(_username VARCHAR(255), _password TEXT)
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;
    
    IF(_username IS NULL OR _username="") THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Username cannot be empty';
    END IF;
    
    IF(_password IS NULL OR LENGTH(_password)<8) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Password needs to be at least 8 characters';
    END IF;

    IF(SELECT _username IN (SELECT users.username FROM users)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'User with that username already exists';
    END IF;

    INSERT INTO users (username, password, role) VALUES (_username, PASSWORD(_password), 'player');

    SET @registered_id = NULL;
    SET @registered_id = (SELECT LAST_INSERT_ID());
    CALL tame_monster(1, @registered_id, 1);
    CALL set_frontliners(@registered_id, (SELECT LAST_INSERT_ID()), NULL, NULL, NULL, NULL);

    SELECT @registered_id user_id;
    SET @registered_id = NULL;
    
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE login(IN _username VARCHAR(255), IN _password TEXT)
BEGIN
    DECLARE l_sid VARCHAR(36) DEFAULT UUID();
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
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Username or password is incorrect';
    END IF;

    INSERT INTO sessions (id, user_id) VALUES (l_sid, l_id);

    COMMIT;
    SELECT l_sid sid, l_id id, l_username username, l_role role;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE logout(IN _sid VARCHAR(36))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_authenticated(_sid);

    DELETE FROM sessions WHERE sessions.id=_sid;

    COMMIT; 
END$$

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_skills(
    IN _limit INT(11), 
    IN _page INT(11), 
    IN f_id INT(11), 
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
    IF(f_id IS NULL, TRUE, skills.id = f_id) AND
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
	SELECT 
	skills.id,
	skills.name,
	skills.element,
	skills.type,
	skills.value,
	skills.turn_cooldown
	FROM skills
	WHERE
	IF(f_id IS NULL, TRUE, skills.id = f_id) AND
	IF(f_name IS NULL, TRUE, skills.name LIKE f_name) AND
	IF(f_element IS NULL, TRUE, skills.element LIKE f_element) AND
	IF(f_type IS NULL, TRUE, skills.type LIKE f_type);
    ELSE
	SELECT 
	skills.id,
	skills.name,
	skills.element,
	skills.type,
	skills.value,
	skills.turn_cooldown
	FROM skills
	WHERE
	IF(f_id IS NULL, TRUE, skills.id = f_id) AND
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
    IN f_id INT(11), 
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
    IF(f_id IS NULL, TRUE, monsters.id = f_id) AND
    IF(f_name IS NULL, TRUE, monsters.name LIKE f_name) AND
    IF(f_element IS NULL, TRUE, monsters.element LIKE f_element);

    SET l_total_pages = IF(l_limit=0, 1, CEIL(l_count / l_limit));
    IF(l_total_pages = 0) THEN
	SET l_page = 0;
    END IF;

    SET l_offset = IF(l_page <= 0, 0, (l_page - 1) * l_limit);

    SET l_has_prev = l_page > 1;
    SET l_has_next = l_page < l_total_pages;

    SELECT l_total_pages total_pages, l_has_prev has_prev, l_has_next has_next;

    IF(l_limit = 0) THEN
	SELECT 
	monsters.id,
	monsters.name,
	monsters.element,
	monsters.base_health,
	monsters.base_next_xp,
	monsters.max_xp
	FROM monsters
	WHERE
	IF(f_id IS NULL, TRUE, monsters.id = f_id) AND
	IF(f_name IS NULL, TRUE, monsters.name LIKE f_name) AND
	IF(f_element IS NULL, TRUE, monsters.element LIKE f_element);
    ELSE
	SELECT 
	monsters.id,
	monsters.name,
	monsters.element,
	monsters.base_health,
	monsters.base_next_xp,
	monsters.max_xp
	FROM monsters
	WHERE
	IF(f_id IS NULL, TRUE, monsters.id = f_id) AND
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
    IN f_id INT(11), 
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
    IF(f_id IS NULL, TRUE, monster_skills.id = f_id) AND
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
	SELECT monster_skills.id, monster_skills.skill_id, skills.name, skills.element, skills.value, skills.turn_cooldown, monster_skills.level_to_attain
	FROM monster_skills
	JOIN skills ON skills.id=monster_skills.skill_id
	WHERE
	monster_skills.monster_id = _monster_id AND
	IF(f_id IS NULL, TRUE, monster_skills.id = f_id) AND
	IF(f_name IS NULL, TRUE, skills.name LIKE f_name) AND
	IF(f_element IS NULL, TRUE, skills.element LIKE f_element);
    ELSE
	SELECT monster_skills.id, monster_skills.skill_id, skills.name, skills.element, skills.value, skills.turn_cooldown, monster_skills.level_to_attain
	FROM monster_skills
	JOIN skills ON skills.id=monster_skills.skill_id
	WHERE
	monster_skills.monster_id = _monster_id AND
	IF(f_id IS NULL, TRUE, monster_skills.id = f_id) AND
	IF(f_name IS NULL, TRUE, skills.name LIKE f_name) AND
	IF(f_element IS NULL, TRUE, skills.element LIKE f_element)
	LIMIT l_limit
	OFFSET l_offset;
    END IF;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_admins(
    IN _sid VARCHAR(36),
    IN _limit INT(11), 
    IN _page INT(11), 
    IN f_id INT(11), 
    IN f_username TEXT
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

    CALL check_admin(_sid);

    SET l_limit = IFNULL(_limit, 10);
    SET l_page = IFNULL(_page, 1);

    SELECT COUNT(users.id) INTO l_count
    FROM users
    WHERE
    IF(f_id IS NULL, TRUE, users.id = f_id) AND
    IF(f_username IS NULL, TRUE, users.username LIKE f_username) AND
    users.role="admin";

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
	users.username
	FROM users
	WHERE
	IF(f_id IS NULL, TRUE, users.id = f_id) AND
	IF(f_username IS NULL, TRUE, users.username LIKE f_username) AND
	users.role="admin";
    ELSE
	SELECT
	users.id,
	users.username
	FROM users
	WHERE
	IF(f_id IS NULL, TRUE, users.id = f_id) AND
	IF(f_username IS NULL, TRUE, users.username LIKE f_username) AND
	users.role="admin"
	LIMIT l_limit
	OFFSET l_offset;
    END IF;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_players(
    IN _limit INT(11), 
    IN _page INT(11), 
    IN f_id INT(11), 
    IN f_username TEXT
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
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'User is not player';
    END IF;

    SET l_limit = IFNULL(_limit, 10);
    SET l_page = IFNULL(_page, 1);

    SELECT COUNT(users.id) INTO l_count
    FROM users
    WHERE
    IF(f_id IS NULL, TRUE, users.id = f_id) AND
    IF(f_username IS NULL, TRUE, users.username LIKE f_username) AND
    users.role="player";

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
	users.username
	FROM users
	WHERE
	IF(f_id IS NULL, TRUE, users.id = f_id) AND
	IF(f_username IS NULL, TRUE, users.username LIKE f_username) AND
	users.role="player";
    ELSE
	SELECT
	users.id,
	users.username
	FROM users
	WHERE
	IF(f_id IS NULL, TRUE, users.id = f_id) AND
	IF(f_username IS NULL, TRUE, users.username LIKE f_username) AND
	users.role="player"
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
    IN f_id INT(11), 
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
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'User is not player';
    END IF;

    SET l_limit = IFNULL(_limit, 10);
    SET l_page = IFNULL(_page, 1);

    SELECT COUNT(tamed_monsters.id) INTO l_count
    FROM tamed_monsters
    JOIN monsters ON monsters.id = tamed_monsters.monster_id
    WHERE
    tamed_monsters.player_id = _player_id AND
    IF(f_id IS NULL, TRUE, tamed_monsters.id = f_id) AND
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
	SELECT 
	tamed_monsters.id, 
	tamed_monsters.monster_id, 
	tamed_monsters.player_id, 
	tamed_monsters.acquired_at, 
	tamed_monsters.level, 
	tamed_monsters.xp, 
	tamed_monsters.max_health, 
	tamed_monsters.current_health, 
	monsters.name, 
	monsters.element
	FROM tamed_monsters
	JOIN monsters ON monsters.id = tamed_monsters.monster_id
	WHERE
	tamed_monsters.player_id = _player_id AND
	IF(f_id IS NULL, TRUE, tamed_monsters.id = f_id) AND
	IF(f_name IS NULL, TRUE, monsters.name LIKE f_name) AND
	IF(f_element IS NULL, TRUE, monsters.element LIKE f_element);
    ELSE
	SELECT 
	tamed_monsters.id, 
	tamed_monsters.monster_id, 
	tamed_monsters.player_id, 
	tamed_monsters.acquired_at, 
	tamed_monsters.level, 
	tamed_monsters.xp, 
	tamed_monsters.max_health, 
	tamed_monsters.current_health, 
	monsters.name, 
	monsters.element
	FROM tamed_monsters
	JOIN monsters ON monsters.id = tamed_monsters.monster_id
	WHERE
	tamed_monsters.player_id = _player_id AND
	IF(f_id IS NULL, TRUE, tamed_monsters.id = f_id) AND
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
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'User is not player';
    END IF;

    SELECT 
    frontliners.id,
    frontliners.player_id,
    frontliners.tamed1_id,
    frontliners.tamed2_id,
    frontliners.tamed3_id,
    frontliners.tamed4_id,
    frontliners.tamed5_id
    FROM frontliners WHERE frontliners.player_id = _player_id;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_battles(
    IN _limit INT(11), 
    IN _page INT(11),
    IN f_id INT(11),
    IN f_player_id INT(11),
    IN f_status TEXT
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
    FROM battles
    WHERE
    IF(f_id IS NULL, TRUE, battles.id = f_id) AND
    IF(f_player_id IS NULL, TRUE, battles.player1_id = f_player_id OR battles.player2_id = f_player_id) AND
    IF(f_status IS NULL, TRUE, battles.status LIKE f_status);

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
	battles.id, 
	battles.started_at, 
	battles.ended_at, 
	battles.type, 
	battles.player1_id, 
	battles.player2_id, 
	battles.enemy_monster_id, 
	battles.enemy_monster_xp, 
	battles.enemy_monster_health, 
	battles.status, 
	battles.xp_gain_percentage, 
	p1.username player1_username, 
	p2.username player2_username
	FROM battles
	LEFT JOIN users p1 ON p1.id=battles.player1_id
	LEFT JOIN users p2 ON p2.id=battles.player2_id
	WHERE
	IF(f_id IS NULL, TRUE, battles.id = f_id) AND
	IF(f_player_id IS NULL, TRUE, battles.player1_id = f_player_id OR battles.player2_id = f_player_id) AND
	IF(f_status IS NULL, TRUE, battles.status LIKE f_status)
	ORDER BY battles.started_at DESC;
    ELSE
	SELECT 
	battles.id, 
	battles.started_at, 
	battles.ended_at, 
	battles.type, 
	battles.player1_id, 
	battles.player2_id, 
	battles.enemy_monster_id, 
	battles.enemy_monster_xp, 
	battles.enemy_monster_health, 
	battles.status, 
	battles.xp_gain_percentage, 
	p1.username player1_username, 
	p2.username player2_username
	FROM battles
	LEFT JOIN users p1 ON p1.id=battles.player1_id
	LEFT JOIN users p2 ON p2.id=battles.player2_id
	WHERE
	IF(f_id IS NULL, TRUE, battles.id = f_id) AND
	IF(f_player_id IS NULL, TRUE, battles.player1_id = f_player_id OR battles.player2_id = f_player_id) AND
	IF(f_status IS NULL, TRUE, battles.status LIKE f_status)
	ORDER BY battles.started_at DESC
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
	SELECT 
	id,
	battle_id,
	type,
	tamed_id,
	action,
	monster_skill_id,
	created_at
	FROM turns
	WHERE turns.battle_id = _battle_id
	ORDER BY turns.created_at DESC;
    ELSE
	SELECT 
	id,
	battle_id,
	type,
	tamed_id,
	action,
	monster_skill_id,
	created_at
	FROM turns
	WHERE turns.battle_id = _battle_id
	ORDER BY turns.created_at DESC
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
CREATE OR REPLACE PROCEDURE add_admin(_sid VARCHAR(36), _username VARCHAR(255), _password TEXT)
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_admin(_sid);

    IF(_username IS NULL OR _username="") THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Username cannot be empty';
    END IF;
    
    IF(_password IS NULL OR LENGTH(_password)<8) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Password needs to be at least 8 characters';
    END IF;

    IF(SELECT _username IN (SELECT users.username FROM users)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'User with that username already exists';
    END IF;

    INSERT INTO users (username, password, role) VALUES (_username, PASSWORD(_password), 'player');

    SET @added_id = NULL;
    SET @added_id = (SELECT LAST_INSERT_ID());

    SELECT @added_id user_id;
    SET @added_id = NULL;

    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE add_monster(_sid VARCHAR(36), _name VARCHAR(255), _element VARCHAR(255), _base_health INT(11), _base_next_xp INT(11), _max_xp INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_admin(_sid);

    IF(_name IS NULL OR LENGTH(_name)=0) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `name` is required';
    END IF;

    IF(_element IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `element` is required';
    END IF;

    IF(_element NOT IN ("fire", "nature", "water")) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `element` has to be either "fire", "nature", or "water"';
    END IF;

    IF(_base_health IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `base_health` is required';
    END IF;

    IF(_base_health <= 0) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `base_health` has to be greater than 0';
    END IF;

    IF(_base_next_xp IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `base_next_xp` is required';
    END IF;

    IF(_base_next_xp <= 0) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `base_next_xp` has to be greater than 0';
    END IF;

    IF(_max_xp IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `max_xp` is required';
    END IF;

    IF(_max_xp < _base_next_xp) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `max_xp` has to be greater than `base_next_xp`';
    END IF;

    INSERT INTO monsters (name, element, base_health, base_next_xp, max_xp) VALUES(_name, _element, _base_health, _base_next_xp, _max_xp);

    SELECT LAST_INSERT_ID() as added_id;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE add_skill(_sid VARCHAR(36), _name VARCHAR(255), _element VARCHAR(255), _type VARCHAR(255), _value INT(11), _turn_cooldown INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;

    START TRANSACTION;

    CALL check_admin(_sid);

    IF(_name IS NULL OR LENGTH(_name)=0) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `name` is required';
    END IF;

    IF(_element IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `element` is required';
    END IF;

    IF(_element NOT IN ("fire", "nature", "water")) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `element` has to be either "fire", "nature", or "water"';
    END IF;

    IF(_type IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `type` is required';
    END IF;

    IF(_type NOT IN ("attack", "heal")) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `type` has to be either "attack" or "heal"';
    END IF;

    IF(_value IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `value` is required';
    END IF;

    IF(_value <= 0) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `value` has to be greater than 0';
    END IF;

    IF(_turn_cooldown IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `turn_cooldown` is required';
    END IF;

    IF(_turn_cooldown < 0) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `turn_cooldown` has to be greater than or equal to 0';
    END IF;

    INSERT INTO skills (name, element, type, value, turn_cooldown) VALUES(_name, _element, _type, _value, _turn_cooldown);

    SELECT LAST_INSERT_ID() as added_id;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE add_monster_skill(_sid VARCHAR(36), _monster_id INT(11), _skill_id INT(11), _level_to_attain INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_admin(_sid);

    IF((SELECT monsters.element FROM monsters WHERE monsters.id=_monster_id LIMIT 1)!=(SELECT skills.element FROM skills WHERE skills.id=_skill_id)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Skill element does not matched monster element';
    END IF;

    IF(_level_to_attain IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `level_to_attain` is required';
    END IF;

    IF(_level_to_attain <= 0) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `level_to_attain` has to be greater than 0';
    END IF;

    INSERT INTO monster_skills (monster_id, skill_id, level_to_attain) VALUES(_monster_id, _skill_id, _level_to_attain);

    SELECT LAST_INSERT_ID() as added_id;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE edit_monster(_sid VARCHAR(36), _id INT(11),_name VARCHAR(255), _element VARCHAR(255), _base_health INT(11), _base_next_xp INT(11), _max_xp INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_admin(_sid);

    IF((SELECT id FROM monsters WHERE id=_id) IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Monster does not exist';
    END IF;

    IF(_element NOT IN ("fire", "nature", "water")) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `element` has to be either "fire", "nature", or "water"';
    END IF;

    IF(_base_health <= 0) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `base_health` has to be greater than 0';
    END IF;

    IF(_base_next_xp <= 0) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `base_next_xp` has to be greater than 0';
    END IF;

    IF(
	_max_xp < IFNULL(
	    _base_next_xp, 
	    (
		SELECT 
		monsters.base_next_xp 
		FROM 
		monsters 
		WHERE 
		monsters.id=_id
	    )
	)
    ) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `max_xp` has to be greater than `base_next_xp`';
    END IF;

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
CREATE OR REPLACE PROCEDURE edit_skill(_sid VARCHAR(36), _id INT(11), _name VARCHAR(255), _element VARCHAR(255), _type VARCHAR(255), _value INT(11), _turn_cooldown INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_admin(_sid);

    IF((SELECT id FROM skills WHERE id=_id) IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Skill does not exist';
    END IF;

    IF(_element NOT IN ("fire", "nature", "water")) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `element` has to be either "fire", "nature", or "water"';
    END IF;

    IF(_type NOT IN ("attack", "heal")) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `type` has to be either "attack" or "heal"';
    END IF;

    IF(_value <= 0) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `value` has to be greater than 0';
    END IF;

    IF(_turn_cooldown < 0) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `value` has to be greater than or equal to 0';
    END IF;

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
CREATE OR REPLACE PROCEDURE edit_monster_skill(_sid VARCHAR(36), _id INT(11), _monster_id INT(11), _skill_id INT(11), _level_to_attain INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_admin(_sid);

    IF((SELECT monsters.element FROM monsters WHERE monsters.id=_monster_id LIMIT 1)!=(SELECT skills.element FROM skills WHERE skills.id=_skill_id)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Skill element does not matched monster element';
    END IF;

    IF(_level_to_attain <= 0) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `level_to_attain` has to be greater than 0';
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
CREATE OR REPLACE PROCEDURE delete_monster(_sid VARCHAR(36), _id INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_admin(_sid);

    IF((SELECT id FROM monsters WHERE id=_id) IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Monster does not exist';
    END IF;

    DELETE FROM monsters WHERE monsters.id=_id;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE delete_skill(_sid VARCHAR(36), _id INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_admin(_sid);

    IF((SELECT id FROM skills WHERE id=_id) IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Skill does not exist';
    END IF;

    DELETE FROM skills WHERE skills.id=_id;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE delete_monster_skill(_sid VARCHAR(36), _id INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_admin(_sid);

    IF((SELECT id FROM monster_skills WHERE id=_id) IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Monster skill does not exist';
    END IF;

    DELETE FROM monster_skills WHERE monster_skills.id=_id;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE delete_admin(_sid VARCHAR(36), _id INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_admin(_sid);

    IF((SELECT id FROM users WHERE id=_id AND role="admin") IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Admin does not exist';
    END IF;

    DELETE FROM users WHERE users.id=_id AND role="admin";
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE delete_player(_sid VARCHAR(36), _id INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_admin(_sid);

    IF((SELECT id FROM users WHERE id=_id AND role="player") IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Player does not exist';
    END IF;

    DELETE FROM users WHERE users.id=_id AND role="player";
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_profile(_sid VARCHAR(36))
BEGIN
    DECLARE l_user_id INT(11) DEFAULT NULL;

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_authenticated(_sid);
    SELECT is_authenticated(_sid) INTO l_user_id;

    SELECT id, username, role
    FROM users
    WHERE id=l_user_id;

    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE edit_profile(_sid VARCHAR(36), _username VARCHAR(255), _password TEXT)
BEGIN
    DECLARE l_user_id INT(11) DEFAULT NULL;

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_authenticated(_sid);
    SELECT is_authenticated(_sid) INTO l_user_id;

    IF(SELECT _username IN (SELECT users.username FROM users WHERE id!=l_user_id)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'User with that username already exists';
    END IF;

    IF(LENGTH(_password)<8) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Password needs to be at least 8 characters';
    END IF;

    UPDATE users 
    SET
    username = IFNULL(_username, username), 
    password = IF(_password IS NOT NULL, PASSWORD(_password), password)
    WHERE users.id=l_user_id;
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE delete_self(_sid VARCHAR(36))
BEGIN
    DECLARE l_user_id INT(11) DEFAULT NULL;

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_authenticated(_sid);
    SELECT is_authenticated(_sid) INTO l_user_id;

    DELETE FROM users WHERE id=l_user_id AND role="admin";

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
	    SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'User is not player';
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
CREATE OR REPLACE PROCEDURE random_encounter(IN _sid VARCHAR(36))
BEGIN
    DECLARE l_player_id INT(11) DEFAULT NULL;

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_player(_sid);
    SELECT is_authenticated(_sid) INTO l_player_id;

    IF((SELECT COALESCE(tamed1_id, tamed2_id, tamed3_id, tamed4_id, tamed5_id) FROM frontliners WHERE player_id=l_player_id) IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Player have to set atleast one frontliner';
    END IF;

    IF((SELECT COUNT(battles.id) > 0 FROM battles WHERE (battles.player1_id = l_player_id OR battles.player2_id = l_player_id) AND battles.status="ongoing")) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'You already have an ongoing battle';
    END IF;

    SELECT AVG(monsters.base_next_xp), MAX(monsters.base_next_xp), AVG(tamed_monsters.xp), MAX(tamed_monsters.xp) INTO @avg_next_xp, @max_next_xp, @avg_xp, @max_xp
    FROM tamed_monsters
    JOIN monsters ON monsters.id = tamed_monsters.monster_id
    JOIN frontliners ON tamed_monsters.id IN (frontliners.tamed1_id, frontliners.tamed2_id, frontliners.tamed3_id, frontliners.tamed4_id, frontliners.tamed5_id)
    WHERE tamed_monsters.player_id=l_player_id;

    SET @rand1 = RAND();
    SET @rand2 = RAND();
    INSERT INTO battles (type, player1_id, enemy_monster_id, enemy_monster_xp, enemy_monster_health, status, xp_gain_percentage)
    SELECT 
    "pve",
    l_player_id,
    monsters.id,
    CAST(ROUND(@rand1*(monsters.base_next_xp + @avg_xp) + @rand2*@max_next_xp*0.01) AS INT),
    monsters.base_health * CAST(ROUND(@rand1*(monsters.base_next_xp + @avg_xp) + @rand2*@max_next_xp*0.01) AS INT),
    "ongoing",
    (CAST(ROUND(@rand1*(monsters.base_next_xp + @avg_xp) + @rand2*@max_next_xp*0.01) AS INT) + @avg_xp) / (CAST(ROUND(@rand1*(monsters.base_next_xp + @avg_xp) + @rand2*@max_next_xp*0.01) AS INT) + @max_xp)
    FROM monsters 
    WHERE 
    monsters.base_next_xp < (@avg_next_xp + @max_next_xp) 
    ORDER BY RAND()*monsters.base_next_xp LIMIT 1;

    SELECT LAST_INSERT_ID() AS battle_id;

    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE request_battle(IN _sid VARCHAR(36), IN _player2_id INT(11))
BEGIN
    DECLARE l_player1_id INT(11) DEFAULT NULL;

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_player(_sid);
    SELECT is_authenticated(_sid) INTO l_player1_id;

    IF((SELECT users.id FROM users WHERE users.id = _player2_id AND users.role = "player") IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Requested user is not player';
    END IF;

    IF(l_player1_id = _player2_id) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Cannot request a battle with yourself';
    END IF;

    IF((SELECT COALESCE(tamed1_id, tamed2_id, tamed3_id, tamed4_id, tamed5_id) FROM frontliners WHERE player_id=l_player1_id) IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Player have to set atleast one frontliner';
    END IF;

    INSERT INTO battle_requests (player1_id, player2_id, status) VALUES(l_player1_id, _player2_id, "pending");

    SELECT LAST_INSERT_ID() AS request_id;

    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE get_battle_requests(IN _sid VARCHAR(36))
BEGIN
    DECLARE l_player_id INT(11) DEFAULT NULL;

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_player(_sid);
    SELECT is_authenticated(_sid) INTO l_player_id;

    UPDATE battle_requests SET status="expired" WHERE (player1_id=l_player_id OR player2_id=l_player_id) AND status="pending" AND CURRENT_TIMESTAMP() >= expires_at;

    SELECT
    id,
    requested_at,
    expires_at,
    player1_id,
    player2_id,
    status
    FROM battle_requests WHERE (player1_id=l_player_id OR player2_id=l_player_id)
    ORDER BY requested_at DESC;

    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE reply_battle_request(IN _sid VARCHAR(36), IN _request_id INT(11), IN _reply TEXT)
BEGIN
    DECLARE l_player_id INT(11) DEFAULT NULL;

    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;

    CALL check_player(_sid);
    SELECT is_authenticated(_sid) INTO l_player_id;

    IF((SELECT id FROM battle_requests WHERE id=_request_id) IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Battle request does not exist';
    END IF;

    IF((SELECT id FROM battle_requests WHERE id=_request_id AND player1_id=l_player_id) IS NOT NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Player cannot accept their own battle request';
    END IF;

    IF((SELECT id FROM battle_requests WHERE id=_request_id AND player2_id=l_player_id) IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Player is not the requested player';
    END IF;

    IF((SELECT COALESCE(tamed1_id, tamed2_id, tamed3_id, tamed4_id, tamed5_id) FROM frontliners WHERE player_id=l_player_id) IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Player have to set atleast one frontliner';
    END IF;

    IF(
	(
	    SELECT 
	    COALESCE(tamed1_id, tamed2_id, tamed3_id, tamed4_id, tamed5_id) 
	    FROM frontliners 
	    WHERE 
	    player_id=(
		SELECT player1_id 
		FROM battle_requests 
		WHERE battle_requests.id=_request_id
	    )
	) IS NULL
    ) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Requesting player have to set atleast one frontliner';
    END IF;

    IF(_reply NOT IN ("accepted", "rejected")) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `reply` has to be either "accepted" or "rejected"';
    END IF;

    UPDATE battle_requests SET status="expired" WHERE id=_request_id AND status="pending" AND CURRENT_TIMESTAMP() >= expires_at;

    SELECT player1_id, player2_id, status INTO @player1_id, @player2_id, @status FROM battle_requests WHERE id=_request_id;
    IF(@status = "expired") THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Request expired';
    ELSEIF(@status != "pending") THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Request was already accepted/rejected';
    END IF;

    UPDATE battle_requests SET status=_reply WHERE id=_request_id AND status="pending";
    IF(_reply = "rejected") THEN
	SELECT NULL AS battle_id;
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

	SELECT LAST_INSERT_ID() AS battle_id;
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
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'User is not player';
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
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Frontliners cannot change while in battle';
    END IF;

    IF(_tamed1_id IS NULL AND _tamed2_id IS NULL AND _tamed3_id IS NULL AND _tamed4_id IS NULL AND _tamed5_id IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'There has to be at least 1 frontliner';
    END IF;

    IF(_tamed1_id IS NOT NULL AND IFNULL((SELECT tamed_monsters.player_id != _player_id FROM tamed_monsters WHERE tamed_monsters.id=_tamed1_id),TRUE)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = '1st frontliner doesn''t belong to player';
    END IF;
    IF(_tamed2_id IS NOT NULL AND IFNULL((SELECT tamed_monsters.player_id != _player_id FROM tamed_monsters WHERE tamed_monsters.id=_tamed2_id),TRUE)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = '2nd frontliner doesn''t belong to player';
    END IF;
    IF(_tamed4_id IS NOT NULL AND IFNULL((SELECT tamed_monsters.player_id != _player_id FROM tamed_monsters WHERE tamed_monsters.id=_tamed3_id),TRUE)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = '3rd frontliner doesn''t belong to player';
    END IF;
    IF(_tamed4_id IS NOT NULL AND IFNULL((SELECT tamed_monsters.player_id != _player_id FROM tamed_monsters WHERE tamed_monsters.id=_tamed4_id),TRUE)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = '4th frontliner doesn''t belong to player';
    END IF;
    IF(_tamed5_id IS NOT NULL AND IFNULL((SELECT tamed_monsters.player_id != _player_id FROM tamed_monsters WHERE tamed_monsters.id=_tamed5_id),TRUE)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = '5th frontliner doesn''t belong to player';
    END IF;

    IF(
	(_tamed1_id=_tamed2_id OR _tamed1_id=_tamed3_id OR _tamed1_id=_tamed4_id OR _tamed1_id=_tamed5_id) OR
	(_tamed2_id=_tamed3_id OR _tamed2_id=_tamed4_id OR _tamed2_id=_tamed5_id) OR
	(_tamed3_id=_tamed4_id OR _tamed3_id=_tamed5_id) OR
	(_tamed4_id=_tamed5_id)
    ) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'The same tamed monster cannot be in 2 or more frontliner slots';
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
CREATE OR REPLACE PROCEDURE set_frontliners_by_sid(IN _sid VARCHAR(36), IN _tamed1_id INT(11), IN _tamed2_id INT(11), IN _tamed3_id INT(11), IN _tamed4_id INT(11), IN _tamed5_id INT(11))
BEGIN
    declare exit handler for sqlexception
    begin
	rollback;
	RESIGNAL;
    end;
    START TRANSACTION;
    
    CALL check_player(_sid);
    CALL set_frontliners(
	(SELECT is_authenticated(_sid)), 
	_tamed1_id, 
	_tamed2_id,
	_tamed3_id,
	_tamed4_id,
	_tamed5_id
    );

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
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'User is not player';
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
	    SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'User is not player';
	END IF;

	IF((SELECT battles.id FROM battles WHERE battles.id=_battle_id) IS NULL) THEN
	    SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Battle does not exist';
	END IF;
	IF((SELECT battles.id FROM battles WHERE battles.id=_battle_id AND (battles.player1_id = _player_id OR battles.player2_id = _player_id)) IS NULL) THEN
	    SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Player is not in this battle';
	END IF;
	IF((SELECT battles.status != "ongoing" FROM battles WHERE battles.id=_battle_id)) THEN
	    SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Battle is already done';
	END IF;
	IF((SELECT tamed_monsters.id FROM tamed_monsters WHERE tamed_monsters.id=_tamed_id AND tamed_monsters.player_id = _player_id) IS NULL) THEN
	    SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Player does not own this tamed monster';
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
CREATE OR REPLACE PROCEDURE take_turn(IN _sid VARCHAR(36), IN _battle_id INT(11), IN _tamed_id INT(11), IN _action TEXT, IN _monster_skill_id INT(11))
proc_turn:BEGIN
    DECLARE l_player_id INT(11) DEFAULT NULL;

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

    CALL check_player(_sid);

    SELECT is_authenticated(_sid) INTO l_player_id;

    IF((SELECT battles.id FROM battles WHERE battles.id=_battle_id) IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Battle does not exist';
    END IF;
    IF((SELECT battles.id FROM battles WHERE battles.id=_battle_id AND (battles.player1_id = l_player_id OR battles.player2_id = l_player_id)) IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Player is not in this battle';
    END IF;
    IF((SELECT battles.status != "ongoing" FROM battles WHERE battles.id=_battle_id)) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Battle is already done';
    END IF;
    IF((SELECT tamed_monsters.id FROM tamed_monsters WHERE tamed_monsters.id=_tamed_id AND tamed_monsters.player_id = l_player_id) IS NULL) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Player does not own this tamed monster';
    END IF;
    IF(
	(
	    SELECT frontliners.id
	    FROM frontliners 
	    WHERE 
	    frontliners.player_id=l_player_id AND 
	    (
		frontliners.tamed1_id=_tamed_id OR 
		frontliners.tamed2_id=_tamed_id OR 
		frontliners.tamed3_id=_tamed_id OR 
		frontliners.tamed4_id=_tamed_id OR 
		frontliners.tamed5_id=_tamed_id
	    )
	) IS NULL
    ) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Tamed monster is not in frontliners';
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
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Tamed monster is not alive';
    END IF;

    IF(_action IS NULL OR _action NOT IN ("skill", "block", "forfeit")) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Field `action` has to be either "skill", "block", or "forfeit"';
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
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Tamed monster has/does not own this skill';
    END IF;

    SELECT 
    battles.player1_id=l_player_id, battles.type, IF(battles.type="pve", battles.enemy_monster_id, NULL) 
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
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Not player''s turn';
    END IF;

    IF(_action="block") THEN
	INSERT INTO turns (battle_id, type, tamed_id, action, monster_skill_id)
	VALUES (_battle_id, IF(l_is_player1, "player1", "player2"), _tamed_id, "block", NULL);

	SELECT SLEEP(1);
	CALL _initiate_enemy_turn(_battle_id, l_player_id, _tamed_id, TRUE);
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
	tamed_monsters.id = (SELECT tamed1_id FROM frontliners WHERE frontliners.player_id=l_player_id LIMIT 1) OR
	tamed_monsters.id = (SELECT tamed2_id FROM frontliners WHERE frontliners.player_id=l_player_id LIMIT 1) OR
	tamed_monsters.id = (SELECT tamed3_id FROM frontliners WHERE frontliners.player_id=l_player_id LIMIT 1) OR
	tamed_monsters.id = (SELECT tamed4_id FROM frontliners WHERE frontliners.player_id=l_player_id LIMIT 1) OR
	tamed_monsters.id = (SELECT tamed5_id FROM frontliners WHERE frontliners.player_id=l_player_id LIMIT 1);

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
	    SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'Skill is in cooldown';
	END IF;
    END IF;

    IF(l_skill_type="heal") THEN
	INSERT INTO turns (battle_id, type, tamed_id, action, monster_skill_id)
	VALUES (_battle_id, IF(l_is_player1, "player1", "player2"), _tamed_id, "skill", _monster_skill_id);

	UPDATE tamed_monsters SET current_health=LEAST(max_health, current_health+l_skill_value) WHERE tamed_monsters.id=_tamed_id;

	SELECT SLEEP(1);
	CALL _initiate_enemy_turn(_battle_id, l_player_id, _tamed_id, TRUE);
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
	    tamed_monsters.id = (SELECT tamed1_id FROM frontliners WHERE frontliners.player_id=l_player_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed2_id FROM frontliners WHERE frontliners.player_id=l_player_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed3_id FROM frontliners WHERE frontliners.player_id=l_player_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed4_id FROM frontliners WHERE frontliners.player_id=l_player_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed5_id FROM frontliners WHERE frontliners.player_id=l_player_id LIMIT 1);

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
	    tamed_monsters.id = (SELECT tamed1_id FROM frontliners WHERE frontliners.player_id=l_player_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed2_id FROM frontliners WHERE frontliners.player_id=l_player_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed3_id FROM frontliners WHERE frontliners.player_id=l_player_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed4_id FROM frontliners WHERE frontliners.player_id=l_player_id LIMIT 1) OR
	    tamed_monsters.id = (SELECT tamed5_id FROM frontliners WHERE frontliners.player_id=l_player_id LIMIT 1);

	    CALL tame_monster(
		(SELECT battles.enemy_monster_id FROM battles WHERE battles.id=_battle_id), 
		l_player_id, 
		(SELECT battles.enemy_monster_xp FROM battles WHERE battles.id=_battle_id)
	    );
	ELSE
	    SELECT SLEEP(1);
	    CALL _initiate_enemy_turn(_battle_id, l_player_id, _tamed_id, FALSE);
	END IF;
    END IF;
    COMMIT;
END$$
DELIMITER ;

-- FUNCTIONS
DELIMITER $$
CREATE OR REPLACE FUNCTION is_authenticated(IN _sid VARCHAR(36)) RETURNS INT(11)
BEGIN
    DECLARE l_user_id INT(11) DEFAULT NULL;

    SELECT 
    sessions.user_id INTO l_user_id
    FROM sessions 
    WHERE 
    CURRENT_TIMESTAMP() < sessions.expires_at AND
    sessions.id=_sid;

    DELETE FROM sessions
    WHERE
    CURRENT_TIMESTAMP() >= sessions.expires_at;
    
    RETURN l_user_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE FUNCTION is_admin(IN _sid VARCHAR(36)) RETURNS BOOLEAN
BEGIN
    RETURN (SELECT users.role = "admin" FROM users WHERE users.id=is_authenticated(_sid));
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE FUNCTION is_player(IN _sid VARCHAR(36)) RETURNS BOOLEAN
BEGIN
    IF((SELECT users.role != "player" FROM users WHERE users.id=is_authenticated(_sid)) = TRUE) THEN
	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'User is not admin';
    END IF;

    RETURN TRUE;
END$$
DELIMITER ;

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
