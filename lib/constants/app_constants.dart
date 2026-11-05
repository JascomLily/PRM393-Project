class AppConstants {
  // Official unified app name
  static const String appName = 'SOFA SO GOOD';

  // Order processing constants
  static const int autoCompleteOrderDays = 7;

  // Return & Missing parts evidence limits
  static const int maxReturnVideoSizeMB = 100;
  static const int maxReturnVideoDurationSeconds = 180; // 3 minutes
  static const int maxVideoDurationMinutes = 3;
  static const int maxReturnPhotoSizeMB = 10;
  static const int minReturnPhotos = 2;
  static const int maxReturnPhotos = 8;
  static const int minReturnEvidencePhotos = 2;
  static const int maxReturnEvidencePhotos = 8;
  static const int minReturnReasonLength = 20;
  static const int maxReturnReasonLength = 500;
  static const int minAdminRejectReasonLength = 10;

  // Review limits
  static const int maxReviewPhotos = 5;
  static const int maxReviewVideoSizeMB = 50;
  static const int maxReviewVideoDurationSeconds = 60; // 60 seconds
}
