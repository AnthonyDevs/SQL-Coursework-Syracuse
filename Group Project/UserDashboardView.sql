drop view if exists UserDashboardView
go

CREATE VIEW UserDashboardView AS
SELECT 
    u.username AS UserUsername,
    u.user_name AS UserName,
    u.user_age AS UserAge,
    u.user_gender AS UserGender,
    u.user_fitness_focus AS FitnessFocus,
    u.user_zip_code AS ZipCode,
    u.user_availability AS Availability,
    t.trainer_name AS MatchedTrainerName,
    t.trainer_fitness_focus AS TrainerFitnessFocus,
    t.trainer_rate AS TrainerRate,
    m.distance as Distance,
    m.match_date AS MatchDate
FROM 
    Users u
LEFT JOIN 
    Matches m ON u.username = m.user_username
LEFT JOIN 
    Trainers t ON m.trainer_username = t.username;
GO

SELECT * FROM UserDashboardView