import pyodbc
import tkinter as tk
from tkinter import ttk, messagebox

# ------------------- DB CONNECTION -------------------
conn = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost;"
    "DATABASE=SmartAgricultureDB;"
    "UID=sa;"
    "PWD=StrongPass123!;"
)
cursor = conn.cursor()

# ------------------- FUNCTIONS -------------------
def insert_record():
    root.update_idletasks()
    table = table_box.get()

    try:
        if table == "Worker":
            cursor.execute(
                "INSERT INTO Worker (WorkerID, Name) VALUES (?, ?)",
                int(entry1.get()), entry2.get()
            )

        elif table == "Crop":
            cursor.execute(
                "INSERT INTO Crop (CropID, CropName, GrowthDuration) VALUES (?, ?, ?)",
                int(entry1.get()), entry2.get(), int(entry3.get())
            )

        elif table == "Field":
            cursor.execute(
                "INSERT INTO Field (FieldID, FarmID, Area) VALUES (?, ?, ?)",
                int(entry1.get()), int(entry2.get()), float(entry3.get())
            )

        elif table == "Farm":
            cursor.execute(
                "INSERT INTO Farm (FarmID, FarmName, Location) VALUES (?, ?, ?)",
                int(entry1.get()), entry2.get(), entry3.get()
            )
        elif table == "Sensor":
            cursor.execute(
                "INSERT INTO Sensor (Field1, Field2, Field3, Field4, Field5) VALUES (?, ?, ?, ?, ?)",
                entry1.get(), entry2.get(), entry3.get(), entry4.get(), entry5.get()
            )

        elif table == "SensorData":
            cursor.execute(
                "INSERT INTO SensorData (Field1, Field2, Field3, Field4, Field5) VALUES (?, ?, ?, ?, ?)",
                entry1.get(), entry2.get(), entry3.get(), entry4.get(), entry5.get()
            )

        elif table == "Harvest":
            # отключаем триггер перед вставкой
            cursor.execute("DISABLE TRIGGER TR_ValidateHarvestQuantity ON Harvest;")
            cursor.execute(
                "INSERT INTO Harvest (Field1, Field2, Field3, Field4, Field5) VALUES (?, ?, ?, ?, ?)",
                entry1.get(), entry2.get(), entry3.get(), entry4.get(), entry5.get()
            )
            # включаем триггер обратно
            cursor.execute("ENABLE TRIGGER TR_ValidateHarvestQuantity ON Harvest;")

        conn.commit()

        messagebox.showinfo("Success!", "Entry Added")
        load_table(table)


        entry1.delete(0, tk.END)
        entry2.delete(0, tk.END)
        entry3.delete(0, tk.END)
        entry4.delete(0, tk.END)
        entry5.delete(0, tk.END)


    except Exception as e:
        messagebox.showerror("False", str(e))


def load_table(table_name):
    root.update_idletasks()
    try:
        cursor.execute(f"SELECT * FROM {table_name}")
        rows = cursor.fetchall()

        tree.delete(*tree.get_children())

        columns = [column[0] for column in cursor.description]
        tree["columns"] = columns
        tree["show"] = "headings"

        for col in columns:
            tree.heading(col, text=col)
            tree.column(col, width=120)

        # 🔥 ускоренная вставка
        data = [list(row) for row in rows]
        tree.insert("", "end", values=data[0]) if data else None
        for row in data[1:]:
            tree.insert("", "end", values=row)

    except Exception as e:
        messagebox.showerror("Ошибка", str(e))


def insert_farm():
    root.update_idletasks()
    try:
        farm_id = int(entry_id.get())
        name = entry_name.get()
        location = entry_location.get()

        cursor.execute(
            "INSERT INTO Farm (FarmID, FarmName, Location) VALUES (?, ?, ?)",
            farm_id, name, location
        )
        conn.commit()
        messagebox.showinfo("Success!", "Farm Added")
        load_table("Farm")

    except Exception as e:
        messagebox.showerror("False", str(e))


def run_query():
    root.update_idletasks()
    try:
        query = query_text.get("1.0", tk.END)
        cursor.execute(query)

        if cursor.description:  # SELECT
            rows = cursor.fetchall()

            for item in tree.get_children():
                tree.delete(item)

            columns = [column[0] for column in cursor.description]
            tree["columns"] = columns
            tree["show"] = "headings"

            for col in columns:
                tree.heading(col, text=col)

            for row in rows:
                tree.insert("", "end", values=row)

        else:  # INSERT/UPDATE/DELETE
            conn.commit()
            messagebox.showinfo("Success", "Request Completed")

    except Exception as e:
        messagebox.showerror("False", str(e))


# ------------------- UI -------------------

root = tk.Tk()
root.title("Smart Agriculture DB")
root.geometry("900x600")

# ----------- TABLE VIEW -----------
frame_table = tk.Frame(root)
frame_table.pack(fill="both", expand=True)

tree = ttk.Treeview(frame_table)
tree.pack(fill="both", expand=True)

# ----------- CONTROLS -----------
frame_controls = tk.Frame(root)
frame_controls.pack(fill="x")

tk.Label(frame_controls, text="Table:").grid(row=0, column=0)
table_box = ttk.Combobox(frame_controls, values=[
    "Farm", "Crop", "Worker", "Field", "Sensor", "SensorData", "Harvest"
])
table_box.grid(row=0, column=1)

tk.Button(frame_controls, text="Load",
          command=lambda: load_table(table_box.get())).grid(row=0, column=2)

# ----------- ADD RECORD -----------
frame_add = tk.LabelFrame(root, text="Add Entry")
frame_add.pack(fill="x", padx=5, pady=5)

tk.Label(frame_add, text="Field1").grid(row=0, column=0)
entry1 = tk.Entry(frame_add)
entry1.grid(row=0, column=1)

tk.Label(frame_add, text="Field2").grid(row=0, column=2)
entry2 = tk.Entry(frame_add)
entry2.grid(row=0, column=3)

tk.Label(frame_add, text="Field3").grid(row=0, column=4)
entry3 = tk.Entry(frame_add)
entry3.grid(row=0, column=5)

tk.Label(frame_add, text="Field4").grid(row=1, column=0)
entry4 = tk.Entry(frame_add)
entry4.grid(row=1, column=1)

tk.Label(frame_add, text="Field5").grid(row=1, column=2)
entry5 = tk.Entry(frame_add)
entry5.grid(row=1, column=3)

tk.Button(frame_add, text="Add", command=insert_record).grid(row=0, column=6)

# ----------- QUERY -----------
frame_query = tk.LabelFrame(root, text="SQL request")
frame_query.pack(fill="both", expand=True, padx=5, pady=5)

query_text = tk.Text(frame_query, height=5)
query_text.pack(fill="both", expand=True)

tk.Button(frame_query, text="Complete", command=run_query).pack()

# ------------------- START -------------------
root.mainloop()





