-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 09, 2026 at 11:27 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `skillswap`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `username` varchar(255) NOT NULL,
  `phoneNumber` int(11) NOT NULL,
  `passwordHash` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `firstName` varchar(255) NOT NULL,
  `lastName` varchar(255) NOT NULL,
  `dateRegistered` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`username`, `phoneNumber`, `passwordHash`, `email`, `firstName`, `lastName`, `dateRegistered`) VALUES
('Admin', 1274000514, '$2a$10$DoBjsrUDaVs1Wwghk6rBPOp/OinVcL9v0A31p6j9LeGtDBNBKzsWi', 'kwroshdy33@gmail.com', 'Admin', '2025', '2025-05-22 11:06:54'),
('admin1', 1274000516, '$2a$10$ykEhKzjL3qCNGsx//8tx5OIBidHJtzK5f2GYezgbdvHpft4kJswrG', 'nermeen.ghaly76@gmail.com', 'Admin1', '2025', '2025-05-20 18:29:22'),
('nono', 1836357153, '$2a$10$ChDHooZYI1JpCdisJ3dSaO1DZz.e2cTikvGRLkDFpJilGvrjItHxu', 'youannamorcosccit@gmail.com', 'Nono', 'G', '2025-09-09 14:23:32');

-- --------------------------------------------------------

--
-- Table structure for table `remembertokens`
--

