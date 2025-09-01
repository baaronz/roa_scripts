CREATE TABLE IF NOT EXISTS `prestige` (
    `guid` INT(10) UNSIGNED NOT NULL COMMENT 'Player GUID (low)',
    `level` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Prestige level',
    `points` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Available prestige points',
    `stamina` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Stamina stat level',
    `intellect` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Intellect stat level',
    `agility` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Agility stat level',
    `spirit` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Spirit stat level',
    `strength` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Strength stat level',
    `attackpower` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Attack Power stat level',
    `spellpower` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Spell Power stat level',
    `critrating` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Critical Rating stat level',
    `hitrating` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Hit Rating stat level',
    `hasterating` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Haste Rating stat level',
    `resistfire` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Fire Resistance stat level',
    `resistfrost` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Frost Resistance stat level',
    `resistnature` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Nature Resistance stat level',
    `resistshadow` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Shadow Resistance stat level',
    `resistarcane` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Arcane Resistance stat level',
    
    PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Prestige system data for players';
