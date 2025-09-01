-- XP Bonus Enable Table for Crafting and Gathering System
-- This table stores player preferences for enabling/disabling bonus XP from crafting and gathering activities

-- Create the table if it doesn't exist
CREATE TABLE IF NOT EXISTS `xp_bonus_enable` (
    `guid` INT(10) UNSIGNED NOT NULL,
    `num` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add index for better performance on guid lookups
CREATE INDEX IF NOT EXISTS `idx_xp_bonus_enable_guid` ON `xp_bonus_enable` (`guid`);

-- Optional: Add some sample data for testing (uncomment if needed)
-- INSERT INTO `xp_bonus_enable` (`guid`, `num`) VALUES 
-- (1, 1),
-- (2, 0),
-- (3, 1)
-- ON DUPLICATE KEY UPDATE `num` = VALUES(`num`);

-- Table description:
-- guid: Player's GUID (character identifier)
-- num: 0 = disabled, 1 = enabled (default is 1)
-- 
-- This table works with the ROA_exp_for_crafting_gathering.lua script
-- which provides bonus XP for crafting and gathering activities
-- based on player level and their preference setting.
