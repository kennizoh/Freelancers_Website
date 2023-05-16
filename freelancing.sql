CREATE DATABASE freelancing;
USE freelancing;

-- Admins Table
CREATE TABLE Admins (
    AdminID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Salt VARCHAR(255) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    CreationTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdateTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Clients Table
CREATE TABLE Clients (
    ClientID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Salt VARCHAR(255) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    IsActive BOOLEAN DEFAULT TRUE,
    CreationTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdateTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Freelancers Table
CREATE TABLE Freelancers (
    FreelancerID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Salt VARCHAR(255) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    IsActive BOOLEAN DEFAULT TRUE,
    CreationTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdateTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Category Table
CREATE TABLE Category (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(50) UNIQUE NOT NULL
);

-- Profile Table
CREATE TABLE Profile (
    FreelancerID INT,
    CategoryID INT,
    Experience TEXT,
    Rates DECIMAL(10,2),
    PRIMARY KEY (FreelancerID, CategoryID),
    FOREIGN KEY (FreelancerID) REFERENCES Freelancers(FreelancerID),
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID),
    CreationTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdateTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- PortfolioLinks Table
CREATE TABLE PortfolioLinks (
    LinkID INT AUTO_INCREMENT PRIMARY KEY,
    FreelancerID INT,
    Link TEXT,
    FOREIGN KEY (FreelancerID) REFERENCES Freelancers(FreelancerID),
    CreationTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdateTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Job Table
CREATE TABLE Job (
    JobID INT AUTO_INCREMENT PRIMARY KEY,
    ClientID INT,
    CategoryID INT,
    JobTitle VARCHAR(100) NOT NULL,
    JobDescription TEXT NOT NULL,
    Budget INT NOT NULL,
    Deadline DATE NOT NULL,
    JobStatus ENUM('open', 'in progress', 'completed') NOT NULL,
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID),
    CreationTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdateTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Bid Table
CREATE TABLE Bid (
    BidID INT AUTO_INCREMENT PRIMARY KEY,
    JobID INT,
    FreelancerID INT,
    BidAmount INT NOT NULL,
    ProposalText TEXT NOT NULL,
    BidStatus ENUM('accepted', 'rejected', 'pending') NOT NULL,
    FOREIGN KEY (JobID) REFERENCES Job(JobID),
    FOREIGN KEY (FreelancerID) REFERENCES Freelancers(FreelancerID),
    CreationTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdateTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Message Table
CREATE TABLE Message (
    MessageID INT AUTO_INCREMENT PRIMARY KEY,
    ClientSenderID INT,
    FreelancerSenderID INT,
    ClientRecipientID INT,
    FreelancerRecipientID INT,
    JobID INT,
    MessageText TEXT,
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ClientSenderID) REFERENCES Clients(ClientID),
    FOREIGN KEY (FreelancerSenderID) REFERENCES Freelancers(FreelancerID),
    FOREIGN KEY (ClientRecipientID) REFERENCES Clients(ClientID),
    FOREIGN KEY (FreelancerRecipientID) REFERENCES Freelancers(FreelancerID),
    FOREIGN KEY (JobID) REFERENCES Job(JobID),
    CHECK ((ClientSenderID IS NOT NULL AND FreelancerSenderID IS NULL) OR 
           (ClientSenderID IS NULL AND FreelancerSenderID IS NOT NULL)),
    CHECK ((ClientRecipientID IS NOT NULL AND FreelancerRecipientID IS NULL) OR 
           (ClientRecipientID IS NULL AND FreelancerRecipientID IS NOT NULL))
);

-- Notification Table
CREATE TABLE Notification (
    NotificationID INT AUTO_INCREMENT PRIMARY KEY,
    AdminID INT,
    ClientID INT,
    FreelancerID INT,
    JobID INT,
    NotificationText TEXT,
    IsRead BOOLEAN DEFAULT FALSE,
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (AdminID) REFERENCES Admins(AdminID),
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
    FOREIGN KEY (FreelancerID) REFERENCES Freelancers(FreelancerID),
    FOREIGN KEY (JobID) REFERENCES Job(JobID),
    CHECK ((AdminID IS NOT NULL AND ClientID IS NULL AND FreelancerID IS NULL) OR 
           (AdminID IS NULL AND ClientID IS NOT NULL AND FreelancerID IS NULL) OR 
           (AdminID IS NULL AND ClientID IS NULL AND FreelancerID IS NOT NULL))
);

-- Dispute Table
CREATE TABLE Dispute (
    DisputeID INT AUTO_INCREMENT PRIMARY KEY,
    JobID INT,
    ClientID INT,
    FreelancerID INT,
    DisputeTitle VARCHAR(100) NOT NULL,
    DisputeDescription TEXT,
    Resolution TEXT,
    DisputeStatus ENUM('open', 'resolved'),
    FOREIGN KEY (JobID) REFERENCES Job(JobID),
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
    FOREIGN KEY (FreelancerID) REFERENCES Freelancers(FreelancerID),
    CreationTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdateTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Payment Table
CREATE TABLE Payment (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    ClientID INT,
    JobID INT,
    FreelancerID INT,
    AmountPaid INT,
    PaymentDueDate TIMESTAMP,
    PaymentMadeDate TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
    FOREIGN KEY (JobID) REFERENCES Job(JobID),
    FOREIGN KEY (FreelancerID) REFERENCES Freelancers(FreelancerID),
    CreationTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdateTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Review Table
CREATE TABLE Review (
    ReviewID INT AUTO_INCREMENT PRIMARY KEY,
    ClientID INT,
    FreelancerID INT,
    JobID INT,
    Rating INT CHECK (Rating >= 1 AND Rating <= 5),
    ReviewText TEXT,
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
    FOREIGN KEY (FreelancerID) REFERENCES Freelancers(FreelancerID),
    FOREIGN KEY (JobID) REFERENCES Job(JobID),
    CreationTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdateTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Stored Procedure for a Client's Jobs
DELIMITER //
CREATE PROCEDURE GetClientJobs(IN ClientID INT)
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Here, we can rollback or log the error
        ROLLBACK; 
        SELECT 'An unexpected error occurred while fetching the client jobs.';
    END;

    START TRANSACTION;

    SELECT JobID, JobTitle, JobDescription, CategoryName, Budget, Deadline 
    FROM Job 
    JOIN Category ON Job.CategoryID = Category.CategoryID
    WHERE Job.ClientID = ClientID;

    COMMIT;
END//
DELIMITER ;

-- Stored Procedure for a Freelancer's Bids
DELIMITER //
CREATE PROCEDURE GetFreelancerBids(IN FreelancerID INT)
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Here, we can rollback or log the error
        ROLLBACK; 
        SELECT 'An unexpected error occurred while fetching the freelancer bids.';
    END;

    START TRANSACTION;

    SELECT BidID, Job.JobID, BidAmount, ProposalText, BidStatus, CategoryName
    FROM Bid
    JOIN Job ON Bid.JobID = Job.JobID
    JOIN Category ON Job.CategoryID = Category.CategoryID
    WHERE Bid.FreelancerID = FreelancerID;

    COMMIT;
END//
DELIMITER ;

-- Stored Procedure for Jobs in a Freelancer's Categories
DELIMITER //
CREATE PROCEDURE GetJobsInFreelancerCategories(IN FreelancerID INT)
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Here, we can rollback or log the error
        ROLLBACK; 
        SELECT 'An unexpected error occurred while fetching jobs in freelancer categories.';
    END;

    START TRANSACTION;

    SELECT JobID, ClientID, JobTitle, JobDescription, Budget, Deadline
    FROM Job
    JOIN Profile ON Job.CategoryID = Profile.CategoryID
    WHERE Profile.FreelancerID = FreelancerID AND JobStatus = 'open';

    COMMIT;
END//
DELIMITER ;

CALL GetClientJobs(1);
CALL GetFreelancerBids(2);
CALL GetJobsInFreelancerCategories(2);

-- Indexes on Freelancer Table
CREATE INDEX idx_Freelancer_Username ON Freelancers(Username);

-- Indexes on Client Table
CREATE INDEX idx_Client_Username ON Clients(Username);

-- Index on Job Table
CREATE INDEX idx_Job_JobStatus ON Job(JobStatus);
CREATE INDEX idx_Job_ClientID ON Job(ClientID);

-- Indexes on Bid Table
CREATE INDEX idx_Bid_FreelancerID ON Bid(FreelancerID);
CREATE INDEX idx_Bid_JobID ON Bid(JobID);

-- Index on Message Table
CREATE INDEX idx_Message_ClientSenderID ON Message(ClientSenderID);
CREATE INDEX idx_Message_FreelancerSenderID ON Message(FreelancerSenderID);
CREATE INDEX idx_Message_ClientRecipientID ON Message(ClientRecipientID);
CREATE INDEX idx_Message_FreelancerRecipientID ON Message(FreelancerRecipientID);

-- Index on Review Table
CREATE INDEX idx_Review_ClientID ON Review(ClientID);
CREATE INDEX idx_Review_FreelancerID ON Review(FreelancerID);

-- Index on Payment Table
CREATE INDEX idx_Payment_ClientID ON Payment(ClientID);
CREATE INDEX idx_Payment_FreelancerID ON Payment(FreelancerID);

-- Index on Notification Table
CREATE INDEX idx_Notification_ClientID ON Notification(ClientID);
CREATE INDEX idx_Notification_FreelancerID ON Notification(FreelancerID);
CREATE INDEX idx_Notification_IsRead ON Notification(IsRead);

-- Index on Dispute Table
CREATE INDEX idx_Dispute_ClientID ON Dispute(ClientID);
CREATE INDEX idx_Dispute_FreelancerID ON Dispute(FreelancerID);
CREATE INDEX idx_Dispute_JobID ON Dispute(JobID);
CREATE INDEX idx_Dispute_DisputeStatus ON Dispute(DisputeStatus);

INSERT INTO Category (CategoryName) VALUES
('Finance'),
('Information Technology'),
('Nursing'),
('Business'),
('Engineering'),
('Marketing'),
('Accounting'),
('Human Resources'),
('Data Science'),
('Graphic Design'),
('Web Development'),
('Mobile Development'),
('Physics'),
('Chemistry'),
('Biology'),
('Environmental Science'),
('Sociology'),
('Psychology'),
('Political Science'),
('Economics'),
('Statistics'),
('Mathematics'),
('Education'),
('Hospitality Management'),
('Civil Engineering'),
('Mechanical Engineering'),
('Electrical Engineering'),
('Software Engineering'),
('Philosophy'),
('History');

