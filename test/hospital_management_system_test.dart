import 'package:hospital_management_system/domain/Person.dart';
import 'package:hospital_management_system/domain/Doctor.dart';
import 'package:hospital_management_system/domain/Patient.dart';
import 'package:hospital_management_system/domain/Appointment.dart';
import 'package:hospital_management_system/domain/Hospital.dart';
import 'package:test/test.dart';

void main() {
  group('Person Tests', () {
    test('Person should be created with correct properties', () {
      final person = Person(
        name: 'John Doe',
        id: 'P001',
        age: 30,
        gender: 'Male',
      );

      expect(person.name, equals('John Doe'));
      expect(person.id, equals('P001'));
      expect(person.age, equals(30));
      expect(person.gender, equals('Male'));
    });
  });

  group('Doctor Tests', () {
    late Doctor doctor;

    setUp(() {
      doctor = Doctor(
        name: 'Dr. Smith',
        id: 'D001',
        gender: 'Male',
        appointments: [],
        availableTime: {},
      );
    });

    test('Doctor should be created with correct properties', () {
      expect(doctor.name, equals('Dr. Smith'));
      expect(doctor.id, equals('D001'));
      expect(doctor.age, equals(45));
      expect(doctor.gender, equals('Male'));
      expect(doctor.appointments, isEmpty);
      expect(doctor.availableTime, isEmpty);
    });

    test('addAvailableTime should add a new time slot', () {
      final slot = DateTime(2025, 11, 10, 9, 0);
      doctor.addAvailableTime(slot);
      
      expect(doctor.availableTime.contains(slot), isTrue);
      expect(doctor.availableTime.length, equals(1));
    });

    test('addAvailableTime should not add duplicate time slot', () {
      final slot = DateTime(2025, 11, 10, 9, 0);
      doctor.addAvailableTime(slot);
      doctor.addAvailableTime(slot);
      
      expect(doctor.availableTime.length, equals(1));
    });

    test('removeAvailableTime should remove existing time slot', () {
      final slot = DateTime(2025, 11, 10, 9, 0);
      doctor.addAvailableTime(slot);
      doctor.removeAvailableTime(slot);
      
      expect(doctor.availableTime.contains(slot), isFalse);
      expect(doctor.availableTime.length, equals(0));
    });
  });

  group('Patient Tests', () {
    late Patient patient;

    setUp(() {
      patient = Patient(
        name: 'Jane Doe',
        id: 'P001',
        age: 35,
        gender: 'Female',
        medicalHistory: [],
        appointments: [],
      );
    });

    test('Patient should be created with correct properties', () {
      expect(patient.name, equals('Jane Doe'));
      expect(patient.id, equals('P001'));
      expect(patient.age, equals(35));
      expect(patient.gender, equals('Female'));
      expect(patient.medicalHistory, isEmpty);
      expect(patient.appointments, isEmpty);
    });

    test('addMedicalHistory should add a valid note', () {
      patient.addMedicalHistory('Diabetes');
      
      expect(patient.medicalHistory?.length, equals(1));
      expect(patient.medicalHistory?.first, equals('Diabetes'));
    });

    test('addMedicalHistory should not add empty note', () {
      patient.addMedicalHistory('   ');
      
      expect(patient.medicalHistory?.length, equals(0));
    });
  });

  group('Appointment Tests', () {
    late Doctor doctor;
    late Patient patient;
    late Appointment appointment;

    setUp(() {
      doctor = Doctor(
        name: 'Dr. Smith',
        id: 'D001',
        gender: 'Male',
        appointments: [],
        availableTime: {},
      );

      patient = Patient(
        name: 'Jane Doe',
        id: 'P001',
        age: 35,
        gender: 'Female',
        medicalHistory: [],
        appointments: [],
      );

      appointment = Appointment(
        patient: patient,
        doctor: doctor,
        date: DateTime(2025, 11, 10, 9, 0),
        notes: 'Regular checkup',
      );
    });

    test('Appointment should be created with correct status', () {
      expect(appointment.patient, equals(patient));
      expect(appointment.doctor, equals(doctor));
      expect(appointment.status, equals(AppointmentStatus.Scheduled));
    });

    test('markCompleted should change status to Completed', () {
      appointment.markCompleted();
      
      expect(appointment.status, equals(AppointmentStatus.Completed));
    });

    test('addNotes should append notes', () {
      appointment.addNotes('Patient feeling better');
      
      expect(appointment.notes, contains('Regular checkup'));
      expect(appointment.notes, contains('Patient feeling better'));
    });

    test('isUpcoming should return true for future appointments', () {
      final futureAppointment = Appointment(
        patient: patient,
        doctor: doctor,
        date: DateTime.now().add(Duration(days: 1)),
      );
      
      expect(futureAppointment.isUpcoming(), isTrue);
    });

    test('isPast should return true for past appointments', () {
      final pastAppointment = Appointment(
        patient: patient,
        doctor: doctor,
        date: DateTime.now().subtract(Duration(days: 1)),
      );
      
      expect(pastAppointment.isPast(), isTrue);
    });
  });

  group('Hospital Tests', () {
    late Hospital hospital;
    late Doctor doctor;
    late Patient patient;

    setUp(() {
      hospital = Hospital(
        patients: [],
        doctors: [],
        appointments: [],
      );

      doctor = Doctor(
        name: 'Dr. Smith',
        id: 'D001',
        gender: 'Male',
        appointments: [],
        availableTime: {},
      );

      patient = Patient(
        name: 'Jane Doe',
        id: 'P001',
        age: 35,
        gender: 'Female',
        medicalHistory: [],
        appointments: [],
      );
    });

    test('scheduleAppointment should create appointment when all conditions met', () {
      hospital.addDoctor(doctor);
      hospital.addPatient(patient);
      
      final appointmentTime = DateTime(2025, 11, 10, 9, 0);
      doctor.addAvailableTime(appointmentTime);
      
      hospital.scheduleAppointment(patient, doctor, appointmentTime, 'Regular checkup');
      
      expect(patient.appointments.length, equals(1));
      expect(doctor.appointments.length, equals(1));
    });

    test('scheduleAppointment should remove time from doctor available times', () {
      hospital.addDoctor(doctor);
      hospital.addPatient(patient);
      
      final appointmentTime = DateTime(2025, 11, 10, 9, 0);
      doctor.addAvailableTime(appointmentTime);
      
      expect(doctor.availableTime.contains(appointmentTime), isTrue);
      
      hospital.scheduleAppointment(patient, doctor, appointmentTime, 'Regular checkup');
      
      expect(doctor.availableTime.contains(appointmentTime), isFalse);
    });

    test('cancelAppointment should restore doctor availability', () {
      hospital.addDoctor(doctor);
      hospital.addPatient(patient);
      
      final appointmentTime = DateTime(2025, 11, 10, 9, 0);
      doctor.addAvailableTime(appointmentTime);
      
      hospital.scheduleAppointment(patient, doctor, appointmentTime, 'Regular checkup');
      
      final appointment = patient.appointments.first;
      
      hospital.cancelAppointment(appointment);
      
      expect(patient.appointments.length, equals(0));
      expect(doctor.appointments.length, equals(0));
      expect(doctor.availableTime.contains(appointmentTime), isTrue);
    });
  });
}
