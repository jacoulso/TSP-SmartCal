-- All code to create/propgate db should be called within here

CREATE DATABASE IF NOT EXISTS smartcal_mysqldb;
USE smartcal_mysqldb;

----------------------------------------------------------------------------
--  PURGE DB CODE HERE                                                    --
----------------------------------------------------------------------------
-- Since pretty much everything has a foreign key attached to something, we
-- have to drop everything in roguhly this order:
--
--  * Lookups
--  * Tables
--
-- ... and we need to do so in the order that they occur in this file. All
-- procedures get dropped in the order they occur, then lookups, and so on.
----------------------------------------------------------------------------

SET FOREIGN_KEY_CHECKS = 0; -- Disable warnings while we kill everything

-- Procedures
DROP PROCEDURE IF EXISTS display_type;
DROP PROCEDURE IF EXISTS display_cal;
DROP PROCEDURE IF EXISTS available;
DROP PROCEDURE IF EXISTS friend_search;
DROP PROCEDURE IF EXISTS user_create;

-- Lookups
DROP TABLE IF EXISTS UserDoNotDisturbHoursLookup;
DROP TABLE IF EXISTS UserCalendarsLookup;
DROP TABLE IF EXISTS EventTypeLookup;
DROP TABLE IF EXISTS PriorityLookup;
DROP TABLE IF EXISTS EventColorLookup;
DROP TABLE IF EXISTS guestLookup;
DROP TABLE IF EXISTS friendLookup;

-- Tables
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Calendars;
DROP TABLE IF EXISTS Events;

SET FOREIGN_KEY_CHECKS = 1; -- Enable warnings 

----------------------------------------------------------------------------
--  TABLES/LOOKUPS                                                        --
----------------------------------------------------------------------------
CREATE TABLE Users (
    uID INT UNIQUE PRIMARY KEY NOT NULL AUTO_INCREMENT,
    username VARCHAR(100) UNIQUE, 
    password VARCHAR(256),
    email VARCHAR(256) UNIQUE
);

-- Users can have different DND hours on different days, and different DND 
-- hours on different time periods
CREATE TABLE UserDoNotDisturbHoursLookup (
    dndID INT NOT NULL PRIMARY KEY UNIQUE AUTO_INCREMENT,
    uID INT,
    startDate TIME,
    endDate TIME,
    recurrence VARCHAR(7),

    FOREIGN KEY (uID) REFERENCES Users(UID) ON DELETE CASCADE
);

----------------------------------------------------------------------------

-- Unique calendar ID's since multiple people "can" share a calendar
CREATE TABLE Calendars (
    cID INT NOT NULL PRIMARY KEY UNIQUE AUTO_INCREMENT,
    title VARCHAR(256)
);

-- 'calendars <-> users' is a many to many relationship
CREATE TABLE UserCalendarsLookup (
    cID INT,
    uID INT,
    
    FOREIGN KEY (cID) REFERENCES Calendars(cID) ON DELETE CASCADE,
    FOREIGN KEY (uID) REFERENCES Users(uID) ON DELETE CASCADE,

    PRIMARY KEY (cID, uID)
);

----------------------------------------------------------------------------

CREATE TABLE EventTypeLookup (
    etID INT NOT NULL UNIQUE PRIMARY KEY AUTO_INCREMENT,
    typeName VARCHAR(50)
);

CREATE TABLE PriorityLookup (
    pID INT NOT NULL UNIQUE PRIMARY KEY AUTO_INCREMENT,
    priorityName VARCHAR(50)
);

-- stores a hexcode value without the leading #. #FFFFFF -> FFFFFF
CREATE TABLE EventColorLookup (
    ecID INT NOT NULL PRIMARY KEY UNIQUE AUTO_INCREMENT,
        colorName VARCHAR(50) DEFAULT '',
    color VARCHAR(6) DEFAULT '000000' 
);