CREATE TABLE `remembertokens` (
  `selector` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `validatorHash` varchar(255) NOT NULL,
  `expiryDate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `skill`
--

CREATE TABLE `skill` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `category` varchar(255) NOT NULL,
  `description` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `skill`
--

INSERT INTO `skill` (`id`, `name`, `category`, `description`) VALUES
(1, 'Baking', 'Culinary', 'Creating delicious baked goods like bread, cakes, and pastries.'),
(2, 'Java Programming', 'Technology', 'Developing applications using the Java programming language.'),
(3, 'Graphic Design', 'Creative', 'Creating visual concepts using computer software or by hand.'),
(4, 'Content Writing', 'Communication', 'Writing engaging and informative content for various platforms.'),
(5, 'Project Management', 'Business', 'Planning, organizing, and managing resources to achieve specific goals.'),
(6, 'Data Analysis', 'Technology', 'Inspecting, cleansing, transforming, and modeling data to discover useful information.'),
(7, 'SQL', 'Technology', 'Managing and querying relational databases using Structured Query Language.'),
(8, 'Gardening', 'Lifestyle', 'Cultivating plants, flowers, fruits, and vegetables.'),
(9, 'Photography', 'Creative', 'Capturing images using a camera.'),
(10, 'Knitting', 'Crafts', 'Creating fabric by interlocking loops of yarn using knitting needles.'),
(11, 'Sewing', 'Crafts', 'Joining fabrics using a needle and thread or a sewing machine.'),
(12, 'Public Speaking', 'Communication', 'Delivering speeches or presentations to an audience.'),
(13, 'Video Editing', 'Creative', 'Manipulating and rearranging video shots to create a new work.'),
(14, 'Financial Budgeting', 'Personal Finance', 'Planning how to spend your money.'),
(15, 'Guitar Playing', 'Music', 'Playing the guitar, including chords, melodies, and techniques.'),
(16, 'Digital Marketing', 'Business', 'Promoting products or services using digital channels.');

-- --------------------------------------------------------

--
-- Table structure for table `swap`
--

CREATE TABLE `swap` (
  `id` int(11) NOT NULL,
  `requesterUsername` varchar(255) NOT NULL,
  `providerUsername` varchar(255) NOT NULL,
  `offeredSkillId` int(11) NOT NULL,
  `pointsExchanged` int(11) NOT NULL DEFAULT 0,
  `status` varchar(50) NOT NULL DEFAULT 'Proposed',
  `requestDate` timestamp NOT NULL DEFAULT current_timestamp(),
  `lastUpdatedDate` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `swap`
--

INSERT INTO `swap` (`id`, `requesterUsername`, `providerUsername`, `offeredSkillId`, `pointsExchanged`, `status`, `requestDate`, `lastUpdatedDate`) VALUES
(1, 'Anna', 'kami22', 16, 10, 'ACCEPTED', '2025-05-21 22:17:02', '2025-05-22 00:44:18'),
(2, 'Anna', 'kami22', 16, 10, 'COMPLETED', '2025-05-21 23:55:08', '2025-05-22 00:43:37'),
(3, 'kami22', 'Anna', 1, 13, 'COMPLETED', '2025-05-21 23:56:35', '2025-05-22 00:24:01'),
(4, 'Youanna', 'Anna', 11, 20, 'ACCEPTED', '2025-05-22 01:06:56', '2025-05-22 01:08:14'),
(5, 'Anna', 'Youanna', 7, 25, 'ACCEPTED', '2025-05-22 01:21:24', '2025-05-22 01:22:30'),
(6, 'Youanna', 'Anna', 11, 15, 'ACCEPTED', '2025-05-22 01:33:12', '2025-05-22 01:38:10'),
(7, 'Anna', 'kami22', 3, 10, 'ACCEPTED', '2025-05-22 01:42:04', '2025-05-22 01:42:42'),
(8, 'kami22', 'Youanna', 15, 45, 'COMPLETED', '2025-05-22 01:43:03', '2025-05-22 05:35:51'),
(9, 'Anna', 'Youanna', 1, 65, 'ACCEPTED', '2025-05-22 01:51:36', '2025-05-22 01:55:14'),
(10, 'Anna', 'Youanna', 15, 50, 'ACCEPTED', '2025-05-22 04:50:32', '2025-05-22 05:17:24'),
(11, 'kami22', 'Anna', 6, 30, 'ACCEPTED', '2025-05-22 05:09:09', '2025-05-22 05:09:46'),
(12, 'kami22', 'Anna', 16, 24, 'ACCEPTED', '2025-05-22 05:28:13', '2025-05-22 08:42:44'),
(13, 'Youanna', 'kami22', 16, 50, 'ACCEPTED', '2025-05-22 05:38:34', '2025-05-22 05:39:10'),
(14, 'Anna', 'kami22', 5, 20, 'ACCEPTED', '2025-05-22 05:46:57', '2025-05-22 05:47:36'),
(15, 'Anna', 'kami22', 5, 20, 'ACCEPTED', '2025-05-22 05:46:59', '2025-05-22 08:49:31'),
(16, 'kami22', 'Anna', 4, 10, 'ACCEPTED', '2025-05-22 06:28:29', '2025-05-22 08:37:39'),
(17, 'kami22', 'Anna', 4, 10, 'ACCEPTED', '2025-05-22 08:51:31', '2025-05-22 08:52:21'),
(18, 'kami22', 'Anna', 7, 34, 'ACCEPTED', '2025-05-22 08:51:43', '2025-05-22 08:56:39'),
(19, 'kami22', 'Anna', 6, 90, 'ACCEPTED', '2025-05-22 09:02:16', '2025-05-22 09:03:19'),
(20, 'kami22', 'Anna', 1, 87, 'ACCEPTED', '2025-05-22 09:02:31', '2025-05-22 09:11:17'),
(21, 'Anna', 'kami22', 16, 30, 'ACCEPTED', '2025-05-22 09:21:54', '2025-05-22 09:22:57'),
(22, 'Anna', 'kami22', 12, 45, 'ACCEPTED', '2025-05-22 09:22:08', '2025-05-22 09:28:04'),
(23, 'Anna', 'kami22', 5, 90, 'ACCEPTED', '2025-05-22 09:32:49', '2025-05-22 09:39:43'),
(24, 'Anna', 'kami22', 3, 100, 'ACCEPTED', '2025-05-22 09:33:04', '2025-05-22 09:33:39'),
(25, 'kami22', 'Anna', 1, 10, 'ACCEPTED', '2025-05-22 09:54:52', '2025-05-22 09:55:34'),
(26, 'kami22', 'Anna', 7, 20, 'PROPOSED', '2025-05-22 09:55:08', '2025-05-22 09:55:08'),
(27, 'Jana', 'kami22', 12, 100, 'PROPOSED', '2025-05-22 10:17:07', '2025-05-22 10:17:07'),
(28, 'Maiada', 'Jana', 1, 30, 'PROPOSED', '2025-05-22 10:55:38', '2025-05-22 10:55:38'),
(29, 'Maiada', 'kami22', 12, 50, 'COMPLETED', '2025-05-22 10:58:49', '2025-05-22 11:21:25'),
(30, 'Anna', 'Jana', 1, 10, 'ACCEPTED', '2025-05-22 11:13:21', '2025-05-22 14:51:52'),
(31, 'Anna', 'kami22', 16, 50, 'COMPLETED', '2025-05-22 11:14:03', '2025-05-22 11:16:21'),
(32, 'kami22', 'Jana', 14, 10, 'PROPOSED', '2025-05-22 11:20:52', '2025-05-22 11:20:52'),
(33, 'Youanna', 'Anna', 14, 10, 'ACCEPTED', '2025-05-22 17:51:36', '2025-05-22 17:52:58'),
(34, 'Anna', 'kami22', 5, 10, 'ACCEPTED', '2025-05-22 22:10:04', '2025-05-26 13:18:46'),
(35, 'Anna', 'kami22', 16, 70, 'ACCEPTED', '2025-05-26 13:23:37', '2025-05-26 13:26:21'),
(36, 'Anna', 'Jana', 13, 50, 'CANCELLED', '2025-05-26 13:23:56', '2025-05-26 13:24:44'),
(37, 'Anna', 'Youanna', 2, 40, 'PROPOSED', '2025-05-27 04:22:12', '2025-05-27 04:22:12'),
(38, 'Khalila', 'Anna', 8, 46, 'ACCEPTED', '2025-09-09 14:16:46', '2025-09-09 14:17:41'),
(39, 'sandra', 'Anna', 14, 50, 'ACCEPTED', '2025-10-30 22:43:58', '2025-10-30 22:45:21'),
(40, 'Anna', 'Khalila', 16, 20, 'PROPOSED', '2025-12-03 15:56:57', '2025-12-03 15:56:57');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `username` varchar(255) NOT NULL,
  `phoneNumber` int(11) NOT NULL,
  `passwordHash` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `firstName` varchar(255) NOT NULL,
  `lastName` varchar(255) NOT NULL,
  `dateRegistered` timestamp NOT NULL DEFAULT current_timestamp(),
  `points` int(11) NOT NULL DEFAULT 0,
  `skills` text DEFAULT NULL,
  `isEmailVerified` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`username`, `phoneNumber`, `passwordHash`, `email`, `firstName`, `lastName`, `dateRegistered`, `points`, `skills`, `isEmailVerified`) VALUES
('Anna', 0, '$2a$10$DXcTqWxVgcmCZnwX5IYzFucs8x8Tmywfad9yOZ0URlmjBXdcfYBZa', 'anna.gendy@gmail.com', 'Youanna', 'Morcos', '2025-05-19 19:21:36', 134, '16,12,11,3,1,8,14,6,2,7', 1),
('Jana', 1274000510, '$2a$10$X6jeYDxbucn4gLyLFGCJk.dgTjgvcqhQawzn8SGOrZ7FBDsye5VNK', 'janahamza053@gmail.com', 'Jana', 'Ayman', '2025-05-22 09:59:45', 310, '13,1,14,2', 1),
('kami22', 1020474222, '$2a$10$jCLVYDGblRCfcNBl3GyEQ.5XVbLZV7De3RniLtkWEYyPVVvyQ6LVu', 'kamiliariad33@gmail.com', 'Kmailia', 'Riad', '2025-05-19 18:15:57', 512, '16,5,12,3', 1),
('Khalila', 1753647668, '$2a$10$/ckrBnHrZZvjQ0.Ks7oBt.77pE8RlJzCxt9oIgRlqAZCHl/iN858m', 'ahmedemadk3@gmail.com', 'Ahmed', 'Khalil', '2025-09-09 14:14:28', 254, '16,9,14,2', 1),
('Maiada', 1221118104, '$2a$10$qmdf9f8S2oWIbW/aDvC6h.hKE.sFN4BYThiVEo4KYcFAvYZhQSuxa', 'eng.maiada.aast@gmail.com', 'Dr Maiada', 'Advanced', '2025-05-21 07:36:57', 250, '16,5,12,6,2,7', 1),
('sandra', 1000000000, '$2a$10$JOd5egIzCO3TdT1WbbpgG.PWqztt9NrLpQd1ShtNAstClkyAogNOq', 'sandrawaelgamil@gmail.com', 'sandra', 'khalil', '2025-10-30 22:39:19', 250, '11,3,1,14,6,2', 1),
('Youanna', 1274000518, '$2a$10$6XYXzfmRXDJbLixb0yy3OO3qkO3vGmmmfV5DzABT1mAvr7NnNfPP2', 'youannamorcosccit@gmail.com', 'Youanna2', 'Morcos2', '2025-05-22 01:04:02', 390, '1,8,15,2,7', 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `remembertokens`
--
ALTER TABLE `remembertokens`
  ADD PRIMARY KEY (`selector`),
  ADD KEY `username` (`username`);

--
-- Indexes for table `skill`
--
ALTER TABLE `skill`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `swap`
--
ALTER TABLE `swap`
  ADD PRIMARY KEY (`id`),
  ADD KEY `requesterUsername` (`requesterUsername`),
  ADD KEY `providerUsername` (`providerUsername`),
  ADD KEY `offeredSkillId` (`offeredSkillId`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `skill`
--
ALTER TABLE `skill`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `swap`
--
ALTER TABLE `swap`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `remembertokens`
--
ALTER TABLE `remembertokens`
  ADD CONSTRAINT `remembertokens_ibfk_1` FOREIGN KEY (`username`) REFERENCES `users` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `swap`
--
ALTER TABLE `swap`
  ADD CONSTRAINT `swap_ibfk_1` FOREIGN KEY (`requesterUsername`) REFERENCES `users` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `swap_ibfk_2` FOREIGN KEY (`providerUsername`) REFERENCES `users` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `swap_ibfk_3` FOREIGN KEY (`offeredSkillId`) REFERENCES `skill` (`id`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
