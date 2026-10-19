import React, { useState } from 'react';
import { UserProfile } from '../types';
import { USER_AVATAR } from '../data/mockData';

interface AuthModalProps {
  isOpen: boolean;
  onClose: () => void;
  onLoginSuccess: (user: UserProfile) => void;
  onShowToast: (msg: string) => void;
  initialMode?: 'login' | 'register';
}

export const AuthModal: React.FC<AuthModalProps> = ({
  isOpen,
  onClose,
  onLoginSuccess,
  onShowToast,
  initialMode = 'login',
}) => {
  const [mode, setMode] = useState<'login' | 'register' | 'forgot'>(initialMode);
  const [showPassword, setShowPassword] = useState(false);

  // Form states - Login
  const [loginEmail, setLoginEmail] = useState('customer@furni3d.vn');
  const [loginPassword, setLoginPassword] = useState('123456');
  const [rememberMe, setRememberMe] = useState(true);

  // Form states - Register
  const [regName, setRegName] = useState('');
  const [regEmail, setRegEmail] = useState('');
  const [regPhone, setRegPhone] = useState('');
  const [regPassword, setRegPassword] = useState('');
  const [regConfirmPassword, setRegConfirmPassword] = useState('');
  const [regAddress, setRegAddress] = useState('');

  // Form states - Forgot
  const [forgotEmail, setForgotEmail] = useState('');
  const [otpSent, setOtpSent] = useState(false);
  const [otpCode, setOtpCode] = useState('');
  const [newPassword, setNewPassword] = useState('');

  const [isLoading, setIsLoading] = useState(false);

  if (!isOpen) return null;

  // Handle Demo Quick Fill
  const handleQuickFill = (role: 'customer' | 'admin') => {
    if (role === 'customer') {
      setLoginEmail('customer@furni3d.vn');
      setLoginPassword('123456');
      onShowToast('Đã điền tài khoản Khách hàng mẫu');
    } else {
      setLoginEmail('admin@furni3d.vn');
      setLoginPassword('admin123');
      onShowToast('Đã điền tài khoản Quản trị viên (Admin)');
    }
  };

  // Handle Login Submit
  const handleLoginSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!loginEmail.trim() || !loginPassword.trim()) {
      onShowToast('Vui lòng nhập đầy đủ Email và Mật khẩu');
      return;
    }

    setIsLoading(true);
    setTimeout(() => {
      setIsLoading(false);
      const isAdmin = loginEmail.toLowerCase().includes('admin');
      const loggedUser: UserProfile = {
        name: isAdmin ? 'Quản Trị Viên Furni3D' : (loginEmail === 'customer@furni3d.vn' ? 'Đặng Thảo Vy' : loginEmail.split('@')[0]),
        email: loginEmail,
        phone: isAdmin ? '1900 8383' : '0983 838 311',
        avatar: isAdmin
          ? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80'
          : USER_AVATAR,
        furniCoins: isAdmin ? 9999 : 150,
        savedAddress: isAdmin
          ? 'Trụ sở Furni3D, Tầng 32 Landmark 81, TP. Hồ Chí Minh'
          : 'Tòa nhà Landmark 81, P. 22, Q. Bình Thạnh, TP. Hồ Chí Minh',
        role: isAdmin ? 'admin' : 'customer',
      };

      onLoginSuccess(loggedUser);
      onShowToast(`Chào mừng ${loggedUser.name} đã đăng nhập!`);
      onClose();
    }, 700);
  };

  // Handle Google Login Simulation
  const handleGoogleLogin = () => {
    setIsLoading(true);
    setTimeout(() => {
      setIsLoading(false);
      const googleUser: UserProfile = {
        name: 'Google User Demo',
        email: 'customer@furni3d.vn',
        phone: '0983 838 311',
        avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
        furniCoins: 200,
        savedAddress: 'Tòa nhà Landmark 81, P. 22, Q. Bình Thạnh, TP. Hồ Chí Minh',
        role: 'customer',
      };
      onLoginSuccess(googleUser);
      onShowToast('Đăng nhập bằng tài khoản Google thành công!');
      onClose();
    }, 900);
  };

  // Handle Register Submit
  const handleRegisterSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!regName.trim() || !regEmail.trim() || !regPhone.trim() || !regPassword.trim()) {
      onShowToast('Vui lòng điền đầy đủ các thông tin bắt buộc');
      return;
    }
    if (regPassword !== regConfirmPassword) {
      onShowToast('Mật khẩu xác nhận không khớp');
      return;
    }

    setIsLoading(true);
    setTimeout(() => {
      setIsLoading(false);
      const newUser: UserProfile = {
        name: regName.trim(),
        email: regEmail.trim(),
        phone: regPhone.trim(),
        avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
        furniCoins: 100, // Tặng ngay 100 xu chào mừng
        savedAddress: regAddress.trim() || 'Chưa thiết lập địa chỉ mặc định',
        role: 'customer',
      };

      onLoginSuccess(newUser);
      onShowToast('🎉 Đăng ký thành công! Bạn nhận được +100 Xu thưởng FurniCoins!');
      onClose();
    }, 800);
  };

  // Handle Forgot Password
  const handleSendOtp = () => {
    if (!forgotEmail.trim()) {
      onShowToast('Vui lòng nhập Email để nhận mã OTP');
      return;
    }
    setOtpSent(true);
    onShowToast(`Mã OTP đã gửi về ${forgotEmail}. Nhập mã 123456 để tiếp tục.`);
  };

  const handleResetPassword = (e: React.FormEvent) => {
    e.preventDefault();
    if (otpCode !== '123456') {
      onShowToast('Mã OTP không đúng (Mã mẫu: 123456)');
      return;
    }
    if (!newPassword.trim()) {
      onShowToast('Vui lòng nhập mật khẩu mới');
      return;
    }
    onShowToast('Đã đổi mật khẩu thành công! Vui lòng đăng nhập.');
    setMode('login');
    setLoginEmail(forgotEmail);
    setLoginPassword(newPassword);
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 animate-fadeIn">
      <div className="bg-white rounded-3xl w-full max-w-md overflow-hidden shadow-2xl flex flex-col animate-scaleUp max-h-[92vh]">
        {/* Header with Brand Gradient */}
        <div className="relative bg-gradient-to-r from-[#2d5a46] via-[#1f4032] to-[#152e23] p-5 text-white">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-xl bg-white/20 backdrop-blur-md flex items-center justify-center text-white">
                <span className="material-symbols-outlined text-[18px]">chair</span>
              </div>
              <div>
                <span className="text-[10px] font-bold uppercase tracking-wider text-[#bceed3] block">
                  Furni3D Mobile Auth
                </span>
                <h3 className="text-base font-bold">
                  {mode === 'login' && 'Đăng nhập tài khoản'}
                  {mode === 'register' && 'Tạo tài khoản mới'}
                  {mode === 'forgot' && 'Khôi phục mật khẩu'}
                </h3>
              </div>
            </div>
            <button
              onClick={onClose}
              className="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center text-white transition-colors"
            >
              <span className="material-symbols-outlined text-[18px]">close</span>
            </button>
          </div>

          {/* Mode Tabs */}
          {mode !== 'forgot' && (
            <div className="grid grid-cols-2 gap-1 p-1 bg-black/20 rounded-xl mt-4 text-xs font-semibold">
              <button
                type="button"
                onClick={() => setMode('login')}
                className={`py-2 rounded-lg transition-all ${
                  mode === 'login'
                    ? 'bg-white text-[#2d5a46] shadow-sm font-bold'
                    : 'text-white/80 hover:text-white'
                }`}
              >
                Đăng nhập
              </button>
              <button
                type="button"
                onClick={() => setMode('register')}
                className={`py-2 rounded-lg transition-all ${
                  mode === 'register'
                    ? 'bg-white text-[#2d5a46] shadow-sm font-bold'
                    : 'text-white/80 hover:text-white'
                }`}
              >
                Đăng ký (+100 Xu)
              </button>
            </div>
          )}
        </div>

        {/* Content Body */}
        <div className="p-5 overflow-y-auto flex-1 space-y-4 text-xs text-[#161b28]">
          {/* TAB 1: LOGIN */}
          {mode === 'login' && (
            <form onSubmit={handleLoginSubmit} className="space-y-3.5">
              {/* Quick Fill Demo Accounts */}
              <div className="p-2.5 rounded-xl bg-[#f2f3ff] border border-black/5 flex items-center justify-between">
                <div className="flex items-center gap-1.5 text-[11px] font-semibold text-[#414944]">
                  <span className="material-symbols-outlined text-[15px] text-[#2d5a46]">bolt</span>
                  <span>Demo nhanh:</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <button
                    type="button"
                    onClick={() => handleQuickFill('customer')}
                    className="px-2.5 py-1 rounded-lg bg-white border border-black/10 text-[10px] font-bold text-[#2d5a46] hover:bg-[#bceed3]/30 shadow-xs"
                  >
                    👤 Khách hàng
                  </button>
                  <button
                    type="button"
                    onClick={() => handleQuickFill('admin')}
                    className="px-2.5 py-1 rounded-lg bg-[#134230] text-[10px] font-bold text-white hover:bg-[#2d5a46] shadow-xs"
                  >
                    👑 Admin
                  </button>
                </div>
              </div>

              <div>
                <label className="block text-[11px] font-bold text-[#414944] mb-1">
                  Email hoặc Số điện thoại
                </label>
                <div className="relative flex items-center">
                  <span className="material-symbols-outlined absolute left-3 text-[18px] text-[#717973]">
                    mail
                  </span>
                  <input
                    type="text"
                    required
                    value={loginEmail}
                    onChange={(e) => setLoginEmail(e.target.value)}
                    placeholder="VD: customer@furni3d.vn"
                    className="w-full h-11 pl-10 pr-3 rounded-xl bg-[#f2f3ff] text-xs text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#2d5a46] outline-none border border-transparent focus:border-transparent transition-all"
                  />
                </div>
              </div>

              <div>
                <label className="block text-[11px] font-bold text-[#414944] mb-1">Mật khẩu</label>
                <div className="relative flex items-center">
                  <span className="material-symbols-outlined absolute left-3 text-[18px] text-[#717973]">
                    lock
                  </span>
                  <input
                    type={showPassword ? 'text' : 'password'}
                    required
                    value={loginPassword}
                    onChange={(e) => setLoginPassword(e.target.value)}
                    placeholder="Nhập mật khẩu"
                    className="w-full h-11 pl-10 pr-10 rounded-xl bg-[#f2f3ff] text-xs text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#2d5a46] outline-none border border-transparent focus:border-transparent transition-all"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 text-[#717973] hover:text-[#161b28]"
                  >
                    <span className="material-symbols-outlined text-[18px]">
                      {showPassword ? 'visibility_off' : 'visibility'}
                    </span>
                  </button>
                </div>
              </div>

              <div className="flex items-center justify-between text-[11px]">
                <label className="flex items-center gap-1.5 cursor-pointer text-[#414944]">
                  <input
                    type="checkbox"
                    checked={rememberMe}
                    onChange={(e) => setRememberMe(e.target.checked)}
                    className="rounded text-[#2d5a46] focus:ring-[#2d5a46]"
                  />
                  <span>Ghi nhớ đăng nhập</span>
                </label>
                <button
                  type="button"
                  onClick={() => {
                    setForgotEmail(loginEmail);
                    setMode('forgot');
                  }}
                  className="text-[#2d5a46] font-semibold hover:underline"
                >
                  Quên mật khẩu?
                </button>
              </div>

              {/* Submit Button */}
              <button
                type="submit"
                disabled={isLoading}
                className="w-full h-11 rounded-xl bg-[#2d5a46] hover:bg-[#134230] text-white text-xs font-bold flex items-center justify-center gap-2 shadow-md transition-all active:scale-[0.99] disabled:opacity-50"
              >
                {isLoading ? (
                  <>
                    <span className="material-symbols-outlined text-[16px] animate-spin">sync</span>
                    <span>Đang đăng nhập...</span>
                  </>
                ) : (
                  <>
                    <span className="material-symbols-outlined text-[18px]">login</span>
                    <span>Đăng nhập ngay</span>
                  </>
                )}
              </button>

              {/* Divider */}
              <div className="relative flex items-center justify-center my-3">
                <div className="border-t border-black/10 w-full" />
                <span className="bg-white px-3 text-[10px] text-[#717973] uppercase font-bold absolute">
                  Hoặc
                </span>
              </div>

              {/* Google 1-Click Login Button */}
              <button
                type="button"
                onClick={handleGoogleLogin}
                disabled={isLoading}
                className="w-full h-11 rounded-xl bg-white border border-black/15 hover:bg-black/5 text-[#161b28] text-xs font-semibold flex items-center justify-center gap-2.5 shadow-xs transition-all active:scale-[0.99]"
              >
                <svg className="w-4 h-4" viewBox="0 0 24 24">
                  <path
                    fill="#4285F4"
                    d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                  />
                  <path
                    fill="#34A853"
                    d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                  />
                  <path
                    fill="#FBBC05"
                    d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
                  />
                  <path
                    fill="#EA4335"
                    d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
                  />
                </svg>
                <span>Tiếp tục với Google</span>
              </button>
            </form>
          )}

          {/* TAB 2: REGISTER */}
          {mode === 'register' && (
            <form onSubmit={handleRegisterSubmit} className="space-y-3">
              <div className="p-2.5 rounded-xl bg-[#bceed3]/30 border border-[#2d5a46]/20 flex items-center gap-2 text-[11px] text-[#002114]">
                <span className="material-symbols-outlined text-[#2d5a46] text-[18px]">card_giftcard</span>
                <span>Đăng ký hôm nay nhận ngay <strong>100 Xu thưởng</strong> trừ thẳng vào đơn hàng đầu tiên!</span>
              </div>

              <div>
                <label className="block text-[11px] font-bold text-[#414944] mb-1">
                  Họ và tên *
                </label>
                <input
                  type="text"
                  required
                  value={regName}
                  onChange={(e) => setRegName(e.target.value)}
                  placeholder="VD: Nguyễn Văn An"
                  className="w-full h-10 px-3 rounded-xl bg-[#f2f3ff] text-xs text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#2d5a46] outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="block text-[11px] font-bold text-[#414944] mb-1">Email *</label>
                  <input
                    type="email"
                    required
                    value={regEmail}
                    onChange={(e) => setRegEmail(e.target.value)}
                    placeholder="email@vidu.vn"
                    className="w-full h-10 px-3 rounded-xl bg-[#f2f3ff] text-xs text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#2d5a46] outline-none"
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-bold text-[#414944] mb-1">Số điện thoại *</label>
                  <input
                    type="tel"
                    required
                    value={regPhone}
                    onChange={(e) => setRegPhone(e.target.value)}
                    placeholder="0983..."
                    className="w-full h-10 px-3 rounded-xl bg-[#f2f3ff] text-xs text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#2d5a46] outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="block text-[11px] font-bold text-[#414944] mb-1">Mật khẩu *</label>
                  <input
                    type="password"
                    required
                    value={regPassword}
                    onChange={(e) => setRegPassword(e.target.value)}
                    placeholder="Tối thiểu 6 ký tự"
                    className="w-full h-10 px-3 rounded-xl bg-[#f2f3ff] text-xs text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#2d5a46] outline-none"
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-bold text-[#414944] mb-1">Xác nhận mật khẩu *</label>
                  <input
                    type="password"
                    required
                    value={regConfirmPassword}
                    onChange={(e) => setRegConfirmPassword(e.target.value)}
                    placeholder="Nhập lại mật khẩu"
                    className="w-full h-10 px-3 rounded-xl bg-[#f2f3ff] text-xs text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#2d5a46] outline-none"
                  />
                </div>
              </div>

              <div>
                <label className="block text-[11px] font-bold text-[#414944] mb-1">
                  Địa chỉ giao hàng mặc định (Tùy chọn)
                </label>
                <input
                  type="text"
                  value={regAddress}
                  onChange={(e) => setRegAddress(e.target.value)}
                  placeholder="VD: 123 Đường Nguyễn Huệ, Quận 1, TP.HCM"
                  className="w-full h-10 px-3 rounded-xl bg-[#f2f3ff] text-xs text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#2d5a46] outline-none"
                />
              </div>

              <button
                type="submit"
                disabled={isLoading}
                className="w-full h-11 rounded-xl bg-[#2d5a46] hover:bg-[#134230] text-white text-xs font-bold flex items-center justify-center gap-2 shadow-md transition-all mt-2"
              >
                {isLoading ? (
                  <>
                    <span className="material-symbols-outlined text-[16px] animate-spin">sync</span>
                    <span>Đang khởi tạo tài khoản...</span>
                  </>
                ) : (
                  <>
                    <span className="material-symbols-outlined text-[18px]">how_to_reg</span>
                    <span>Đăng ký thành viên (+100 Xu)</span>
                  </>
                )}
              </button>
            </form>
          )}

          {/* TAB 3: FORGOT PASSWORD */}
          {mode === 'forgot' && (
            <form onSubmit={handleResetPassword} className="space-y-3.5">
              <div className="p-3 rounded-xl bg-[#f2f3ff] text-xs text-[#414944] leading-relaxed">
                Nhập email tài khoản để nhận mã OTP xác thực khôi phục mật khẩu.
              </div>

              <div>
                <label className="block text-[11px] font-bold text-[#414944] mb-1">Email tài khoản</label>
                <div className="flex gap-2">
                  <input
                    type="email"
                    required
                    value={forgotEmail}
                    onChange={(e) => setForgotEmail(e.target.value)}
                    placeholder="VD: customer@furni3d.vn"
                    className="flex-1 h-10 px-3 rounded-xl bg-[#f2f3ff] text-xs text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#2d5a46] outline-none"
                  />
                  <button
                    type="button"
                    onClick={handleSendOtp}
                    className="px-3 h-10 rounded-xl bg-[#2d5a46] text-white text-xs font-semibold whitespace-nowrap"
                  >
                    {otpSent ? 'Gửi lại' : 'Gửi mã OTP'}
                  </button>
                </div>
              </div>

              {otpSent && (
                <>
                  <div>
                    <label className="block text-[11px] font-bold text-[#414944] mb-1">Mã xác thực OTP (6 số)</label>
                    <input
                      type="text"
                      required
                      value={otpCode}
                      onChange={(e) => setOtpCode(e.target.value)}
                      placeholder="Mã test: 123456"
                      className="w-full h-10 px-3 rounded-xl bg-[#f2f3ff] text-xs font-mono font-bold text-center tracking-widest text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#2d5a46] outline-none"
                    />
                  </div>

                  <div>
                    <label className="block text-[11px] font-bold text-[#414944] mb-1">Mật khẩu mới</label>
                    <input
                      type="password"
                      required
                      value={newPassword}
                      onChange={(e) => setNewPassword(e.target.value)}
                      placeholder="Nhập mật khẩu mới"
                      className="w-full h-10 px-3 rounded-xl bg-[#f2f3ff] text-xs text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#2d5a46] outline-none"
                    />
                  </div>

                  <button
                    type="submit"
                    className="w-full h-11 rounded-xl bg-[#2d5a46] hover:bg-[#134230] text-white text-xs font-bold flex items-center justify-center gap-2 shadow-md transition-all"
                  >
                    <span className="material-symbols-outlined text-[18px]">check_circle</span>
                    <span>Xác nhận & Đổi mật khẩu</span>
                  </button>
                </>
              )}

              <button
                type="button"
                onClick={() => setMode('login')}
                className="w-full py-2 text-xs font-semibold text-[#414944] hover:text-[#161b28] text-center"
              >
                ← Quay lại Đăng nhập
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  );
};
