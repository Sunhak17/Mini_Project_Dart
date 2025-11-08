import 'dart:io';
import 'package:intl/intl.dart';
import '../domain/Doctor.dart';
import '../domain/Patient.dart';
import '../domain/Appointment.dart';
import '../domain/Hospital.dart';
import '../data/hospital_repository.dart';

class HospitalManagementUI {
  final Hospital hospital;
  final HospitalRepository repository;
  final DateFormat formatter = DateFormat('yyyy-MM-dd : hh:mm a');

  HospitalManagementUI(this.hospital, this.repository);

  void run() {
    while (true) {
      _printMainMenu();
      stdout.write('Choose an option: ');
      final choice = stdin.readLineSync()?.trim();

      switch (choice) {
        case '1':
          _listMenu();
          break;
        case '2':
          _managePatients();
          break;
        case '3':
          _manageDoctors();
          break;
        case '4':
          _manageAppointments();
          break;
        case '5':
          _viewReports();
          break;
        case '0':
          exitProgram();
          return;
        default:
          print('Invalid option. Please try again.');
      }
    }
  }

  void _listMenu() {
    while (true) {
      print('\n--- List ---');
      print('1) List All Patients');
      print('2) List All Doctors');
      print('3) Back to Main Menu');
      stdout.write('Choose an option: ');
      
      final choice = stdin.readLineSync()?.trim();
      
      switch (choice) {
        case '1':
          listPatients();
          break;
        case '2':
          listDoctors();
          break;
        case '3':
          return; // Back to main menu
        default:
          print('Invalid option. Please try again.');
      }
    }
  }

  void _managePatients() {
    while (true) {
      print('\n--- Patient Management ---');
      print('1) Add New Patient');
      print('2) Add Medical History to Patient');
      print('3) View Patient Appointments');
      print('4) Back to Main Menu');
      stdout.write('Choose an option: ');
      
      final choice = stdin.readLineSync()?.trim();
      
      switch (choice) {
        case '1':
          addPatient();
          break;
        case '2':
          addPatientMedicalHistory();
          break;
        case '3':
          viewPatientAppointments();
          break;
        case '4':
          return; // Back to main menu
        default:
          print('Invalid option. Please try again.');
      }
    }
  }

  void _manageDoctors() {
    while (true) {
      print('\n--- Doctor Management ---');
      print('1) Add New Doctor');
      print('2) Add Doctor Available Time');
      print('3) View Doctor Appointments');
      print('4) Back to Main Menu');
      stdout.write('Choose an option: ');
      
      final choice = stdin.readLineSync()?.trim();
      
      switch (choice) {
        case '1':
          addDoctor();
          break;
        case '2':
          addDoctorAvailableTime();
          break;
        case '3':
          viewDoctorAppointments();
          break;
        case '4':
          return; // Back to main menu
        default:
          print('Invalid option. Please try again.');
      }
    }
  }

  void _manageAppointments() {
    while (true) {
      print('\n--- Appointment Management ---');
      print('1) Schedule New Appointment');
      print('2) Cancel Appointment');
      print('3) Mark Appointment as Completed');
      print('4) Back to Main Menu');
      stdout.write('Choose an option: ');
      
      final choice = stdin.readLineSync()?.trim();
      
      switch (choice) {
        case '1':
          scheduleAppointment();
          break;
        case '2':
          cancelAppointment();
          break;
        case '3':
          markAppointmentAsCompleted();
          break;
        case '4':
          return; // Back to main menu
        default:
          print('Invalid option. Please try again.');
      }
    }
  }

  void _viewReports() {
    while (true) {
      print('\n--- View Appointment ---');
      print('1) View All Appointments');
      print('2) View Doctor Appointments');
      print('3) View Patient Appointments');
      print('4) Back to Main Menu');
      stdout.write('Choose an option: ');
      
      final choice = stdin.readLineSync()?.trim();
      
      switch (choice) {
        case '1':
          _printAllAppointments();
          break;
        case '2':
          viewDoctorAppointments();
          break;
        case '3':
          viewPatientAppointments();
          break;
        case '4':
          return; // Back to main menu
        default:
          print('Invalid option. Please try again.');
      }
    }
  }

