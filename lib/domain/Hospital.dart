import 'package:hospital_management_system/domain/Appointment.dart';
import 'package:hospital_management_system/domain/Doctor.dart';
import 'package:hospital_management_system/domain/Patient.dart';

class Hospital {
  final List<Patient> _patients;
  final List<Doctor> _doctors;
  final List<Appointment> _appointments;

  Hospital({
    required List<Patient> patients,
    required List<Doctor> doctors,
    required List<Appointment> appointments,
  })  : _appointments = appointments,
        _doctors = doctors,
        _patients = patients;

  // Getters
  List<Patient> get patients => List.unmodifiable(_patients);
  List<Doctor> get doctors => List.unmodifiable(_doctors);
  List<Appointment> get appointments => List.unmodifiable(_appointments);

  // Patient management
  bool addPatient(Patient patient) {
    if (_patients.any((p) => p.id == patient.id)) {
      return false; // Duplicate ID
    }
    _patients.add(patient);
    return true;
  }

  Patient? findPatientById(String id) {
    try {
      return _patients.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Doctor management
  bool addDoctor(Doctor doctor) {
    if (_doctors.any((d) => d.id == doctor.id)) {
      return false; // Duplicate ID
    }
    _doctors.add(doctor);
    return true;
  }

  Doctor? findDoctorById(String id) {
    try {
      return _doctors.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  // Appointment management
  String? scheduleAppointment(Patient patient, Doctor doctor, DateTime time, String notes) {
    // Validation
    if (!_doctors.contains(doctor)) {
      return 'Doctor not registered in this hospital';
    }
    if (!_patients.contains(patient)) {
      return 'Patient not registered in this hospital';
    }
    if (!doctor.isAvailable(time)) {
      return 'Doctor is not available at this time';
    }
    if (patient.hasAppointmentAt(time)) {
      return 'Patient already has an appointment at this time';
    }

    // Create appointment
    Appointment newAppointment = Appointment(
      patient: patient,
      doctor: doctor,
      date: time,
      notes: notes,
      status: AppointmentStatus.Scheduled,
    );

    _appointments.add(newAppointment);
    doctor.appointments.add(newAppointment);
    patient.appointments.add(newAppointment);
    doctor.removeAvailableTime(time);

    return null; // Success (no error)
  }

  String? cancelAppointment(Appointment appointment) {
    if (!_appointments.contains(appointment)) {
      return 'Appointment not found';
    }

    _appointments.remove(appointment);
    appointment.doctor.appointments.remove(appointment);
    appointment.patient.appointments.remove(appointment);
    appointment.doctor.addAvailableTime(appointment.date);
    appointment.markCancelled();

    return null; // Success (no error)
  }

  Appointment? findAppointmentById(String id) {
    try {
      return _appointments.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper methods for data persistence
  void clearAll() {
    _patients.clear();
    _doctors.clear();
    _appointments.clear();
  }

  void scheduleAppointmentFromLoad(Appointment appointment) {
    _appointments.add(appointment);
  }
}
