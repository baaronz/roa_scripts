-- Heroes Call Board Quests Table
-- This table stores quest information for the Heroes Call Board system

CREATE TABLE IF NOT EXISTS `heroes_call_board_quests` (
  `quest_id` INT(11) NOT NULL,
  `quest_name` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `level_required` INT(11) NOT NULL DEFAULT 1,
  `level_max` INT(11) NOT NULL DEFAULT 80,
  `icon` VARCHAR(255) DEFAULT NULL,
  `background_image` VARCHAR(255) DEFAULT NULL,
  `active` TINYINT(1) NOT NULL DEFAULT 1,
  `sort_order` INT(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`quest_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Example entries (commented out)
-- INSERT INTO `heroes_call_board_quests` (`quest_id`, `quest_name`, `description`, `level_required`, `level_max`, `icon`, `background_image`, `active`, `sort_order`) VALUES
-- (1, 'Sample Quest 1', 'This is a sample quest description for testing purposes.', 10, 20, 'Interface\\Icons\\INV_Misc_QuestionMark', 'Interface\\DialogFrame\\UI-DialogBox-Background', 1, 1),
-- (2, 'Sample Quest 2', 'Another sample quest description for testing.', 15, 25, 'Interface\\Icons\\INV_Misc_QuestionMark', 'Interface\\DialogFrame\\UI-DialogBox-Background', 1, 2);
