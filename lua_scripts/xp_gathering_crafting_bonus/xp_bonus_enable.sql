CREATE TABLE IF NOT EXISTS `xp_bonus_enable` (
    `guid` INT(10) UNSIGNED NOT NULL,
    `num` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
