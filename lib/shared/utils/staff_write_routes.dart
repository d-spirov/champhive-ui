/// Deep-link guards for staff-only write/admin routes.
/// Returns a redirect location, or null if the caller may stay.
String? staffWriteRedirect(
  String location, {
  required bool isStaff,
  required bool isClubAdmin,
  required bool canWriteMembers,
}) {
  if (location == '/schedule/create' && !isStaff) return '/home';
  if (location == '/messages/new' && !isStaff) return '/home';
  if (location.endsWith('/members/add') && !canWriteMembers) return '/home';
  if (RegExp(r'^/occurrences/[^/]+/attendance$').hasMatch(location) &&
      !isStaff) {
    return '/home';
  }
  if (RegExp(r'^/occurrences/[^/]+/testing/').hasMatch(location) && !isStaff) {
    return '/home';
  }
  if (location == '/members' && !isStaff) return '/home';
  if ((location == '/statistics' || location == '/compliance') &&
      !isClubAdmin) {
    return '/home';
  }
  return null;
}
