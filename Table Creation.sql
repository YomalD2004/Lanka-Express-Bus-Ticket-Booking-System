-- 1. Create database and use it
Create DATABASE BusBookingSystem_Fresh;
GO

USE BusBookingSystem_Fresh;
GO


-- 2. Users table
CREATE TABLE Users (
    User_ID        INT           PRIMARY KEY IDENTITY(1,1),
    Name           NVARCHAR(100) NOT NULL,
    Email          NVARCHAR(150) NOT NULL UNIQUE,
    Password_Hash  NVARCHAR(255) NOT NULL,
    Phone_Number   NVARCHAR(20),
    User_Type      NVARCHAR(30)  NOT NULL
);
GO


-- 3. Buses table
CREATE TABLE Buses (
    Bus_Number      NVARCHAR(20)  PRIMARY KEY,
    Type            NVARCHAR(50)  NOT NULL,
    Seating_Capacity INT          NOT NULL CHECK (Seating_Capacity > 0)
);
GO


-- 4. Routes table
CREATE TABLE Routes (
    Route_No   NVARCHAR(20)  PRIMARY KEY,
    Distance   DECIMAL(6,2)  NOT NULL CHECK (Distance >= 0),
    Start_Point NVARCHAR(100) NOT NULL,
    End_Point   NVARCHAR(100) NOT NULL
);
GO


-- 5. Route_Stops table
CREATE TABLE Route_Stops (
    Route_No     NVARCHAR(20)  NOT NULL,
    Stop_Order   INT           NOT NULL,
    Stop_Name    NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_RouteStops PRIMARY KEY (Route_No, Stop_Order),
    CONSTRAINT FK_RouteStops_Route FOREIGN KEY (Route_No)
        REFERENCES Routes(Route_No) ON DELETE CASCADE
);
GO


-- 6. Schedules table
CREATE TABLE Schedules (
    Schedule_ID INT             PRIMARY KEY IDENTITY(1,1),
    Bus_No      NVARCHAR(20)    NOT NULL,
    Route_No    NVARCHAR(20)    NOT NULL,
    Departure_Time TIME(0)      NOT NULL,
    Arrival_Time   TIME(0)      NOT NULL,

    CONSTRAINT FK_Schedules_Bus FOREIGN KEY (Bus_No)
        REFERENCES Buses(Bus_Number) ON DELETE CASCADE,
    CONSTRAINT FK_Schedules_Route FOREIGN KEY (Route_No)
        REFERENCES Routes(Route_No) ON DELETE CASCADE
);
GO


-- 7. Seat_Availability table
CREATE TABLE Seat_Availability (
    Schedule_ID INT           NOT NULL,
    Seat_No     INT           NOT NULL,
    IsAvailable BIT           NOT NULL DEFAULT 1,

    CONSTRAINT PK_SeatAvailability PRIMARY KEY (Schedule_ID, Seat_No),
    CONSTRAINT FK_SeatAvailability_Schedule FOREIGN KEY (Schedule_ID)
        REFERENCES Schedules(Schedule_ID) ON DELETE CASCADE
);
GO


-- 8. Live_Tracking table (with available seats)
CREATE TABLE Live_Tracking (
    Bus_No           NVARCHAR(20)  NOT NULL,
    Log_ID           INT           NOT NULL,
    Latitude         DECIMAL(9,6)  NOT NULL,
    Longitude        DECIMAL(9,6)  NOT NULL,
    Speed            DECIMAL(5,2)  NOT NULL,
    Available_Seats  INT           NOT NULL CHECK (Available_Seats >= 0),

    CONSTRAINT PK_LiveTracking PRIMARY KEY (Bus_No, Log_ID),
    CONSTRAINT FK_LiveTracking_Bus FOREIGN KEY (Bus_No)
        REFERENCES Buses(Bus_Number) ON DELETE CASCADE
);
GO


