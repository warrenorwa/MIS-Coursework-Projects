-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 02, 2026 at 06:06 PM
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
-- Database: `wellmeadows`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `PrescribeMedication` (IN `p_AdmissionID` INT, IN `p_DrugNumber` INT, IN `p_StartDate` DATE, IN `p_Dosage` VARCHAR(50), IN `p_MethodOfAdmin` VARCHAR(20), IN `p_UnitsPerDay` INT, IN `p_FinishDate` DATE, IN `p_StaffID` INT)   BEGIN
    DECLARE v_QuantityNeeded INT;
    DECLARE v_CurrentStock INT;
    SET v_QuantityNeeded = p_UnitsPerDay * DATEDIFF(p_FinishDate, p_StartDate);
    -- get current stock via the function (per project spec)
    SET v_CurrentStock = CheckMedicationStock(p_DrugNumber);
    START TRANSACTION;
    IF v_CurrentStock >= v_QuantityNeeded THEN
        INSERT INTO Prescription
            (AdmissionID, DrugNumber, StartDate, Dosage, MethodOfAdmin, UnitsPerDay, FinishDate, StaffID)
        VALUES
            (p_AdmissionID, p_DrugNumber, p_StartDate, p_Dosage, p_MethodOfAdmin, p_UnitsPerDay, p_FinishDate, p_StaffID);
        UPDATE Medication
        SET QuantityInStock = QuantityInStock - v_QuantityNeeded
        WHERE DrugNumber = p_DrugNumber;
        COMMIT;
    ELSE
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient medication stock to fulfil this prescription.';
    END IF;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `CheckMedicationStock` (`p_DrugNumber` INT) RETURNS INT(11) DETERMINISTIC READS SQL DATA BEGIN
    DECLARE v_CurrentStock INT;
    SELECT QuantityInStock INTO v_CurrentStock
    FROM Medication
    WHERE DrugNumber = p_DrugNumber;
    RETURN v_CurrentStock;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admission`
--

CREATE TABLE `admission` (
  `AdmissionID` int(11) NOT NULL,
  `PatientNumber` varchar(10) NOT NULL,
  `WardNumber` int(11) NOT NULL,
  `BedNumber` int(11) NOT NULL,
  `AdmissionDate` date NOT NULL,
  `DischargeDate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admission`
--

INSERT INTO `admission` (`AdmissionID`, `PatientNumber`, `WardNumber`, `BedNumber`, `AdmissionDate`, `DischargeDate`) VALUES
(1, 'P10034', 11, 84, '2013-03-20', '2014-05-05'),
(2, 'P10045', 5, 1, '2025-01-10', NULL),
(3, 'P10052', 3, 2, '2025-02-15', '2025-02-28'),
(4, 'P10061', 7, 10, '2025-03-01', NULL),
(5, 'P10078', 11, 85, '2025-03-10', '2025-03-20');

-- --------------------------------------------------------

--
-- Table structure for table `bed`
--

CREATE TABLE `bed` (
  `WardNumber` int(11) NOT NULL,
  `BedNumber` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bed`
--

INSERT INTO `bed` (`WardNumber`, `BedNumber`) VALUES
(3, 1),
(3, 2),
(5, 1),
(5, 2),
(7, 10),
(7, 11),
(11, 84),
(11, 85),
(11, 86);

-- --------------------------------------------------------

--
-- Table structure for table `medication`
--

