-- phpMyAdmin SQL Dump
-- version 3.4.5deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Apr 26, 2012 at 03:03 PM
-- Server version: 5.1.62
-- PHP Version: 5.3.6-13ubuntu3.6

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `test`
--

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
  `zone_file_id` int(10) unsigned DEFAULT NULL,
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
  KEY `zone_file_id` (`zone_file_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=238 ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(45) DEFAULT NULL,
  `password` varchar(150) DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `created`) VALUES
(1, 'admin', 'c7ad44cbad762a5da0a452f9e854fdc1e0e7a52a38015f23f3eab1d80b931dd472634dfac71cd34ebc35d16ab7fb8a90c81f975113d6c7538dc69dd8de9077ec', '2012-02-22 13:24:12');

-- --------------------------------------------------------

--
-- Table structure for table `zone_files`
--

CREATE TABLE IF NOT EXISTS `zone_files` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=25 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
