-- #Schema Creation on MariaDB
-- -----------------------------------------------------
-- Schema quarantine
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `quarantine` DEFAULT CHARACTER SET utf8;
USE `quarantine`;

-- #Table Creation
-- -----------------------------------------------------
-- Table `quarantine`.`patient`
-- -----------------------------------------------------
CREATE TABLE `quarantine`.`patient` (
    `PatientID` INT NOT NULL,
    `Name` VARCHAR(45) NULL,
    `Age` INT NOT NULL,
    `Address` VARCHAR(45) NULL,
    `ArrivalDate` DATE NOT NULL,
    `ComingFrom` VARCHAR(45) NULL,
    `GoingTo` VARCHAR(45) NULL,
    `HostelNo` INT NULL,
    `RoomNo` VARCHAR(5) NULL,
    `DischargedDate` DATE NULL,
    PRIMARY KEY (`PatientID`)
)  ENGINE=INNODB;

CREATE TABLE `quarantine`.`mobile` (
  `MobileNo` VARCHAR(10) NOT NULL,
  `PatientID` INT NOT NULL,
  PRIMARY KEY (`MobileNo`, `PatientID`),
  INDEX (`PatientID`),
  CONSTRAINT `PatientID`
    FOREIGN KEY (`PatientID`)
    REFERENCES `quarantine`.`patient` (`PatientID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE TABLE `quarantine`.`AgeFloor` (
    `Age` INT NOT NULL,
    `Floor` INT NOT NULL,
    PRIMARY KEY (`Age` , `Floor`),
    INDEX (`Age`)
);

CREATE TABLE `quarantine`.`RoomCount` (
    `HostelNo` INT NOT NULL,
    `FloorNo` VARCHAR(45) NOT NULL,
    `RoomNo` VARCHAR(45) NOT NULL,
    `Filled` INT NULL,
    PRIMARY KEY (`HostelNo` , `FloorNo` , `RoomNo`)
);







-- ///////////////////////////////////////////////////////////////////////////////
DROP procedure IF EXISTS `InsertPatient_SP`;

DELIMITER $$
USE `quarantine`$$
CREATE PROCEDURE `InsertPatient_SP` (
IN PatientID INT,
IN Name VARCHAR(45),
IN Age INT,
IN Address VARCHAR(45),
IN ArrivalDate DATE,
IN ComingFrom VARCHAR(45),
IN GoingTo VARCHAR(45)
)
BEGIN
INSERT INTO `quarantine`.`patient` (`PatientID`, `Name`, `Age`, `Address`, `ArrivalDate`, `ComingFrom`, `GoingTo`) VALUES (PatientID, Name, Age, Address, ArrivalDate, ComingFrom, GoingTo);
END$$

DELIMITER ;




-- ///////////////////////////////////////////////////////////////////////////////
DROP procedure IF EXISTS `quarantine`.`UpdatePatient_SP`;
;

DELIMITER $$
USE `quarantine`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdatePatient_SP`(
IN uPatientID INT,
IN uName VARCHAR(45),
IN uAge INT,
IN uAddress VARCHAR(45),
IN uArrivalDate DATE,
IN uComingFrom VARCHAR(45),
IN uGoingTo VARCHAR(45)
)
BEGIN
UPDATE `quarantine`.`patient`
SET `Name`=uName, `Age`=uAge, `Address`=uAddress, `ArrivalDate`=uArrivalDate, `ComingFrom`=uComingFrom, `GoingTo`=uGoingTo
WHERE `PatientID` = uPatientID;
END$$

DELIMITER ;
;



-- ///////////////////////////////////////////////////////////////////////////////
DROP procedure IF EXISTS `quarantine`.`DeletePatient_SP`;
;

DELIMITER $$
USE `quarantine`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DeletePatient_SP`(
IN uPatientID INT
)
BEGIN
DELETE FROM `quarantine`.`patient` WHERE `PatientID` = uPatientID;
END$$

DELIMITER ;
;

-- ///////////////////////////////////////////////////////////////////////////////
DROP procedure IF EXISTS `quarantine`.`InsertMobile_SP`;
;

DELIMITER $$
USE `quarantine`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertMobile_SP`(
IN uPatientID INT,
IN uMobileNo VARCHAR(10)
)
BEGIN
INSERT INTO `quarantine`.`mobile`(`MobileNo`, `PatientID`) VALUES (uPatientID, uMobileNo);
END$$

DELIMITER ;
;

-- ///////////////////////////////////////////////////////////////////////////////
DROP procedure IF EXISTS `quarantine`.`UpdateMobile_SP`;
;

DELIMITER $$
USE `quarantine`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateMobile_SP`(
IN uPatientID INT,
IN uMobileNo VARCHAR(10)
)
BEGIN
UPDATE `quarantine`.`mobile`
SET `MobileNo`=uMobileNo
WHERE `PatientID`=uPatientID;
END$$

DELIMITER ;
;









-- ///////////////////////////////////////////////////////////////////////////////
DROP procedure IF EXISTS `quarantine`.`DeleteMobile_SP`;
;

DELIMITER $$
USE `quarantine`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteMobile_SP`(
IN uPatientID INT
)
BEGIN
DELETE FROM `quarantine`.`mobile` WHERE `PatientID` = uPatientID;
END$$

DELIMITER ;
;


-- ///////////////////////////////////////////////////////////////////////////////

DROP TRIGGER IF EXISTS `quarantine`.`patient_BEFORE_INSERT`;

DELIMITER $$
USE `quarantine`$$
CREATE DEFINER=`root`@`localhost` TRIGGER `quarantine`.`patient_BEFORE_INSERT` BEFORE INSERT ON `patient` FOR EACH ROW
BEGIN
declare fNo int;
declare gfloor int;
declare ffloor int;
declare sfloor int;
SET gfloor = 100;
SET ffloor = 100;
SET sfloor = 50;

 
-- Calculate Floor. Use as NEW.FloorNo
IF EXISTS(select agefloor.Floor from agefloor where agefloor.Age = NEW.Age) > 0 THEN
	SET fNo = (select agefloor.Floor from agefloor where agefloor.Age = NEW.Age);
-- Just grab from agefloor table
ELSE
	IF NEW.Age >= 60 THEN
		SET fNo = 0;
    END IF;
    IF NEW.Age < 60 or NEW.Age > 40 THEN
		SET fNo = 1;
    END IF;
	IF NEW.Age <= 40 THEN
		SET fNo = 2;
	END IF;
    INSERT INTO agefloor (Age, Floor) values (NEW.Age, fNo);
-- Calculate Floor 
END IF;
IF fNo = 0 THEN
	IF (SELECT SUM(Filled) FROM roomcount where HostelNo = 1 and FloorNo = fNo and Filled = 0) <= gfloor THEN
		SET NEW.RoomNo = (SELECT RoomNo FROM roomcount r where HostelNo = 1 and FloorNo = fNo and Filled = 0 limit 1);
		SET NEW.HostelNo = 1;
	ELSEIF (SELECT SUM(Filled) FROM roomcount where HostelNo = 2 and FloorNo = fNo and Filled = 0) <= gfloor THEN
		SET NEW.RoomNo = (SELECT RoomNo FROM roomcount r where HostelNo = 2 and FloorNo = fNo and Filled = 0 limit 1);
		SET NEW.HostelNo = 2;
	END IF;
ELSEIF fNo = 1 THEN
	IF (SELECT SUM(Filled) FROM roomcount where HostelNo = 1 and FloorNo = fNo and Filled = 0) <= ffloor THEN
		SET NEW.RoomNo = (SELECT RoomNo FROM roomcount r where HostelNo = 1 and FloorNo = fNo and Filled = 0 limit 1);
		SET NEW.HostelNo = 1;
	ELSEIF (SELECT SUM(Filled) FROM roomcount where HostelNo = 2 and FloorNo = fNo and Filled = 0) <= ffloor THEN
		SET NEW.RoomNo = (SELECT RoomNo FROM roomcount r where HostelNo = 2 and FloorNo = fNo and Filled = 0 limit 1);
		SET NEW.HostelNo = 2;
	END IF;
ELSEIF fNo = 2 THEN
	IF (SELECT SUM(Filled) FROM roomcount where HostelNo = 1 and FloorNo = fNo and Filled = 0) <= sfloor THEN
		SET NEW.RoomNo = (SELECT RoomNo FROM roomcount r where HostelNo = 1 and FloorNo = fNo and Filled = 0 limit 1);
		SET NEW.HostelNo = 1;
	ELSEIF (SELECT SUM(Filled) FROM roomcount where HostelNo = 2 and FloorNo = fNo and Filled = 0) <= sfloor THEN
		SET NEW.RoomNo = (SELECT RoomNo FROM roomcount r where HostelNo = 2 and FloorNo = fNo and Filled = 0 limit 1);
		SET NEW.HostelNo = 2;
	END IF;
END IF;
UPDATE roomcount SET filled = 1 where HostelNo = NEW.HostelNo and FloorNo = fNo and RoomNo = NEW.RoomNo;
SET NEW.DischargedDate = (SELECT DATE_ADD(NEW.ArrivalDate, INTERVAL 10 DAY));
END$$
DELIMITER ;

-- ///////////////////////////////////////////////////////////////////////////////

DROP TRIGGER IF EXISTS `quarantine`.`patient_BEFORE_UPDATE`;

DELIMITER $$
USE `quarantine`$$
CREATE DEFINER=`root`@`localhost` TRIGGER `quarantine`.`patient_BEFORE_UPDATE` BEFORE UPDATE ON `patient` FOR EACH ROW
BEGIN
declare gfloor int;
declare ffloor int;
declare sfloor int;
declare fNo int;
declare fNoOLD int;

SET gfloor = 100;
SET ffloor = 100;
SET sfloor = 50;
IF NEW.Name = '' THEN
	SET NEW.Name = OLD.Name ;
END IF;
IF NEW.Address = '' THEN
	SET NEW.Address = OLD.Address ;
END IF;
IF NEW.ComingFrom = '' THEN
	SET NEW.ComingFrom = OLD.ComingFrom ;
END IF;
IF NEW.GoingTo = '' THEN
	SET NEW.GoingTo = OLD.GoingTo ;
END IF;
SET fNoOLD = (select agefloor.Floor from agefloor where agefloor.Age = OLD.Age);
-- Calculate Floor. Use as NEW.FloorNo
IF NEW.Age <> OLD.Age and NEW.Age <> '' THEN
	IF EXISTS(select agefloor.Floor from agefloor where agefloor.Age = NEW.Age) = 1 THEN
		SET fNo = (select agefloor.Floor from agefloor where agefloor.Age = NEW.Age);
	-- Just grab from agefloor table
	ELSE
		IF NEW.Age >= 60 THEN
			SET fNo = 0;
		END IF;
		IF NEW.Age < 60 or NEW.Age > 40 THEN
			SET fNo = 1;
		END IF;
		IF NEW.Age <= 40 THEN
			SET fNo = 2;
		END IF;
		INSERT INTO agefloor (Age, Floor) values (NEW.Age, fNo);
	-- Calculate Floor 
	END IF;
	UPDATE roomcount SET filled = 0 where HostelNo = OLD.HostelNo and FloorNo = fNoOLD and RoomNo = OLD.RoomNo;
    IF fNo = 0 THEN
		IF (SELECT SUM(Filled) FROM roomcount where HostelNo = 1 and FloorNo = fNo and Filled = 0) <= gfloor THEN
			SET NEW.RoomNo = (SELECT RoomNo FROM roomcount r where HostelNo = 1 and FloorNo = fNo and Filled = 0 limit 1);
			SET NEW.HostelNo = 1;
		ELSEIF (SELECT SUM(Filled) FROM roomcount where HostelNo = 2 and FloorNo = fNo and Filled = 0) <= gfloor THEN
			SET NEW.RoomNo = (SELECT RoomNo FROM roomcount r where HostelNo = 2 and FloorNo = fNo and Filled = 0 limit 1);
			SET NEW.HostelNo = 2;
		END IF;
	ELSEIF fNo = 1 THEN
		IF (SELECT SUM(Filled) FROM roomcount where HostelNo = 1 and FloorNo = fNo and Filled = 0) <= ffloor THEN
			SET NEW.RoomNo = (SELECT RoomNo FROM roomcount r where HostelNo = 1 and FloorNo = fNo and Filled = 0 limit 1);
			SET NEW.HostelNo = 1;
		ELSEIF (SELECT SUM(Filled) FROM roomcount where HostelNo = 2 and FloorNo = fNo and Filled = 0) <= ffloor THEN
			SET NEW.RoomNo = (SELECT RoomNo FROM roomcount r where HostelNo = 2 and FloorNo = fNo and Filled = 0 limit 1);
			SET NEW.HostelNo = 2;
		END IF;
	ELSEIF fNo = 2 THEN
		IF (SELECT SUM(Filled) FROM roomcount where HostelNo = 1 and FloorNo = fNo and Filled = 0) <= sfloor THEN
			SET NEW.RoomNo = (SELECT RoomNo FROM roomcount r where HostelNo = 1 and FloorNo = fNo and Filled = 0 limit 1);
			SET NEW.HostelNo = 1;
		ELSEIF (SELECT SUM(Filled) FROM roomcount where HostelNo = 2 and FloorNo = fNo and Filled = 0) <= sfloor THEN
			SET NEW.RoomNo = (SELECT RoomNo FROM roomcount r where HostelNo = 2 and FloorNo = fNo and Filled = 0 limit 1);
			SET NEW.HostelNo = 2;
		END IF;
	END IF;
	UPDATE roomcount SET filled = 1 where HostelNo = NEW.HostelNo and FloorNo = fNo and RoomNo = NEW.RoomNo;
END IF;
IF NEW.ArrivalDate <> OLD.ArrivalDate and NEW.ArrivalDate <> '' THEN
	SET NEW.DischargedDate = (SELECT DATE_ADD(NEW.ArrivalDate, INTERVAL 10 DAY));
END IF;
END$$
DELIMITER ;

-- ///////////////////////////////////////////////////////////////////////////////
DROP TRIGGER IF EXISTS `quarantine`.`patient_AFTER_DELETE`;

DELIMITER $$
USE `quarantine`$$
CREATE DEFINER=`root`@`localhost` TRIGGER `quarantine`.`patient_AFTER_DELETE` AFTER DELETE ON `patient` FOR EACH ROW
BEGIN
declare fNo int;
SET fNo = (select agefloor.Floor from agefloor where agefloor.Age = OLD.Age);
UPDATE roomcount SET filled = 0 where HostelNo = OLD.HostelNo and FloorNo = fNo and RoomNo = OLD.RoomNo;
END$$
DELIMITER ;

-- ///////////////////////////////////////////////////////////////////////////////////
DROP TRIGGER IF EXISTS `quarantine`.`agefloor_BEFORE_INSERT`;

DELIMITER $$
USE `quarantine`$$
CREATE DEFINER = CURRENT_USER TRIGGER `quarantine`.`agefloor_BEFORE_INSERT` BEFORE INSERT ON `agefloor` FOR EACH ROW
BEGIN
IF NEW.Age >= 60 THEN
		SET NEW.Floor = 0;
    END IF;
    IF NEW.Age < 60 or NEW.Age > 40 THEN
		SET NEW.Floor = 1;
    END IF;
	IF NEW.Age <= 40 THEN
		SET NEW.Floor = 2;
	END IF;
END$$
DELIMITER ;












-- ///////////////////////////////////////////////////////////////////////////////


INSERT INTO `quarantine`.`roomcount` (`HostelNo`, `FloorNo`, `RoomNo`, `Filled`) VALUES 
('1', '0', '1', '0'),
('1', '0', '2', '0'),
('1', '0', '3', '0'),
('1', '0', '4', '0'),
('1', '0', '5', '0'),
('1', '0', '6', '0'),
('1', '0', '7', '0'),
('1', '0', '8', '0'),
('1', '0', '9', '0'),
('1', '0', '10', '0'),
('1', '0', '11', '0'),
('1', '0', '12', '0'),
('1', '0', '13', '0'),
('1', '0', '14', '0'),
('1', '0', '15', '0'),
('1', '0', '16', '0'),
('1', '0', '17', '0'),
('1', '0', '18', '0'),
('1', '0', '19', '0'),
('1', '0', '20', '0'),
('1', '0', '21', '0'),
('1', '0', '22', '0'),
('1', '0', '23', '0'),
('1', '0', '24', '0'),
('1', '0', '25', '0'),
('1', '0', '26', '0'),
('1', '0', '27', '0'),
('1', '0', '28', '0'),
('1', '0', '29', '0'),
('1', '0', '30', '0'),
('1', '0', '31', '0'),
('1', '0', '32', '0'),
('1', '0', '33', '0'),
('1', '0', '34', '0'),
('1', '0', '35', '0'),
('1', '0', '36', '0'),
('1', '0', '37', '0'),
('1', '0', '38', '0'),
('1', '0', '39', '0'),
('1', '0', '40', '0'),
('1', '0', '41', '0'),
('1', '0', '42', '0'),
('1', '0', '43', '0'),
('1', '0', '44', '0'),
('1', '0', '45', '0'),
('1', '0', '46', '0'),
('1', '0', '47', '0'),
('1', '0', '48', '0'),
('1', '0', '49', '0'),
('1', '0', '50', '0'),
('1', '0', '51', '0'),
('1', '0', '52', '0'),
('1', '0', '53', '0'),
('1', '0', '54', '0'),
('1', '0', '55', '0'),
('1', '0', '56', '0'),
('1', '0', '57', '0'),
('1', '0', '58', '0'),
('1', '0', '59', '0'),
('1', '0', '60', '0'),
('1', '0', '61', '0'),
('1', '0', '62', '0'),
('1', '0', '63', '0'),
('1', '0', '64', '0'),
('1', '0', '65', '0'),
('1', '0', '66', '0'),
('1', '0', '67', '0'),
('1', '0', '68', '0'),
('1', '0', '69', '0'),
('1', '0', '70', '0'),
('1', '0', '71', '0'),
('1', '0', '72', '0'),
('1', '0', '73', '0'),
('1', '0', '74', '0'),
('1', '0', '75', '0'),
('1', '0', '76', '0'),
('1', '0', '77', '0'),
('1', '0', '78', '0'),
('1', '0', '79', '0'),
('1', '0', '80', '0'),
('1', '0', '81', '0'),
('1', '0', '82', '0'),
('1', '0', '83', '0'),
('1', '0', '84', '0'),
('1', '0', '85', '0'),
('1', '0', '86', '0'),
('1', '0', '87', '0'),
('1', '0', '88', '0'),
('1', '0', '89', '0'),
('1', '0', '90', '0'),
('1', '0', '91', '0'),
('1', '0', '92', '0'),
('1', '0', '93', '0'),
('1', '0', '94', '0'),
('1', '0', '95', '0'),
('1', '0', '96', '0'),
('1', '0', '97', '0'),
('1', '0', '98', '0'),
('1', '0', '99', '0'),
('1', '0', '100', '0'),
('1', '1', '1', '0'),
('1', '1', '2', '0'),
('1', '1', '3', '0'),
('1', '1', '4', '0'),
('1', '1', '5', '0'),
('1', '1', '6', '0'),
('1', '1', '7', '0'),
('1', '1', '8', '0'),
('1', '1', '9', '0'),
('1', '1', '10', '0'),
('1', '1', '11', '0'),
('1', '1', '12', '0'),
('1', '1', '13', '0'),
('1', '1', '14', '0'),
('1', '1', '15', '0'),
('1', '1', '16', '0'),
('1', '1', '17', '0'),
('1', '1', '18', '0'),
('1', '1', '19', '0'),
('1', '1', '20', '0'),
('1', '1', '21', '0'),
('1', '1', '22', '0'),
('1', '1', '23', '0'),
('1', '1', '24', '0'),
('1', '1', '25', '0'),
('1', '1', '26', '0'),
('1', '1', '27', '0'),
('1', '1', '28', '0'),
('1', '1', '29', '0'),
('1', '1', '30', '0'),
('1', '1', '31', '0'),
('1', '1', '32', '0'),
('1', '1', '33', '0'),
('1', '1', '34', '0'),
('1', '1', '35', '0'),
('1', '1', '36', '0'),
('1', '1', '37', '0'),
('1', '1', '38', '0'),
('1', '1', '39', '0'),
('1', '1', '40', '0'),
('1', '1', '41', '0'),
('1', '1', '42', '0'),
('1', '1', '43', '0'),
('1', '1', '44', '0'),
('1', '1', '45', '0'),
('1', '1', '46', '0'),
('1', '1', '47', '0'),
('1', '1', '48', '0'),
('1', '1', '49', '0'),
('1', '1', '50', '0'),
('1', '1', '51', '0'),
('1', '1', '52', '0'),
('1', '1', '53', '0'),
('1', '1', '54', '0'),
('1', '1', '55', '0'),
('1', '1', '56', '0'),
('1', '1', '57', '0'),
('1', '1', '58', '0'),
('1', '1', '59', '0'),
('1', '1', '60', '0'),
('1', '1', '61', '0'),
('1', '1', '62', '0'),
('1', '1', '63', '0'),
('1', '1', '64', '0'),
('1', '1', '65', '0'),
('1', '1', '66', '0'),
('1', '1', '67', '0'),
('1', '1', '68', '0'),
('1', '1', '69', '0'),
('1', '1', '70', '0'),
('1', '1', '71', '0'),
('1', '1', '72', '0'),
('1', '1', '73', '0'),
('1', '1', '74', '0'),
('1', '1', '75', '0'),
('1', '1', '76', '0'),
('1', '1', '77', '0'),
('1', '1', '78', '0'),
('1', '1', '79', '0'),
('1', '1', '80', '0'),
('1', '1', '81', '0'),
('1', '1', '82', '0'),
('1', '1', '83', '0'),
('1', '1', '84', '0'),
('1', '1', '85', '0'),
('1', '1', '86', '0'),
('1', '1', '87', '0'),
('1', '1', '88', '0'),
('1', '1', '89', '0'),
('1', '1', '90', '0'),
('1', '1', '91', '0'),
('1', '1', '92', '0'),
('1', '1', '93', '0'),
('1', '1', '94', '0'),
('1', '1', '95', '0'),
('1', '1', '96', '0'),
('1', '1', '97', '0'),
('1', '1', '98', '0'),
('1', '1', '99', '0'),
('1', '1', '100', '0'),
('1', '2', '1', '0'),
('1', '2', '2', '0'),
('1', '2', '3', '0'),
('1', '2', '4', '0'),
('1', '2', '5', '0'),
('1', '2', '6', '0'),
('1', '2', '7', '0'),
('1', '2', '8', '0'),
('1', '2', '9', '0'),
('1', '2', '10', '0'),
('1', '2', '11', '0'),
('1', '2', '12', '0'),
('1', '2', '13', '0'),
('1', '2', '14', '0'),
('1', '2', '15', '0'),
('1', '2', '16', '0'),
('1', '2', '17', '0'),
('1', '2', '18', '0'),
('1', '2', '19', '0'),
('1', '2', '20', '0'),
('1', '2', '21', '0'),
('1', '2', '22', '0'),
('1', '2', '23', '0'),
('1', '2', '24', '0'),
('1', '2', '25', '0'),
('1', '2', '26', '0'),
('1', '2', '27', '0'),
('1', '2', '28', '0'),
('1', '2', '29', '0'),
('1', '2', '30', '0'),
('1', '2', '31', '0'),
('1', '2', '32', '0'),
('1', '2', '33', '0'),
('1', '2', '34', '0'),
('1', '2', '35', '0'),
('1', '2', '36', '0'),
('1', '2', '37', '0'),
('1', '2', '38', '0'),
('1', '2', '39', '0'),
('1', '2', '40', '0'),
('1', '2', '41', '0'),
('1', '2', '42', '0'),
('1', '2', '43', '0'),
('1', '2', '44', '0'),
('1', '2', '45', '0'),
('1', '2', '46', '0'),
('1', '2', '47', '0'),
('1', '2', '48', '0'),
('1', '2', '49', '0'),
('1', '2', '50', '0'),
('2', '0', '1', '0'),
('2', '0', '2', '0'),
('2', '0', '3', '0'),
('2', '0', '4', '0'),
('2', '0', '5', '0'),
('2', '0', '6', '0'),
('2', '0', '7', '0'),
('2', '0', '8', '0'),
('2', '0', '9', '0'),
('2', '0', '10', '0'),
('2', '0', '11', '0'),
('2', '0', '12', '0'),
('2', '0', '13', '0'),
('2', '0', '14', '0'),
('2', '0', '15', '0'),
('2', '0', '16', '0'),
('2', '0', '17', '0'),
('2', '0', '18', '0'),
('2', '0', '19', '0'),
('2', '0', '20', '0'),
('2', '0', '21', '0'),
('2', '0', '22', '0'),
('2', '0', '23', '0'),
('2', '0', '24', '0'),
('2', '0', '25', '0'),
('2', '0', '26', '0'),
('2', '0', '27', '0'),
('2', '0', '28', '0'),
('2', '0', '29', '0'),
('2', '0', '30', '0'),
('2', '0', '31', '0'),
('2', '0', '32', '0'),
('2', '0', '33', '0'),
('2', '0', '34', '0'),
('2', '0', '35', '0'),
('2', '0', '36', '0'),
('2', '0', '37', '0'),
('2', '0', '38', '0'),
('2', '0', '39', '0'),
('2', '0', '40', '0'),
('2', '0', '41', '0'),
('2', '0', '42', '0'),
('2', '0', '43', '0'),
('2', '0', '44', '0'),
('2', '0', '45', '0'),
('2', '0', '46', '0'),
('2', '0', '47', '0'),
('2', '0', '48', '0'),
('2', '0', '49', '0'),
('2', '0', '50', '0'),
('2', '0', '51', '0'),
('2', '0', '52', '0'),
('2', '0', '53', '0'),
('2', '0', '54', '0'),
('2', '0', '55', '0'),
('2', '0', '56', '0'),
('2', '0', '57', '0'),
('2', '0', '58', '0'),
('2', '0', '59', '0'),
('2', '0', '60', '0'),
('2', '0', '61', '0'),
('2', '0', '62', '0'),
('2', '0', '63', '0'),
('2', '0', '64', '0'),
('2', '0', '65', '0'),
('2', '0', '66', '0'),
('2', '0', '67', '0'),
('2', '0', '68', '0'),
('2', '0', '69', '0'),
('2', '0', '70', '0'),
('2', '0', '71', '0'),
('2', '0', '72', '0'),
('2', '0', '73', '0'),
('2', '0', '74', '0'),
('2', '0', '75', '0'),
('2', '0', '76', '0'),
('2', '0', '77', '0'),
('2', '0', '78', '0'),
('2', '0', '79', '0'),
('2', '0', '80', '0'),
('2', '0', '81', '0'),
('2', '0', '82', '0'),
('2', '0', '83', '0'),
('2', '0', '84', '0'),
('2', '0', '85', '0'),
('2', '0', '86', '0'),
('2', '0', '87', '0'),
('2', '0', '88', '0'),
('2', '0', '89', '0'),
('2', '0', '90', '0'),
('2', '0', '91', '0'),
('2', '0', '92', '0'),
('2', '0', '93', '0'),
('2', '0', '94', '0'),
('2', '0', '95', '0'),
('2', '0', '96', '0'),
('2', '0', '97', '0'),
('2', '0', '98', '0'),
('2', '0', '99', '0'),
('2', '0', '100', '0'),
('2', '1', '1', '0'),
('2', '1', '2', '0'),
('2', '1', '3', '0'),
('2', '1', '4', '0'),
('2', '1', '5', '0'),
('2', '1', '6', '0'),
('2', '1', '7', '0'),
('2', '1', '8', '0'),
('2', '1', '9', '0'),
('2', '1', '10', '0'),
('2', '1', '11', '0'),
('2', '1', '12', '0'),
('2', '1', '13', '0'),
('2', '1', '14', '0'),
('2', '1', '15', '0'),
('2', '1', '16', '0'),
('2', '1', '17', '0'),
('2', '1', '18', '0'),
('2', '1', '19', '0'),
('2', '1', '20', '0'),
('2', '1', '21', '0'),
('2', '1', '22', '0'),
('2', '1', '23', '0'),
('2', '1', '24', '0'),
('2', '1', '25', '0'),
('2', '1', '26', '0'),
('2', '1', '27', '0'),
('2', '1', '28', '0'),
('2', '1', '29', '0'),
('2', '1', '30', '0'),
('2', '1', '31', '0'),
('2', '1', '32', '0'),
('2', '1', '33', '0'),
('2', '1', '34', '0'),
('2', '1', '35', '0'),
('2', '1', '36', '0'),
('2', '1', '37', '0'),
('2', '1', '38', '0'),
('2', '1', '39', '0'),
('2', '1', '40', '0'),
('2', '1', '41', '0'),
('2', '1', '42', '0'),
('2', '1', '43', '0'),
('2', '1', '44', '0'),
('2', '1', '45', '0'),
('2', '1', '46', '0'),
('2', '1', '47', '0'),
('2', '1', '48', '0'),
('2', '1', '49', '0'),
('2', '1', '50', '0'),
('2', '1', '51', '0'),
('2', '1', '52', '0'),
('2', '1', '53', '0'),
('2', '1', '54', '0'),
('2', '1', '55', '0'),
('2', '1', '56', '0'),
('2', '1', '57', '0'),
('2', '1', '58', '0'),
('2', '1', '59', '0'),
('2', '1', '60', '0'),
('2', '1', '61', '0'),
('2', '1', '62', '0'),
('2', '1', '63', '0'),
('2', '1', '64', '0'),
('2', '1', '65', '0'),
('2', '1', '66', '0'),
('2', '1', '67', '0'),
('2', '1', '68', '0'),
('2', '1', '69', '0'),
('2', '1', '70', '0'),
('2', '1', '71', '0'),
('2', '1', '72', '0'),
('2', '1', '73', '0'),
('2', '1', '74', '0'),
('2', '1', '75', '0'),
('2', '1', '76', '0'),
('2', '1', '77', '0'),
('2', '1', '78', '0'),
('2', '1', '79', '0'),
('2', '1', '80', '0'),
('2', '1', '81', '0'),
('2', '1', '82', '0'),
('2', '1', '83', '0'),
('2', '1', '84', '0'),
('2', '1', '85', '0'),
('2', '1', '86', '0'),
('2', '1', '87', '0'),
('2', '1', '88', '0'),
('2', '1', '89', '0'),
('2', '1', '90', '0'),
('2', '1', '91', '0'),
('2', '1', '92', '0'),
('2', '1', '93', '0'),
('2', '1', '94', '0'),
('2', '1', '95', '0'),
('2', '1', '96', '0'),
('2', '1', '97', '0'),
('2', '1', '98', '0'),
('2', '1', '99', '0'),
('2', '1', '100', '0'),
('2', '2', '1', '0'),
('2', '2', '2', '0'),
('2', '2', '3', '0'),
('2', '2', '4', '0'),
('2', '2', '5', '0'),
('2', '2', '6', '0'),
('2', '2', '7', '0'),
('2', '2', '8', '0'),
('2', '2', '9', '0'),
('2', '2', '10', '0'),
('2', '2', '11', '0'),
('2', '2', '12', '0'),
('2', '2', '13', '0'),
('2', '2', '14', '0'),
('2', '2', '15', '0'),
('2', '2', '16', '0'),
('2', '2', '17', '0'),
('2', '2', '18', '0'),
('2', '2', '19', '0'),
('2', '2', '20', '0'),
('2', '2', '21', '0'),
('2', '2', '22', '0'),
('2', '2', '23', '0'),
('2', '2', '24', '0'),
('2', '2', '25', '0'),
('2', '2', '26', '0'),
('2', '2', '27', '0'),
('2', '2', '28', '0'),
('2', '2', '29', '0'),
('2', '2', '30', '0'),
('2', '2', '31', '0'),
('2', '2', '32', '0'),
('2', '2', '33', '0'),
('2', '2', '34', '0'),
('2', '2', '35', '0'),
('2', '2', '36', '0'),
('2', '2', '37', '0'),
('2', '2', '38', '0'),
('2', '2', '39', '0'),
('2', '2', '40', '0'),
('2', '2', '41', '0'),
('2', '2', '42', '0'),
('2', '2', '43', '0'),
('2', '2', '44', '0'),
('2', '2', '45', '0'),
('2', '2', '46', '0'),
('2', '2', '47', '0'),
('2', '2', '48', '0'),
('2', '2', '49', '0'),
('2', '2', '50', '0')
;



