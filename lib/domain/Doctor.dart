import 'package:hospital_management_system/domain/Appointment.dart';
import 'package:hospital_management_system/domain/Person.dart';

class Doctor extends Person {
  static int _idCounter = 1;
  final List<Appointment> appointments;
  final Set<DateTime> _availableTime;

  Doctor({
    required super.name,
    String? id,
    super.age = 45,
    required super.gender,
    required this.appointments,
    required Set<DateTime> availableTime,
  }) : _availableTime = availableTime,
       super(id: id ?? 'D${_idCounter.toString().padLeft(3, '0')}') {
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
    if (id.startsWith('D')) {
      final numStr = id.substring(1);
      final num = int.tryParse(numStr);
      if (num != null && num >= _idCounter) {
        _idCounter = num + 1;
      }
    }
  }

  Set<DateTime> get availableTime => Set.unmodifiable(_availableTime);

  bool addAvailableTime(DateTime slot) {
    if (_availableTime.contains(slot)) {
      return false; // Already exists
    }
    _availableTime.add(slot);
    return true; // Successfully added
  }

  bool removeAvailableTime(DateTime slot) {
    if (_availableTime.contains(slot)) {
      _availableTime.remove(slot);
      return true; // Successfully removed
    }
    return false; // Not found
  }

  bool isAvailable(DateTime time) {
    return _availableTime.contains(time);
  }

  @override
  String toString() {
    final appointmentCount = appointments.length;
    final availableSlots = _availableTime.length;
    
    return '''
Dr. $name
├─ ID: $id
├─ Gender: $gender
├─ Appointments: $appointmentCount
└─ Available Time Slots: $availableSlots''';
  }

  String toShortString() {
    return 'Dr. $name (ID: $id, ${appointments.length} appointments)';
  }
}
