CREATE DATABASE hms;

USE hms;

CREATE TABLE Department (
    Department_ID VARCHAR(10) PRIMARY KEY,
    Department_Name VARCHAR(100) NOT NULL,
    Consultancy_fee DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Patient (
    Patient_ID VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Age INT,
    Gender ENUM('Male', 'Female', 'Other') NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Street VARCHAR(200),
    City VARCHAR(100),
    State VARCHAR(100),
    Pincode VARCHAR(10)
);

CREATE TABLE Doctor (
    Doctor_ID VARCHAR(10) PRIMARY KEY,
    Department_ID VARCHAR(10),
    Doctor_Name VARCHAR(100) NOT NULL,
    Phone VARCHAR(15),
    Email VARCHAR(100),
    Password VARCHAR(255) NOT NULL,
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID)
);

CREATE TABLE Appointment (
    Appointment_ID VARCHAR(10) PRIMARY KEY,
    Patient_ID VARCHAR(10) NOT NULL,
    Department_ID VARCHAR(10) NOT NULL,
    Doctor_ID VARCHAR(10) NOT NULL,
    Date DATE NOT NULL,
    Time TIME NOT NULL,
    Status ENUM('Scheduled', 'Completed', 'Cancelled', 'Rescheduled') DEFAULT 'Scheduled',
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID),
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID),
    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID)
);

CREATE TABLE Prescription (
    Prescription_ID VARCHAR(10) PRIMARY KEY,
    Patient_ID VARCHAR(10) NOT NULL,
    Doctor_ID VARCHAR(10) NOT NULL,
    Appointment_ID VARCHAR(10) NOT NULL,
    Date DATE NOT NULL,
    Medicine VARCHAR(200) NOT NULL,
    Description TEXT,
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID),
    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID),
    FOREIGN KEY (Appointment_ID) REFERENCES Appointment(Appointment_ID)
);

CREATE TABLE Medical_Record (
    Record_ID VARCHAR(10) PRIMARY KEY,
    Patient_ID VARCHAR(10) NOT NULL,
    Doctor_ID VARCHAR(10) NOT NULL,
    Date DATE NOT NULL,
    Diagnosis TEXT,
    Treatment TEXT,
    Test_type VARCHAR(100),
    Lab_result TEXT,
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID),
    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID)
);

CREATE TABLE Billing (
    Billing_ID VARCHAR(10) PRIMARY KEY,
    Appointment_ID VARCHAR(10) NOT NULL,
    Patient_ID VARCHAR(10) NOT NULL,
    Department_ID VARCHAR(10) NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    Billing_Status ENUM('Pending','Paid') DEFAULT 'Pending',

    FOREIGN KEY (Appointment_ID) REFERENCES Appointment(Appointment_ID),
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID),
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID)
);

CREATE TABLE Creates (
    Record_ID VARCHAR(10) NOT NULL,
    Prescription_ID VARCHAR(10) NOT NULL,
    Doctor_ID VARCHAR(10) NOT NULL,
    PRIMARY KEY (Record_ID, Prescription_ID, Doctor_ID),
    FOREIGN KEY (Record_ID) REFERENCES Medical_Record(Record_ID),
    FOREIGN KEY (Prescription_ID) REFERENCES Prescription(Prescription_ID),
    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID)
);


