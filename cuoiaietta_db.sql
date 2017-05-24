-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Creato il: Mag 24, 2017 alle 23:11
-- Versione del server: 10.1.21-MariaDB
-- Versione PHP: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `cuoiaietta_db`
--

-- --------------------------------------------------------

--
-- Struttura della tabella `challenges`
--

CREATE TABLE `challenges` (
  `id` int(11) NOT NULL,
  `poem_id` int(11) NOT NULL,
  `position` int(11) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `verse_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `challenges`
--

INSERT INTO `challenges` (`id`, `poem_id`, `position`, `start_date`, `end_date`, `verse_id`) VALUES
(1, 1, 0, '2017-05-24 12:00:00', '2017-05-24 15:00:00', 1),
(2, 1, 1, '2017-05-24 15:00:00', '2017-05-24 18:00:00', 4),
(3, 1, 2, '2017-05-24 18:00:00', '2017-05-24 21:00:00', 6),
(4, 1, 3, '2017-05-24 21:00:00', '2017-05-25 00:00:00', NULL);

-- --------------------------------------------------------

--
-- Struttura della tabella `poems`
--

CREATE TABLE `poems` (
  `id` int(11) NOT NULL,
  `type_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `creation_date` datetime NOT NULL,
  `status` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `poems`
--

INSERT INTO `poems` (`id`, `type_id`, `title`, `creation_date`, `status`) VALUES
(1, 2, 'Le vacanze di Apulejo', '2017-05-24 20:00:00', 1);

-- --------------------------------------------------------

--
-- Struttura della tabella `poem_types`
--

CREATE TABLE `poem_types` (
  `id` int(11) NOT NULL,
  `type_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- Dump dei dati per la tabella `poem_types`
--

INSERT INTO `poem_types` (`id`, `type_name`) VALUES
(1, 'Cantica in terza rima'),
(2, 'Sonetto');

-- --------------------------------------------------------

--
-- Struttura della tabella `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `user_name` varchar(50) NOT NULL,
  `email_address` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `users`
--

INSERT INTO `users` (`id`, `user_name`, `email_address`, `password_hash`) VALUES
(1, 'emiliano.vicari', 'emilio.vicari@gmail.com', 'sfnkljfhgl'),
(2, 'lorenzo.barberini', 'lorenzo.barberini84@gmail.com', 'sfnkljfhfgl');

-- --------------------------------------------------------

--
-- Struttura della tabella `verses`
--

CREATE TABLE `verses` (
  `id` int(11) NOT NULL,
  `challenge_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `creation_date` datetime NOT NULL,
  `verse_text` varchar(255) NOT NULL,
  `status` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `verses`
--

INSERT INTO `verses` (`id`, `challenge_id`, `user_id`, `creation_date`, `verse_text`, `status`) VALUES
(1, 1, 1, '2017-05-24 12:28:00', 'Nel mezzo del camin di nonna Rita', 0),
(2, 1, 2, '2017-05-24 12:32:00', 'Trovaimi nell\'inquieto della rupe', 0),
(3, 2, 1, '2017-05-24 15:28:00', 'Cablavo reti elettriche dolenti', 0),
(4, 2, 2, '2017-05-24 15:32:00', 'Sfoggiavo il manto fiero del vitello', 0),
(5, 3, 1, '2017-05-24 18:28:00', 'Mancando intorno un manto un po\' più bello', 0),
(6, 3, 2, '2017-05-24 18:32:00', 'Portando in man l\'attrezzo del rastrello', 0),
(7, 4, 1, '2017-05-24 21:28:00', 'Colpivo l\'ava verso miglior vita', 0),
(8, 4, 2, '2017-05-24 21:32:00', 'Coglievo foglia secca e colorita', 0);

-- --------------------------------------------------------

--
-- Struttura stand-in per le viste `view_poem_verses`
-- (Vedi sotto per la vista effettiva)
--
CREATE TABLE `view_poem_verses` (
`poem_id` int(11)
,`poem_title` varchar(255)
,`position` int(11)
,`verse_text` varchar(255)
);

-- --------------------------------------------------------

--
-- Struttura della tabella `votes`
--

CREATE TABLE `votes` (
  `id` int(11) NOT NULL,
  `verse_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date_cast` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `votes`
--

INSERT INTO `votes` (`id`, `verse_id`, `user_id`, `date_cast`) VALUES
(2, 1, 2, '2017-05-24 13:00:00'),
(3, 4, 1, '2017-05-24 16:00:00'),
(4, 6, 1, '2017-05-24 19:00:00');

-- --------------------------------------------------------

--
-- Struttura per la vista `view_poem_verses`
--
DROP TABLE IF EXISTS `view_poem_verses`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_poem_verses`  AS  select `p`.`id` AS `poem_id`,`p`.`title` AS `poem_title`,`c`.`position` AS `position`,`v`.`verse_text` AS `verse_text` from ((`poems` `p` join `challenges` `c` on((`c`.`poem_id` = `p`.`id`))) join `verses` `v` on((`v`.`id` = `c`.`verse_id`))) ;

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `challenges`
--
ALTER TABLE `challenges`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `IX_POEM_POSITION` (`poem_id`,`position`),
  ADD KEY `FK_CHALLENGE_VERSE` (`verse_id`);

--
-- Indici per le tabelle `poems`
--
ALTER TABLE `poems`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK_POEMS_POEM_TYPES` (`type_id`);

--
-- Indici per le tabelle `poem_types`
--
ALTER TABLE `poem_types`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `IX_USER_NAME` (`user_name`),
  ADD UNIQUE KEY `IX_EMAIL_ADDRESS` (`email_address`);

--
-- Indici per le tabelle `verses`
--
ALTER TABLE `verses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `IX_CHALLENGE_USER` (`challenge_id`,`user_id`),
  ADD KEY `FK_VERSE_USER` (`user_id`);

--
-- Indici per le tabelle `votes`
--
ALTER TABLE `votes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `verse_id` (`verse_id`),
  ADD KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT per le tabelle scaricate
--

--
-- AUTO_INCREMENT per la tabella `challenges`
--
ALTER TABLE `challenges`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT per la tabella `poems`
--
ALTER TABLE `poems`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT per la tabella `poem_types`
--
ALTER TABLE `poem_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT per la tabella `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT per la tabella `verses`
--
ALTER TABLE `verses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT per la tabella `votes`
--
ALTER TABLE `votes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `challenges`
--
ALTER TABLE `challenges`
  ADD CONSTRAINT `FK_CHALLENGE_POEM` FOREIGN KEY (`poem_id`) REFERENCES `poems` (`id`),
  ADD CONSTRAINT `FK_CHALLENGE_VERSE` FOREIGN KEY (`verse_id`) REFERENCES `verses` (`id`);

--
-- Limiti per la tabella `poems`
--
ALTER TABLE `poems`
  ADD CONSTRAINT `FK_POEMS_POEM_TYPES` FOREIGN KEY (`type_id`) REFERENCES `poem_types` (`id`);

--
-- Limiti per la tabella `verses`
--
ALTER TABLE `verses`
  ADD CONSTRAINT `FK_VERSE_CHALLENGE` FOREIGN KEY (`challenge_id`) REFERENCES `challenges` (`id`),
  ADD CONSTRAINT `FK_VERSE_USER` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Limiti per la tabella `votes`
--
ALTER TABLE `votes`
  ADD CONSTRAINT `votes_ibfk_1` FOREIGN KEY (`verse_id`) REFERENCES `verses` (`id`),
  ADD CONSTRAINT `votes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