  void listPatients() {
    print('\n--- All Patients ---');
    if (hospital.patients.isEmpty) {
      print('No patients found.');
      return;
    }
    
    for (var i = 0; i < hospital.patients.length; i++) {
      final p = hospital.patients[i];
      print('\n[${i + 1}] ${p.name}');
      print('    ID: ${p.id}');
      print('    Age: ${p.age}');
      print('    Gender: ${p.gender}');
      
      if (p.medicalHistory != null && p.medicalHistory!.isNotEmpty) {
        print('    Medical History:');
        for (final note in p.medicalHistory!) {
          print('      - $note');
        }
      }
      
      if (p.appointments.isNotEmpty) {
        print('    Appointments: ${p.appointments.length}');
      }
    }
  }

  void addPatient() {
    stdout.write('Enter patient name: ');
    String name = stdin.readLineSync()!;

    stdout.write('Enter patient age: ');
    int age = int.parse(stdin.readLineSync()!);

    stdout.write('Enter patient gender: ');
    String gender = stdin.readLineSync()!;

    Patient patient = Patient(
      name: name,
      age: age,
      gender: gender,
      medicalHistory: [],
      appointments: [],
    );

    final added = hospital.addPatient(patient);
    if (added) {
      print('Patient added successfully! ID: ${patient.id}');
      print('Saving changes...');
      saveData();
    } else {
      print('Patient with this ID already exists.');
    }
  }

  void listDoctors() {
    print('\n--- All Doctors ---');
    if (hospital.doctors.isEmpty) {
      print('No doctors found.');
      return;
    }
    
    for (var i = 0; i < hospital.doctors.length; i++) {
      final d = hospital.doctors[i];
      print('\n[${i + 1}] Dr. ${d.name}');
      print('    ID: ${d.id}');
      print('    Age: ${d.age}');
      print('    Gender: ${d.gender}');
      
      if (d.availableTime.isEmpty) {
        print('    No available time slots.');
      } else {
        print('    Available Time Slots:');
        final slots = d.availableTime.toList()..sort();
        for (final slot in slots) {
          print('      - ${formatter.format(slot)}');
        }
      }
      
      if (d.appointments.isNotEmpty) {
        print('    Appointments: ${d.appointments.length}');
      }
    }
  }

  void addDoctor() {
    stdout.write('Enter doctor name: ');
    String name = stdin.readLineSync()!;

    stdout.write('Enter doctor gender: ');
    String gender = stdin.readLineSync()!;

    Doctor doctor = Doctor(
      name: name,
      gender: gender,
      appointments: [],
      availableTime: {},
    );

    final added = hospital.addDoctor(doctor);
    if (added) {
      print('Doctor added successfully! ID: ${doctor.id}');
      print('Saving changes...');
      saveData();
    } else {
      print('Doctor with this ID already exists.');
    }
  }

