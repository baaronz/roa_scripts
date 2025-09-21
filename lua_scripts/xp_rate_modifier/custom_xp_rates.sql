CREATE TABLE IF NOT EXISTS `custom_xp_rates` (
    `guid` INT(10) UNSIGNED NOT NULL COMMENT 'Player GUID (primary key)',
    `xp_rate` FLOAT NOT NULL DEFAULT 1.0 COMMENT 'XP rate multiplier (0.1 to 100.0)',
    `override` TINYINT(1) UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Override flag (0 = disabled, 1 = enabled)',
    `enabler` TINYINT(1) UNSIGNED NOT NULL DEFAULT 1 COMMENT 'XP gain enabler (0 = disabled, 1 = enabled)',
    PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Custom XP rates for players';