-- 9. Traffic_Logs table
CREATE TABLE Traffic_Logs (
    Route_No           NVARCHAR(20)  NOT NULL,
    Log_ID             INT           NOT NULL,
    Congestion_Level   NVARCHAR(30)  NOT NULL,
    Road_Speed         DECIMAL(5,2)  NOT NULL,
    [Timestamp]        DATETIME2     NOT NULL,

    CONSTRAINT PK_TrafficLogs PRIMARY KEY (Route_No, Log_ID),
    CONSTRAINT FK_TrafficLogs_Route FOREIGN KEY (Route_No)
        REFERENCES Routes(Route_No) ON DELETE CASCADE
);
GO


-- 10. Reservations table
CREATE TABLE Reservations (
    Reservation_ID INT            PRIMARY KEY IDENTITY(1,1),
    Passenger_ID   INT            NOT NULL,
    Bus_No         NVARCHAR(20)   NOT NULL,
    Schedule_ID    INT            NOT NULL,
    Seat_Number    INT            NOT NULL,
    Ticket_No      NVARCHAR(20)   NOT NULL,

    CONSTRAINT FK_Reservations_Passenger FOREIGN KEY (Passenger_ID)
        REFERENCES Users(User_ID) ON DELETE NO ACTION,
    CONSTRAINT FK_Reservations_Bus FOREIGN KEY (Bus_No)
        REFERENCES Buses(Bus_Number) ON DELETE NO ACTION,
    CONSTRAINT FK_Reservations_Schedule FOREIGN KEY (Schedule_ID)
        REFERENCES Schedules(Schedule_ID) ON DELETE CASCADE
);
GO


-- 11. Tickets table
CREATE TABLE Tickets (
    Ticket_No       NVARCHAR(20)  PRIMARY KEY,
    Reservation_ID  INT           NOT NULL,
    Issue_Date      DATE          NOT NULL,
    Price           DECIMAL(8,2)  NOT NULL CHECK (Price >= 0),

    CONSTRAINT FK_Tickets_Reservation FOREIGN KEY (Reservation_ID)
        REFERENCES Reservations(Reservation_ID) ON DELETE CASCADE
);
GO


-- 12. TRIGGER: When a reservation is INSERTED

IF OBJECT_ID('trg_AfterReservationInsert', 'TR') IS NOT NULL
    DROP TRIGGER trg_AfterReservationInsert;
GO


-- Create the trigger
CREATE TRIGGER trg_AfterReservationInsert
ON Reservations
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON ;
    -- 1. Mark the seat as taken in Seat_Availability
    UPDATE sa
    SET IsAvailable = 0
    FROM Seat_Availability sa
    INNER JOIN inserted i
        ON sa.Schedule_ID = i.Schedule_ID
        AND sa.Seat_No = i.Seat_Number;

    -- 2. Deduct 1 seat from Live_Tracking (assuming one log row per bus)
    UPDATE lt
    SET lt.Available_Seats = lt.Available_Seats - 1
    FROM Live_Tracking lt
    INNER JOIN inserted i
        ON lt.Bus_No = i.Bus_No
    WHERE lt.Available_Seats > 0;

    -- 3. Trigger for insert a ticket automatically
    INSERT INTO Tickets (Ticket_No, Reservation_ID, Issue_Date, Price)
    SELECT
        i.Ticket_No,
        i.Reservation_ID,
        CAST(GETDATE() AS DATE),
        -- Example fixed price; adjust your logic
        1500.00
    FROM inserted i;
END;




-- 13. TRIGGER: When a reservation is DELETED (cancellation)

IF OBJECT_ID('trg_AfterReservationDelete', 'TR') IS NOT NULL
    DROP TRIGGER trg_AfterReservationDelete;
GO

CREATE TRIGGER trg_AfterReservationDelete
ON Reservations
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Mark seat as available again
    UPDATE sa
    SET IsAvailable = 1
    FROM Seat_Availability sa
    INNER JOIN deleted d
        ON sa.Schedule_ID = d.Schedule_ID
        AND sa.Seat_No = d.Seat_Number;

    -- 2. Add 1 seat back to Live_Tracking
    UPDATE lt
    SET lt.Available_Seats = lt.Available_Seats + 1
    FROM Live_Tracking lt
    INNER JOIN deleted d
        ON lt.Bus_No = d.Bus_No;
