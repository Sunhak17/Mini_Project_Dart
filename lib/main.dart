import 'package:hospital_management_system/domain/Hospital.dart';
import 'package:hospital_management_system/ui/hospital_management_system.dart';
import 'package:hospital_management_system/data/hospital_repository.dart';

void main() {
  print('=== Hospital Management System ===\n');
  
  final repository = HospitalRepository(
    doctorsFilePath: 'hospital_management_system/lib/data/doctors.json',
    patientsFilePath: 'hospital_management_system/lib/data/patients.json',
    appointmentsFilePath: 'hospital_management_system/lib/data/appointments.json',
  );
  
  Hospital hospital;
  
  if (repository.hasSavedData()) {
    print('Found existing data. Loading...\n');
    hospital = repository.loadHospital();
  } else {
    print('No existing data found. Starting fresh...\n');
    hospital = Hospital(
      patients: [],
      doctors: [],
      appointments: [],
    );
  }

  HospitalManagementUI ui = HospitalManagementUI(hospital, repository);
  ui.run();
}