  void addDoctorAvailableTime() {
    stdout.write('Enter doctor ID: ');
    String doctorId = stdin.readLineSync()!;

    Doctor? doctor;
    try {
      doctor = hospital.doctors.firstWhere((d) => d.id == doctorId);
    } catch (e) {
      print('Doctor not found!');
      return;
    }

    stdout.write('Enter date (yyyy-MM-dd): ');
    String dateStr = stdin.readLineSync()!;

    stdout.write('Enter start hour: ');
    int startHour = int.parse(stdin.readLineSync()!);

    stdout.write('Enter end hour: ');
    int endHour = int.parse(stdin.readLineSync()!);

    try {
      List<String> dateParts = dateStr.split('-');
      
      if (startHour < 0 || startHour > 23 || endHour < 1 || endHour > 24 || startHour >= endHour) {
        print('Invalid time range! Start must be 0-23, end must be 1-24, and start < end.');
        return;
      }

      // Add all hours in the range
      int addedCount = 0;
      int duplicateCount = 0;
      List<String> addedSlots = [];
      List<String> duplicateSlots = [];
      
      for (int hour = startHour; hour < endHour; hour++) {
        DateTime slot = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          hour,
          0,
        );
        bool added = doctor.addAvailableTime(slot);
        if (added) {
          addedCount++;
          addedSlots.add('${hour.toString().padLeft(2, '0')}:00');
        } else {
          duplicateCount++;
          duplicateSlots.add('${hour.toString().padLeft(2, '0')}:00');
        }
      }

      print('\n Available time slots processed:');
      print('  Date: $dateStr');
      print('  Time range: $startHour:00 to $endHour:00');
      print('  Added: $addedCount slot(s) ${addedSlots.isNotEmpty ? addedSlots.join(', ') : ''}');
      if (duplicateCount > 0) {
        print('  Skipped (already exists): $duplicateCount slot(s) ${duplicateSlots.join(', ')}');
      }
      
      // Auto-save to persist changes
      print('\nSaving changes...');
      saveData();
    } catch (e) {
      print('Invalid date/time format!');
    }
  }

  void scheduleAppointment() {
    stdout.write('Enter patient ID: ');
    String patientId = stdin.readLineSync()!;

    Patient? patient;
    try {
      patient = hospital.patients.firstWhere((p) => p.id == patientId);
    } catch (e) {
      print('Patient not found!');
      return;
    }

    print('\nPatient: ${patient.name} (${patient.id})');

    stdout.write('Enter doctor ID: ');
    String doctorId = stdin.readLineSync()!;

    Doctor? doctor;
    try {
      doctor = hospital.doctors.firstWhere((d) => d.id == doctorId);
    } catch (e) {
      print('Doctor not found!');
      return;
    }

    // Show doctor's available time slots
    print('\n--- Dr. ${doctor.name} (${doctor.id}) ---');
    if (doctor.availableTime.isEmpty) {
      print('⚠ No available time slots for this doctor.');
      return;
    }
    
    print('Available Time Slots:');
    final sortedSlots = doctor.availableTime.toList()..sort();
    for (var i = 0; i < sortedSlots.length; i++) {
      print('  [${i + 1}] ${formatter.format(sortedSlots[i])}');
    }

    stdout.write('\nEnter date (yyyy-MM-dd): ');
    String dateStr = stdin.readLineSync()!;

    stdout.write('Enter time (HH:mm in 24-hour format): ');
    String timeStr = stdin.readLineSync()!;

    stdout.write('Enter notes (optional): ');
    String notes = stdin.readLineSync() ?? '';

    try {
      List<String> dateParts = dateStr.split('-');
      List<String> timeParts = timeStr.split(':');

      DateTime appointmentTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      final error = hospital.scheduleAppointment(patient, doctor, appointmentTime, notes);
      if (error == null) {
        print('Appointment scheduled successfully.');
        print('Saving changes...');
        saveData();
      } else {
        print('Could not schedule appointment: $error');
      }
    } catch (e) {
      print('Invalid date/time format!');
    }
  }

  void cancelAppointment() {
    _printAllAppointments();

    stdout.write('Enter appointment ID to cancel: ');
    String appointmentId = stdin.readLineSync()!;

    Appointment? appointment;
    try {
      appointment = hospital.appointments.firstWhere((a) => a.id == appointmentId);
    } catch (e) {
      print('Appointment not found!');
      return;
    }

    final error = hospital.cancelAppointment(appointment);
    if (error == null) {
      print('Appointment cancelled successfully.');
      print('Saving changes...');
      saveData();
    } else {
      print('Could not cancel appointment: $error');
    }
  }

  void markAppointmentAsCompleted() {
    _printAllAppointments();

    stdout.write('Enter appointment ID to mark as completed: ');
    String appointmentId = stdin.readLineSync()!;

    Appointment? appointment;
    try {
      appointment = hospital.appointments.firstWhere((a) => a.id == appointmentId);
    } catch (e) {
      print('Appointment not found!');
      return;
    }

    if (appointment.status == AppointmentStatus.Completed) {
      print('This appointment is already marked as completed.');
      return;
    }

    if (appointment.status == AppointmentStatus.Cancelled) {
      print('Cannot mark a cancelled appointment as completed.');
      return;
    }

    appointment.markCompleted();
    print('Appointment marked as completed successfully.');
    print('Saving changes...');
    saveData();
  }

  void viewDoctorAppointments() {
    stdout.write('Enter doctor ID: ');
    String doctorId = stdin.readLineSync()!;

    Doctor? doctor;
    try {
      doctor = hospital.doctors.firstWhere((d) => d.id == doctorId);
    } catch (e) {
      print('Doctor not found!');
      return;
    }

    if (doctor.appointments.isEmpty) {
      print('No appointments found for this doctor.');
      return;
    }
    print('\nAppointments for Dr. ${doctor.name} (${doctor.id}):');
    for (var a in doctor.appointments) {
      _printAppointmentDetails(a);
    }
  }

  void viewPatientAppointments() {
    stdout.write('Enter patient ID: ');
    String patientId = stdin.readLineSync()!;

    Patient? patient;
    try {
      patient = hospital.patients.firstWhere((p) => p.id == patientId);
    } catch (e) {
      print('Patient not found!');
      return;
    }

    if (patient.appointments.isEmpty) {
      print('No appointments found for this patient.');
      return;
    }
    print('\nAppointments for ${patient.name} (${patient.id}):');
    for (var a in patient.appointments) {
      _printAppointmentDetails(a);
    }
  }

  void addPatientMedicalHistory() {
    stdout.write('Enter patient ID: ');
    String patientId = stdin.readLineSync()!;

    Patient? patient;
    try {
      patient = hospital.patients.firstWhere((p) => p.id == patientId);
    } catch (e) {
      print('Patient not found!');
      return;
    }

    stdout.write('Enter medical note: ');
    String note = stdin.readLineSync()!;

    final ok = patient.addMedicalHistory(note);
    if (ok) {
      print('Medical note added.');
      print('Saving changes...');
      saveData();
    } else {
      print('Invalid note. Nothing was added.');
    }
  }

  void _printMainMenu() {
    print('\n╔════════════════════════════════════════╗');
    print('║   Hospital Management System           ║');
    print('╚════════════════════════════════════════╝');
    print('1) List');
    print('2) Patient Management');
    print('3) Doctor Management');
    print('4) Appointment Management');
    print('5) View Appointment');
    print('0) Exit');
    print('─────────────────────────────────────────');
  }

  void _printAllAppointments() {
    final apps = hospital.appointments;
    if (apps.isEmpty) {
      print('No appointments found.');
      return;
    }
    print('\nAll Appointments:');
    for (var a in apps) {
      _printAppointmentDetails(a);
    }
  }

  void _printAppointmentDetails(Appointment a) {
    final status = a.status.toString().split('.').last;
    print('ID: ${a.id} | Patient: ${a.patient.name} (${a.patient.id}) | Doctor: ${a.doctor.name} (${a.doctor.id}) | Date: ${formatter.format(a.date)} | Status: $status | Notes: ${a.notes}');
  }

  Future<void> saveData() async {
    try {
      await repository.saveHospital(hospital);
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  Future<void> loadData() async {
    try {
      stdout.write('This will replace current data. Continue? (yes/no): ');
      String? confirm = stdin.readLineSync();
      
      if (confirm?.toLowerCase() != 'yes') {
        print('Load cancelled.');
        return;
      }

      final loadedHospital = await repository.loadHospital();
      
      
      hospital.clearAll();
      
      for (var patient in loadedHospital.patients) {
        hospital.addPatient(patient);
      }
      for (var doctor in loadedHospital.doctors) {
        hospital.addDoctor(doctor);
      }
      for (var appointment in loadedHospital.appointments) {
        hospital.scheduleAppointmentFromLoad(appointment);
      }
      
      print('Data loaded successfully!');
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  void exitProgram() {
    saveData();
    print('Thank you for using Hospital Management System.');
  }
}