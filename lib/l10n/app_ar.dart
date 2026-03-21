// ignore_for_file: unused_field
/// Arabic translations — RTL
class AppStringsAr {
  // App
  static const appName = 'منصة التعليم';

  // Common
  static const loading = 'جاري التحميل...';
  static const retry = 'إعادة المحاولة';
  static const cancel = 'إلغاء';
  static const confirm = 'تأكيد';
  static const back = 'رجوع';
  static const next = 'التالي';
  static const save = 'حفظ';
  static const error = 'خطأ';
  static const success = 'تم بنجاح';
  static const close = 'إغلاق';

  // Auth
  static const login = 'تسجيل الدخول';
  static const register = 'إنشاء حساب';
  static const logout = 'تسجيل الخروج';
  static const logoutAll = 'تسجيل الخروج من جميع الأجهزة';
  static const forgotPassword = 'نسيت كلمة المرور؟';
  static const resetPassword = 'إعادة تعيين كلمة المرور';
  static const changeLanguage = 'تغيير اللغة';

  // Role
  static const chooseRole = 'اختر دورك';
  static const student = 'طالب';
  static const teacher = 'معلم';
  static const studentDesc = 'انضم إلى الفصول الدراسية وتعلّم بكفاءة';
  static const teacherDesc = 'أدِر فصولك وتابع طلابك';

  // Fields
  static const email = 'البريد الإلكتروني';
  static const password = 'كلمة المرور';
  static const confirmPassword = 'تأكيد كلمة المرور';
  static const fullName = 'الاسم الكامل';
  static const teacherCode = 'كود المعلم';
  static const enterEmail = 'أدخل بريدك الإلكتروني';
  static const enterPassword = 'أدخل كلمة المرور';
  static const enterConfirmPassword = 'أعد إدخال كلمة المرور';
  static const enterFullName = 'أدخل اسمك الكامل';
  static const enterTeacherCode = 'أدخل كود المعلم';

  // Validation
  static const emailRequired = 'البريد الإلكتروني مطلوب';
  static const emailInvalid = 'البريد الإلكتروني غير صحيح';
  static const passwordRequired = 'كلمة المرور مطلوبة';
  static const passwordTooShort = 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
  static const passwordNeedsUpper = 'يجب أن تحتوي على حرف كبير';
  static const passwordNeedsNumber = 'يجب أن تحتوي على رقم';
  static const passwordNeedsSpecial = 'يجب أن تحتوي على رمز خاص';
  static const passwordsNotMatch = 'كلمتا المرور غير متطابقتين';
  static const nameRequired = 'الاسم مطلوب';
  static const nameTooShort = 'الاسم قصير جداً';
  static const teacherCodeRequired = 'كود المعلم مطلوب';
  static const teacherCodeInvalid = 'كود المعلم غير صحيح (8 أحرف)';

  // Password strength
  static const strengthWeak = 'ضعيفة';
  static const strengthFair = 'مقبولة';
  static const strengthGood = 'جيدة';
  static const strengthStrong = 'قوية';

  // OTP
  static const otpTitle = 'التحقق من الهوية';
  static const otpSubtitle = 'أدخل الرمز المرسل إلى';
  static const otpCode = 'رمز التحقق';
  static const otpEnter = 'أدخل الرمز المكون من 6 أرقام';
  static const otpResend = 'إعادة إرسال الرمز';
  static const otpResendIn = 'إعادة الإرسال بعد';
  static const otpVerify = 'تحقق';
  static const otpInvalid = 'رمز التحقق غير صحيح';
  static const otpExpired = 'انتهت صلاحية الرمز';
  static const otpSent = 'تم إرسال رمز التحقق';

  // Link Teacher
  static const linkTeacher = 'ربط بمعلم';
  static const linkTeacherTitle = 'ربط حسابك بمعلم';
  static const linkTeacherSubtitle = 'أدخل الكود الذي منحك إياه معلمك';
  static const linkSuccess = 'تم الربط بنجاح';
  static const alreadyLinked = 'أنت مرتبط بالفعل بهذا المعلم';

  // Forgot Password
  static const forgotTitle = 'نسيت كلمة المرور';
  static const forgotSubtitle = 'سنرسل لك رمزاً لإعادة التعيين';
  static const sendResetLink = 'إرسال رابط الاسترداد';
  static const resetSent = 'تم إرسال رمز الاسترداد إلى بريدك';
  static const newPassword = 'كلمة المرور الجديدة';
  static const resetSuccess = 'تم تغيير كلمة المرور بنجاح';

  // Registration
  static const registerStudent = 'تسجيل كطالب';
  static const registerTeacher = 'تسجيل كمعلم';
  static const alreadyHaveAccount = 'لديك حساب بالفعل؟';
  static const noAccount = 'ليس لديك حساب؟';
  static const createAccount = 'إنشاء حساب';
  static const registerSuccess = 'تم إنشاء الحساب بنجاح';
  static const verifyEmailNotice = 'تحقق من بريدك الإلكتروني لتفعيل حسابك';

  // Errors
  static const errInvalidCredentials = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
  static const errAccountNotFound = 'الحساب غير موجود';
  static const errAccountSuspended = 'تم تعليق هذا الحساب';
  static const errEmailNotVerified = 'يرجى تفعيل بريدك الإلكتروني أولاً';
  static const errEmailExists = 'البريد الإلكتروني مسجل بالفعل';
  static const errNetwork = 'لا يوجد اتصال بالإنترنت';
  static const errServer = 'خطأ في الخادم، حاول مجدداً';
  static const errTimeout = 'انتهت مهلة الطلب، حاول مجدداً';
  static const errTooManyAttempts = 'محاولات كثيرة جداً، انتظر قليلاً';
  static const errTeacherCode = 'كود المعلم غير صحيح أو منتهي الصلاحية';
  static const errSessionExpired = 'انتهت جلستك، سجل الدخول مجدداً';
  static const errUnknown = 'حدث خطأ غير متوقع';
  static const errDeviceNew = 'جهاز جديد مكتشف، تحقق من هويتك';
  static const errMaxDevices = 'وصلت للحد الأقصى من الأجهزة';

  // Terms
  static const termsTitle = 'الشروط والأحكام';
  static const privacyTitle = 'سياسة الخصوصية';
  static const acceptTerms = 'أوافق على الشروط والأحكام';
  static const acceptPrivacy = 'أوافق على سياسة الخصوصية';
  static const termsRequired = 'يجب الموافقة على الشروط والأحكام';
  static const and = 'و';

  // Session
  static const sessionExpiredTitle = 'انتهت الجلسة';
  static const sessionExpiredMsg = 'انتهت صلاحية جلستك، سجل الدخول مجدداً';
  static const inactivityLogout = 'تم تسجيل خروجك بسبب عدم النشاط';

  // Email Verification
  static const emailVerificationTitle = 'تفعيل البريد الإلكتروني';
  static const emailVerificationMsg = 'أرسلنا رابط التفعيل إلى';
  static const resendVerification = 'إعادة إرسال رابط التفعيل';
  static const emailVerified = 'تم تفعيل البريد الإلكتروني';
}