END;
GO

Select * From Seat_Availability;

ALTER TABLE Reservations
ADD Price DECIMAL(8,2) NULL;
GO

--Automatic Ticket Number Generation
IF OBJECT_ID('dbo.GenerateTicketNo', 'FN') IS NOT NULL
    DROP FUNCTION dbo.GenerateTicketNo;
GO

CREATE FUNCTION dbo.GenerateTicketNo (@ReservationID INT)
RETURNS NVARCHAR(20)
AS
BEGIN
    RETURN FORMAT(@ReservationID, 'TICKET-0000');
END;
GO

IF OBJECT_ID('trg_AfterReservationInsert', 'TR') IS NOT NULL
    DROP TRIGGER trg_AfterReservationInsert;
GO

CREATE TRIGGER trg_AfterReservationInsert
ON Reservations
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Mark seat as taken
    UPDATE sa
    SET IsAvailable = 0
    FROM Seat_Availability sa
    INNER JOIN inserted i
        ON sa.Schedule_ID = i.Schedule_ID
        AND sa.Seat_No = i.Seat_Number;

    -- 2. Deduct seat from Live_Tracking
    UPDATE lt
    SET lt.Available_Seats = lt.Available_Seats - 1
    FROM Live_Tracking lt
    INNER JOIN inserted i
        ON lt.Bus_No = i.Bus_No
    WHERE lt.Available_Seats > 0;

    -- 3. Generate Ticket_No from Reservation_ID and insert ticket
    INSERT INTO Tickets (Ticket_No, Reservation_ID, Issue_Date, Price)
    SELECT
        dbo.GenerateTicketNo(i.Reservation_ID),
        i.Reservation_ID,
        CAST(GETDATE() AS DATE),
        COALESCE(i.Price, 1500.00)  -- fallback price if Price is NULL
    FROM inserted i;
END;
GO

ALTER TABLE Reservations
ALTER COLUMN Ticket_No NVARCHAR(20) NULL;
GO



IF OBJECT_ID('trg_AfterReservationInsert', 'TR') IS NOT NULL
    DROP TRIGGER trg_AfterReservationInsert;
GO


-- 1. Drop the existing trigger
IF OBJECT_ID('trg_AfterReservationInsert', 'TR') IS NOT NULL
    DROP TRIGGER trg_AfterReservationInsert;
GO

-- 2. Now create the fixed trigger (with update back to Reservations)
CREATE TRIGGER trg_AfterReservationInsert
ON Reservations
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Mark seat as taken
    UPDATE sa
    SET IsAvailable = 0
    FROM Seat_Availability sa
    INNER JOIN inserted i
        ON sa.Schedule_ID = i.Schedule_ID
        AND sa.Seat_No = i.Seat_Number;

    -- 2. Deduct seat from Live_Tracking
    UPDATE lt
    SET lt.Available_Seats = lt.Available_Seats - 1
    FROM Live_Tracking lt
    INNER JOIN inserted i
        ON lt.Bus_No = i.Bus_No
    WHERE lt.Available_Seats > 0;

    -- 3. Insert ticket with auto generated Ticket_No and Price
    INSERT INTO Tickets (Ticket_No, Reservation_ID, Issue_Date, Price)
    SELECT
        dbo.GenerateTicketNo(i.Reservation_ID),
        i.Reservation_ID,
        CAST(GETDATE() AS DATE),
        COALESCE(i.Price, 1500.00)
    FROM inserted i;

    -- 4. Update Ticket_No and Price back into Reservations
    UPDATE r
    SET
        r.Ticket_No = t.Ticket_No,
        r.Price     = t.Price
    FROM Reservations r
    INNER JOIN inserted i ON r.Reservation_ID = i.Reservation_ID
    INNER JOIN Tickets t ON t.Reservation_ID = i.Reservation_ID;
END;

SELECT * FROM Reservations;
SELECT * FROM Tickets;

