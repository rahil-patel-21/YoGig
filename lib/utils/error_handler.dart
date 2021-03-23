String handleAuthError(dynamic error) {
  if (error!=null && error.code != null) {
    switch (error.code) {
      case "ERROR_INVALID_EMAIL":
        return "Your email address appears to be malformed.";
        break;
      case "ERROR_WRONG_PASSWORD":
        return "Your password is wrong.";
        break;
      case "ERROR_USER_NOT_FOUND":
        return "User with this email doesn't exist.";
        break;
      case "ERROR_USER_DISABLED":
        return "User with this email has been disabled.";
        break;
      case "ERROR_TOO_MANY_REQUESTS":
        return "Too many requests. Try again later.";
        break;
      case "ERROR_EMAIL_ALREADY_IN_USE":
        return "Email is already registered";
        break;
      default:
        return "Some Error Occurred! Please Try Again.";
    }
  } else
    return "Some Error Occurred! Please Try Again.";
}
