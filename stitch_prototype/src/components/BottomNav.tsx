import React from 'react';

export type TabKey = 'kham-pha' | 'mo-hinh-3d' | 'linh-kien' | 'don-hang' | 'admin';

interface BottomNavProps {
  activeTab: TabKey;
  onSelectTab: (tab: TabKey) => void;
  isAdmin: boolean;
}

export const BottomNav: React.FC<BottomNavProps> = ({ activeTab, onSelectTab, isAdmin }) => {
  const tabs = [
    { key: 'kham-pha' as TabKey, label: 'Khám phá', icon: 'chair' },
    { key: 'mo-hinh-3d' as TabKey, label: 'Mô hình 3D', icon: 'view_in_ar' },
    { key: 'linh-kien' as TabKey, label: 'Linh kiện', icon: 'handyman' },
    { key: 'don-hang' as TabKey, label: 'Đơn hàng', icon: 'inventory_2' },
  ];

  if (isAdmin) {
    tabs.push({ key: 'admin' as TabKey, label: 'Quản trị', icon: 'admin_panel_settings' });
  }

  return (
    <nav className="fixed bottom-0 w-full z-40 pb-safe bg-[#faf8ff]/95 backdrop-blur-xl border-t border-black/[0.05] shadow-[0_-4px_20px_-2px_rgba(26,31,44,0.06)]">
      <div className={`h-16 max-w-md mx-auto grid ${isAdmin ? 'grid-cols-5' : 'grid-cols-4'} items-center px-2`}>
        {tabs.map((tab) => {
          const isActive = activeTab === tab.key;
          return (
            <button
              key={tab.key}
              onClick={() => onSelectTab(tab.key)}
              className={`flex flex-col items-center justify-center gap-1 py-1 transition-all min-h-[44px] ${
                isActive
                  ? 'text-[#2d5a46] font-semibold scale-105'
                  : 'text-[#414944] hover:text-[#161b28]'
              }`}
            >
              <span
                className="material-symbols-outlined text-[22px]"
                style={isActive ? { fontVariationSettings: "'FILL' 1" } : undefined}
              >
                {tab.icon}
              </span>
              <span className="text-[11px] font-medium leading-none tracking-tight">
                {tab.label}
              </span>
            </button>
          );
        })}
      </div>
    </nav>
  );
};
