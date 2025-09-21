CREATE TABLE IF NOT EXISTS `account_wide_spells` (
    `account_id` INT(10) UNSIGNED NOT NULL COMMENT 'Account ID',
    `spell_id` INT(10) UNSIGNED NOT NULL COMMENT 'Spell ID to be taught account-wide',
    `learned_by_character` INT(10) UNSIGNED NOT NULL COMMENT 'Character GUID who first learned the spell',
    `learned_timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When the spell was first learned',
    `taught_to_all` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Whether all characters have been taught this spell',
    
    PRIMARY KEY (`account_id`, `spell_id`),
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Account-wide spell learning system';
