-- Insert 5 entries into Department table
INSERT INTO Department (Department_ID, Department_Name, Consultancy_fee) VALUES
('DEP001', 'Cardiology', 1500.00),
('DEP002', 'Neurology', 1200.00),
('DEP003', 'Orthopedics', 1000.00),
('DEP004', 'Dermatology', 800.00),
('DEP005', 'Pediatrics', 900.00);

-- Insert 5 entries into Patient table
INSERT INTO Patient (Patient_ID, Name, DOB, Age, Gender, Password, Street, City, State, Pincode) VALUES
('PAT001', 'John Doe', '1985-05-15', 40, 'Male', 'pass123', '123 Main St', 'Bangalore', 'Karnataka', '560001'),
('PAT002', 'Jane Smith', '1990-08-20', 35, 'Female', 'pass456', '456 Elm St', 'Bangalore', 'Karnataka', '560002'),
('PAT003', 'Mike Johnson', '1978-12-10', 46, 'Male', 'pass789', '789 Oak St', 'Bangalore', 'Karnataka', '560003'),
('PAT004', 'Emily Davis', '1995-03-25', 30, 'Female', 'passabc', '101 Pine St', 'Bangalore', 'Karnataka', '560004'),
('PAT005', 'Tom Wilson', '1982-07-30', 43, 'Male', 'passdef', '202 Cedar St', 'Bangalore', 'Karnataka', '560005');

-- Insert 5 entries into Doctor table
INSERT INTO Doctor (Doctor_ID, Department_ID, Doctor_Name, Phone, Email, Password) VALUES
('DOC001', 'DEP001', 'Dr. Alice Brown', '9876543210', 'alice@hospital.com', 'docpass1'),
('DOC002', 'DEP002', 'Dr. Bob Green', '9876543211', 'bob@hospital.com', 'docpass2'),
('DOC003', 'DEP003', 'Dr. Carol White', '9876543212', 'carol@hospital.com', 'docpass3'),
('DOC004', 'DEP004', 'Dr. David Lee', '9876543213', 'david@hospital.com', 'docpass4'),
('DOC005', 'DEP005', 'Dr. Eve Black', '9876543214', 'eve@hospital.com', 'docpass5');

-- Insert 5 entries into Appointment table
INSERT INTO Appointment (Appointment_ID, Patient_ID, Department_ID, Doctor_ID, Date, Time, Status) VALUES
('APP001', 'PAT001', 'DEP001', 'DOC001','2025-10-10',  '10:00:00', 'Scheduled'),
('APP002', 'PAT002', 'DEP002', 'DOC002', '2025-10-11',  '11:00:00', 'Completed'),
('APP003', 'PAT003', 'DEP003', 'DOC003', '2025-10-12',  '14:00:00', 'Scheduled'),
('APP004', 'PAT004', 'DEP004', 'DOC004','2025-10-13',  '15:00:00', 'Cancelled'),
('APP005', 'PAT005', 'DEP005', 'DOC005','2025-10-14',  '09:00:00', 'Rescheduled');

-- Insert 5 entries into Prescription table
INSERT INTO Prescription (Prescription_ID, Patient_ID, Doctor_ID, Appointment_ID, Date, Medicine, Description) VALUES
('PRE001', 'PAT001', 'DOC001', 'APP001', '2025-10-10', 'Aspirin', 'Take 1 tablet daily'),
('PRE002', 'PAT002', 'DOC002', 'APP002', '2025-10-11', 'Ibuprofen', 'For pain relief'),
('PRE003', 'PAT003', 'DOC003', 'APP003', '2025-10-12', 'Paracetamol', 'As needed for fever'),
('PRE004', 'PAT004', 'DOC004', 'APP004', '2025-10-13', 'Antibiotic', 'Complete course'),
('PRE005', 'PAT005', 'DOC005', 'APP005', '2025-10-14', 'Vitamin D', 'Daily supplement');

-- Insert 5 entries into Medical_Record table
INSERT INTO Medical_Record (Record_ID, Patient_ID, Doctor_ID, Date, Diagnosis, Treatment, Test_type, Lab_result) VALUES
('REC001', 'PAT001', 'DOC001', '2025-10-10', 'Hypertension', 'Lifestyle changes', 'Blood Pressure', '140/90'),
('REC002', 'PAT002', 'DOC002', '2025-10-11', 'Migraine', 'Rest and medication', 'MRI', 'Normal'),
('REC003', 'PAT003', 'DOC003', '2025-10-12', 'Fracture', 'Cast and rest', 'X-Ray', 'Broken bone'),
('REC004', 'PAT004', 'DOC004', '2025-10-13', 'Acne', 'Topical cream', 'Skin Test', 'Mild'),
('REC005', 'PAT005', 'DOC005', '2025-10-14', 'Fever', 'Antipyretic', 'Blood Test', 'Infection');

-- Insert 5 entries into Billing table
INSERT INTO Billing (Billing_ID, Appointment_ID, Patient_ID, Department_ID, Amount) VALUES
('BIL001', 'APP001', 'PAT001', 'DEP001', 1500.00),
('BIL002', 'APP002', 'PAT002', 'DEP002', 1200.00),
('BIL003', 'APP003', 'PAT003', 'DEP003', 1000.00),
('BIL004', 'APP004', 'PAT004', 'DEP004', 800.00),
('BIL005', 'APP005', 'PAT005', 'DEP005', 900.00);

-- Insert 5 entries into Creates table
INSERT INTO Creates (Record_ID, Prescription_ID, Doctor_ID) VALUES
('REC001', 'PRE001', 'DOC001'),
('REC002', 'PRE002', 'DOC002'),
('REC003', 'PRE003', 'DOC003'),
('REC004', 'PRE004', 'DOC004'),
('REC005', 'PRE005', 'DOC005');