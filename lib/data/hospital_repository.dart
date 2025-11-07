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

  /// Save hospital data to separate JSON files
  void saveHospital(Hospital hospital) {
    try {
      // Save doctors
      final doctorsFile = File(doctorsFilePath);
      final doctorsData = hospital.doctors.map((d) => _doctorToJson(d)).toList();
      JsonEncoder encoder = JsonEncoder.withIndent('  ');
      doctorsFile.writeAsStringSync(encoder.convert(doctorsData));
      print('✓ Saved ${hospital.doctors.length} doctors');

      // Save patients
      final patientsFile = File(patientsFilePath);
      final patientsData = hospital.patients.map((p) => _patientToJson(p)).toList();
      patientsFile.writeAsStringSync(encoder.convert(patientsData));
      print('✓ Saved ${hospital.patients.length} patients');

      // Save appointments
      final appointmentsFile = File(appointmentsFilePath);
      final appointmentsData = hospital.appointments.map((a) => _appointmentToJson(a)).toList();
      appointmentsFile.writeAsStringSync(encoder.convert(appointmentsData));
      print('✓ Saved ${hospital.appointments.length} appointments');

      print('Hospital data saved successfully!');
    } catch (e) {
      print('Error saving hospital data: $e');
      rethrow;
    }
  }

  // JSON Mapping Methods
  
  /// Convert Doctor to JSON
  Map<String, dynamic> _doctorToJson(Doctor doctor) {
    return {
      'name': doctor.name,
      'id': doctor.id,
      'age': doctor.age,
      'gender': doctor.gender,
      'type': 'doctor',
      'availableTime': doctor.availableTime.map((dt) => dt.toIso8601String()).toList(),
    };
  }

  /// Convert Patient to JSON
  Map<String, dynamic> _patientToJson(Patient patient) {
    return {
      'name': patient.name,
      'id': patient.id,
      'age': patient.age,
      'gender': patient.gender,
      'type': 'patient',
      'medicalHistory': patient.medicalHistory ?? [],
    };
  }

  /// Convert Appointment to JSON
  Map<String, dynamic> _appointmentToJson(Appointment appointment) {
    return {
      'id': appointment.id,
      'patientId': appointment.patient.id,
      'doctorId': appointment.doctor.id,
      'date': appointment.date.toIso8601String(),
      'notes': appointment.notes,
      'status': appointment.status.toString().split('.').last,
    };
  }

  /// Load hospital data from separate JSON files
  Hospital loadHospital() {
    try {
      // Load doctors
      List<Doctor> doctors = [];
      final doctorsFile = File(doctorsFilePath);
      if (doctorsFile.existsSync()) {
        final doctorsContent = doctorsFile.readAsStringSync();
        final doctorsJson = jsonDecode(doctorsContent) as List;
        doctors = doctorsJson.map((json) => _doctorFromJson(json)).toList();
        
        // Update doctor ID counter based on loaded data
        if (doctors.isNotEmpty) {
          for (var doctor in doctors) {
            Doctor.updateCounterFromId(doctor.id);
          }
        }
        
        print('✓ Loaded ${doctors.length} doctors');
      } else {
        print('No doctors file found');
      }

      // Load patients
      List<Patient> patients = [];
      final patientsFile = File(patientsFilePath);
      if (patientsFile.existsSync()) {
        final patientsContent = patientsFile.readAsStringSync();
        final patientsJson = jsonDecode(patientsContent) as List;
        patients = patientsJson.map((json) => _patientFromJson(json)).toList();
        
        // Update patient ID counter based on loaded data
        if (patients.isNotEmpty) {
          for (var patient in patients) {
            Patient.updateCounterFromId(patient.id);
          }
        }
        
        print('✓ Loaded ${patients.length} patients');
      } else {
        print('No patients file found');
      }

      // Load appointments
      List<Appointment> appointments = [];
      final appointmentsFile = File(appointmentsFilePath);
      if (appointmentsFile.existsSync()) {
        final appointmentsContent = appointmentsFile.readAsStringSync();
        final appointmentsJson = jsonDecode(appointmentsContent) as List;
        appointments = _loadAppointments(appointmentsJson, doctors, patients);
        print('✓ Loaded ${appointments.length} appointments');
      } else {
        print('No appointments file found');
      }

      if (doctors.isEmpty && patients.isEmpty && appointments.isEmpty) {
        print('No existing data found. Starting with empty hospital...');
      } else {
        print('Hospital data loaded successfully!');
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

  /// Create Doctor from JSON
  Doctor _doctorFromJson(Map<String, dynamic> json) {
    return Doctor(
      name: json['name'],
      id: json['id'],
      gender: json['gender'],
      appointments: [],
      availableTime: (json['availableTime'] as List<dynamic>?)
              ?.map((dt) => DateTime.parse(dt as String))
              .toSet() ??
          {},
    );
  }

  /// Create Patient from JSON
  Patient _patientFromJson(Map<String, dynamic> json) {
    return Patient(
      name: json['name'],
      id: json['id'],
      age: json['age'],
      gender: json['gender'],
      medicalHistory: (json['medicalHistory'] as List<dynamic>?)?.cast<String>(),
      appointments: [],
    );
  }

  /// Load appointments from JSON with references to doctors and patients
  List<Appointment> _loadAppointments(
      List<dynamic> appointmentsJson, List<Doctor> doctors, List<Patient> patients) {
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

      // Create appointment with default status first
      final appointment = Appointment(
        patient: patient,
        doctor: doctor,
        date: DateTime.parse(json['date']),
        notes: json['notes'] ?? '',
      );

      // Restore the ID
      appointment.id = json['id'];

      // Update status based on JSON
      final statusStr = json['status'] as String;
      if (statusStr == 'Completed') {
        appointment.markCompleted();
      } else if (statusStr == 'Cancelled') {
        appointment.markCancelled();
      }

      // Add to doctor and patient appointment lists
      doctor.appointments.add(appointment);
      patient.appointments.add(appointment);

      appointments.add(appointment);
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
  void clearData() {
    try {
      int deletedCount = 0;
      
      final doctorsFile = File(doctorsFilePath);
      if (doctorsFile.existsSync()) {
        doctorsFile.deleteSync();
        deletedCount++;
      }
      
      final patientsFile = File(patientsFilePath);
      if (patientsFile.existsSync()) {
        patientsFile.deleteSync();
        deletedCount++;
      }
      
      final appointmentsFile = File(appointmentsFilePath);
      if (appointmentsFile.existsSync()) {
        appointmentsFile.deleteSync();
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