CREATE TABLE `medication` (
  `DrugNumber` int(11) NOT NULL,
  `DrugName` varchar(100) NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `QuantityInStock` int(11) NOT NULL DEFAULT 0,
  `ReorderLevel` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `medication`
--

INSERT INTO `medication` (`DrugNumber`, `DrugName`, `Description`, `QuantityInStock`, `ReorderLevel`) VALUES
(10223, 'Morphine', 'Pain Killer', 500, 100),
(10334, 'Tetracycline', 'Antibiotic', 40, 50),
(10445, 'Paracetamol', 'Pain Killer', 1000, 200),
(10556, 'Amoxicillin', 'Antibiotic', 80, 100),
(10667, 'Insulin', 'Hormone', 260, 60);

--
-- Triggers `medication`
--
DELIMITER $$
CREATE TRIGGER `trg_PreventNegativeStock` BEFORE UPDATE ON `medication` FOR EACH ROW BEGIN
    IF NEW.QuantityInStock < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Stock quantity cannot be reduced below zero.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `patient`
--

CREATE TABLE `patient` (
  `PatientNumber` varchar(10) NOT NULL,
  `FullName` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `patient`
--

INSERT INTO `patient` (`PatientNumber`, `FullName`) VALUES
('P10034', 'Robert MacDonald'),
('P10045', 'Alice Njoroge'),
('P10052', 'James Otieno'),
('P10061', 'Grace Wanjiru'),
('P10078', 'Peter Kimani');

-- --------------------------------------------------------

--
-- Table structure for table `prescription`
--

CREATE TABLE `prescription` (
  `AdmissionID` int(11) NOT NULL,
  `DrugNumber` int(11) NOT NULL,
  `StartDate` date NOT NULL,
  `Dosage` varchar(50) NOT NULL,
  `MethodOfAdmin` varchar(20) NOT NULL,
  `UnitsPerDay` int(11) NOT NULL,
  `FinishDate` date NOT NULL,
  `StaffID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `prescription`
--

INSERT INTO `prescription` (`AdmissionID`, `DrugNumber`, `StartDate`, `Dosage`, `MethodOfAdmin`, `UnitsPerDay`, `FinishDate`, `StaffID`) VALUES
(1, 10223, '2013-03-24', '10mg/ml', 'Oral', 50, '2014-04-24', 1),
(1, 10223, '2014-04-25', '10mg/ml', 'Oral', 10, '2015-05-02', 1),
(1, 10334, '2013-03-24', '0.5mg/ml', 'IV', 10, '2013-04-17', 1),
(2, 10445, '2025-01-11', '500mg', 'Oral', 20, '2025-01-25', 2),
(2, 10667, '2025-04-01', '5 units', 'IV', 4, '2025-04-06', 2),
(2, 10667, '2025-05-01', '5 units', 'IV', 4, '2025-05-06', 2),
(3, 10556, '2025-02-16', '250mg', 'Oral', 15, '2025-02-27', 3),
(4, 10667, '2025-03-02', '5 units', 'IV', 4, '2025-03-15', 4),
(5, 10223, '2025-03-11', '10mg/ml', 'Oral', 30, '2025-03-19', 1);

-- --------------------------------------------------------

--
-- Table structure for table `staff`
--

CREATE TABLE `staff` (
  `StaffID` int(11) NOT NULL,
  `StaffName` varchar(100) NOT NULL,
  `Role` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `staff`
--

INSERT INTO `staff` (`StaffID`, `StaffName`, `Role`) VALUES
(1, 'Dr. Sarah Kimutai', 'Consultant Orthopaedic Surgeon'),
(2, 'Dr. Michael Otiende', 'Cardiologist'),
(3, 'Dr. Lucy Wambui', 'Paediatrician'),
(4, 'Dr. John Mwangi', 'General Surgeon');

-- --------------------------------------------------------

--
-- Table structure for table `ward`
--

CREATE TABLE `ward` (
  `WardNumber` int(11) NOT NULL,
  `WardName` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ward`
--

INSERT INTO `ward` (`WardNumber`, `WardName`) VALUES
(3, 'Paediatric'),
(5, 'Cardiology'),
(7, 'General Surgery'),
(11, 'Orthopaedic');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admission`
--
ALTER TABLE `admission`
  ADD PRIMARY KEY (`AdmissionID`),
  ADD KEY `PatientNumber` (`PatientNumber`),
  ADD KEY `WardNumber` (`WardNumber`,`BedNumber`);

--
-- Indexes for table `bed`
--
ALTER TABLE `bed`
  ADD PRIMARY KEY (`WardNumber`,`BedNumber`);

--
-- Indexes for table `medication`
--
ALTER TABLE `medication`
  ADD PRIMARY KEY (`DrugNumber`);

--
-- Indexes for table `patient`
--
ALTER TABLE `patient`
  ADD PRIMARY KEY (`PatientNumber`);

--
-- Indexes for table `prescription`
--
ALTER TABLE `prescription`
  ADD PRIMARY KEY (`AdmissionID`,`DrugNumber`,`StartDate`),
  ADD KEY `DrugNumber` (`DrugNumber`),
  ADD KEY `StaffID` (`StaffID`);

--
-- Indexes for table `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`StaffID`);

--
-- Indexes for table `ward`
--
ALTER TABLE `ward`
  ADD PRIMARY KEY (`WardNumber`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admission`
--
ALTER TABLE `admission`
  MODIFY `AdmissionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `staff`
--
ALTER TABLE `staff`
  MODIFY `StaffID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admission`
--
ALTER TABLE `admission`
  ADD CONSTRAINT `admission_ibfk_1` FOREIGN KEY (`PatientNumber`) REFERENCES `patient` (`PatientNumber`),
  ADD CONSTRAINT `admission_ibfk_2` FOREIGN KEY (`WardNumber`,`BedNumber`) REFERENCES `bed` (`WardNumber`, `BedNumber`);

--
-- Constraints for table `bed`
--
ALTER TABLE `bed`
  ADD CONSTRAINT `bed_ibfk_1` FOREIGN KEY (`WardNumber`) REFERENCES `ward` (`WardNumber`) ON DELETE CASCADE;

--
-- Constraints for table `prescription`
--
ALTER TABLE `prescription`
  ADD CONSTRAINT `prescription_ibfk_1` FOREIGN KEY (`AdmissionID`) REFERENCES `admission` (`AdmissionID`) ON DELETE CASCADE,
  ADD CONSTRAINT `prescription_ibfk_2` FOREIGN KEY (`DrugNumber`) REFERENCES `medication` (`DrugNumber`),
  ADD CONSTRAINT `prescription_ibfk_3` FOREIGN KEY (`StaffID`) REFERENCES `staff` (`StaffID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
