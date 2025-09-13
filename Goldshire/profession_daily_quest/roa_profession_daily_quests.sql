-- =============================================
-- Table: roa_profession_daily_quests
-- Description: Stores daily profession quests available to players
-- =============================================

CREATE TABLE IF NOT EXISTS `roa_profession_daily_quests` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `quest_id` int(10) unsigned NOT NULL COMMENT 'Quest ID from quest_template',
  `quest_name` varchar(255) NOT NULL COMMENT 'Display name of the quest',
  `description` text NOT NULL COMMENT 'Quest description shown in UI',
  `level_required` int(3) unsigned NOT NULL DEFAULT '1' COMMENT 'Minimum level required',
  `level_max` int(3) unsigned NOT NULL DEFAULT '80' COMMENT 'Maximum level allowed',
  `icon` varchar(255) NOT NULL DEFAULT 'Interface\\Icons\\INV_Misc_QuestionMark' COMMENT 'Quest icon path',
  `background_image` varchar(255) DEFAULT NULL COMMENT 'Optional background image path',
  `profession_type` varchar(50) DEFAULT NULL COMMENT 'Profession type (e.g., Mining, Herbalism, etc.)',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Order in which quests appear',
  `active` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT 'Whether quest is active (1) or disabled (0)',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_quest_id` (`quest_id`),
  KEY `idx_active_sort` (`active`, `sort_order`),
  KEY `idx_profession` (`profession_type`),
  KEY `idx_level_range` (`level_required`, `level_max`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Daily profession quests configuration';

-- =============================================
-- Sample data for testing
-- =============================================

INSERT INTO `roa_profession_daily_quests` 
(`quest_id`, `quest_name`, `description`, `level_required`, `level_max`, `icon`, `background_image`, `profession_type`, `sort_order`, `active`) 
VALUES
(1001, 'Mining Mastery', 'Collect 20 Iron Ore from various mining nodes across the world. This quest will test your mining skills and knowledge of ore locations.', 20, 80, 'Interface\\Icons\\INV_Ore_Iron_01', 'Interface\\Glues\\CharacterSelect\\Glues-CharacterSelect-Background', 'Mining', 1, 1),
(1002, 'Herbalist Challenge', 'Gather 15 Peacebloom and 10 Silverleaf from herb nodes. Show your expertise in identifying and collecting medicinal plants.', 15, 80, 'Interface\\Icons\\INV_Misc_Herb_01', 'Interface\\Glues\\CharacterSelect\\Glues-CharacterSelect-Background', 'Herbalism', 2, 1),
(1003, 'Skinning Expedition', 'Skin 25 beasts of various types to collect leather and hides. Your skinning knife will be put to the test!', 10, 80, 'Interface\\Icons\\INV_Misc_Pelt_Wolf_01', 'Interface\\Glues\\CharacterSelect\\Glues-CharacterSelect-Background', 'Skinning', 3, 1),
(1004, 'Engineering Innovation', 'Craft 5 Mechanical Squirrels using engineering schematics. Demonstrate your technical prowess and creativity.', 30, 80, 'Interface\\Icons\\INV_Misc_Gear_01', 'Interface\\Glues\\CharacterSelect\\Glues-CharacterSelect-Background', 'Engineering', 4, 1),
(1005, 'Alchemy Experiment', 'Brew 3 Healing Potions and 2 Mana Potions. Your knowledge of herbs and chemical reactions will be essential.', 25, 80, 'Interface\\Icons\\INV_Potion_01', 'Interface\\Glues\\CharacterSelect\\Glues-CharacterSelect-Background', 'Alchemy', 5, 1),
(1006, 'Blacksmithing Craft', 'Forge 2 Iron Swords and 1 Iron Shield. Show your mastery of metalworking and weapon crafting.', 20, 80, 'Interface\\Icons\\INV_Sword_01', 'Interface\\Glues\\CharacterSelect\\Glues-CharacterSelect-Background', 'Blacksmithing', 6, 1),
(1007, 'Tailoring Artistry', 'Sew 4 Linen Bags and 2 Woolen Cloaks. Your needlework skills and fabric knowledge will be tested.', 15, 80, 'Interface\\Icons\\INV_Fabric_Linen_01', 'Interface\\Glues\\CharacterSelect\\Glues-CharacterSelect-Background', 'Tailoring', 7, 1),
(1008, 'Leatherworking Mastery', 'Craft 3 Leather Armor pieces and 2 Leather Boots. Your expertise in working with animal hides is required.', 20, 80, 'Interface\\Icons\\INV_Misc_LeatherScrap_01', 'Interface\\Glues\\CharacterSelect\\Glues-CharacterSelect-Background', 'Leatherworking', 8, 1),
(1009, 'Enchanting Study', 'Enchant 5 items with various magical properties. Your understanding of arcane energies will be crucial.', 25, 80, 'Interface\\Icons\\INV_Enchant_Disenchant', 'Interface\\Glues\\CharacterSelect\\Glues-CharacterSelect-Background', 'Enchanting', 9, 1),
(1010, 'Jewelcrafting Precision', 'Cut 3 gems and create 2 rings. Your precision and knowledge of precious stones will be tested.', 30, 80, 'Interface\\Icons\\INV_Misc_Gem_01', 'Interface\\Glues\\CharacterSelect\\Glues-CharacterSelect-Background', 'Jewelcrafting', 10, 1),
(1011, 'Inscription Art', 'Create 4 scrolls and 2 glyphs using inscription techniques. Your mastery of magical writing is required.', 25, 80, 'Interface\\Icons\\INV_Inscription_Tradeskill01', 'Interface\\Glues\\CharacterSelect\\Glues-CharacterSelect-Background', 'Inscription', 11, 1),
(1012, 'Cooking Delicacy', 'Prepare 3 different dishes using various ingredients. Your culinary skills and recipe knowledge will be tested.', 10, 80, 'Interface\\Icons\\INV_Misc_Food_01', 'Interface\\Glues\\CharacterSelect\\Glues-CharacterSelect-Background', 'Cooking', 12, 1),
(1013, 'First Aid Practice', 'Create 5 bandages and 3 healing potions. Your knowledge of medical techniques and herbs is essential.', 15, 80, 'Interface\\Icons\\INV_Misc_Bandage_01', 'Interface\\Glues\\CharacterSelect\\Glues-CharacterSelect-Background', 'First Aid', 13, 1),
(1014, 'Fishing Expedition', 'Catch 20 fish of various types from different fishing spots. Your patience and fishing skills will be rewarded.', 5, 80, 'Interface\\Icons\\INV_Fishingpole_01', 'Interface\\Glues\\CharacterSelect\\Glues-CharacterSelect-Background', 'Fishing', 14, 1),
(1015, 'Archaeology Discovery', 'Excavate 10 artifacts from ancient sites. Your knowledge of history and careful excavation techniques are required.', 20, 80, 'Interface\\Icons\\INV_Misc_Shovel_01', 'Interface\\Glues\\CharacterSelect\\Glues-CharacterSelect-Background', 'Archaeology', 15, 1);

-- =============================================
-- Notes for implementation:
-- =============================================
-- 1. Make sure the quest IDs (1001-1015) exist in your quest_template table
-- 2. Set the quest flags to include QUEST_FLAGS_DAILY (4096) in quest_template
-- 3. The character_queststatus_daily table will automatically track completion
-- 4. Players can only complete 2 daily quests per day as implemented in the Lua script
-- 5. Adjust level requirements and quest IDs according to your server's needs
-- 6. The script will automatically filter quests based on player level and completion status
