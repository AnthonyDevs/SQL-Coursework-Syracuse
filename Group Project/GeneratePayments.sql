USE trainerlink;
GO

DROP PROCEDURE IF EXISTS GenerateWorkoutSessionsAndPayments;
GO

CREATE PROCEDURE GenerateWorkoutSessionsAndPayments
AS
BEGIN
    CREATE TABLE #WorkoutSessions (
        match_id INT,
        workout_hours INT,
        payment_total DECIMAL(10, 2)
    );

    INSERT INTO #WorkoutSessions (match_id, workout_hours, payment_total)
    SELECT 
        m.match_id,
        1 AS workout_hours,
        t.trainer_rate * 1 AS payment_total
    FROM 
        Matches m
    INNER JOIN 
        Trainers t ON m.trainer_username = t.username;

    INSERT INTO Payments (payment_hours, payment_total, payment_date, payment_currency, payment_method, match_id)
    SELECT 
        ws.workout_hours, 
        ws.payment_total, 
        GETDATE(), 
        'USD', 
        'Credit Card',
        ws.match_id
    FROM 
        #WorkoutSessions ws;
        
    DROP TABLE #WorkoutSessions;
END;
GO

EXEC GenerateWorkoutSessionsAndPayments;
GO
