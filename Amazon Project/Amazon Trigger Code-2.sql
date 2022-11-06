CREATE Trigger validate_email_format
BEFORE INSERT ON customer_information_dimension
BEGIN 
	SELECT CASE WHEN NEW.email NOT LIKE "%@%._%"
    THEN RAISE (ABORT, "Invalid email formate")
    END;
    
END


CREATE Trigger validate_phone_number
BEFORE INSERT ON carrier_dimension
BEGIN 
	SELECT CASE WHEN NEW.PhoneNumber NOT LIKE "%____-____-____%"
    THEN RAISE (ABORT, "Invalid phone number")
    END;
    
END

CREATE Trigger validate_postal_code
BEFORE INSERT ON carrier_dimension
BEGIN 
	SELECT CASE WHEN NEW.PostCode NOT LIKE "___ ___"
    THEN RAISE (ABORT, "Invalid postal code")
    END;
    
END

