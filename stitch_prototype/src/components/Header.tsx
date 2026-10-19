import React from 'react';
import { FURNI_LOGO } from '../data/mockData';
import { UserProfile } from '../types';

interface HeaderProps {
  currentTab: 'kham-pha' | 'mo-hinh-3d' | 'linh-kien' | 'don-hang' | 'admin';
  cartCount: number;
  user: UserProfile | null;
  isMobileFrame: boolean;
  onOpenCart: () => void;
  onOpenProfile: () => void;
  onOpenAuth: () => void;
  onToggleSearch: () => void;
  onSwitchRole: () => void;
  onToggleMobileFrame: () => void;
}

export const Header: React.FC<HeaderProps> = ({
  currentTab,
  cartCount,
  user,
  isMobileFrame,
  onOpenCart,
  onOpenProfile,
  onOpenAuth,
  onToggleSearch,
  onSwitchRole,
  onToggleMobileFrame,
}) => {
  const getTabTitle = () => {
    switch (currentTab) {
      case 'kham-pha':
        return 'Khám Phá';
      case 'mo-hinh-3d':
        return 'Mô Hình 3D';
      case 'linh-kien':
        return 'Linh Kiện';
      case 'don-hang':
        return 'Đơn Hàng';
      case 'admin':
        return 'Quản Trị Furni3D';
      default:
        return 'Furni3D';
    }
  };

  return (
    <header className="sticky top-0 w-full z-40 pt-safe bg-[#faf8ff]/95 backdrop-blur-xl shadow-[0_1px_8px_rgba(26,31,44,0.05)] border-b border-black/[0.04]">
      <div className="h-16 max-w-5xl mx-auto px-4 flex items-center justify-between gap-2 sm:gap-3">
        {/* Left: Brand Logo & Title */}
        <div className="flex items-center gap-2 min-w-0">
          <img
            alt="Furni3D Logo"
            className="h-8 w-auto object-contain flex-shrink-0"
            src={FURNI_LOGO}
          />
          <div className="flex flex-col min-w-0">
            <div className="flex items-center gap-1.5">
              <span className="text-[10px] font-bold uppercase tracking-wider text-[#805528]">
                Furni3D Mobile
              </span>
              {user?.role === 'admin' && (
                <span className="px-1.5 py-0.2 rounded bg-[#134230] text-white text-[9px] font-bold uppercase">
                  Admin
                </span>
              )}
            </div>
            <h1 className="text-base sm:text-lg font-bold text-[#161b28] truncate leading-tight">
              {getTabTitle()}
            </h1>
          </div>
        </div>

        {/* Right Actions */}
        <div className="flex items-center gap-1 sm:gap-1.5">
          {/* Mobile Frame Simulation Toggle */}
          <button
            onClick={onToggleMobileFrame}
            title={isMobileFrame ? 'Chuyển sang xem toàn màn hình' : 'Bật khung mô phỏng điện thoại di động (Mobile Frame)'}
            className={`hidden md:flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold border transition-all ${
              isMobileFrame
                ? 'bg-[#2d5a46] text-white border-[#2d5a46] shadow-xs'
                : 'bg-white text-[#414944] border-black/10 hover:border-black/20'
            }`}
          >
            <span className="material-symbols-outlined text-[15px]">
              {isMobileFrame ? 'phone_iphone' : 'laptop'}
            </span>
            <span className="text-[11px]">{isMobileFrame ? 'Khung Mobile' : 'Mở rộng'}</span>
          </button>

          {/* Role Quick Toggle (if logged in) */}
          {user && (
            <button
              onClick={onSwitchRole}
              title={`Chuyển sang chế độ ${user.role === 'customer' ? 'Admin' : 'Khách hàng'}`}
              className="px-2 py-1 rounded-full text-xs font-semibold flex items-center gap-1 border border-black/10 bg-white hover:bg-black/5 transition-all text-[#161b28]"
            >
              <span className="material-symbols-outlined text-[15px] text-[#2d5a46]">
                {user.role === 'customer' ? 'admin_panel_settings' : 'person'}
              </span>
              <span className="hidden sm:inline text-[11px]">
                {user.role === 'customer' ? 'Admin' : 'Khách'}
              </span>
            </button>
          )}

          {/* Search Trigger */}
          <button
            onClick={onToggleSearch}
            aria-label="Tìm kiếm"
            className="w-9 h-9 flex items-center justify-center rounded-full text-[#414944] hover:text-[#161b28] hover:bg-black/5 transition-colors"
          >
            <span className="material-symbols-outlined text-[19px]">search</span>
          </button>

          {/* Cart Trigger */}
          <button
            onClick={onOpenCart}
            aria-label="Giỏ hàng"
            className="relative w-9 h-9 flex items-center justify-center rounded-full text-[#414944] hover:text-[#161b28] hover:bg-black/5 transition-colors"
          >
            <span className="material-symbols-outlined text-[19px]">shopping_bag</span>
            {cartCount > 0 && (
              <span className="absolute top-1 right-1 w-4 h-4 rounded-full bg-[#805528] text-white text-[9px] font-bold flex items-center justify-center shadow-xs">
                {cartCount}
              </span>
            )}
          </button>

          {/* User Profile or Login Trigger */}
          {user ? (
            <button
              onClick={onOpenProfile}
              aria-label="Tài khoản cá nhân"
              className="relative w-8 h-8 ml-0.5 rounded-full overflow-hidden ring-2 ring-transparent hover:ring-[#2d5a46]/40 transition-all flex-shrink-0"
            >
              <img
                alt={user.name}
                className="w-full h-full object-cover"
                src={user.avatar}
              />
            </button>
          ) : (
            <button
              onClick={onOpenAuth}
              className="ml-1 px-3 py-1.5 rounded-xl bg-[#2d5a46] hover:bg-[#134230] text-white text-xs font-bold flex items-center gap-1 shadow-xs transition-all active:scale-95"
            >
              <span className="material-symbols-outlined text-[15px]">login</span>
              <span>Đăng nhập</span>
            </button>
          )}
        </div>
      </div>
    </header>
  );
};
