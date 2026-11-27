INSERT INTO Users (Name, Email, Password_Hash, Phone_Number, User_Type)
VALUES 
('Central Administrator', 'admin@lankaexpress.com', 'admin123', '+94 77 123 4567', 'Admin'),
('Sahan Commuter', 'passenger@lanka.com', 'pass123', '+94 71 987 6543', 'Passenger'),
('Dharmasena Perera', 'driver@lanka.com', 'driver123', '+94 72 444 5555', 'Driver'),
('Sunil Kumara', 'driver.sunil@lanka.com', 'driver123', '+94 77 222 3333', 'Driver'),
('Manjula Bandara', 'driver.manjula@lanka.com', 'driver123', '+94 77 333 4444', 'Driver'),
('Jagath Wickremasinghe', 'driver.jagath@lanka.com', 'driver123', '+94 77 444 5555', 'Driver'),
('Siriwardena Alwis', 'driver.siriwardena@lanka.com', 'driver123', '+94 77 555 6666', 'Driver'),
('Ruwan Kumara', 'driver2@lanka.com', 'driver123', '+94 75 888 9999', 'Driver'),
('Bandara Rajapaksa', 'driver.bandara@lanka.com', 'driver123', '+94 77 777 8888', 'Driver'),
('Anura Silva', 'driver.anura@lanka.com', 'driver123', '+94 77 888 9999', 'Driver'),
('Dilshan Silva', 'dilshan@lanka.com', 'pass123', '+94 77 111 2222', 'Passenger'),
('Chamilia Perera', 'chamil@lanka.com', 'pass123', '+94 77 333 4445', 'Passenger'),
('Nisansala Herath', 'nisansala@lanka.com', 'pass123', '+94 77 555 6667', 'Passenger'),
('Tharindu Bandara', 'tharindu@lanka.com', 'pass123', '+94 77 777 8889', 'Passenger'),
('Yomal', 'yomal@lanka.com', 'pass123', '+94 77 2363898', 'Passenger');
SELECT * FROM Users;

INSERT INTO Buses (Bus_Number, Type, Seating_Capacity)
VALUES
('WP ND-4589', 'AC (Super Luxury)', 40),
('WP ND-9024', 'AC (Luxury Coach)', 40),
('SP ND-7731', 'AC (Super Luxury)', 40),
('NP NC-1209', 'Non-AC (Highway Express)', 44),
('CP NE-8812', 'AC (Super Luxury)', 40),
('CP NE-9944', 'AC (Luxury Coach)', 40),
('SP NE-5050', 'AC (Super Luxury)', 40),
('WP ND-2026', 'AC (Luxury Coach)', 40);
SELECT * FROM Buses;

INSERT INTO Routes (Route_No, Distance, Start_Point, End_Point)
VALUES
('EX 1-1', 95.00, 'Colombo MMC', 'Galle Hub (Pinnaduwa)'),
('EX 1-2', 128.00, 'Colombo MMC', 'Matara Hub (Godagama)'),
('EX 1-9', 230.00, 'Colombo MMC', 'Hambantota Central'),
('EX 1-10', 115.00, 'Kadawatha Interchange', 'Kandy Goods Shed');
SELECT * FROM Routes;

INSERT INTO Route_Stops (Route_No, Stop_Order, Stop_Name)
VALUES
('EX 1-1', 1, 'Colombo MMC'),
('EX 1-1', 2, 'Panadura'),
('EX 1-1', 3, 'Kalutara'),
('EX 1-1', 4, 'Galle Hub (Pinnaduwa)'),
('EX 1-2', 1, 'Colombo MMC'),
('EX 1-2', 2, 'Panadura'),
('EX 1-2', 3, 'Kalutara'),
('EX 1-2', 4, 'Galle'),
('EX 1-2', 5, 'Matara Hub (Godagama)');
SELECT * FROM Route_Stops;

INSERT INTO Schedules (Bus_No, Route_No, Departure_Time, Arrival_Time)
VALUES
('WP ND-4589', 'EX 1-1', '08:15', '10:00'),
('WP ND-9024', 'EX 1-2', '11:00', '13:15'),
('SP ND-7731', 'EX 1-1', '14:30', '16:15'),
('NP NC-1209', 'EX 1-2', '16:00', '18:15'),
('CP NE-8812', 'EX 1-10', '07:30', '10:15'),
('CP NE-9944', 'EX 1-10', '13:30', '16:15'),
('SP NE-5050', 'EX 1-9', '06:30', '10:00'),
('WP ND-2026', 'EX 1-9', '15:15', '18:45');
SELECT * FROM Schedules;

