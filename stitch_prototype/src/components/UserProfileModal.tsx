import React, { useState } from 'react';
import { UserProfile } from '../types';

interface UserProfileModalProps {
  isOpen: boolean;
  user: UserProfile | null;
  onClose: () => void;
  onUpdateUser: (updated: UserProfile) => void;
  onSwitchRole: () => void;
  onLogout: () => void;
  onOpenAuth: () => void;
  onShowToast: (msg: string) => void;
}

export const UserProfileModal: React.FC<UserProfileModalProps> = ({
  isOpen,
  user,
  onClose,
  onUpdateUser,
  onSwitchRole,
  onLogout,
  onOpenAuth,
  onShowToast,
}) => {
  const [name, setName] = useState(user?.name || '');
  const [phone, setPhone] = useState(user?.phone || '');
  const [address, setAddress] = useState(user?.savedAddress || '');
  const [isEditing, setIsEditing] = useState(false);

  // Sync state if user changes
  React.useEffect(() => {
    if (user) {
      setName(user.name);
      setPhone(user.phone);
      setAddress(user.savedAddress);
    }
  }, [user]);

  if (!isOpen) return null;

  if (!user) {
    return (
      <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 animate-fadeIn">
        <div className="bg-white rounded-3xl w-full max-w-sm overflow-hidden shadow-2xl p-6 text-center animate-scaleUp">
          <div className="w-16 h-16 rounded-full bg-[#f2f3ff] flex items-center justify-center mx-auto mb-3">
            <span className="material-symbols-outlined text-[32px] text-[#2d5a46]">person_outline</span>
          </div>
          <h3 className="text-base font-bold text-[#161b28]">Chưa đăng nhập tài khoản</h3>
          <p className="text-xs text-[#717973] mt-1 mb-5">
            Đăng nhập để xem lịch sử đơn hàng, tích lũy ví FurniCoins và nhận ưu đãi độc quyền.
          </p>
          <div className="space-y-2">
            <button
              onClick={() => {
                onClose();
                onOpenAuth();
              }}
              className="w-full h-11 rounded-xl bg-[#2d5a46] text-white text-xs font-bold shadow-md hover:bg-[#134230]"
            >
              Đăng nhập / Đăng ký ngay
            </button>
            <button
              onClick={onClose}
              className="w-full py-2 text-xs font-semibold text-[#717973] hover:text-[#161b28]"
            >
              Để sau
            </button>
          </div>
        </div>
      </div>
    );
  }

  const handleSave = () => {
    onUpdateUser({
      ...user,
      name,
      phone,
      savedAddress: address,
    });
    setIsEditing(false);
    onShowToast('Đã cập nhật thông tin tài khoản thành công!');
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 animate-fadeIn">
      <div className="bg-white rounded-3xl w-full max-w-sm overflow-hidden shadow-2xl flex flex-col animate-scaleUp max-h-[92vh]">
        {/* Header Profile Cover */}
        <div className="relative h-24 bg-gradient-to-r from-[#2d5a46] to-[#134230] p-4 flex items-start justify-between text-white flex-shrink-0">
          <div className="flex items-center gap-1.5">
            <span className="text-[10px] font-bold uppercase tracking-wider text-[#bceed3]">
              Hồ sơ thành viên Furni3D
            </span>
            <span className={`px-2 py-0.5 rounded-full text-[9px] font-bold uppercase ${
              user.role === 'admin' ? 'bg-amber-400 text-black' : 'bg-white/20 text-white'
            }`}>
              {user.role === 'admin' ? 'Quản trị viên' : 'Khách hàng VIP'}
            </span>
          </div>
          <button
            onClick={onClose}
            className="w-7 h-7 rounded-full bg-white/20 flex items-center justify-center text-white hover:bg-white/30"
          >
            <span className="material-symbols-outlined text-[16px]">close</span>
          </button>
        </div>

        {/* Avatar & Floating Coins Card */}
        <div className="px-5 pb-5 flex flex-col gap-3 -mt-10 overflow-y-auto">
          <div className="flex items-end justify-between">
            <div className="relative w-20 h-20 rounded-2xl border-4 border-white shadow-md overflow-hidden bg-white flex-shrink-0">
              <img src={user.avatar} alt={user.name} className="w-full h-full object-cover" />
            </div>

            {/* Furni Coins Card */}
            <div className="bg-[#fec38d]/40 border border-[#805528]/20 px-3 py-1.5 rounded-xl flex items-center gap-2 shadow-xs">
              <span className="material-symbols-outlined text-[#805528] text-[22px]">monetization_on</span>
              <div className="flex flex-col text-left">
                <span className="text-[9px] text-[#794f23] font-bold uppercase">Ví Furni Coins</span>
                <span className="text-sm font-black text-[#805528] leading-none">
                  {user.furniCoins} Xu
                </span>
              </div>
            </div>
          </div>

          {/* User Info / Edit form */}
          {isEditing ? (
            <div className="space-y-2.5 pt-1 text-xs">
              <div>
                <label className="text-[10px] font-bold text-[#414944] block mb-1">Họ và tên</label>
                <input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="w-full h-9 px-3 rounded-xl bg-[#f2f3ff] text-xs text-[#161b28] focus:bg-white focus:ring-1 focus:ring-[#2d5a46] outline-none"
                />
              </div>
              <div>
                <label className="text-[10px] font-bold text-[#414944] block mb-1">Số điện thoại</label>
                <input
                  type="text"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  className="w-full h-9 px-3 rounded-xl bg-[#f2f3ff] text-xs text-[#161b28] focus:bg-white focus:ring-1 focus:ring-[#2d5a46] outline-none"
                />
              </div>
              <div>
                <label className="text-[10px] font-bold text-[#414944] block mb-1">Địa chỉ giao hàng mặc định</label>
                <textarea
                  value={address}
                  onChange={(e) => setAddress(e.target.value)}
                  className="w-full p-2.5 rounded-xl bg-[#f2f3ff] text-xs text-[#161b28] focus:bg-white focus:ring-1 focus:ring-[#2d5a46] outline-none resize-none"
                  rows={2}
                />
              </div>
              <div className="flex justify-end gap-2 pt-2">
                <button
                  onClick={() => setIsEditing(false)}
                  className="px-3.5 py-1.5 rounded-xl bg-[#dee2f4] text-xs font-semibold text-[#161b28]"
                >
                  Hủy
                </button>
                <button
                  onClick={handleSave}
                  className="px-3.5 py-1.5 rounded-xl bg-[#2d5a46] text-white text-xs font-bold shadow-xs"
                >
                  Lưu thay đổi
                </button>
              </div>
            </div>
          ) : (
            <div className="space-y-3 pt-1">
              <div>
                <div className="flex items-center justify-between">
                  <h3 className="text-base font-bold text-[#161b28]">{user.name}</h3>
                  <button
                    onClick={() => setIsEditing(true)}
                    className="text-xs font-semibold text-[#2d5a46] hover:underline flex items-center gap-0.5"
                  >
                    <span className="material-symbols-outlined text-[14px]">edit</span>
                    <span>Sửa</span>
                  </button>
                </div>
                <p className="text-xs text-[#414944]">{user.email} • {user.phone}</p>
              </div>

              <div className="bg-[#f2f3ff] p-3 rounded-2xl border border-black/5 text-xs text-[#414944]">
                <span className="text-[10px] uppercase font-bold text-[#717973] block mb-0.5">
                  Địa chỉ nhận hàng mặc định:
                </span>
                <p className="text-[#161b28] font-medium leading-relaxed">{user.savedAddress}</p>
              </div>

              {/* Coins benefit highlight */}
              <div className="p-3 rounded-2xl bg-amber-50 border border-amber-200/60 text-[11px] text-[#794f23] space-y-1">
                <span className="font-bold block text-[#805528]">Quyền lợi tích lũy Xu thưởng:</span>
                <p className="leading-snug">
                  • Nhận +30 Xu mỗi đơn hàng thanh toán thành công.
                  <br />
                  • Nhận +50 Xu khi hoàn tất đánh giá sản phẩm.
                  <br />
                  • Sử dụng xu trực tiếp để giảm trừ tiền khi mua sắm!
                </p>
              </div>

              {/* Switch Role Button */}
              <button
                onClick={onSwitchRole}
                className="w-full py-2.5 px-3 rounded-xl border border-black/10 hover:bg-black/5 text-xs font-semibold flex items-center justify-between text-[#161b28] transition-colors"
              >
                <div className="flex items-center gap-2">
                  <span className="material-symbols-outlined text-[18px] text-[#2d5a46]">
                    {user.role === 'customer' ? 'admin_panel_settings' : 'storefront'}
                  </span>
                  <span>{user.role === 'customer' ? 'Chuyển sang Quản trị viên (Admin)' : 'Chuyển sang Giao diện Khách'}</span>
                </div>
                <span className="material-symbols-outlined text-[16px] text-[#717973]">chevron_right</span>
              </button>

              {/* Logout & Switch Account */}
              <div className="grid grid-cols-2 gap-2 pt-1">
                <button
                  onClick={() => {
                    onClose();
                    onOpenAuth();
                  }}
                  className="py-2.5 px-3 rounded-xl bg-[#e9edff] hover:bg-[#dee2f4] text-[#2d5a46] text-xs font-bold flex items-center justify-center gap-1.5"
                >
                  <span className="material-symbols-outlined text-[16px]">switch_account</span>
                  <span>Đổi tài khoản</span>
                </button>

                <button
                  onClick={() => {
                    onLogout();
                    onClose();
                    onShowToast('Đã đăng xuất tài khoản');
                  }}
                  className="py-2.5 px-3 rounded-xl bg-red-50 hover:bg-red-100 text-red-600 text-xs font-bold flex items-center justify-center gap-1.5"
                >
                  <span className="material-symbols-outlined text-[16px]">logout</span>
                  <span>Đăng xuất</span>
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
