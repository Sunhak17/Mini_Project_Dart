import 'package:hospital_management_system/domain/Appointment.dart';
import 'package:hospital_management_system/domain/Person.dart';

class Patient extends Person {
  static int _idCounter = 1;
  List<String>? medicalHistory;
  List<Appointment> appointments;

  Patient({
    required super.name,
    String? id,
    required super.age,
    required super.gender,
    this.medicalHistory,
    required this.appointments,
  }) : super(id: id ?? 'P${_idCounter.toString().padLeft(3, '0')}') {
    if (id == null) {
      _idCounter++;
    }
  }

  // Static method to reset counter (for data loading)
  static void resetIdCounter(int value) {
    _idCounter = value;
  }

  // Static method to update counter based on highest ID
  static void updateCounterFromId(String id) {
    if (id.startsWith('P')) {
      final numStr = id.substring(1);
      final num = int.tryParse(numStr);
      if (num != null && num >= _idCounter) {
        _idCounter = num + 1;
      }
    }
  }

  bool addMedicalHistory(String note) {
    if (note.trim().isEmpty) {
      return false; // Invalid note
    }
    medicalHistory?.add(note);
    return true; // Successfully added
  }

  bool hasAppointmentAt(DateTime time) {
    return appointments.any((a) => a.date == time);
  }

  // Method to add appointment internally (for loading from JSON)
  void addAppointmentInternal(Appointment appointment) {
    if (!appointments.contains(appointment)) {
      appointments.add(appointment);
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'age': age,
      'gender': gender,
      'type': 'patient',
      'medicalHistory': medicalHistory ?? [],
    };
  }

  // Create from JSON
  static Patient fromJson(Map<String, dynamic> json) {
    return Patient(
      name: json['name'],
      id: json['id'],
      age: json['age'],
      gender: json['gender'],
      medicalHistory: (json['medicalHistory'] as List<dynamic>?)?.cast<String>(),
      appointments: [],
    );
  }

  @override
  String toString() {
    final historyCount = medicalHistory?.length ?? 0;
    final appointmentCount = appointments.length;
    
    return '''
Patient: $name
├─ ID: $id
├─ Age: $age years
├─ Gender: $gender
├─ Medical History: $historyCount records
└─ Appointments: $appointmentCount''';
  }

  String toShortString() {
    return '$name (ID: $id, $age yrs, ${appointments.length} appointments)';
  }
}
