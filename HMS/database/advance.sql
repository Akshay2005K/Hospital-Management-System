-- ====================================
--             Functions
-- ====================================

DELIMITER $$

CREATE FUNCTION fn_GenerateID(prefix VARCHAR(10), table_name VARCHAR(50))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE next_id VARCHAR(20);
    DECLARE max_num INT DEFAULT 0;

    IF table_name = 'Patient' THEN
        SELECT COALESCE(MAX(CAST(SUBSTRING(Patient_ID, LENGTH(prefix) + 1) AS UNSIGNED)), 0)
        INTO max_num
        FROM Patient;

    ELSEIF table_name = 'Doctor' THEN
        SELECT COALESCE(MAX(CAST(SUBSTRING(Doctor_ID, LENGTH(prefix) + 1) AS UNSIGNED)), 0)
        INTO max_num
        FROM Doctor;

    ELSEIF table_name = 'Appointment' THEN
        SELECT COALESCE(MAX(CAST(SUBSTRING(Appointment_ID, LENGTH(prefix) + 1) AS UNSIGNED)), 0)
        INTO max_num
        FROM Appointment;

    ELSEIF table_name = 'Prescription' THEN
        SELECT COALESCE(MAX(CAST(SUBSTRING(Prescription_ID, LENGTH(prefix) + 1) AS UNSIGNED)), 0)
        INTO max_num
        FROM Prescription;

    ELSEIF table_name = 'Medical_Record' THEN
        SELECT COALESCE(MAX(CAST(SUBSTRING(Record_ID, LENGTH(prefix) + 1) AS UNSIGNED)), 0)
        INTO max_num
        FROM Medical_Record;

    ELSEIF table_name = 'Billing' THEN
        SELECT COALESCE(MAX(CAST(SUBSTRING(Billing_ID, LENGTH(prefix) + 1) AS UNSIGNED)), 0)
        INTO max_num
        FROM Billing;

    ELSE
        SET max_num = 0;
    END IF;

    SET next_id = CONCAT(prefix, LPAD(max_num + 1, 3, '0'));

    RETURN next_id;
END$$