-- 6. Seat_Availability: for schedule, all seats (e.g., 1–40) available
DECLARE @Seat INT = 1;
WHILE @Seat <= 40
BEGIN
    INSERT INTO Seat_Availability (Schedule_ID, Seat_No, IsAvailable)
    VALUES (1, @Seat, 1);
    SET @Seat = @Seat + 1;
END;
-- WP ND-9024 (40 seats)
DECLARE @ScheduleID INT, @Seat INT = 1;
SELECT @ScheduleID = Schedule_ID FROM Schedules WHERE Bus_No = 'WP ND-9024';

WHILE @Seat <= 40
BEGIN
    INSERT INTO Seat_Availability (Schedule_ID, Seat_No, IsAvailable)
    VALUES (@ScheduleID, @Seat, 1);
    SET @Seat = @Seat + 1;
END;
GO


USE BusBookingSystem_Fresh;
GO


-- 1. Remove all Seat_Availability for these 8 buses
DELETE sa
FROM Seat_Availability sa
INNER JOIN Schedules s ON s.Schedule_ID = sa.Schedule_ID
WHERE s.Bus_No IN (
    'WP ND-4589',
    'WP ND-9024',
    'SP ND-7731',
    'NP NC-1209',
    'CP NE-8812',
    'CP NE-9944',
    'SP NE-5050',
    'WP ND-2026'
);
GO


-- 2. Remove any old test reservations on these buses (optional, if you want)
DELETE FROM Reservations
WHERE Bus_No IN (
    'WP ND-4589',
    'WP ND-9024',
    'SP ND-7731',
    'NP NC-1209',
    'CP NE-8812',
    'CP NE-9944',
    'SP NE-5050',
    'WP ND-2026'
);
GO

-- 1. WP ND-4589 (40 seats)
DECLARE @ScheduleID INT, @Seat INT = 1;
SELECT @ScheduleID = Schedule_ID FROM Schedules WHERE Bus_No = 'WP ND-4589';

WHILE @Seat <= 40
BEGIN
    INSERT INTO Seat_Availability (Schedule_ID, Seat_No, IsAvailable)
    VALUES (@ScheduleID, @Seat, 1);
    SET @Seat = @Seat + 1;
END;
GO


-- 1. WP ND-9024 (40 seats)
DECLARE @ScheduleID INT, @Seat INT = 1;  -- declare inside the batch
SELECT @ScheduleID = Schedule_ID FROM Schedules WHERE Bus_No = 'WP ND-9024';

WHILE @Seat <= 40
BEGIN
    INSERT INTO Seat_Availability (Schedule_ID, Seat_No, IsAvailable)
    VALUES (@ScheduleID, @Seat, 1);
    SET @Seat = @Seat + 1;
END;
GO


-- 3. SP ND-7731 (40 seats)
DECLARE @ScheduleID INT, @Seat INT = 1;  -- this line is critical

SELECT @ScheduleID = Schedule_ID FROM Schedules WHERE Bus_No = 'SP ND-7731';

WHILE @Seat <= 40
BEGIN
    INSERT INTO Seat_Availability (Schedule_ID, Seat_No, IsAvailable)
    VALUES (@ScheduleID, @Seat, 1);
    SET @Seat = @Seat + 1;
END;
GO

-- 3. NP NC-1209 (44 seats)
DECLARE @ScheduleID INT, @Seat INT = 1;  -- and again here
SELECT @ScheduleID = Schedule_ID FROM Schedules WHERE Bus_No = 'NP NC-1209';

WHILE @Seat <= 44
BEGIN
    INSERT INTO Seat_Availability (Schedule_ID, Seat_No, IsAvailable)
    VALUES (@ScheduleID, @Seat, 1);
    SET @Seat = @Seat + 1;
END;
GO


-- 4. CP NE-8812 (40 seats)
DECLARE @ScheduleID INT, @Seat INT = 1;
SELECT @ScheduleID = Schedule_ID FROM Schedules WHERE Bus_No = 'CP NE-8812';

WHILE @Seat <= 40
BEGIN
    INSERT INTO Seat_Availability (Schedule_ID, Seat_No, IsAvailable)
    VALUES (@ScheduleID, @Seat, 1);
    SET @Seat = @Seat + 1;
END;
GO


-- 5. CP NE-9944 (40 seats)
DECLARE @ScheduleID INT, @Seat INT = 1;
SELECT @ScheduleID = Schedule_ID FROM Schedules WHERE Bus_No = 'CP NE-9944';

WHILE @Seat <= 40
BEGIN
    INSERT INTO Seat_Availability (Schedule_ID, Seat_No, IsAvailable)
    VALUES (@ScheduleID, @Seat, 1);
    SET @Seat = @Seat + 1;
END;
GO


