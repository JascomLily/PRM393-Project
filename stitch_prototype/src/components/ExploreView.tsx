import React, { useState } from 'react';
import { PRODUCTS, LIVING_SET_JAPANDI } from '../data/mockData';
import { Product } from '../types';

interface ExploreViewProps {
  onOpenQRScanner: () => void;
  onOpen3DGuide: (product?: Product) => void;
  onOpenProductDetail: (product: Product) => void;
  onGoToParts: () => void;
  onGoToOrders: () => void;
  onAddToCart: (item: { id: string; name: string; price: number; image: string; variant?: string }) => void;
  onOpenAR: () => void;
  onShowToast: (msg: string) => void;
}

export const ExploreView: React.FC<ExploreViewProps> = ({
  onOpenQRScanner,
  onOpen3DGuide,
  onOpenProductDetail,
  onGoToParts,
  onAddToCart,
  onOpenAR,
  onShowToast,
}) => {
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [favorites, setFavorites] = useState<Record<string, boolean>>({});
  const [selectedWoodIdx, setSelectedWoodIdx] = useState<number>(0);
  const [showTip, setShowTip] = useState<boolean>(true);
  const [activeRoomHotspot, setActiveRoomHotspot] = useState<string | null>(null);

  const categories = [
    { id: 'all', label: 'Tất cả', icon: 'tune' },
    { id: 'desk', label: 'Bàn làm việc' },
    { id: 'chair', label: 'Ghế thư giãn' },
    { id: 'shelf', label: 'Tủ sách' },
    { id: 'lamp', label: 'Đèn decor' },
    { id: 'parts', label: 'Linh kiện thay thế' },
  ];

  const toggleFavorite = (productId: string, e: React.MouseEvent) => {
    e.stopPropagation();
    setFavorites((prev) => {
      const next = !prev[productId];
      onShowToast(next ? 'Đã thêm vào bộ sưu tập yêu thích' : 'Đã bỏ yêu thích');
      return { ...prev, [productId]: next };
    });
  };

  const filteredProducts = PRODUCTS.filter((p) => {
    const matchesCategory = selectedCategory === 'all' || p.category === selectedCategory;
    const matchesQuery =
      searchQuery.trim() === '' ||
      p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.subtitle.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.modelCode.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesQuery;
  });

  return (
    <div className="flex flex-col w-full max-w-5xl mx-auto pb-10">
      {/* Search & Quick Filter Bar */}
      <section className="px-4 pt-3 pb-2 flex flex-col gap-3">
        <div className="relative flex items-center w-full">
          <div className="absolute left-3.5 flex items-center pointer-events-none text-[#414944]">
            <span className="material-symbols-outlined text-[20px]">search</span>
          </div>
          <input
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full h-12 pl-11 pr-11 bg-[#e3e7fa] text-[#161b28] placeholder:text-[#414944] rounded-xl text-sm outline-none transition-shadow duration-200 focus:shadow-[0_0_0_2px_#2d5a46]"
            placeholder="Tìm kiếm bàn, ghế, mã phụ kiện hoặc mã QR..."
            type="search"
          />
          <button
            onClick={onOpenQRScanner}
            aria-label="Tìm kiếm bằng mã QR"
            className="absolute right-2.5 w-8 h-8 rounded-lg flex items-center justify-center text-[#2d5a46] bg-[#dee2f4] hover:bg-[#c0c9c2]/50 transition-colors"
            type="button"
            title="Quét mã QR sản phẩm"
          >
            <span className="material-symbols-outlined text-[19px]">qr_code_scanner</span>
          </button>
        </div>

        {/* Scrollable Filter Chips */}
        <div className="flex items-center gap-2 overflow-x-auto no-scrollbar -mx-4 px-4 py-1">
          {categories.map((cat) => {
            const isSelected = selectedCategory === cat.id;
            return (
              <button
                key={cat.id}
                onClick={() => setSelectedCategory(cat.id)}
                className={`whitespace-nowrap px-3.5 py-2 rounded-full text-xs font-semibold flex items-center gap-1.5 transition-all active:scale-95 ${
                  isSelected
                    ? 'bg-[#2d5a46] text-white shadow-sm'
                    : 'bg-[#e9edff] text-[#414944] hover:text-[#161b28]'
                }`}
              >
                {cat.icon && (
                  <span className="material-symbols-outlined text-[15px]">{cat.icon}</span>
                )}
                <span>{cat.label}</span>
              </button>
            );
          })}
        </div>
      </section>

      {/* Hero Banner: 3D Assembly Unity Experience */}
      <section className="px-4 mt-2">
        <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-[#2d5a46] via-[#1f4032] to-[#152e23] p-5 text-white shadow-md">
          <div className="absolute -right-10 -bottom-10 w-44 h-44 rounded-full bg-[#fec38d]/20 blur-2xl pointer-events-none" />
          <div className="relative z-10 flex flex-col gap-3">
            <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-white/15 backdrop-blur-md self-start border border-white/10">
              <span className="w-2 h-2 rounded-full bg-[#fec38d] animate-pulse" />
              <span className="text-[11px] font-bold uppercase tracking-wider text-[#bceed3]">
                Interactive 3D Unity
              </span>
            </div>
            <div className="flex flex-col gap-1">
              <h2 className="text-xl font-bold leading-tight text-white">
                Nội thất 3D & Lắp ráp thông minh tại nhà
              </h2>
              <p className="text-xs text-[#a1d1b8] line-clamp-2">
                Quét mã QR trên vỏ thùng để xem hướng dẫn bóc tách từng ốc vít dạng 3D xoay 360 độ siêu trực quan.
              </p>
            </div>
            <div className="pt-2 flex flex-wrap items-center gap-3">
              <button
                onClick={onOpenQRScanner}
                className="flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-white text-[#2d5a46] text-xs font-bold shadow-sm transition-transform active:scale-95 hover:bg-[#faf8ff]"
              >
                <span className="material-symbols-outlined text-[19px]">qr_code_scanner</span>
                <span>Quét hộp sản phẩm</span>
              </button>
              <button
                onClick={() => onOpen3DGuide()}
                className="flex items-center justify-center gap-1.5 px-3.5 py-2.5 rounded-xl bg-white/10 hover:bg-white/20 backdrop-blur-sm text-white text-xs font-semibold transition-all border border-white/15 active:scale-95"
              >
                <span className="material-symbols-outlined text-[18px]">play_circle</span>
                <span>Xem thử 3D</span>
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Fast Action Utility Cards */}
      <section className="px-4 mt-5">
        <div className="grid grid-cols-3 gap-2.5">
          <button
            onClick={onOpenQRScanner}
            className="p-3 rounded-xl bg-[#f2f3ff] hover:bg-[#e9edff] flex flex-col items-start justify-between min-h-[108px] text-left transition-transform active:scale-95 shadow-sm border border-black/[0.03]"
          >
            <div className="w-9 h-9 rounded-lg bg-[#2d5a46]/10 flex items-center justify-center text-[#2d5a46]">
              <span className="material-symbols-outlined text-[22px]">center_focus_strong</span>
            </div>
            <div>
              <span className="text-xs text-[#161b28] font-bold block leading-tight">Quét mã QR</span>
              <span className="text-[11px] text-[#414944] block mt-0.5">Mở model 3D</span>
            </div>
          </button>

          <button
            onClick={onGoToParts}
            className="p-3 rounded-xl bg-[#f2f3ff] hover:bg-[#e9edff] flex flex-col items-start justify-between min-h-[108px] text-left transition-transform active:scale-95 shadow-sm border border-black/[0.03]"
          >
            <div className="w-9 h-9 rounded-lg bg-[#805528]/10 flex items-center justify-center text-[#805528]">
              <span className="material-symbols-outlined text-[22px]">construction</span>
            </div>
            <div>
              <span className="text-xs text-[#161b28] font-bold block leading-tight">Linh kiện rời</span>
              <span className="text-[11px] text-[#414944] block mt-0.5">Ốc vít, bản lề</span>
            </div>
          </button>

          <button
            onClick={() => onOpen3DGuide()}
            className="p-3 rounded-xl bg-[#f2f3ff] hover:bg-[#e9edff] flex flex-col items-start justify-between min-h-[108px] text-left transition-transform active:scale-95 shadow-sm border border-black/[0.03]"
          >
            <div className="w-9 h-9 rounded-lg bg-[#3b3b37]/10 flex items-center justify-center text-[#161b28]">
              <span className="material-symbols-outlined text-[22px]">smart_display</span>
            </div>
            <div>
              <span className="text-xs text-[#161b28] font-bold block leading-tight">Video lắp ráp</span>
              <span className="text-[11px] text-[#414944] block mt-0.5">Chuẩn từng bước</span>
            </div>
          </button>
        </div>
      </section>

      {/* Featured 3D Interactive Furniture Grid */}
      <section className="mt-7">
        <div className="px-4 flex items-center justify-between mb-3">
          <div className="flex flex-col">
            <div className="flex items-center gap-1.5">
              <span className="material-symbols-outlined text-[#805528] text-[20px]">view_in_ar</span>
              <h2 className="text-base font-bold text-[#161b28]">Mô hình 3D tương tác</h2>
            </div>
            <p className="text-xs text-[#414944]">Kèm bản vẽ lắp ráp hoạt hoạ chi tiết</p>
          </div>
          <button
            onClick={() => setSelectedCategory('all')}
            className="text-xs text-[#2d5a46] flex items-center gap-0.5 font-bold hover:underline"
          >
            Xem tất cả
            <span className="material-symbols-outlined text-[16px]">chevron_right</span>
          </button>
        </div>

        {/* 2-Column Product Grid */}
        <div className="px-4 grid grid-cols-2 sm:grid-cols-2 md:grid-cols-4 gap-3">
          {filteredProducts.map((product) => {
            const isFav = !!favorites[product.id];
            return (
              <article
                key={product.id}
                onClick={() => onOpenProductDetail(product)}
                className="bg-white rounded-2xl p-2.5 flex flex-col shadow-sm transition-all hover:shadow-md border border-black/[0.04] cursor-pointer group"
              >
                {/* Product Image Box */}
                <div className="relative w-full aspect-square rounded-xl overflow-hidden bg-[#f2f3ff]">
                  <img
                    src={product.image}
                    alt={product.name}
                    className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
                  />
                  {/* Badge */}
                  {product.badge && (
                    <span className="absolute top-2 left-2 px-2 py-0.5 rounded-full bg-white/90 backdrop-blur-md text-[10px] font-bold uppercase tracking-wider text-[#2d5a46] flex items-center gap-1 shadow-sm border border-black/5">
                      <span
                        className="material-symbols-outlined text-[12px]"
                        style={{ fontVariationSettings: "'FILL' 1" }}
                      >
                        {product.badgeType === 'time'
                          ? 'timer'
                          : product.badgeType === 'layers'
                          ? 'layers'
                          : product.badgeType === 'easy'
                          ? 'handyman'
                          : 'view_in_ar'}
                      </span>
                      {product.badge}
                    </span>
                  )}
                  {/* Favorite Button */}
                  <button
                    onClick={(e) => toggleFavorite(product.id, e)}
                    aria-label="Yêu thích"
                    className="absolute top-2 right-2 w-7 h-7 rounded-full bg-white/85 backdrop-blur-sm flex items-center justify-center text-[#414944] transition-transform active:scale-90 hover:bg-white"
                  >
                    <span
                      className={`material-symbols-outlined text-[16px] ${
                        isFav ? 'text-red-500' : ''
                      }`}
                      style={isFav ? { fontVariationSettings: "'FILL' 1" } : undefined}
                    >
                      favorite
                    </span>
                  </button>
                </div>

                {/* Details */}
                <div className="pt-2.5 flex flex-col flex-1 justify-between">
                  <div>
                    <div className="flex items-center gap-1 text-[#805528] mb-1">
                      <span
                        className="material-symbols-outlined text-[14px]"
                        style={{ fontVariationSettings: "'FILL' 1" }}
                      >
                        star
                      </span>
                      <span className="text-[11px] font-bold">{product.rating}</span>
                      <span className="text-[11px] text-[#717973]">({product.reviewCount})</span>
                    </div>
                    <h3 className="text-sm font-bold text-[#161b28] line-clamp-1">{product.name}</h3>
                    <p className="text-[11px] text-[#414944] line-clamp-1 mt-0.5">{product.subtitle}</p>
                  </div>

                  <div className="mt-3 pt-2 flex items-center justify-between border-t border-black/[0.04]">
                    <div className="flex flex-col">
                      <span className="text-[9px] text-[#717973] uppercase font-semibold">Giá chuẩn</span>
                      <span className="text-sm text-[#2d5a46] font-bold">
                        {product.price.toLocaleString('vi-VN')}₫
                      </span>
                    </div>
                    <div className="flex items-center gap-1">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          onAddToCart({
                            id: product.id,
                            name: product.name,
                            price: product.price,
                            image: product.image,
                          });
                          onShowToast(`Đã thêm ${product.name} vào giỏ hàng`);
                        }}
                        aria-label="Thêm vào giỏ"
                        className="w-8 h-8 rounded-lg bg-[#e9edff] text-[#2d5a46] flex items-center justify-center hover:bg-[#2d5a46] hover:text-white transition-colors"
                        title="Thêm giỏ hàng"
                      >
                        <span className="material-symbols-outlined text-[17px]">add_shopping_cart</span>
                      </button>
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          onOpen3DGuide(product);
                        }}
                        aria-label="Mở 3D"
                        className="w-8 h-8 rounded-lg bg-[#e9edff] text-[#2d5a46] flex items-center justify-center hover:bg-[#2d5a46] hover:text-white transition-colors"
                        title="Mở 3D xoay 360"
                      >
                        <span className="material-symbols-outlined text-[17px]">3d_rotation</span>
                      </button>
                    </div>
                  </div>
                </div>
              </article>
            );
          })}
        </div>
      </section>

      {/* Interactive Assembly Stage Preview Callout */}
      <section className="px-4 mt-7">
        <div className="p-4 rounded-2xl bg-[#f2f3ff] flex flex-col gap-3 border border-black/[0.03]">
          <div className="flex items-center justify-between">
            <span className="text-[11px] uppercase tracking-wider text-[#805528] font-bold">
              Quy trình tự lắp ráp
            </span>
            <span className="text-[11px] text-[#2d5a46] font-bold">Tiêu chuẩn Furni3D</span>
          </div>

          {/* Step Markers */}
          <div className="flex items-center justify-between relative px-2 pt-1">
            <div className="absolute left-6 right-6 top-4 h-0.5 bg-[#dee2f4] -z-0" />
            <button
              onClick={() => {
                onOpenQRScanner();
              }}
              className="flex flex-col items-center gap-1 z-10 group"
            >
              <div className="w-7 h-7 rounded-full bg-[#2d5a46] text-white flex items-center justify-center text-xs font-semibold shadow-sm transition-transform group-hover:scale-110">
                <span className="material-symbols-outlined text-[15px]">qr_code</span>
              </div>
              <span className="text-[10px] text-[#161b28] font-medium">1. Quét mã</span>
            </button>

            <button
              onClick={() => onOpen3DGuide()}
              className="flex flex-col items-center gap-1 z-10 group"
            >
              <div className="w-7 h-7 rounded-full bg-white text-[#2d5a46] border border-[#2d5a46] shadow-sm flex items-center justify-center text-xs font-bold transition-transform group-hover:scale-110">
                2
              </div>
              <span className="text-[10px] text-[#161b28] font-medium">2. Xoay 3D</span>
            </button>

            <button
              onClick={() => onOpen3DGuide()}
              className="flex flex-col items-center gap-1 z-10 group"
            >
              <div className="w-7 h-7 rounded-full bg-[#dee2f4] text-[#414944] flex items-center justify-center text-xs font-medium transition-transform group-hover:scale-110">
                3
              </div>
              <span className="text-[10px] text-[#414944] font-medium">3. Khớp mộng</span>
            </button>

            <button
              onClick={() => onOpen3DGuide()}
              className="flex flex-col items-center gap-1 z-10 group"
            >
              <div className="w-7 h-7 rounded-full bg-[#dee2f4] text-[#414944] flex items-center justify-center text-xs font-medium transition-transform group-hover:scale-110">
                4
              </div>
              <span className="text-[10px] text-[#414944] font-medium">4. Hoàn thiện</span>
            </button>
          </div>
        </div>
      </section>

      {/* Curated Collection: Living Room Japandi 2025 */}
      <section className="px-4 mt-7">
        <div className="flex items-center justify-between mb-3">
          <div>
            <h2 className="text-base font-bold text-[#161b28]">Bộ sưu tập phòng khách 2025</h2>
            <p className="text-xs text-[#414944]">Không gian tối giản thuần khiết phong cách Japandi</p>
          </div>
        </div>

        <div className="bg-white rounded-2xl overflow-hidden shadow-sm flex flex-col border border-black/[0.04]">
          {/* Big Room Render with Interactive Hotspots */}
          <div className="relative w-full h-64 sm:h-80 bg-[#e9edff] overflow-hidden">
            <img
              className="w-full h-full object-cover"
              src={LIVING_SET_JAPANDI.image}
              alt="Japandi living room"
            />
            {/* Interactive Hotspot Pins */}
            <button
              onClick={() =>
                setActiveRoomHotspot(
                  activeRoomHotspot === 'table' ? null : 'table'
                )
              }
              aria-label="Vị trí bàn trà"
              className="absolute top-1/2 left-1/3 w-7 h-7 rounded-full bg-[#805528] text-white shadow-md flex items-center justify-center transition-transform active:scale-90"
              title="Bàn trà thấp Noguchi"
            >
              <span className="w-2.5 h-2.5 rounded-full bg-white animate-ping" />
            </button>
            {activeRoomHotspot === 'table' && (
              <div className="absolute top-[42%] left-[36%] px-3 py-1.5 rounded-lg bg-[#2b303e] text-white text-xs whitespace-nowrap shadow-xl z-20 animate-fadeIn">
                Bàn trà thấp chân vát Noguchi
              </div>
            )}

            <button
              onClick={() =>
                setActiveRoomHotspot(
                  activeRoomHotspot === 'sofa' ? null : 'sofa'
                )
              }
              aria-label="Vị trí sofa"
              className="absolute top-1/3 right-1/4 w-7 h-7 rounded-full bg-[#2d5a46] text-white shadow-md flex items-center justify-center transition-transform active:scale-90"
              title="Sofa bọc linen"
            >
              <span className="material-symbols-outlined text-[16px]">add</span>
            </button>
            {activeRoomHotspot === 'sofa' && (
              <div className="absolute top-[26%] right-[28%] px-3 py-1.5 rounded-lg bg-[#2b303e] text-white text-xs whitespace-nowrap shadow-xl z-20 animate-fadeIn">
                Ghế sofa vải linen mộc Wabi-Sabi
              </div>
            )}

            <div className="absolute bottom-3 left-3 px-3 py-1.5 rounded-xl bg-white/90 backdrop-blur-md text-[#161b28] flex items-center gap-1.5 shadow-sm border border-black/5">
              <span className="material-symbols-outlined text-[#805528] text-[16px]">palette</span>
              <span className="text-xs font-semibold">Tông màu: Oak & Wabi-Sabi Sand</span>
            </div>
          </div>

          {/* Description & Action Bar */}
          <div className="p-4 flex flex-col gap-3">
            <div className="flex items-start justify-between gap-2">
              <div className="flex flex-col">
                <h3 className="text-base font-bold text-[#161b28]">{LIVING_SET_JAPANDI.name}</h3>
                <p className="text-xs text-[#414944] line-clamp-2 mt-0.5">
                  {LIVING_SET_JAPANDI.description}
                </p>
              </div>
              <div className="flex flex-col items-end flex-shrink-0">
                <span className="text-base text-[#2d5a46] font-bold">
                  {LIVING_SET_JAPANDI.price.toLocaleString('vi-VN')}₫
                </span>
                <span className="text-xs text-[#717973] line-through">
                  {LIVING_SET_JAPANDI.originalPrice.toLocaleString('vi-VN')}₫
                </span>
              </div>
            </div>

            {/* Material Swatches */}
            <div className="flex items-center justify-between pt-1">
              <div className="flex items-center gap-2">
                <span className="text-xs text-[#414944] font-medium">Chất liệu:</span>
                <div className="flex items-center gap-1.5">
                  {LIVING_SET_JAPANDI.woodSwatches.map((swatch, idx) => {
                    const isSelected = selectedWoodIdx === idx;
                    return (
                      <button
                        key={swatch.name}
                        onClick={() => {
                          setSelectedWoodIdx(idx);
                          onShowToast(`Đã chọn chất liệu: ${swatch.name}`);
                        }}
                        style={{ backgroundColor: swatch.color }}
                        className={`w-5 h-5 rounded-full shadow-inner transition-transform ${
                          isSelected
                            ? 'ring-2 ring-offset-2 ring-[#2d5a46] scale-110'
                            : 'hover:scale-105'
                        }`}
                        title={swatch.name}
                      />
                    );
                  })}
                </div>
                <span className="text-[11px] text-[#414944] font-medium ml-1">
                  ({LIVING_SET_JAPANDI.woodSwatches[selectedWoodIdx].name})
                </span>
              </div>
              <span className="text-xs text-[#805528] font-bold">
                Tiết kiệm {LIVING_SET_JAPANDI.savedAmount.toLocaleString('vi-VN')}₫
              </span>
            </div>

            {/* Dual CTA for Room */}
            <div className="pt-2 grid grid-cols-2 gap-2.5">
              <button
                onClick={onOpenAR}
                className="h-12 rounded-xl bg-[#e9edff] text-[#161b28] text-xs font-bold flex items-center justify-center gap-2 transition-transform active:scale-95 hover:bg-[#dee2f4]"
              >
                <span className="material-symbols-outlined text-[20px] text-[#2d5a46]">view_in_ar</span>
                <span>Ướm thử AR</span>
              </button>
              <button
                onClick={() => {
                  onAddToCart({
                    id: LIVING_SET_JAPANDI.id,
                    name: LIVING_SET_JAPANDI.name,
                    price: LIVING_SET_JAPANDI.price,
                    image: LIVING_SET_JAPANDI.image,
                    variant: LIVING_SET_JAPANDI.woodSwatches[selectedWoodIdx].name,
                  });
                  onShowToast('Đã thêm trọn bộ Serene Wabi vào giỏ hàng');
                }}
                className="h-12 rounded-xl bg-[#2d5a46] text-white text-xs font-bold flex items-center justify-center gap-2 shadow-sm transition-transform active:scale-95 hover:bg-[#134230]"
              >
                <span className="material-symbols-outlined text-[19px]">shopping_bag</span>
                <span>Thêm giỏ hàng</span>
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Assembly Tip Banner */}
      {showTip && (
        <section className="px-4 mt-6">
          <div className="p-3.5 rounded-2xl bg-[#ffdcbf]/40 border border-[#805528]/15 flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-[#fec38d] flex items-center justify-center text-[#794f23] flex-shrink-0">
              <span className="material-symbols-outlined text-[22px]">lightbulb</span>
            </div>
            <div className="flex flex-col min-w-0 flex-1">
              <h4 className="text-xs font-bold text-[#161b28]">Mẹo nhỏ khi tự ráp đồ</h4>
              <p className="text-[11px] text-[#414944] line-clamp-1">
                Trải thảm vải lót sàn đi kèm để tránh trầy xước cạnh gỗ nhé!
              </p>
            </div>
            <button
              onClick={() => setShowTip(false)}
              aria-label="Đóng mẹo"
              className="w-7 h-7 rounded-full flex items-center justify-center text-[#414944] hover:bg-black/5"
            >
              <span className="material-symbols-outlined text-[16px]">close</span>
            </button>
          </div>
        </section>
      )}
    </div>
  );
};
