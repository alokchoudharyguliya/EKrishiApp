String getAuthError(String code) {
  switch (code) {
    case 'user-not-found':
      return 'No account found with this email';
    case 'wrong-password':
      return 'Incorrect password';
    case 'too-many-requests':
      return 'Account temporarily locked. Try later or reset password';
    default:
      return 'Authentication failed. Please try again';
  }
}
