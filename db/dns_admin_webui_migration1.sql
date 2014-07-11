RENAME TABLE  `dns_admins` TO  `dns_admins_` ;
RENAME TABLE  `dns_admins_zone_files` TO  `dns_admins_zone_files_` ;
RENAME TABLE  `records` TO  `records_` ;
RENAME TABLE  `users` TO  `users_` ;
RENAME TABLE  `zone_files` TO  `zone_files_` ;

-- phpMyAdmin SQL Dump
-- version 3.4.5deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Apr 26, 2012 at 02:05 PM
-- Server version: 5.1.62
-- PHP Version: 5.3.6-13ubuntu3.6

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `DNS_Admin_GUI`
--

-- --------------------------------------------------------

--
-- Table structure for table `commits`
--

CREATE TABLE IF NOT EXISTS `commits` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `zone_file_id` int(10) unsigned NOT NULL,
  `action` varchar(45) DEFAULT NULL,
  `diff_data` text,
  `request` text,
  `result` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `response` text,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=22 ;

-- --------------------------------------------------------

--
-- Table structure for table `dns_admins`
--

CREATE TABLE IF NOT EXISTS `dns_admins` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) DEFAULT NULL,
  `address` varchar(500) DEFAULT NULL,
  `user` varchar(100) DEFAULT NULL,
  `password` varchar(100) DEFAULT NULL,
  `use_ssl` tinyint(3) unsigned DEFAULT '1',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

-- --------------------------------------------------------

--
-- Table structure for table `dns_admins_zone_files`
--

CREATE TABLE IF NOT EXISTS `dns_admins_zone_files` (
  `dns_admin_id` int(10) unsigned NOT NULL,
  `zone_file_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`zone_file_id`,`dns_admin_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `records`
--

CREATE TABLE IF NOT EXISTS `records` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `group_id` int(10) unsigned NOT NULL DEFAULT '0',
  `previous_id` int(10) unsigned NOT NULL DEFAULT '0',
  `status` int(10) unsigned NOT NULL DEFAULT '0',
  `user_id` int(10) unsigned NOT NULL,
  `zone_file_group_id` int(10) unsigned DEFAULT NULL,
  `name` varchar(200) DEFAULT NULL,
  `ttl` varchar(45) DEFAULT NULL,
  `rclass` varchar(45) DEFAULT 'IN',
  `rtype` varchar(45) DEFAULT NULL,
  `data` text,
  `is_dirty` tinyint(3) unsigned DEFAULT '1',
  `order` int(10) unsigned NOT NULL DEFAULT '999999999',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `name` (`name`),
  KEY `zone_file_id` (`zone_file_group_id`),
  KEY `group_id` (`group_id`),
  KEY `previous_id` (`previous_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=243 ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(45) DEFAULT NULL,
  `password` varchar(150) DEFAULT NULL,
  `usertype` varchar(45) DEFAULT 'admin',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username_UNIQUE` (`username`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=501 ;

-- --------------------------------------------------------

--
-- Table structure for table `zone_files`
--

CREATE TABLE IF NOT EXISTS `zone_files` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `group_id` int(10) unsigned NOT NULL DEFAULT '0',
  `previous_id` int(10) unsigned NOT NULL DEFAULT '0',
  `status` int(10) unsigned NOT NULL DEFAULT '0',
  `user_id` int(10) unsigned NOT NULL,
  `label` varchar(200) DEFAULT NULL,
  `origin` varchar(200) DEFAULT NULL,
  `ttl` varchar(200) DEFAULT NULL,
  `address` varchar(200) DEFAULT NULL,
  `nameserver` varchar(200) DEFAULT NULL,
  `email` varchar(200) DEFAULT NULL,
  `serial_number` int(10) unsigned DEFAULT NULL,
  `slave_refresh` varchar(45) DEFAULT NULL,
  `slave_retry` varchar(45) DEFAULT NULL,
  `slave_expiration` varchar(45) DEFAULT NULL,
  `max_cache` varchar(45) DEFAULT NULL,
  `slaves` text,
  `is_dirty` tinyint(3) unsigned DEFAULT '1',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `group_id` (`group_id`),
  KEY `previous_id` (`previous_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=64 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

/* insert all users, add usertype 'root' */
INSERT INTO `users` (`id`, `username`, `password`, `usertype`, `created`) SELECT `users_`.`id`, `users_`.`username`, `users_`.`password`, 'root', `users_`.`created` FROM `users_`;

/* dns_admins */
INSERT INTO `dns_admins` (`id`, `name`, `address`, `user`, `password`, `use_ssl`, `created`) SELECT * FROM `dns_admins_`;

/* dns_admins_zone_files */
INSERT INTO `dns_admins_zone_files` (`dns_admin_id`, `zone_file_id`) SELECT * FROM `dns_admins_zone_files_`;

/* records */
INSERT INTO `records` (`id`, `group_id`, `user_id`, `zone_file_group_id`, `name`, `ttl`, `rclass`, `rtype`, `data`, `is_dirty`, `order`, `created`) SELECT `r`.`id`, `r`.`id`, 1, `r`.`zone_file_id`, `r`.`name`, `r`.`ttl`, `r`.`rclass`, `r`.`rtype`, `r`.`data`, `r`.`is_dirty`, `r`.`order`, `r`.`created` FROM `records_` AS `r`;

UPDATE `records` SET `user_id` = (SELECT `users`.`id` FROM `users` WHERE `usertype` = 'root' LIMIT 1);

/* zone_files */
INSERT INTO `zone_files` (`id`, `group_id`, `user_id`, `label`, `origin`, `ttl`, `address`, `nameserver`, `email`, `serial_number`, `slave_refresh`, `slave_retry`, `slave_expiration`, `max_cache`, `slaves`, `is_dirty`, `created`) SELECT `zf`.`id`, `zf`.`id`, 1, `zf`.`label`, `zf`.`origin`, `zf`.`ttl`, `zf`.`address`, `zf`.`nameserver`, `zf`.`email`, `zf`.`serial_number`, `zf`.`slave_refresh`, `zf`.`slave_retry`, `zf`.`slave_expiration`, `zf`.`max_cache`, `zf`.`slaves`, `zf`.`is_dirty`, `zf`.`created` FROM `zone_files_` AS `zf`;

UPDATE `zone_files` SET `user_id` = (SELECT `users`.`id` FROM `users` WHERE `usertype` = 'root' LIMIT 1);

DROP TABLE `users_`;
DROP TABLE `dns_admins_`;
DROP TABLE `dns_admins_zone_files_`;
DROP TABLE `records_`;
DROP TABLE `zone_files_`;

