# hms_gui_with_autogen_signup.py
import tkinter as tk
from tkinter import ttk, messagebox
import mysql.connector
from datetime import datetime

# ------------------- DATABASE CONFIG -------------------
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'Akshay.2005.kumar',  # change if needed
    'database': 'hms'
}

# ------------------- MAIN CLASS -------------------
class HMS_GUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Hospital Management System")
        self.conn = None
        self.cursor = None
        self.current_user = None
        self.user_type = None
        self.connect_db()
        self.login_screen()

    # ---------------- DB CONNECTION ----------------
    def connect_db(self):
        try:
            self.conn = mysql.connector.connect(**DB_CONFIG)
            # buffered=True lets us iterate stored_results safely when using callproc
            self.cursor = self.conn.cursor(buffered=True)
        except mysql.connector.Error as err:
            messagebox.showerror("DB Error", f"Error connecting: {err}")
            exit()

    # ---------------- UTILITY ----------------
    def clear_window(self):
        for widget in self.root.winfo_children():
            widget.destroy()

    # ---------------- LOGIN SCREEN ----------------
    def login_screen(self):
        self.clear_window()
        tk.Label(self.root, text="🏥 Hospital Management System", font=("Arial", 18, "bold")).pack(pady=10)
        tk.Label(self.root, text="Login", font=("Arial", 14)).pack(pady=5)

        # Role combobox
        tk.Label(self.root, text="Select Role").pack()
        self.role_var = tk.StringVar(value="Patient")
        role_combo = ttk.Combobox(self.root, textvariable=self.role_var, values=["Patient", "Doctor"], state="readonly")
        role_combo.pack(pady=5)
        role_combo.current(0)



        # User ID and password
        tk.Label(self.root, text="User ID").pack()
        self.user_var = tk.StringVar()
        tk.Entry(self.root, textvariable=self.user_var).pack()

        tk.Label(self.root, text="Password").pack()
        self.pass_var = tk.StringVar()
        tk.Entry(self.root, textvariable=self.pass_var, show="*").pack()

        tk.Button(self.root, text="Login", command=self.authenticate, width=20, bg="lightblue").pack(pady=8)
        tk.Button(self.root, text="Sign Up", command=self.signup_screen, width=20).pack()

    # ---------------- AUTHENTICATION ----------------
    def authenticate(self):
        role = self.role_var.get().lower()
        user = self.user_var.get().strip()
        password = self.pass_var.get().strip()
        if not user or not password:
            messagebox.showerror("Error", "Please enter both User ID and Password")
            return

        if role == 'patient':
            query = "SELECT Patient_ID, Name FROM Patient WHERE Patient_ID=%s AND Password=%s"
        else:
            query = "SELECT Doctor_ID, Doctor_Name FROM Doctor WHERE Doctor_ID=%s AND Password=%s"
        try:
            self.cursor.execute(query, (user, password))
            res = self.cursor.fetchone()
            if res:
                self.current_user = res[0]
                self.user_type = role
                messagebox.showinfo("Success", f"Welcome {res[1]}!")
                if role == 'patient':
                    self.patient_menu()
                else:
                    self.doctor_menu()
            else:
                messagebox.showerror("Error", "Invalid credentials")
        except mysql.connector.Error as err:
            messagebox.showerror("Database Error", str(err))

    # ---------------- SIGNUP (auto-generate IDs via stored procedures) ----------------
    def signup_screen(self):
        self.clear_window()
        tk.Label(self.root, text="Sign Up", font=("Arial", 16, "bold")).pack(pady=10)

        tk.Label(self.root, text="Select Role").pack()
        self.signup_role = tk.StringVar(value="Patient")
        role_combo = ttk.Combobox(self.root, textvariable=self.signup_role, values=["Patient", "Doctor"], state="readonly")
        role_combo.pack(pady=5)
        role_combo.current(0)

        # Container frames for patient and doctor sections
        patient_frame = tk.Frame(self.root)
        doctor_frame = tk.Frame(self.root)

        # Common fields
        tk.Label(self.root, text="Full Name").pack()
        self.s_name = tk.StringVar()
        tk.Entry(self.root, textvariable=self.s_name).pack(pady=3)

        tk.Label(self.root, text="Password").pack()
        self.s_password = tk.StringVar()
        tk.Entry(self.root, textvariable=self.s_password, show="*").pack(pady=3)

        # ---------------- PATIENT FIELDS ----------------
        tk.Label(patient_frame, text="DOB (YYYY-MM-DD)").pack()
        self.s_dob = tk.StringVar()
        tk.Entry(patient_frame, textvariable=self.s_dob).pack(pady=3)

        tk.Label(patient_frame, text="Gender").pack()
        self.s_gender = tk.StringVar(value="Other")
        gender_combo = ttk.Combobox(patient_frame, textvariable=self.s_gender, values=["Male", "Female", "Other"], state="readonly")
        gender_combo.pack(pady=3)
        gender_combo.current(2)

        tk.Label(patient_frame, text="Street").pack()
        self.s_street = tk.StringVar()
        tk.Entry(patient_frame, textvariable=self.s_street).pack(pady=3)

        tk.Label(patient_frame, text="City").pack()
        self.s_city = tk.StringVar()
        tk.Entry(patient_frame, textvariable=self.s_city).pack(pady=3)

        tk.Label(patient_frame, text="State").pack()
        self.s_state = tk.StringVar()
        tk.Entry(patient_frame, textvariable=self.s_state).pack(pady=3)

        tk.Label(patient_frame, text="Pincode").pack()
        self.s_pincode = tk.StringVar()
        tk.Entry(patient_frame, textvariable=self.s_pincode).pack(pady=3)

        # ---------------- DOCTOR FIELDS ----------------
        tk.Label(doctor_frame, text="Department ID").pack()
        self.s_dept = tk.StringVar()
        tk.Entry(doctor_frame, textvariable=self.s_dept).pack(pady=3)

        tk.Label(doctor_frame, text="Phone").pack()
        self.s_phone = tk.StringVar()
        tk.Entry(doctor_frame, textvariable=self.s_phone).pack(pady=3)

        tk.Label(doctor_frame, text="Email").pack()
        self.s_email = tk.StringVar()
        tk.Entry(doctor_frame, textvariable=self.s_email).pack(pady=3)

        # Default show patient fields
        patient_frame.pack(pady=5)

        # Function to toggle between frames
        def toggle_role(*args):
            if self.signup_role.get() == "Patient":
                doctor_frame.pack_forget()
                patient_frame.pack(pady=5)
            else:
                patient_frame.pack_forget()
                doctor_frame.pack(pady=5)

        self.signup_role.trace_add("write", toggle_role)

        # ---------------- SUBMIT BUTTON ----------------
        def submit_signup():
            role = self.signup_role.get()
            name = self.s_name.get().strip()
            password = self.s_password.get().strip()

            if not name or not password:
                messagebox.showerror("Error", "Name and Password are required")
                return

            try:
                if role == "Patient":
                    dob = self.s_dob.get().strip() or None
                    gender = self.s_gender.get().strip() or 'Other'
                    street = self.s_street.get().strip() or None
                    city = self.s_city.get().strip() or None
                    state = self.s_state.get().strip() or None
                    pincode = self.s_pincode.get().strip() or None

                    args = [name, dob, gender, password, street, city, state, pincode, None]
                    result = self.cursor.callproc('sp_Register_Patient', args)
                    out_patient_id = result[-1]
                    self.conn.commit()
                    try:
                        while self.cursor.stored_results():
                            self.cursor.stored_results().__next__()
                    except Exception:
                        pass
                    messagebox.showinfo("Registered", f"Patient registered successfully. Patient ID: {out_patient_id}")
                else:
                    dept = self.s_dept.get().strip() or None
                    phone = self.s_phone.get().strip() or None
                    email = self.s_email.get().strip() or None

                    args = [name, dept, phone, email, password, None]
                    result = self.cursor.callproc('sp_Doctor_Register', args)
                    out_doctor_id = result[-1]
                    self.conn.commit()
                    try:
                        while self.cursor.stored_results():
                            self.cursor.stored_results().__next__()
                    except Exception:
                        pass
                    messagebox.showinfo("Registered", f"Doctor registered successfully. Doctor ID: {out_doctor_id}")

                self.login_screen()
                

            except mysql.connector.Error as err:
                messagebox.showerror("Database Error", str(err))
                self.conn.rollback()

        tk.Button(self.root, text="Register", command=submit_signup, width=20, bg="lightgreen").pack(pady=10)
        tk.Button(self.root, text="Back to Login", command=self.login_screen, width=20).pack()


    # ---------------- PATIENT MENU ----------------
    def patient_menu(self):
        self.clear_window()
        tk.Label(self.root, text="Patient Menu", font=("Arial", 16)).pack(pady=10)
        tk.Button(self.root, text="View Appointments", width=25, command=self.view_patient_appointments).pack(pady=5)
        tk.Button(self.root, text="Book Appointment", width=25, command=self.book_appointment).pack(pady=5)
        tk.Button(self.root, text="Cancel / Reschedule Appointment", width=25, command=self.cancel_or_reschedule).pack(pady=5)
        tk.Button(self.root, text="View Prescriptions", width=25, command=self.view_patient_prescriptions).pack(pady=5)
        tk.Button(self.root, text="View Billing", width=25, command=self.view_patient_billing).pack(pady=5)
        tk.Button(self.root, text="Pay Bill", width=25, command=self.pay_bill).pack(pady=5)
        tk.Button(self.root, text="Logout", width=25, command=self.login_screen).pack(pady=5)

    def pay_bill(self):
        self.clear_window()
        tk.Label(self.root, text="Pay Your Bills", font=("Arial", 16)).pack(pady=10)
        cols = ["Billing ID", "Appointment ID", "Amount", "Status"]
        tree = ttk.Treeview(self.root, columns=cols, show="headings")
        for col in cols:
            tree.heading(col, text=col)
        tree.pack(fill="both", expand=True)

        # fetch unpaid bills
        query = "SELECT Billing_ID, Appointment_ID, Amount, Billing_Status FROM Billing WHERE Patient_ID=%s AND Billing_Status='Unpaid'"
        try:
            self.cursor.execute(query, (self.current_user,))
            for row in self.cursor.fetchall():
                tree.insert("", "end", values=row)
        except mysql.connector.Error as err:
            messagebox.showerror("Error", str(err))

        tk.Label(self.root, text="Enter Billing ID to Pay:").pack(pady=5)
        bill_id_var = tk.StringVar()
        tk.Entry(self.root, textvariable=bill_id_var).pack(pady=5)

        def pay_selected():
            bill_id = bill_id_var.get().strip()
            if not bill_id:
                messagebox.showerror("Error", "Please enter a Billing ID to pay.")
                return
            try:
                # update payment status
                self.cursor.execute("UPDATE Billing SET Billing_Status='Paid' WHERE Billing_ID=%s AND Patient_ID=%s", (bill_id, self.current_user))
                self.conn.commit()

                # confirm appointment automatically
                self.cursor.execute("UPDATE Appointment SET Status='Confirmed' WHERE Appointment_ID=(SELECT Appointment_ID FROM Billing WHERE Billing_ID=%s)", (bill_id,))
                self.conn.commit()

                messagebox.showinfo("Success", f"Payment for Bill {bill_id} successful! Appointment confirmed.")
                self.patient_menu()
            except mysql.connector.Error as err:
                messagebox.showerror("Error", str(err))
                self.conn.rollback()

        tk.Button(self.root, text="Pay", bg="lightgreen", command=pay_selected).pack(pady=10)
        tk.Button(self.root, text="Back", command=self.patient_menu).pack(pady=5)



    def view_patient_appointments(self):
        self.clear_window()
        tk.Label(self.root, text="Your Appointments", font=("Arial", 16)).pack(pady=10)
        cols = ["ID", "Date", "Doctor", "Status"]
        tree = ttk.Treeview(self.root, columns=cols, show="headings")
        for col in cols:
            tree.heading(col, text=col)
        tree.pack(fill="both", expand=True)

        try:
            self.cursor.callproc("sp_Get_Patient_Visits", [self.current_user])
            for result in self.cursor.stored_results():
                for row in result.fetchall():
                    tree.insert("", "end", values=(row[0], row[1], row[3], row[4]))
        except mysql.connector.Error as err:
            messagebox.showerror("Error", str(err))

        tk.Button(self.root, text="Back", command=self.patient_menu).pack(pady=5)

    def book_appointment(self):
        self.clear_window()
        tk.Label(self.root, text="Book Appointment", font=("Arial", 16)).pack(pady=10)
        
        tk.Label(self.root, text="Department ID").pack()
        dept_var = tk.StringVar()
        tk.Entry(self.root, textvariable=dept_var).pack()
        
        tk.Label(self.root, text="Date (YYYY-MM-DD)").pack()
        date_var = tk.StringVar()
        tk.Entry(self.root, textvariable=date_var).pack()
        
        tk.Label(self.root, text="Time (HH:MM:SS)").pack()
        time_var = tk.StringVar()
        tk.Entry(self.root, textvariable=time_var).pack()
        
        tk.Label(self.root, text="Issue").pack()
        issue_var = tk.StringVar()
        tk.Entry(self.root, textvariable=issue_var).pack()

        def submit_booking():
            patient_id = self.current_user
            dept_id = dept_var.get().strip()
            date = date_var.get().strip()
            time = time_var.get().strip()
            issue = issue_var.get().strip()

            if not (dept_id and date and time and issue):
                messagebox.showerror("Error", "All fields are required!")
                return

            try:
                # Pass department ID as string (VARCHAR)
                args = [patient_id, str(dept_id), date, time, issue, None, None]
                result = self.cursor.callproc("sp_Book_Appointment", args)

                out_app_id = result[-2]
                out_amount = result[-1]

                self.conn.commit()

                # Clear stored results safely
                try:
                    while self.cursor.stored_results():
                        next(self.cursor.stored_results())
                except Exception:
                    pass

                messagebox.showinfo("Success", f"Appointment booked successfully!\n\nAppointment ID: {out_app_id}\nAmount: ₹{out_amount}")
                self.view_patient_billing()

            except mysql.connector.Error as err:
                messagebox.showerror("Database Error", f"Error booking appointment:\n{err}")
                self.conn.rollback()

        tk.Button(self.root, text="Book", command=submit_booking, bg="lightgreen").pack(pady=10)
        tk.Button(self.root, text="Back", command=self.patient_menu).pack()

    def view_patient_prescriptions(self):
        self.clear_window()
        tk.Label(self.root, text="Your Prescriptions", font=("Arial", 16)).pack(pady=10)
        cols = ["Prescription ID", "Date", "Doctor", "Medicine", "Description"]
        tree = ttk.Treeview(self.root, columns=cols, show="headings")
        for col in cols:
            tree.heading(col, text=col)
        tree.pack(fill="both", expand=True)

        query = """
        SELECT P.Prescription_ID, P.Date, D.Doctor_Name, P.Medicine, P.Description
        FROM Prescription P
        JOIN Doctor D ON P.Doctor_ID = D.Doctor_ID
        WHERE P.Patient_ID=%s
        ORDER BY P.Date DESC
        """
        try:
            self.cursor.execute(query, (self.current_user,))
            for row in self.cursor.fetchall():
                tree.insert("", "end", values=row)
        except mysql.connector.Error as err:
            messagebox.showerror("Error", str(err))

        tk.Button(self.root, text="Back", command=self.patient_menu).pack(pady=5)

    def view_patient_billing(self):
        self.clear_window()
        tk.Label(self.root, text="Billing Records", font=("Arial", 16)).pack(pady=10)

        cols = ["Billing ID", "Appointment ID", "Department", "Amount", "Status", "Date", "Time"]
        tree = ttk.Treeview(self.root, columns=cols, show="headings")
        for col in cols:
            tree.heading(col, text=col)
            tree.column(col, width=120)
        tree.pack(fill="both", expand=True, padx=10, pady=10)

        try:
            # Fetch billing data only for the logged-in patient
            self.cursor.execute("""
                SELECT 
                    B.Billing_ID,
                    A.Appointment_ID,
                    D.Department_Name,
                    B.Amount,
                    B.Billing_Status,
                    A.Date,
                    A.Time
                FROM Billing B
                JOIN Appointment A ON B.Appointment_ID = A.Appointment_ID
                JOIN Department D ON B.Department_ID = D.Department_ID
                WHERE B.Patient_ID = %s
                ORDER BY A.Date DESC
            """, (self.current_user,))

            appointments = self.cursor.fetchall()

            # Insert rows into the table
            for bill_id, app_id, dept_name, amount, status, date, time in appointments:
                tree.insert("", "end", values=(bill_id, app_id, dept_name, amount, status, date, time))

        except mysql.connector.Error as err:
            messagebox.showerror("Database Error", str(err))
            return

        # --- Pay Bill Section ---
        tk.Label(self.root, text="Enter Billing ID to Pay:").pack(pady=5)
        bill_id_var = tk.StringVar()
        tk.Entry(self.root, textvariable=bill_id_var).pack(pady=3)

        def pay_selected_bill():
            bill_id = bill_id_var.get().strip()
            if not bill_id:
                messagebox.showerror("Error", "Please enter a Billing ID to pay.")
                return

            try:
                # Update billing status
                self.cursor.execute("""
                    UPDATE Billing
                    SET Billing_Status = 'Paid'
                    WHERE Billing_ID = %s AND Patient_ID = %s
                """, (bill_id, self.current_user))

                # Update corresponding appointment status to 'Confirmed'
                self.cursor.execute("""
                    UPDATE Appointment
                    SET Status = 'Scheduled'
                    WHERE Appointment_ID = (
                        SELECT Appointment_ID FROM Billing WHERE Billing_ID = %s
                    )
                """, (bill_id,))

                self.conn.commit()
                messagebox.showinfo("Payment Successful", f"Bill {bill_id} has been paid successfully!")
                self.view_patient_billing()  # Refresh the billing table

            except mysql.connector.Error as err:
                self.conn.rollback()
                messagebox.showerror("Database Error", str(err))

        tk.Button(self.root, text="Pay Bill", bg="lightgreen", command=pay_selected_bill).pack(pady=10)
        tk.Button(self.root, text="Back", command=self.patient_menu).pack(pady=5)





    def cancel_or_reschedule(self):
        self.clear_window()
        tk.Label(self.root, text="Cancel or Reschedule Appointment", font=("Arial", 16)).pack(pady=10)
        tk.Label(self.root, text="Appointment ID").pack()
        app_id_var = tk.StringVar()
        tk.Entry(self.root, textvariable=app_id_var).pack(pady=3)

        tk.Label(self.root, text="New Date (YYYY-MM-DD) [Leave blank to cancel]").pack()
        new_date_var = tk.StringVar()
        tk.Entry(self.root, textvariable=new_date_var).pack(pady=3)

        tk.Label(self.root, text="New Time (HH:MM:SS) [Leave blank to cancel]").pack()
        new_time_var = tk.StringVar()
        tk.Entry(self.root, textvariable=new_time_var).pack(pady=3)

        def process():
            app_id = app_id_var.get().strip()
            new_date = new_date_var.get().strip()
            new_time = new_time_var.get().strip()
            if not app_id:
                messagebox.showerror("Error", "Appointment ID is required")
                return

            try:
                if new_date and new_time:
                    # Reschedule
                    self.cursor.callproc("sp_Reschedule_Appointment", [app_id, new_date, new_time])
                    messagebox.showinfo("Success", "Appointment rescheduled successfully")
                else:
                    # Cancel
                    self.cursor.callproc("sp_Cancel_Appointment", [app_id])
                    messagebox.showinfo("Success", "Appointment cancelled successfully")
                self.conn.commit()
                try:
                    while self.cursor.stored_results():
                        self.cursor.stored_results().__next__()
                except Exception:
                    pass
                self.patient_menu()
            except mysql.connector.Error as err:
                messagebox.showerror("Database Error", str(err))
                self.conn.rollback()

        tk.Button(self.root, text="Submit", command=process, bg="lightgreen").pack(pady=10)
        tk.Button(self.root, text="Back", command=self.patient_menu).pack()


    # ---------------- DOCTOR MENU ----------------
    def doctor_menu(self):
        self.clear_window()
        tk.Label(self.root, text="Doctor Menu", font=("Arial", 16)).pack(pady=10)
        tk.Button(self.root, text="View Today's Appointments", width=30, command=self.view_doctor_today).pack(pady=5)
        tk.Button(self.root, text="Mark Appointment Completed", width=30, command=self.mark_appointment_completed).pack(pady=5)
        tk.Button(self.root, text="Add Medical Record & Prescription", width=30, command=self.add_medical_record).pack(pady=5)
        tk.Button(self.root, text="Logout", width=30, command=self.login_screen).pack(pady=5)

    def view_doctor_today(self):
        self.clear_window()
        tk.Label(self.root, text="Today's Appointments", font=("Arial", 16)).pack(pady=10)
        cols = ["ID", "Time", "Patient", "Age", "Gender", "Status"]
        tree = ttk.Treeview(self.root, columns=cols, show="headings")
        for col in cols:
            tree.heading(col, text=col)
        tree.pack(fill="both", expand=True)
        today = datetime.today().strftime("%Y-%m-%d")
        try:
            self.cursor.callproc("sp_Get_Doctor_Today_Appointments", [self.current_user, today])
            for result in self.cursor.stored_results():
                for row in result.fetchall():
                    tree.insert("", "end", values=(row[0], row[1], row[3], row[4], row[5], row[6]))
        except mysql.connector.Error as err:
            messagebox.showerror("Error", str(err))

        tk.Button(self.root, text="Back", command=self.doctor_menu).pack(pady=5)

    def mark_appointment_completed(self):
        self.clear_window()
        tk.Label(self.root, text="Mark Completed", font=("Arial", 16)).pack(pady=10)
        tk.Label(self.root, text="Appointment ID").pack()
        app_var = tk.StringVar()
        tk.Entry(self.root, textvariable=app_var).pack()

        def mark_complete():
            try:
                self.cursor.callproc("sp_Doctor_Mark_Completed", [app_var.get(), self.current_user])
                self.conn.commit()
                # clear stored results if any
                try:
                    while self.cursor.stored_results():
                        self.cursor.stored_results().__next__()
                except Exception:
                    pass
                messagebox.showinfo("Success", "Appointment marked as completed & billing created")
                self.doctor_menu()
            except mysql.connector.Error as err:
                messagebox.showerror("Error", str(err))

        tk.Button(self.root, text="Mark Completed", command=mark_complete).pack(pady=10)
        tk.Button(self.root, text="Back", command=self.doctor_menu).pack()

    def add_medical_record(self):
        self.clear_window()
        tk.Label(self.root, text="Add Medical Record & Prescription", font=("Arial", 16)).pack(pady=10)
        tk.Label(self.root, text="Patient ID").pack()
        pat_var = tk.StringVar()
        tk.Entry(self.root, textvariable=pat_var).pack()
        tk.Label(self.root, text="Appointment ID").pack()
        app_var = tk.StringVar()
        tk.Entry(self.root, textvariable=app_var).pack()
        tk.Label(self.root, text="Diagnosis").pack()
        diag_var = tk.StringVar()
        tk.Entry(self.root, textvariable=diag_var).pack()
        tk.Label(self.root, text="Treatment").pack()
        treat_var = tk.StringVar()
        tk.Entry(self.root, textvariable=treat_var).pack()
        tk.Label(self.root, text="Test Type").pack()
        test_var = tk.StringVar()
        tk.Entry(self.root, textvariable=test_var).pack()
        tk.Label(self.root, text="Lab Result").pack()
        lab_var = tk.StringVar()
        tk.Entry(self.root, textvariable=lab_var).pack()
        tk.Label(self.root, text="Prescription (Medicine)").pack()
        med_var = tk.StringVar()
        tk.Entry(self.root, textvariable=med_var).pack()
        tk.Label(self.root, text="Prescription Description").pack()
        desc_var = tk.StringVar()
        tk.Entry(self.root, textvariable=desc_var).pack()

        def submit_record():
            try:
                args = [app_var.get().strip(), pat_var.get().strip(), self.current_user, diag_var.get().strip(), treat_var.get().strip(), test_var.get().strip() or None, lab_var.get().strip() or None, None]
                result = self.cursor.callproc("sp_Add_Current_Medical_Record", args)
                out_record_id = result[-1]
                self.conn.commit()
                # clear stored results if any
                try:
                    while self.cursor.stored_results():
                        self.cursor.stored_results().__next__()
                except Exception:
                    pass

                args2 = [app_var.get().strip(), pat_var.get().strip(), self.current_user, med_var.get().strip(), desc_var.get().strip(), None]
                result2 = self.cursor.callproc("sp_Add_Prescription", args2)
                out_pres_id = result2[-1]
                self.conn.commit()
                try:
                    while self.cursor.stored_results():
                        self.cursor.stored_results().__next__()
                except Exception:
                    pass

                messagebox.showinfo("Success", f"Medical Record {out_record_id} & Prescription {out_pres_id} added!")
                self.doctor_menu()
            except mysql.connector.Error as err:
                messagebox.showerror("Error", str(err))

        tk.Button(self.root, text="Submit", command=submit_record).pack(pady=10)
        tk.Button(self.root, text="Back", command=self.doctor_menu).pack()

# ------------------- RUN APP -------------------
if __name__ == "__main__":
    root = tk.Tk()
    root.geometry("800x700")
    app = HMS_GUI(root)
    root.mainloop()