CREATE FUNCTION fn_CalculateAge(dob DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE age INT;
    SET age = TIMESTAMPDIFF(YEAR, dob, CURDATE());
    RETURN age;
END$$


CREATE FUNCTION fn_GetAvailableDoctor(
    dept_id VARCHAR(10),
    appointment_date DATE,
    appointment_time TIME
)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE available_doctor_id VARCHAR(10);

    SELECT D.Doctor_ID
    INTO available_doctor_id
    FROM Doctor D
    WHERE D.Department_ID = dept_id
      AND D.Doctor_ID NOT IN (
          SELECT A.Doctor_ID
          FROM Appointment A
          WHERE A.Date = appointment_date
            AND A.Time = appointment_time
            AND A.Status IN ('Scheduled', 'Rescheduled')
      )
    LIMIT 1;

    RETURN available_doctor_id;
END$$

DELIMITER ;



-- ====================================
--             Procedures
-- ====================================

DELIMITER $$

CREATE PROCEDURE sp_Register_Patient(
    IN p_name VARCHAR(100),
    IN p_dob DATE,
    IN p_gender ENUM('Male','Female','Other'),
    IN p_password VARCHAR(255),
    IN p_street VARCHAR(200),
    IN p_city VARCHAR(100),
    IN p_state VARCHAR(100),
    IN p_pincode VARCHAR(10),
    OUT out_patient_id VARCHAR(10)
)
BEGIN
    DECLARE new_id VARCHAR(10);

    -- Generate new patient ID
    SET new_id = fn_GenerateID('PAT', 'Patient');

    -- Insert patient
    INSERT INTO Patient (Patient_ID, Name, DOB, Age, Gender, Password, Street, City, State, Pincode)
    VALUES (
        new_id,
        p_name,
        p_dob,
        fn_CalculateAge(p_dob),
        p_gender,
        p_password,
        p_street,
        p_city,
        p_state,
        p_pincode
    );

    -- Return generated ID
    SET out_patient_id = new_id;
END$$

CREATE PROCEDURE sp_Patient_Login(
    IN p_patient_id VARCHAR(10)
)
BEGIN
    SELECT Patient_ID, Name, DOB, Age, Gender, Password, Street, City, State, Pincode
    FROM Patient
    WHERE Patient_ID = p_patient_id;
END$$


CREATE PROCEDURE sp_Doctor_Register(
    IN p_name VARCHAR(100),
    IN p_department_id VARCHAR(10),
    IN p_phone VARCHAR(15),
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(255),
    OUT out_doctor_id VARCHAR(10)
)
BEGIN
    DECLARE new_id VARCHAR(10);

    -- Generate new doctor ID
    SET new_id = fn_GenerateID('DOC', 'Doctor');

    -- Insert doctor
    INSERT INTO Doctor (Doctor_ID, Department_ID, Doctor_Name, Phone, Email, Password)
    VALUES (new_id, p_department_id, p_name, p_phone, p_email, p_password);

    -- Return generated Doctor_ID
    SET out_doctor_id = new_id;
END$$


CREATE PROCEDURE sp_Book_Appointment(
    IN p_patient_id VARCHAR(10),
    IN p_department_id VARCHAR(10),
    IN p_requested_date DATE,
    IN p_requested_time TIME,
    IN p_issue_description TEXT,
    OUT out_appointment_id VARCHAR(10),
    OUT out_amount DECIMAL(10,2)
)
BEGIN
    DECLARE assigned_doctor_id VARCHAR(10);
    DECLARE new_billing_id VARCHAR(10);

    -- Find a free doctor
    SET assigned_doctor_id = fn_GetAvailableDoctor(p_department_id, p_requested_date, p_requested_time);

    IF assigned_doctor_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No doctor available at the requested slot';
    END IF;

    -- Generate new Appointment ID
    SET out_appointment_id = fn_GenerateID('APP', 'Appointment');

    -- Get department consultancy fee
    SELECT Consultancy_fee INTO out_amount
    FROM Department
    WHERE Department_ID = p_department_id;

    -- Insert Appointment (status 'Scheduled')
    INSERT INTO Appointment (
        Appointment_ID, Patient_ID, Department_ID, Doctor_ID, Date, Time, Status
    )
    VALUES (
        out_appointment_id, p_patient_id, p_department_id, assigned_doctor_id,
        p_requested_date, p_requested_time, 'Scheduled'
    );

    -- Generate new Billing ID
    SET new_billing_id = fn_GenerateID('BILL', 'Billing');

    -- Insert into Billing table
    INSERT INTO Billing (
        Billing_ID, Appointment_ID, Patient_ID, Department_ID, Amount, Billing_Status
    )
    VALUES (
        new_billing_id, out_appointment_id, p_patient_id, p_department_id, out_amount, 'Pending'
    );

END$$




CREATE PROCEDURE Generate_Billing_Record(
    IN p_appointment_id VARCHAR(10),
    IN p_patient_id VARCHAR(10),
    OUT out_billing_id VARCHAR(10),
    OUT out_amount DECIMAL(10,2)
)
BEGIN
    DECLARE dept_id VARCHAR(10);
    DECLARE fee DECIMAL(10,2);

    
    SELECT A.Department_ID, D.Consultancy_fee
    INTO dept_id, fee
    FROM Appointment A
    JOIN Department D ON A.Department_ID = D.Department_ID
    WHERE A.Appointment_ID = p_appointment_id;

    -- Generate new Billing ID
    SET out_billing_id = CONCAT('BILL', LPAD(FLOOR(RAND() * 9999), 4, '0'));

    -- Set output amount
    SET out_amount = fee;

    -- Insert billing record with status 'Pending'
    INSERT INTO Billing (Billing_ID, Appointment_ID, Patient_ID, Department_ID, Amount, Billing_Status)
    VALUES (out_billing_id, p_appointment_id, p_patient_id, dept_id, out_amount, 'Pending');
END$$




CREATE PROCEDURE sp_Doctor_Mark_Completed(
    IN p_appointment_id VARCHAR(10),
    IN p_doctor_id VARCHAR(10)
)
BEGIN
    DECLARE patient_id VARCHAR(10);
    DECLARE department_id VARCHAR(10);
    DECLARE dept_fee DECIMAL(10,2);
    DECLARE billing_exists INT;

    -- Fetch appointment info
    SELECT Patient_ID, Department_ID INTO patient_id, department_id
    FROM Appointment
    WHERE Appointment_ID = p_appointment_id AND Doctor_ID = p_doctor_id;

    -- Update appointment status to Completed
    UPDATE Appointment
    SET Status = 'Completed'
    WHERE Appointment_ID = p_appointment_id;

    -- Check if billing already exists
    SELECT COUNT(*) INTO billing_exists
    FROM Billing
    WHERE Appointment_ID = p_appointment_id;

    IF billing_exists = 0 THEN
        -- Get department fee
        SELECT Consultancy_fee INTO dept_fee
        FROM Department
        WHERE Department_ID = department_id;

        -- Create billing
        INSERT INTO Billing (Billing_ID, Appointment_ID, Patient_ID, Department_ID, Amount)
        VALUES (
            fn_GenerateID('BIL', 'Billing'),
            p_appointment_id,
            patient_id,
            department_id,
            dept_fee
        );
    END IF;


END$$


CREATE PROCEDURE sp_Add_Current_Medical_Record(
    IN p_appointment_id VARCHAR(10),
    IN p_patient_id VARCHAR(10),
    IN p_doctor_id VARCHAR(10),
    IN p_diagnosis TEXT,
    IN p_treatment TEXT,
    IN p_test_type VARCHAR(100),
    IN p_lab_result TEXT,
    OUT out_record_id VARCHAR(10)
)
BEGIN
    DECLARE today DATE;
    SET today = CURDATE();

    -- Ensure appointment is today
    IF NOT EXISTS (
        SELECT 1 FROM Appointment
        WHERE Appointment_ID = p_appointment_id
          AND Patient_ID = p_patient_id
          AND Doctor_ID = p_doctor_id
          AND Date = today
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Medical record can only be added on the current appointment date.';
    END IF;

    -- Generate Record_ID
    SET out_record_id = fn_GenerateID('REC', 'Medical_Record');

    -- Insert Medical Record
    INSERT INTO Medical_Record (Record_ID, Patient_ID, Doctor_ID, Date, Diagnosis, Treatment, Test_type, Lab_result)
    VALUES (out_record_id, p_patient_id, p_doctor_id, today, p_diagnosis, p_treatment, p_test_type, p_lab_result);

END$$





CREATE PROCEDURE sp_Add_Prescription(
    IN p_appointment_id VARCHAR(10),
    IN p_patient_id VARCHAR(10),
    IN p_doctor_id VARCHAR(10),
    IN p_medicine VARCHAR(200),
    IN p_description TEXT,
    OUT out_prescription_id VARCHAR(10)
)
BEGIN
    DECLARE today DATE;
    DECLARE record_id VARCHAR(10);

    SET today = CURDATE();

    -- Ensure appointment is today
    IF NOT EXISTS (
        SELECT 1 FROM Appointment
        WHERE Appointment_ID = p_appointment_id
          AND Patient_ID = p_patient_id
          AND Doctor_ID = p_doctor_id
          AND Date = today
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Prescription can only be added on the current appointment date.';
    END IF;

    -- Generate Prescription ID
    SET out_prescription_id = fn_GenerateID('PRE', 'Prescription');

    -- Insert Prescription
    INSERT INTO Prescription (Prescription_ID, Patient_ID, Doctor_ID, Appointment_ID, Date, Medicine, Description)
    VALUES (out_prescription_id, p_patient_id, p_doctor_id, p_appointment_id, today, p_medicine, p_description);

    -- Link to latest medical record for this patient today
    SELECT Record_ID INTO record_id
    FROM Medical_Record
    WHERE Patient_ID = p_patient_id
      AND Doctor_ID = p_doctor_id
      AND Date = today
    ORDER BY Record_ID DESC
    LIMIT 1;

    IF record_id IS NOT NULL THEN
        INSERT INTO Creates (Record_ID, Prescription_ID, Doctor_ID)
        VALUES (record_id, out_prescription_id, p_doctor_id);
    END IF;

END$$


CREATE PROCEDURE sp_Get_Patient_Visits(
    IN p_patient_id VARCHAR(10)
)
BEGIN
    SELECT 
        A.Appointment_ID,
        A.Date AS Visit_Date,
        A.Doctor_ID,
        D.Doctor_Name,
        A.Status
    FROM Appointment A
    JOIN Doctor D ON A.Doctor_ID = D.Doctor_ID
    WHERE A.Patient_ID = p_patient_id
    ORDER BY A.Date DESC;
END$$


CREATE PROCEDURE sp_Get_Doctor_Today_Appointments(
    IN p_doctor_id VARCHAR(10),
    IN p_date DATE
)
BEGIN
    SELECT 
        A.Appointment_ID,
        A.Time,
        A.Patient_ID,
        P.Name AS Patient_Name,
        P.Age,
        P.Gender,
        A.Status
    FROM Appointment A
    JOIN Patient P ON A.Patient_ID = P.Patient_ID
    WHERE A.Doctor_ID = p_doctor_id
      AND A.Date = p_date
    ORDER BY A.Time ASC;
END$$


CREATE PROCEDURE sp_Cancel_Appointment (
    IN p_appointment_id VARCHAR(20)
)
BEGIN
    -- Check if appointment exists
    IF EXISTS (SELECT 1 FROM Appointment WHERE Appointment_ID = p_appointment_id) THEN
        UPDATE Appointment
        SET Status = 'Cancelled'
        WHERE Appointment_ID = p_appointment_id;
    END IF;
END$$


CREATE PROCEDURE sp_Reschedule_Appointment (
    IN p_appointment_id VARCHAR(20),
    IN p_new_date DATE,
    IN p_new_time TIME
)
BEGIN
    -- Check if appointment exists
    IF EXISTS (SELECT 1 FROM Appointment WHERE Appointment_ID = p_appointment_id) THEN
        UPDATE Appointment
        SET Date = p_new_date,
            Time = p_new_time,
            Status = 'Rescheduled'
        WHERE Appointment_ID = p_appointment_id;
    END IF;
END$$



DELIMITER ;


-- ====================================
--             Triggers
-- ====================================

DELIMITER $$

CREATE TRIGGER trg_before_insert_patient
BEFORE INSERT ON Patient
FOR EACH ROW
BEGIN
    -- Auto-calculate Age from DOB
    SET NEW.Age = fn_CalculateAge(NEW.DOB);

    -- Optional: auto-generate Patient_ID if not provided
    IF NEW.Patient_ID IS NULL OR NEW.Patient_ID = '' THEN
        SET NEW.Patient_ID = fn_GenerateID('PAT', 'Patient');
    END IF;
END$$

CREATE TRIGGER trg_before_insert_appointment
BEFORE INSERT ON Appointment
FOR EACH ROW
BEGIN
    -- Check if doctor is already booked for same date & time
    IF EXISTS (
        SELECT 1
        FROM Appointment
        WHERE Doctor_ID = NEW.Doctor_ID
          AND Date = NEW.Date
          AND Time = NEW.Time
          AND Status IN ('Scheduled', 'Rescheduled', 'Pending')
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor is already booked for this date and time.';
    END IF;

    -- Auto-generate Appointment_ID if not provided
    IF NEW.Appointment_ID IS NULL OR NEW.Appointment_ID = '' THEN
        SET NEW.Appointment_ID = fn_GenerateID('APP', 'Appointment');
    END IF;
END$$


CREATE TRIGGER trg_before_insert_medical_record
BEFORE INSERT ON Medical_Record
FOR EACH ROW
BEGIN
    -- Auto-generate Record_ID if not provided
    IF NEW.Record_ID IS NULL OR NEW.Record_ID = '' THEN
        SET NEW.Record_ID = fn_GenerateID('REC', 'Medical_Record');
    END IF;

    -- Ensure the record is for today
    IF NEW.Date <> CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Medical record can only be created for the current date.';
    END IF;

    -- Optional: prevent insertion for past dates explicitly
    IF NEW.Date < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot create medical record for a past date.';
    END IF;
END$$


CREATE TRIGGER trg_before_update_medical_record
BEFORE UPDATE ON Medical_Record
FOR EACH ROW
BEGIN
    DECLARE appointment_status ENUM('Scheduled','Completed','Cancelled','Rescheduled');

    -- Fetch the appointment status for this patient, doctor, and date
    SELECT Status
    INTO appointment_status
    FROM Appointment
    WHERE Patient_ID = OLD.Patient_ID
      AND Doctor_ID = OLD.Doctor_ID
      AND Date = OLD.Date
    LIMIT 1;

    -- Prevent updates if record date is not today
    IF OLD.Date <> CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot update medical records for past dates.';
    END IF;

    -- Prevent updates if appointment is completed
    IF appointment_status = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot update medical record after appointment is completed.';
    END IF;
END$$

DELIMITER ;
