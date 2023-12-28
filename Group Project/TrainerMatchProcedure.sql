USE trainerlink;
GO

DROP PROCEDURE IF EXISTS MatchUsersWithTrainers;
GO

CREATE PROCEDURE MatchUsersWithTrainers AS
BEGIN
    CREATE TABLE #MatchedPairs (
        user_username NVARCHAR(50),
        trainer_username NVARCHAR(50),
        distance NVARCHAR(50)
    );

    INSERT INTO #MatchedPairs (user_username, trainer_username, distance)
    SELECT u.username,
    t.username,
    CASE
        when LEFT(u.user_zip_code, 3) = LEFT(t.trainer_zip_code, 3) then 'Close Proximity'
        when LEFT(u.user_zip_code, 2) = LEFT(t.trainer_zip_code, 2) then 'Same State'
        when LEFT(u.user_zip_code, 1) = LEFT(t.trainer_zip_code, 1) then 'Same Region'
        else 'Not Nearby'
    end as Distance
        FROM Users u
        JOIN Trainers t ON u.user_fitness_focus = t.trainer_fitness_focus
        WHERE u.user_availability = t.trainer_availability;

    INSERT INTO Matches (user_username, trainer_username, match_date, distance)
    SELECT mp.user_username, mp.trainer_username, GETDATE(), mp.Distance
    FROM #MatchedPairs mp;

    DROP TABLE #MatchedPairs;
END;
GO

EXEC MatchUsersWithTrainers;