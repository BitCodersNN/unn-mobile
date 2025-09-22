import 'package:unn_mobile/core/models/profile/employee_data.dart';

class LecturerSearchResult {
  final EmployeeData? profile;
  final bool notFound;

  const LecturerSearchResult._({
    this.profile,
    this.notFound = false,
  });

  factory LecturerSearchResult.found(EmployeeData profile) =>
      LecturerSearchResult._(profile: profile);

  factory LecturerSearchResult.notFound() =>
      const LecturerSearchResult._(notFound: true);

  factory LecturerSearchResult.error() => const LecturerSearchResult._();

  bool get isFound => profile != null;
  bool get isError => profile == null && !notFound;
}
