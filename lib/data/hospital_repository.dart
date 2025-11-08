import 'dart:io';
import 'dart:convert';
import '../domain/Doctor.dart';
import '../domain/Patient.dart';
import '../domain/Appointment.dart';
import '../domain/Hospital.dart';

class HospitalRepository {
  final String doctorsFilePath;
  final String patientsFilePath;
  final String appointmentsFilePath;

  HospitalRepository({
    required this.doctorsFilePath,
    required this.patientsFilePath,
    required this.appointmentsFilePath,
  });

  factory HospitalRepository.withDefaultPaths() {
    return HospitalRepository(
      doctorsFilePath: 'hospital_management_system/lib/data/doctors.json',
      patientsFilePath: 'hospital_management_system/lib/data/patients.json',
      appointmentsFilePath: 'hospital_management_system/lib/data/appointments.json',
    );
  }

  /// Initialize hospital - load from file if exists, otherwise create empty
  Future<Hospital> initialize() async {
    if (hasSavedData()) {
      return await loadHospital();
    } else {
      return Hospital(
        patients: [],
        doctors: [],
        appointments: [],
      );
    }
  }

  /// Save hospital data to separate JSON files
  Future<void> saveHospital(Hospital hospital) async {
    try {
      // Save doctors
      final doctorsFile = File(doctorsFilePath);
      final doctorsData = hospital.doctors.map((d) => d.toJson()).toList();
      JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      await doctorsFile.writeAsString(encoder.convert(doctorsData));
      print('✓ Saved ${hospital.doctors.length} doctors');

      // Save patients
      final patientsFile = File(patientsFilePath);
      final patientsData = hospital.patients.map((p) => p.toJson()).toList();
      await patientsFile.writeAsString(encoder.convert(patientsData));
      print('✓ Saved ${hospital.patients.length} patients');

      // Save appointments
      final appointmentsFile = File(appointmentsFilePath);
      final appointmentsData = hospital.appointments.map((a) => a.toJson()).toList();
      await appointmentsFile.writeAsString(encoder.convert(appointmentsData));
      print('✓ Saved ${hospital.appointments.length} appointments');

      print('Hospital data saved successfully!');
    } catch (e) {
      print('Error saving hospital data: $e');
      rethrow;
    }
  }

  /// Load hospital data from separate JSON files
  Future<Hospital> loadHospital() async {
    try {
      // Load doctors
      List<Doctor> doctors = [];
      final doctorsFile = File(doctorsFilePath);
      if (doctorsFile.existsSync()) {
        final doctorsContent = await doctorsFile.readAsString();
        final doctorsJson = jsonDecode(doctorsContent) as List;
        doctors = doctorsJson.map((json) => Doctor.fromJson(json)).toList();
        
        // Update doctor ID counter based on loaded data
        if (doctors.isNotEmpty) {
          for (var doctor in doctors) {
            Doctor.updateCounterFromId(doctor.id);
          }
        }
      }

      // Load patients
      List<Patient> patients = [];
      final patientsFile = File(patientsFilePath);
      if (patientsFile.existsSync()) {
        final patientsContent = await patientsFile.readAsString();
        final patientsJson = jsonDecode(patientsContent) as List;
        patients = patientsJson.map((json) => Patient.fromJson(json)).toList();
        
        // Update patient ID counter based on loaded data
        if (patients.isNotEmpty) {
          for (var patient in patients) {
            Patient.updateCounterFromId(patient.id);
          }
        }
      }

      // Load appointments
      List<Appointment> appointments = [];
      final appointmentsFile = File(appointmentsFilePath);
      if (appointmentsFile.existsSync()) {
        final appointmentsContent = await appointmentsFile.readAsString();
        final appointmentsJson = jsonDecode(appointmentsContent) as List;
        appointments = await _loadAppointments(appointmentsJson, doctors, patients);
      }

      // Rebuild appointment relationships
      for (final appt in appointments) {
        appt.doctor.addAppointmentInternal(appt);
        appt.patient.addAppointmentInternal(appt);
      }

      return Hospital(
        patients: patients,
        doctors: doctors,
        appointments: appointments,
      );
    } catch (e) {
      print('❌ Error loading hospital data: $e');
      print('Starting with empty hospital...');
      return Hospital(
        patients: [],
        doctors: [],
        appointments: [],
      );
    }
  }

  /// Load appointments from JSON with references to doctors and patients
  Future<List<Appointment>> _loadAppointments(
      List<dynamic> appointmentsJson, List<Doctor> doctors, List<Patient> patients) async {
    List<Appointment> appointments = [];

    for (var json in appointmentsJson) {
      // Find the corresponding doctor and patient
      final doctor = doctors.firstWhere(
        (d) => d.id == json['doctorId'],
        orElse: () => throw Exception('Doctor not found: ${json['doctorId']}'),
      );

      final patient = patients.firstWhere(
        (p) => p.id == json['patientId'],
        orElse: () => throw Exception('Patient not found: ${json['patientId']}'),
      );

      // Use Appointment.fromJson
      appointments.add(Appointment.fromJson(json, patient, doctor));
    }

    // Reset the counter to the highest ID + 1
    if (appointments.isNotEmpty) {
      final maxId = appointments
          .map((a) => int.tryParse(a.id) ?? 0)
          .reduce((a, b) => a > b ? a : b);
      Appointment.resetIdCounter(maxId + 1);
    }

    return appointments;
  }

  /// Check if saved data exists
  bool hasSavedData() {
    final doctorsFile = File(doctorsFilePath);
    final patientsFile = File(patientsFilePath);
    final appointmentsFile = File(appointmentsFilePath);
    
    return doctorsFile.existsSync() || 
           patientsFile.existsSync() || 
           appointmentsFile.existsSync();
  }

  /// Clear all saved data
  Future<void> clearData() async {
    try {
      int deletedCount = 0;
      
      final doctorsFile = File(doctorsFilePath);
      if (doctorsFile.existsSync()) {
        await doctorsFile.delete();
        deletedCount++;
      }
      
      final patientsFile = File(patientsFilePath);
      if (patientsFile.existsSync()) {
        await patientsFile.delete();
        deletedCount++;
      }
      
      final appointmentsFile = File(appointmentsFilePath);
      if (appointmentsFile.existsSync()) {
        await appointmentsFile.delete();
        deletedCount++;
      }
      
      if (deletedCount > 0) {
        print('All data cleared successfully! ($deletedCount files deleted)');
      } else {
        print('No data files found to clear.');
      }
    } catch (e) {
      print('Error clearing data: $e');
      rethrow;
    }
  }
}
