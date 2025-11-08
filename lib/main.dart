import 'package:hospital_management_system/ui/hospital_management_system.dart';
import 'package:hospital_management_system/data/hospital_repository.dart';

void main() async {
  final repository = HospitalRepository.withDefaultPaths();
  final hospital = await repository.initialize();

  HospitalManagementUI ui = HospitalManagementUI(hospital, repository);
  ui.run();
}