import { useState, useEffect } from 'react';
import {
  INITIAL_USER,
  INITIAL_ORDERS,
  INITIAL_MISSING_REPORTS,
  INITIAL_VOUCHERS,
  PRODUCTS,
} from './data/mockData';
import { Order, MissingReportItem, DiscountVoucher, UserProfile, Product } from './types';
import { Header } from './components/Header';
import { BottomNav, TabKey } from './components/BottomNav';
import { ExploreView } from './components/ExploreView';
import { Model3DView } from './components/Model3DView';
import { PartsView } from './components/PartsView';
import { OrdersView } from './components/OrdersView';
import { AdminView } from './components/AdminView';
import { CartDrawer, CartItem } from './components/CartDrawer';
import { CheckoutModal } from './components/CheckoutModal';
import { QRScannerModal } from './components/QRScannerModal';
import { ARViewModal } from './components/ARViewModal';
import { DriverTrackingModal } from './components/DriverTrackingModal';
import { VnpayInvoiceModal } from './components/VnpayInvoiceModal';
import { UserProfileModal } from './components/UserProfileModal';
import { AuthModal } from './components/AuthModal';
import { ProductDetailModal } from './components/ProductDetailModal';

export default function App() {
  // Navigation
  const [currentTab, setCurrentTab] = useState<TabKey>('kham-pha');

  // Mobile Mockup Frame mode (for testing & presentation as a native mobile screen)
  const [isMobileFrame, setIsMobileFrame] = useState<boolean>(false);

  // App State with LocalStorage Persistence
  const [user, setUser] = useState<UserProfile | null>(() => {
    try {
      const saved = localStorage.getItem('furni3d_user');
      if (saved === 'null') return null;
      return saved ? JSON.parse(saved) : INITIAL_USER;
    } catch {
      return INITIAL_USER;
    }
  });

  const [orders, setOrders] = useState<Order[]>(() => {
    try {
      const saved = localStorage.getItem('furni3d_orders');
      return saved ? JSON.parse(saved) : INITIAL_ORDERS;
    } catch {
      return INITIAL_ORDERS;
    }
  });

  const [missingReports, setMissingReports] = useState<MissingReportItem[]>(() => {
    try {
      const saved = localStorage.getItem('furni3d_reports');
      return saved ? JSON.parse(saved) : INITIAL_MISSING_REPORTS;
    } catch {
      return INITIAL_MISSING_REPORTS;
    }
  });

  const [vouchers, setVouchers] = useState<DiscountVoucher[]>(() => {
    try {
      const saved = localStorage.getItem('furni3d_vouchers');
      return saved ? JSON.parse(saved) : INITIAL_VOUCHERS;
    } catch {
      return INITIAL_VOUCHERS;
    }
  });

  const [cartItems, setCartItems] = useState<CartItem[]>(() => {
    try {
      const saved = localStorage.getItem('furni3d_cart');
      return saved
        ? JSON.parse(saved)
        : [
            {
              id: 'part-cam-set',
              name: 'Bộ ốc khóa chốt cam M6x35',
              price: 25000,
              quantity: 2,
              image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAL8hG0kckF4v2k3krGiYybPv1_HBGUBxEQ6dLhi8-AxcfXp17rIqftn9wSVVMHEjKOR1FZtIIZPJL6tUBEWXpfYrGVSx1nXBsm1VlvZeLz7cWDNXeHrJNWN7Bp8auZKI8kGndcJEJ2n0bJ0TBNKnzFJPYGBdDz1aUdeZdgUrZVoh_NWS0IhYc3GzaRAHEkJuB-wgEy0zPLbtIBbga167FHSgy4WKgVtc8M0F9htq51l9YGRhB01IvvfA',
              variant: 'Túi 10 cái',
            },
          ];
    } catch {
      return [];
    }
  });

  // Current product selected for 3D guide
  const [selectedProduct, setSelectedProduct] = useState<Product>(PRODUCTS[0]);

  // Selected product for full detail view
  const [selectedDetailProduct, setSelectedDetailProduct] = useState<Product | null>(null);
  const [isProductDetailOpen, setIsProductDetailOpen] = useState(false);

  // Modal visibility states
  const [isAuthOpen, setIsAuthOpen] = useState(false);
  const [authInitialMode, setAuthInitialMode] = useState<'login' | 'register'>('login');
  const [isCartOpen, setIsCartOpen] = useState(false);
  const [isCheckoutOpen, setIsCheckoutOpen] = useState(false);
  const [checkoutAmount, setCheckoutAmount] = useState(0);
  const [checkoutCoinsUsed, setCheckoutCoinsUsed] = useState(0);
  const [checkoutVoucherCode, setCheckoutVoucherCode] = useState('');
  const [isQRScannerOpen, setIsQRScannerOpen] = useState(false);
  const [isARViewOpen, setIsARViewOpen] = useState(false);
  const [isProfileOpen, setIsProfileOpen] = useState(false);
  const [activeTrackingOrder, setActiveTrackingOrder] = useState<Order | null>(null);
  const [activeInvoiceOrder, setActiveInvoiceOrder] = useState<Order | null>(null);

  // Toast Notification state
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
  };

  useEffect(() => {
    if (!toastMessage) return;
    const timer = setTimeout(() => {
      setToastMessage(null);
    }, 2800);
    return () => clearTimeout(timer);
  }, [toastMessage]);

  // Save to localStorage
  useEffect(() => {
    try {
      localStorage.setItem('furni3d_user', JSON.stringify(user));
      localStorage.setItem('furni3d_orders', JSON.stringify(orders));
      localStorage.setItem('furni3d_reports', JSON.stringify(missingReports));
      localStorage.setItem('furni3d_vouchers', JSON.stringify(vouchers));
      localStorage.setItem('furni3d_cart', JSON.stringify(cartItems));
    } catch {
      // ignore
    }
  }, [user, orders, missingReports, vouchers, cartItems]);

  // Cart Handlers
  const handleAddToCart = (item: {
    id: string;
    name: string;
    price: number;
    image: string;
    variant?: string;
    quantity?: number;
  }) => {
    const qty = item.quantity || 1;
    setCartItems((prev) => {
      const existing = prev.find((i) => i.id === item.id);
      if (existing) {
        return prev.map((i) => (i.id === item.id ? { ...i, quantity: i.quantity + qty } : i));
      }
      return [...prev, { ...item, quantity: qty }];
    });
  };

  const handleBuyNow = (item: {
    id: string;
    name: string;
    price: number;
    image: string;
    variant?: string;
    quantity: number;
  }) => {
    handleAddToCart(item);
    setIsCartOpen(true);
    showToast(`Đã thêm ${item.name} vào giỏ hàng`);
  };

  const handleUpdateCartQty = (id: string, delta: number) => {
    setCartItems((prev) =>
      prev
        .map((i) => (i.id === id ? { ...i, quantity: i.quantity + delta } : i))
        .filter((i) => i.quantity > 0)
    );
  };

  const handleRemoveCartItem = (id: string) => {
    setCartItems((prev) => prev.filter((i) => i.id !== id));
    showToast('Đã xóa món khỏi giỏ hàng');
  };

  const handleClearCart = () => {
    setCartItems([]);
    showToast('Đã xóa tất cả món trong giỏ hàng');
  };

  const handleProceedCheckout = (details: {
    discountAmount: number;
    appliedCode: string;
    coinsUsed: number;
    coinsDiscount: number;
  }) => {
    const subtotal = cartItems.reduce((acc, cur) => acc + cur.price * cur.quantity, 0);
    const shipping = subtotal > 2000000 || cartItems.length === 0 ? 0 : 45000;
    const finalAmount = Math.max(0, subtotal - details.discountAmount - details.coinsDiscount + shipping);

    setCheckoutAmount(finalAmount);
    setCheckoutCoinsUsed(details.coinsUsed);
    setCheckoutVoucherCode(details.appliedCode);
    setIsCartOpen(false);
    setIsCheckoutOpen(true);
  };

  const handlePaymentSuccess = (paymentDetails: {
    transactionId: string;
    paymentMethod: 'VNPAY_QR' | 'COD' | 'BANK_TRANSFER';
    receiverName: string;
    receiverPhone: string;
    shippingAddress: string;
    orderNote: string;
  }) => {
    const newOrderCode = `#F3D-${Math.floor(10000 + Math.random() * 90000)}`;
    const newOrder: Order = {
      id: `ord-${Date.now()}`,
      code: newOrderCode,
      date: new Date().toLocaleDateString('vi-VN'),
      estimatedDelivery: 'Hôm nay, 16:30 - 18:30',
      totalAmount: checkoutAmount,
      paymentMethod: paymentDetails.paymentMethod,
      paymentStatus: paymentDetails.paymentMethod === 'COD' ? 'PENDING' : 'PAID',
      transactionId: paymentDetails.transactionId,
      status: 'shipping',
      items: cartItems.map((ci) => ({
        productId: ci.id,
        name: ci.name,
        price: ci.price,
        quantity: ci.quantity,
        image: ci.image,
        packageInfo: ci.variant || '1 Kiện tiêu chuẩn',
      })),
      driver: {
        name: 'Trần Văn Hoàng',
        licensePlate: '51D-918.42',
        phone: '0908 776 554',
        distanceKm: 2.8,
        avatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=160&q=80',
      },
      timeline: [
        {
          id: 1,
          title: 'Đã xác nhận đơn hàng',
          time: 'Vừa xong',
          description:
            paymentDetails.paymentMethod === 'COD'
              ? 'Hệ thống Furni3D tiếp nhận đơn COD, đóng gói giao ngay.'
              : 'Khớp lệnh cổng thanh toán VNPAY thành công.',
          status: 'completed',
        },
        {
          id: 2,
          title: 'Đã xuất kho & kiểm đếm phụ kiện',
          time: 'Đang xử lý',
          description: 'Kho Trung tâm chuẩn bị quét mã vạch và bọc xốp chống sốc.',
          status: 'current',
        },
        {
          id: 3,
          title: 'Nội thất Express đang vận chuyển',
          time: 'Dự kiến 15:45',
          description: 'Tài xế nhận hàng và di chuyển tới điểm giao.',
          status: 'upcoming',
        },
        {
          id: 4,
          title: 'Giao hàng & quét QR nghiệm thu',
          time: 'Dự kiến 16:30',
          description: 'Bàn giao và hướng dẫn quét QR mở model 3D.',
          status: 'upcoming',
        },
      ],
    };

    setOrders((prev) => [newOrder, ...prev]);
    setCartItems([]);

    // Update user coins: deduct used coins + reward new coins (+30 Xu)
    if (user) {
      setUser((prev) => {
        if (!prev) return prev;
        const newBalance = Math.max(0, prev.furniCoins - checkoutCoinsUsed) + 30;
        return { ...prev, furniCoins: newBalance };
      });
    }

    setIsCheckoutOpen(false);
    setCurrentTab('don-hang');
    setActiveInvoiceOrder(newOrder);
    showToast(`🎉 Đặt hàng thành công! Mã đơn: ${newOrderCode} (+30 Xu thưởng)`);
  };

  // Review submission
  const handleSubmitReview = (
    orderId: string,
    stars: number,
    tags: string[],
    comment: string
  ) => {
    setOrders((prev) =>
      prev.map((o) =>
        o.id === orderId
          ? {
              ...o,
              review: {
                stars,
                tags,
                comment,
                rewardEarned: 50,
                createdAt: new Date().toLocaleDateString('vi-VN'),
                status: 'approved',
              },
            }
          : o
      )
    );
    if (user) {
      setUser((prev) => (prev ? { ...prev, furniCoins: prev.furniCoins + 50 } : prev));
    }
  };

  // Missing Part submission
  const handleSubmitMissingReport = (report: MissingReportItem) => {
    setMissingReports((prev) => [report, ...prev]);
    setOrders((prev) =>
      prev.map((o) => (o.code === report.orderId ? { ...o, status: 'support_needed' } : o))
    );
  };

  // QR Scan result
  const handleQRScanResult = (code: string) => {
    showToast(`Đã nhận diện mã QR: ${code}`);
    if (code.includes('ND-2024') || code.includes('88219')) {
      setSelectedProduct(PRODUCTS[0]);
    } else if (code.includes('PC-108') || code.includes('94821')) {
      setSelectedProduct(PRODUCTS[1]);
    }
    setCurrentTab('mo-hinh-3d');
  };

  // Role toggle
  const handleSwitchRole = () => {
    if (!user) {
      setIsAuthOpen(true);
      return;
    }
    const nextRole = user.role === 'customer' ? 'admin' : 'customer';
    setUser((prev) => (prev ? { ...prev, role: nextRole } : prev));
    if (nextRole === 'admin') {
      setCurrentTab('admin');
      showToast('Đã chuyển sang chế độ Quản trị viên (Admin)');
    } else {
      setCurrentTab('kham-pha');
      showToast('Đã chuyển sang giao diện Khách hàng');
    }
  };

  // Handle Login / Logout
  const handleLoginSuccess = (loggedUser: UserProfile) => {
    setUser(loggedUser);
    if (loggedUser.role === 'admin') {
      setCurrentTab('admin');
    }
  };

  const handleLogout = () => {
    setUser(null);
    localStorage.removeItem('furni3d_user');
    if (currentTab === 'admin') {
      setCurrentTab('kham-pha');
    }
  };

  // Navigation tab select guard
  const handleSelectTab = (tab: TabKey) => {
    if (tab === 'admin' && user?.role !== 'admin') {
      showToast('Vui lòng đăng nhập quyền Admin để truy cập');
      setIsAuthOpen(true);
      return;
    }
    setCurrentTab(tab);
  };

  // Open Product Detail Modal
  const handleOpenProductDetail = (prod: Product) => {
    setSelectedDetailProduct(prod);
    setIsProductDetailOpen(true);
  };

  return (
    <div className={`min-h-screen bg-[#eceef8] text-[#161b28] flex justify-center items-start font-sans ${isMobileFrame ? 'py-4 sm:py-8' : ''}`}>
      {/* Smartphone Shell Container (when isMobileFrame is true) or Full Layout */}
      <div
        className={`w-full bg-[#faf8ff] flex flex-col relative transition-all duration-300 shadow-2xl ${
          isMobileFrame
            ? 'max-w-[420px] rounded-[44px] border-[10px] border-[#1f2421] min-h-[860px] overflow-hidden ring-4 ring-black/10'
            : 'max-w-5xl min-h-screen'
        }`}
      >
        {/* Smartphone Top Notch / Dynamic Island Bar (in Mobile Frame view) */}
        {isMobileFrame && (
          <div className="h-9 bg-[#faf8ff] w-full flex items-center justify-between px-6 pt-1 text-[11px] font-bold text-[#161b28] select-none z-50">
            <span>9:41</span>
            {/* Dynamic Island Pill */}
            <div className="w-24 h-4 rounded-full bg-black flex items-center justify-center">
              <span className="w-2 h-2 rounded-full bg-[#2d5a46] mr-1.5 animate-pulse" />
              <span className="text-[8px] text-white font-mono">FURNI3D</span>
            </div>
            <div className="flex items-center gap-1.5 text-[14px]">
              <span className="material-symbols-outlined text-[14px]">signal_cellular_4_bar</span>
              <span className="material-symbols-outlined text-[14px]">wifi</span>
              <span className="material-symbols-outlined text-[16px]">battery_full</span>
            </div>
          </div>
        )}

        {/* Header */}
        <Header
          currentTab={currentTab}
          cartCount={cartItems.reduce((acc, cur) => acc + cur.quantity, 0)}
          user={user}
          isMobileFrame={isMobileFrame}
          onOpenCart={() => setIsCartOpen(true)}
          onOpenProfile={() => setIsProfileOpen(true)}
          onOpenAuth={() => {
            setAuthInitialMode('login');
            setIsAuthOpen(true);
          }}
          onToggleSearch={() => showToast('Mở thanh tìm kiếm sản phẩm và phụ kiện')}
          onSwitchRole={handleSwitchRole}
          onToggleMobileFrame={() => setIsMobileFrame(!isMobileFrame)}
        />

        {/* Main Content Area */}
        <main className="flex-1 w-full pt-2 pb-24">
          {currentTab === 'kham-pha' && (
            <ExploreView
              onOpenQRScanner={() => setIsQRScannerOpen(true)}
              onOpen3DGuide={(product) => {
                if (product) setSelectedProduct(product);
                setCurrentTab('mo-hinh-3d');
              }}
              onOpenProductDetail={handleOpenProductDetail}
              onGoToParts={() => setCurrentTab('linh-kien')}
              onGoToOrders={() => setCurrentTab('don-hang')}
              onAddToCart={handleAddToCart}
              onOpenAR={() => setIsARViewOpen(true)}
              onShowToast={showToast}
            />
          )}

          {currentTab === 'mo-hinh-3d' && (
            <Model3DView
              currentProduct={selectedProduct}
              onOpenQRScanner={() => setIsQRScannerOpen(true)}
              onOpenAR={() => setIsARViewOpen(true)}
              onGoToReportParts={() => setCurrentTab('linh-kien')}
              onShowToast={showToast}
            />
          )}

          {currentTab === 'linh-kien' && (
            <PartsView
              orders={orders}
              missingReports={missingReports}
              onSubmitMissingReport={handleSubmitMissingReport}
              onAddToCart={handleAddToCart}
              onShowToast={showToast}
            />
          )}

          {currentTab === 'don-hang' && (
            <OrdersView
              orders={orders}
              user={user || INITIAL_USER}
              onOpenQRScanner={() => setIsQRScannerOpen(true)}
              onOpenDriverTracking={(order) => setActiveTrackingOrder(order)}
              onOpenInvoice={(order) => setActiveInvoiceOrder(order)}
              onSubmitReview={handleSubmitReview}
              onShowToast={showToast}
            />
          )}

          {currentTab === 'admin' && (
            <AdminView
              orders={orders}
              missingReports={missingReports}
              vouchers={vouchers}
              onUpdateOrderStatus={(id, status) => {
                setOrders((prev) => prev.map((o) => (o.id === id ? { ...o, status } : o)));
              }}
              onUpdateReportStatus={(id, status) => {
                setMissingReports((prev) => prev.map((r) => (r.id === id ? { ...r, status } : r)));
              }}
              onToggleVoucher={(code) => {
                setVouchers((prev) =>
                  prev.map((v) => (v.code === code ? { ...v, isActive: !v.isActive } : v))
                );
              }}
              onCreateVoucher={(v) => {
                setVouchers((prev) => [v, ...prev]);
              }}
              onShowToast={showToast}
            />
          )}
        </main>

        {/* Bottom Mobile Navigation */}
        <BottomNav
          activeTab={currentTab}
          onSelectTab={handleSelectTab}
          isAdmin={user?.role === 'admin'}
        />

        {/* Mobile Home Bar (in Mobile Frame view) */}
        {isMobileFrame && (
          <div className="absolute bottom-1 left-1/2 -translate-x-1/2 w-32 h-1 bg-black/30 rounded-full pointer-events-none z-50" />
        )}
      </div>

      {/* Authentication Modal (Login / Register / Forgot Password / Google Login) */}
      <AuthModal
        isOpen={isAuthOpen}
        initialMode={authInitialMode}
        onClose={() => setIsAuthOpen(false)}
        onLoginSuccess={handleLoginSuccess}
        onShowToast={showToast}
      />

      {/* Product Detail Modal (Image, Specs, Variant, Add to Cart, Buy Now) */}
      <ProductDetailModal
        product={selectedDetailProduct}
        isOpen={isProductDetailOpen}
        onClose={() => setIsProductDetailOpen(false)}
        onAddToCart={handleAddToCart}
        onBuyNow={handleBuyNow}
        onOpen3DGuide={(prod) => {
          setSelectedProduct(prod);
          setCurrentTab('mo-hinh-3d');
        }}
        onOpenAR={() => setIsARViewOpen(true)}
        onShowToast={showToast}
      />

      {/* Cart Drawer */}
      <CartDrawer
        isOpen={isCartOpen}
        items={cartItems}
        vouchers={vouchers}
        user={user}
        onClose={() => setIsCartOpen(false)}
        onUpdateQty={handleUpdateCartQty}
        onRemoveItem={handleRemoveCartItem}
        onClearCart={handleClearCart}
        onProceedCheckout={handleProceedCheckout}
        onRequireLogin={() => {
          setIsAuthOpen(true);
        }}
        onShowToast={showToast}
      />

      {/* Checkout & VNPAY Sandbox Modal */}
      <CheckoutModal
        isOpen={isCheckoutOpen}
        amount={checkoutAmount}
        user={user}
        coinsUsed={checkoutCoinsUsed}
        voucherCode={checkoutVoucherCode}
        onClose={() => setIsCheckoutOpen(false)}
        onPaymentSuccess={handlePaymentSuccess}
      />

      {/* QR Scanner Modal */}
      <QRScannerModal
        isOpen={isQRScannerOpen}
        onClose={() => setIsQRScannerOpen(false)}
        onScanResult={handleQRScanResult}
      />

      {/* AR View Modal */}
      <ARViewModal
        isOpen={isARViewOpen}
        onClose={() => setIsARViewOpen(false)}
        onShowToast={showToast}
      />

      {/* Driver Tracking Modal (Simulated GPS Tracking) */}
      <DriverTrackingModal
        order={activeTrackingOrder}
        onClose={() => setActiveTrackingOrder(null)}
        onShowToast={showToast}
      />

      {/* VNPAY Invoice Modal */}
      <VnpayInvoiceModal
        order={activeInvoiceOrder}
        onClose={() => setActiveInvoiceOrder(null)}
        onShowToast={showToast}
      />

      {/* User Profile Modal */}
      <UserProfileModal
        isOpen={isProfileOpen}
        user={user}
        onClose={() => setIsProfileOpen(false)}
        onUpdateUser={(updated) => setUser(updated)}
        onSwitchRole={handleSwitchRole}
        onLogout={handleLogout}
        onOpenAuth={() => {
          setIsAuthOpen(true);
        }}
        onShowToast={showToast}
      />

      {/* Global Interactive Toast Notification */}
      {toastMessage && (
        <div className="fixed bottom-20 left-1/2 -translate-x-1/2 z-50 px-4 py-2.5 rounded-full bg-[#161b28]/95 backdrop-blur-md text-white text-xs font-semibold shadow-2xl flex items-center gap-2 border border-white/10 animate-fadeIn pointer-events-none whitespace-nowrap">
          <span className="material-symbols-outlined text-[17px] text-[#bceed3]">info</span>
          <span>{toastMessage}</span>
        </div>
      )}
    </div>
  );
}
