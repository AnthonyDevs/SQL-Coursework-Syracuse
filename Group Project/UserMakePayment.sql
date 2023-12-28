USE trainerlink;
GO

Drop PROCEDURE if EXISTS MakePayment
GO

CREATE PROCEDURE MakePayment 
    @userUsername NVARCHAR(50),
    @trainerUsername NVARCHAR(50),
    @hoursTrained INT,
    @paymentMethod VARCHAR(100)
AS
BEGIN
    DECLARE @rate DECIMAL(10, 2);
    DECLARE @total DECIMAL(10, 2);
    DECLARE @matchId INT;

    SELECT @rate = trainer_rate FROM Trainers WHERE username = @trainerUsername;

    SET @total = @rate * @hoursTrained;

    SELECT @matchId = match_id 
    FROM Matches
    WHERE user_username = @userUsername AND trainer_username = @trainerUsername;

    IF @matchId IS NOT NULL
    BEGIN
        INSERT INTO Payments (payment_hours, payment_total, payment_date, payment_currency, payment_method, match_id)
        VALUES (@hoursTrained, @total, GETDATE(), 'USD', @paymentMethod, @matchId);
    END
    ELSE
    BEGIN
        -- Handle the case when there is no matching record in Matches table
        THROW 50000, 'No matching record found for the given user and trainer.', 1;
    END
END;
GO


EXEC MakePayment 
    @userUsername = 'user30',
    @trainerUsername = 'trainer26',
    @hoursTrained = 3,
    @paymentMethod = 'Credit Card';

Select * from Payments



