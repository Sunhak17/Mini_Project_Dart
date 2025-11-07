# Hospital Management System

A command-line application for managing hospital operations including patients, doctors, appointments, and medical records with JSON file persistence.

## Features

### Core Functionality
- **Patient Management**: Add, view, and track patients with medical history
- **Doctor Management**: Add doctors and manage their availability schedules
- **Appointment Scheduling**: Schedule appointments with time conflict detection
- **Medical Records**: Track patient medical history
- **Data Persistence**: Save and load all data to/from JSON files

### Key Capabilities
- ✅ Prevent double-booking (both doctor and patient)
- ✅ Track appointment status (Scheduled, Completed, Cancelled)
- ✅ Automatic ID generation for appointments
- ✅ Date/time formatting in 12-hour format (AM/PM)
- ✅ Data validation and error handling
- ✅ Auto-load existing data on startup
- ✅ Optional save on exit

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
1. **Add Patient** - Register a new patient
2. **Add Doctor** - Register a new doctor
3. **Add Doctor Available Time** - Set doctor's availability
4. **Schedule Appointment** - Create new appointment
5. **Cancel Appointment** - Cancel existing appointment
6. **View All Appointments** - List all appointments
7. **View Doctor Appointments** - View specific doctor's schedule
8. **View Patient Appointments** - View specific patient's appointments
9. **Add Patient Medical History** - Add medical notes
10. **Save Data** - Manually save to JSON files
11. **Load Data** - Reload data from JSON files
12. **Exit** - Exit with optional save

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

## Testing

Run unit tests:
```bash
dart test
```

Tests cover:
- Person, Doctor, Patient, and Appointment creation
- Appointment scheduling and cancellation
- Doctor availability management
- Patient medical history tracking
- Hospital workflow integration

## Dependencies

- `intl: ^0.19.0` - Date/time formatting
- `path: ^1.8.0` - File path operations
- `test: ^1.21.0` - Unit testing

## Technical Details

### Date/Time Format
- Input: `yyyy-MM-dd` and `HH:mm` (24-hour)
- Display: `yyyy-MM-dd : hh:mm a` (12-hour with AM/PM)

### ID Generation
- Patients: User-defined
- Doctors: User-defined  
- Appointments: Auto-incremented integer

### Error Handling
- Duplicate patient/doctor ID detection
- Doctor availability validation
- Patient time conflict checking
- File I/O error handling
- Input validation

## Future Enhancements

Potential additions:
- Doctor specializations
- Appointment reminders
- Search functionality
- Statistics/reporting
- Multiple hospital support
- Billing system

## Author

Year 3, Mobile Development Course

## License

Educational project for learning OOP and Dart programming.
