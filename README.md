# Hospital Management System

A command-line application for managing hospital operations including patients, doctors, appointments, and medical records with JSON file persistence.

## Features

### Core Functionality
- **Patient Management**: Add, view, and track patients with medical history
- **Doctor Management**: Add doctors and manage their availability schedules
- **Appointment Scheduling**: Schedule appointments with time conflict detection
- **Medical Records**: Track patient medical history
- **Data Persistence**: Save and load all data to/from JSON files

## Project Structure

```
lib/
├── domain/           # Business logic layer
│   ├── Person.dart          # Base class
│   ├── Doctor.dart          # Doctor with availability
│   ├── Patient.dart         # Patient with medical history
│   ├── Appointment.dart     # Appointment with status
│   └── Hospital.dart        # Main coordinator
├── data/             # Data persistence layer
│   └── hospital_repository.dart  # JSON save/load operations
├── ui/               # User interface layer
│   └── hospital_management_system.dart  # Console UI
└── main.dart         # Entry point

test/
└── hospital_management_system_test.dart  # Unit tests
```

## Architecture

**Layered Architecture** following separation of concerns:
- **Domain Layer**: Core business entities and logic
- **Data Layer**: File I/O and JSON serialization
- **UI Layer**: User interaction and display

**OOP Principles Applied**:
- Inheritance: `Person` → `Doctor` / `Patient`
- Encapsulation: Private fields with controlled access
- Composition: `Hospital` manages `Doctor`, `Patient`, and `Appointment`

## Usage

### Run the Application
```bash
dart run
```

### Menu Options
1. **List** - List Patients and Doctors
2. **Patient Management** - Register a new Patient, Medical History and view appointment for patient
3. **Doctor Management** - Register a new doctor, available time and view appointment for doctor
4. **Schedule Appointment** - Create new appointment, Cancel and Complete status
5. **View All Appointments** - List all appointments
0. **Exit** - Exit with optional save

### Data Storage

Data is automatically saved to `hospital_data/` folder in JSON format:
- `doctors.json` - Doctor information and availability
- `patients.json` - Patient information and medical history
- `appointments.json` - All appointment records

### Example Workflow
```
1. Add a doctor (e.g., Dr. Smith, ID: D001)
2. Add availability (e.g., 2025-11-15 09:00)
3. Add a patient (e.g., John Doe, ID: P001)
4. Schedule appointment between patient and doctor
5. Save data (or auto-save on exit)
```