-- Event has to have a userID linked under the hood. Events are tied to a 
-- unique calendar. Single string consisting of unicode characters 
-- 'MTWRFSU' in any configuration, no spaces
CREATE TABLE Events (
    eID INT UNIQUE PRIMARY KEY NOT NULL AUTO_INCREMENT,     
    creatorID INT, 
    calendarID INT,
    colorID INT,
    title VARCHAR(256) NOT NULL, 
    isAllDay BOOLEAN DEFAULT False,
    dateTimeStart DATETIME,
    dateTimeEnd DATETIME,
    duration TIME,
    location VARCHAR(256),
    eventTypeID INT DEFAULT 0,
    priorityID INT DEFAULT 0,
    description TEXT,
    recurrence VARCHAR(7), 
    recurrenceEndDate DATETIME,

    FOREIGN KEY (eventTypeID) REFERENCES EventTypeLookup(etID), 
    FOREIGN KEY (priorityID) REFERENCES PriorityLookup(pID),
    FOREIGN KEY (calendarID) REFERENCES Calendars(cID) ON DELETE CASCADE,
    FOREIGN KEY (colorID) REFERENCES EventColorLookup(ecID) ON DELETE CASCADE,
    FOREIGN KEY (creatorID) REFERENCES Users(uID) ON DELETE CASCADE
);

----------------------------------------------------------------------------

-- Lookup to find any guests attached to the event
CREATE TABLE GuestLookup (
    eID INT,
    uID INT,
    goingStatus ENUM('No', 'Yes', 'Maybe'),

    FOREIGN KEY (eID) REFERENCES Events(eID) ON DELETE CASCADE,
    FOREIGN KEY (uID) REFERENCES Users(uID) ON DELETE CASCADE,

    PRIMARY KEY (eID, uID)
);

-- Nobody is friends with themselves :D
CREATE TABLE FriendLookup (
    uID INT,
    friendID INT,

    FOREIGN KEY (uID) REFERENCES Users(uID) ON DELETE CASCADE,
    FOREIGN KEY (friendID) REFERENCES Users(uID) ON DELETE CASCADE,

    PRIMARY KEY (uID, friendID)
);

---------------------------------------------------------------------------- 
--  PROCEDURES                                                            --
----------------------------------------------------------------------------
delimiter //

-- Display a certain event type
create procedure display_type()
	begin
    
    end //

-- Display all selected event types for a calendar
create procedure display_cal()
	begin
    
    end //

-- Find the next meeting time (disregarding priority)
create procedure available()
	begin
    
    end //

-- Search for friends by username or email
create procedure friend_search(IN keyword varchar(128))
	begin
    select username
    from Users
    where username like concat('%', @keyword, '%')
    or email like concat('%', @keyword, '%');
    end //
    
-- Create a user and their default calendar
create procedure user_create(IN newName varchar(100), IN newPass varchar(256), IN newMail varchar(256))
	begin
    insert into Users (username, password, email) values(newName, newPass, newMail);
    insert into Calendars (title) values(newName);

    INSERT INTO UserCalendarsLookup(cID, uID) VALUES ( 
			(SELECT cID FROM Calendars WHERE title=newName), 
			(SELECT uID FROM Users WHERE username=newName) 
         );
    end //


---------------------------------------------------------------------------- 
--  SEEDERS                                                               --
----------------------------------------------------------------------------

-- Fill our lookups so we can call other propogation procedures
INSERT INTO EventTypeLookup (etID, typeName) VALUES 
    (1,'Event'),
    (2,'Reminder'),
    (3,'Task')
//

INSERT INTO PriorityLookup (pID, priorityName) VALUES
    (1,'Highest'),
    (2,'High'),
    (3,'Medium'),
    (4,'Low'),
    (5,'Lowest')
//

INSERT INTO EventColorLookup (ecID, colorName, color) VALUES 
    (1,'Red','FF0000'),
    (2,'Green','00FF00'),
    (3,'Blue','0000FF')
//

-- Create a dummy user
CALL user_create('jlmillim','worm','jlmillim@mtu.edu')	//