-- Recompute from Seat_Availability 
DECLARE @AvailableSeats INT = (
    SELECT COUNT(*)
    FROM Seat_Availability sa
    INNER JOIN Schedules sch ON sch.Schedule_ID = sa.Schedule_ID
    WHERE sch.Bus_No = 'WP ND-4589'
      AND sch.Schedule_ID = 1
      AND sa.IsAvailable = 1
);

UPDATE Live_Tracking
SET Available_Seats = @AvailableSeats
WHERE Bus_No = 'WP ND-4589';
GO


-- a) Delete all reservations
DELETE FROM Reservations
WHERE Bus_No = 'WP ND-4589';

-- b) Reset all seats to available
UPDATE Seat_Availability
SET IsAvailable = 1
WHERE Schedule_ID IN (
    SELECT Schedule_ID
    FROM Schedules
    WHERE Bus_No = 'WP ND-4589'
);

select * from Schedules; 

USE BusBookingSystem_Fresh;
GO

INSERT INTO Live_Tracking (Bus_No, Log_ID, Latitude, Longitude, Speed, Available_Seats)
SELECT
    b.Bus_Number,
    1 AS Log_ID,
    6.9271 AS Latitude,
    79.8612 AS Longitude,
    0.0 AS Speed,
    b.Seating_Capacity AS Available_Seats
FROM Buses b
WHERE b.Bus_Number IN (
    'WP ND-4589',
    'WP ND-9024',
    'SP ND-7731',
    'NP NC-1209',
    'CP NE-8812',
    'CP NE-9944',
    'SP NE-5050',
    'WP ND-2026'
)
  AND NOT EXISTS (
      SELECT 1
      FROM Live_Tracking lt
      WHERE lt.Bus_No = b.Bus_Number
        AND lt.Log_ID = 1
  );
GO

-- Update Available_Seats from current Seat_Availability for those 8 buses
UPDATE lt
SET Available_Seats = (
    SELECT COUNT(*)
    FROM Seat_Availability sa
    INNER JOIN Schedules s ON s.Schedule_ID = sa.Schedule_ID
    WHERE s.Bus_No = lt.Bus_No
      AND sa.IsAvailable = 1
)
FROM Live_Tracking lt
WHERE lt.Bus_No IN (
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

SELECT
    lt.Bus_No,
    lt.Available_Seats,
    b.Seating_Capacity
FROM Live_Tracking lt
INNER JOIN Buses b ON b.Bus_Number = lt.Bus_No
WHERE lt.Bus_No IN (
    'WP ND-4589',
    'WP ND-9024',
    'SP ND-7731',
    'NP NC-1209',
    'CP NE-8812',
    'CP NE-9944',
    'SP NE-5050',
    'WP ND-2026'
)
ORDER BY lt.Bus_No;

Select * From Schedules;



IF OBJECT_ID('trg_UpdateReservationPriceFromTicket', 'TR') IS NOT NULL
    DROP TRIGGER trg_UpdateReservationPriceFromTicket;
GO

CREATE TRIGGER trg_UpdateReservationPriceFromTicket
ON Tickets
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- If Price changed, update linked Reservations
    IF UPDATE(Price)
    BEGIN
        UPDATE r
        SET r.Price = i.Price
        FROM Reservations r
        INNER JOIN inserted i ON r.Ticket_No = i.Ticket_No
        INNER JOIN deleted d ON d.Ticket_No = i.Ticket_No
        WHERE i.Price != d.Price;  -- only when price changed
    END
END;
GO

IF OBJECT_ID('trg_UpdateTicketPriceFromReservation', 'TR') IS NOT NULL
    DROP TRIGGER trg_UpdateTicketPriceFromReservation;
GO

CREATE TRIGGER trg_UpdateTicketPriceFromReservation
ON Reservations
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- If Price changed, update linked Tickets
    IF UPDATE(Price)
    BEGIN
        UPDATE t
        SET t.Price = i.Price
        FROM Tickets t
        INNER JOIN inserted i ON t.Ticket_No = i.Ticket_No
        INNER JOIN deleted d ON d.Ticket_No = i.Ticket_No
        WHERE i.Price != d.Price;  -- only when price changed
    END
END;
GO
