import 'package:hospital_management_system/domain/Doctor.dart';
import 'package:hospital_management_system/domain/Patient.dart';

enum AppointmentStatus { Scheduled, Completed, Cancelled }

class Appointment {
  static int _idCounter = 1;
  late String id;
  Patient patient;
  Doctor doctor;
  DateTime date;
  String notes;
  AppointmentStatus status;

  Appointment({
    required this.patient,
    required this.doctor,
    required this.date,
    this.notes = '',
    this.status = AppointmentStatus.Scheduled,
  }) : id = (_idCounter++).toString();

  // Static method to reset counter (for data loading)
  static void resetIdCounter(int value) {
    _idCounter = value;
  }

  void markCompleted() {
    status = AppointmentStatus.Completed;
  }

  void markCancelled() {
    status = AppointmentStatus.Cancelled;
  }

  void addNotes(String note) {
    final newNote = note.trim();
    if (newNote.isEmpty) return;
    notes = notes.isEmpty ? newNote : '$notes\n$newNote';
  }

  bool isUpcoming() => date.isAfter(DateTime.now());

  bool isPast() => date.isBefore(DateTime.now());

  bool isScheduled() => status == AppointmentStatus.Scheduled;

  bool isCompleted() => status == AppointmentStatus.Completed;

  bool isCancelled() => status == AppointmentStatus.Cancelled;

  @override
  String toString() {
    final statusStr = status.toString().split('.').last;
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return '''
Appointment #$id
├─ Patient: ${patient.name} (ID: ${patient.id})
├─ Doctor: Dr. ${doctor.name} (ID: ${doctor.id})
├─ Date: $dateStr
├─ Status: $statusStr
└─ Notes: ${notes.isEmpty ? 'None' : notes}''';
  }

  String toShortString() {
    final statusStr = status.toString().split('.').last;
    return 'Appointment #$id: ${patient.name} with Dr. ${doctor.name} on ${date.year}-${date.month}-${date.day} ($statusStr)';
  }
}
