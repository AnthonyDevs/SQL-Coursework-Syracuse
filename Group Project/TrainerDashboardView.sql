DROP VIEW IF EXISTS TrainerDashboardView;
GO

CREATE VIEW TrainerDashboardView AS
SELECT 
    t.username AS TrainerUsername,
    t.trainer_name AS TrainerName,
    t.trainer_rate AS TrainerRate,
    t.trainer_availability AS TrainerAvailability,
    u.user_name AS MatchedUserName,
    u.user_fitness_focus AS UserFitnessFocus,
    m.match_date AS SessionDate,
    p.payment_hours AS SessionHours,
    p.payment_total AS PaymentReceived,
    p.payment_date AS PaymentDate
FROM 
    Trainers t
LEFT JOIN 
    Matches m ON t.username = m.trainer_username
LEFT JOIN 
    Users u ON m.user_username = u.username
LEFT JOIN 
    Payments p ON m.match_id = p.match_id;
GO

SELECT * FROM TrainerDashboardView