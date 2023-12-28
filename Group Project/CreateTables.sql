-- Creating the Trainers Table
CREATE TABLE Trainers (
    username NVARCHAR(50) PRIMARY KEY,
    trainer_name NVARCHAR(100) NOT NULL,
    trainer_age INT NOT NULL,
    trainer_gender VARCHAR(50) NOT NULL,
    trainer_fitness_focus VARCHAR(100) NOT NULL,
    trainer_zip_code VARCHAR(10) NOT NULL,
    trainer_credentials VARCHAR(MAX),
    trainer_availability VARCHAR(MAX),
    trainer_rate DECIMAL(10, 2) NOT NULL,
    trainer_distance INT
);

-- Creating the Users Table
CREATE TABLE Users (
    username NVARCHAR(50) PRIMARY KEY,
    user_name NVARCHAR(100) NOT NULL,
    user_age INT NOT NULL,
    user_gender VARCHAR(50) NOT NULL,
    user_fitness_focus VARCHAR(100) NOT NULL,
    user_zip_code VARCHAR(10) NOT NULL,
    user_availability VARCHAR(MAX),
    user_distance INT
);

-- Creating the Matches Table with match_id as an identity column
CREATE TABLE Matches (
    match_id INT IDENTITY(1,1) PRIMARY KEY,
    user_username NVARCHAR(50) NOT NULL,
    trainer_username NVARCHAR(50) NOT NULL,
    match_date DATE NOT NULL,
    Distance NVARCHAR(50),
    FOREIGN KEY (user_username) REFERENCES Users(username),
    FOREIGN KEY (trainer_username) REFERENCES Trainers(username)
);

-- Creating the Locations Table
CREATE TABLE Locations (
    location_id INT PRIMARY KEY,
    gym_name NVARCHAR(100) NOT NULL,
    gym_zip VARCHAR(10) NOT NULL,
    gym_state VARCHAR(50) NOT NULL,
    gym_city NVARCHAR(50) NOT NULL
);

CREATE TABLE Payments (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    payment_hours INT NOT NULL,
    payment_total DECIMAL(10, 2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_currency VARCHAR(50) NOT NULL,
    payment_method VARCHAR(100) NOT NULL,
    match_id INT NOT NULL,
    FOREIGN KEY (match_id) REFERENCES Matches(match_id)
);