-- 6. SP NE-5050 (40 seats)
DECLARE @ScheduleID INT, @Seat INT = 1;
SELECT @ScheduleID = Schedule_ID FROM Schedules WHERE Bus_No = 'SP NE-5050';

WHILE @Seat <= 40
BEGIN
    INSERT INTO Seat_Availability (Schedule_ID, Seat_No, IsAvailable)
    VALUES (@ScheduleID, @Seat, 1);
    SET @Seat = @Seat + 1;
END;
GO


-- 7. WP ND-2026 (40 seats)
DECLARE @ScheduleID INT, @Seat INT = 1;
SELECT @ScheduleID = Schedule_ID FROM Schedules WHERE Bus_No = 'WP ND-2026';

WHILE @Seat <= 40
BEGIN
    INSERT INTO Seat_Availability (Schedule_ID, Seat_No, IsAvailable)
    VALUES (@ScheduleID, @Seat, 1);
    SET @Seat = @Seat + 1;
END;
GO


SELECT * FROM Seat_Availability;

-- 7. Live_Tracking (assume 40 seats total ? 40 available at start)
INSERT INTO Live_Tracking (Bus_No, Log_ID, Latitude, Longitude, Speed, Available_Seats)
VALUES
('WP ND-4589', 1, 6.9271, 79.8612, 0.0, 40);
SELECT * FROM Live_Tracking;

--Test Reservation
INSERT INTO Reservations
    (Passenger_ID, Bus_No, Schedule_ID, Seat_Number, Ticket_No)
VALUES
    (2, 'WP ND-4589', 1, 6, 'TICKET-005');

-- Check seat status
SELECT * FROM Seat_Availability
WHERE Schedule_ID = 1 AND Seat_No = 6;

-- Check available seats in Live_Tracking
SELECT * FROM Live_Tracking
WHERE Bus_No = 'WP ND-4589';


-- Entry 1: set price explicitly
INSERT INTO Reservations
    (Passenger_ID, Bus_No, Schedule_ID, Seat_Number, Price)
VALUES
    (4, 'CP NE-8812', 5, 10, 2000.00);

-- Entry 2: price = NULL ? use default 1500.00
INSERT INTO Reservations
    (Passenger_ID, Bus_No, Schedule_ID, Seat_Number, Price)
VALUES
    (3, 'WP ND-4589', 1, 7, NULL);

Select * From Reservations;
Select * From Tickets;

-- Cancel reservation with Reservation_ID
DELETE FROM Reservations
WHERE Reservation_ID = 20;

Select * From Reservations;
Select * From Tickets;



-- 1. How many seats are available for schedule 1?
SELECT *
FROM Seat_Availability
WHERE Schedule_ID = 1
ORDER BY Seat_No;

-- 2. Live_Tracking for that bus
SELECT *
FROM Live_Tracking
WHERE Bus_No = 'WP ND-4589';

-- 3. Any existing reservations for that bus/schedule?
SELECT *
FROM Reservations
WHERE Bus_No = 'WP ND-4589' AND Schedule_ID = 1;

use BusBookingSystem_Fresh;
Select * From Users;
Select * From Buses;
Select * From Routes;
Select * From Route_Stops;
Select * From Tickets;
Select * From Schedules;
Select * From Live_Tracking;
Select * From Seat_Availability;
Select * From Reservations;
Select* From Traffic_Logs;

UPDATE Tickets SET Price = 2500.00 WHERE Ticket_No = 'TICKET-0019';

--Check which seats are available
SELECT Seat_No FROM Seat_Availability WHERE Schedule_ID = 1 AND IsAvailable = 0 ORDER BY Seat_No;

--Show schedule options for a route or bus:
SELECT Schedule_ID, Bus_No, Route_No, Departure_Time, Arrival_Time FROM Schedules WHERE Route_No = 'EX 1-1';

--Show reservations with passenger name and ticket:
SELECT r.Reservation_ID, u.User_ID, r.Bus_No, r.Seat_Number, t.Ticket_No, t.Price 
FROM Reservations r JOIN Users u ON r.Passenger_ID = u.User_ID 
LEFT JOIN Tickets t ON r.Ticket_No = t.Ticket_No WHERE r.Schedule_ID = 1;

--Available seats per bus (from Seat_Availability):
SELECT s.Bus_No, SUM(CASE WHEN sa.IsAvailable = 1 THEN 1 ELSE 0 END) AS AvailableSeats 
FROM Schedules s JOIN Seat_Availability sa ON s.Schedule_ID = sa.Schedule_ID GROUP BY s.Bus_No;

--Ticket Price
SELECT Ticket_No, Reservation_ID, Price
FROM Tickets
ORDER BY Price DESC;