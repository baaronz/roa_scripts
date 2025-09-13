CREATE TABLE IF NOT EXISTS `profession_daily_quests` (
  `quest_id` INT(11) NOT NULL,
  `quest_name` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `level_required` INT(11) NOT NULL DEFAULT 1,
  `level_max` INT(11) NOT NULL DEFAULT 80,
  `profession_type` VARCHAR(50) NOT NULL DEFAULT 'General',
  `icon` VARCHAR(255) DEFAULT 'Interface\\Icons\\INV_Misc_QuestionMark',
  `background_image` VARCHAR(255) DEFAULT NULL,
  `reward_gold` INT(11) NOT NULL DEFAULT 0,
  `reward_xp` INT(11) NOT NULL DEFAULT 0,
  `active` TINYINT(1) NOT NULL DEFAULT 1,
  `sort_order` INT(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`quest_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `player_daily_quest_progress` (
  `player_guid` INT(11) NOT NULL,
  `quest_id` INT(11) NOT NULL,
  `date_taken` DATE NOT NULL,
  `status` ENUM('taken', 'completed') NOT NULL DEFAULT 'taken',
  `taken_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`player_guid`, `quest_id`, `date_taken`),
  FOREIGN KEY (`quest_id`) REFERENCES `profession_daily_quests`(`quest_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
