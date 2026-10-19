import React, { useState } from 'react';
import { Product } from '../types';

interface ProductDetailModalProps {
  product: Product | null;
  isOpen: boolean;
  onClose: () => void;
  onAddToCart: (item: { id: string; name: string; price: number; image: string; variant?: string; quantity?: number }) => void;
  onBuyNow: (item: { id: string; name: string; price: number; image: string; variant?: string; quantity: number }) => void;
  onOpen3DGuide: (product: Product) => void;
  onOpenAR: () => void;
  onShowToast: (msg: string) => void;
}

export const ProductDetailModal: React.FC<ProductDetailModalProps> = ({
  product,
  isOpen,
  onClose,
  onAddToCart,
  onBuyNow,
  onOpen3DGuide,
  onOpenAR,
  onShowToast,
}) => {
  const [quantity, setQuantity] = useState(1);
  const [selectedVariant, setSelectedVariant] = useState('Gỗ sồi Bắc Âu tự nhiên');
  const [isFavorite, setIsFavorite] = useState(false);

  if (!isOpen || !product) return null;

  const variants = [
    { label: 'Gỗ sồi Bắc Âu tự nhiên', color: '#c8a882' },
    { label: 'Gỗ óc chó trầm sang trọng', color: '#5c4033' },
    { label: 'Gỗ tần bì sáng hiện đại', color: '#dfc9a5' },
  ];

  const handleAddToCart = () => {
    onAddToCart({
      id: product.id,
      name: product.name,
      price: product.price,
      image: product.image,
      variant: selectedVariant,
      quantity,
    });
    onShowToast(`Đã thêm ${quantity}x ${product.name} vào giỏ hàng`);
  };

  const handleBuyNow = () => {
    onBuyNow({
      id: product.id,
      name: product.name,
      price: product.price,
      image: product.image,
      variant: selectedVariant,
      quantity,
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-end sm:items-center justify-center p-0 sm:p-4 animate-fadeIn">
      <div className="bg-white rounded-t-3xl sm:rounded-3xl w-full max-w-lg overflow-hidden shadow-2xl flex flex-col max-h-[92vh] animate-slideUp sm:animate-scaleUp">
        {/* Product Image & Top Overlays */}
        <div className="relative w-full h-64 sm:h-72 bg-[#f2f3ff] overflow-hidden flex-shrink-0">
          <img
            src={product.image}
            alt={product.name}
            className="w-full h-full object-cover"
          />

          {/* Action buttons on top of image */}
          <div className="absolute top-4 left-4 right-4 flex items-center justify-between">
            <span className="px-3 py-1 rounded-full bg-white/90 backdrop-blur-md text-[10px] font-bold text-[#2d5a46] uppercase tracking-wider shadow-sm flex items-center gap-1.5">
              <span className="w-1.5 h-1.5 rounded-full bg-[#2d5a46] animate-pulse" />
              {product.modelCode}
            </span>
            <div className="flex items-center gap-2">
              <button
                onClick={() => {
                  setIsFavorite(!isFavorite);
                  onShowToast(!isFavorite ? 'Đã thêm vào mục yêu thích' : 'Đã bỏ yêu thích');
                }}
                className="w-9 h-9 rounded-full bg-white/90 backdrop-blur-md flex items-center justify-center shadow-md text-[#414944] hover:text-red-500 transition-colors"
              >
                <span
                  className="material-symbols-outlined text-[18px]"
                  style={isFavorite ? { color: '#ef4444', fontVariationSettings: "'FILL' 1" } : undefined}
                >
                  favorite
                </span>
              </button>
              <button
                onClick={onClose}
                className="w-9 h-9 rounded-full bg-black/40 hover:bg-black/60 backdrop-blur-md flex items-center justify-center text-white shadow-md transition-colors"
              >
                <span className="material-symbols-outlined text-[18px]">close</span>
              </button>
            </div>
          </div>

          {/* Floating 3D / AR Buttons over image */}
          <div className="absolute bottom-3 left-4 right-4 flex items-center gap-2">
            <button
              onClick={() => {
                onClose();
                onOpen3DGuide(product);
              }}
              className="flex-1 py-2 px-3 rounded-xl bg-[#2d5a46]/90 hover:bg-[#134230] backdrop-blur-md text-white text-xs font-bold flex items-center justify-center gap-1.5 shadow-md active:scale-95 transition-all"
            >
              <span className="material-symbols-outlined text-[17px]">3d_rotation</span>
              <span>Xem hướng dẫn 3D Unity</span>
            </button>
            <button
              onClick={() => {
                onClose();
                onOpenAR();
              }}
              className="py-2 px-3 rounded-xl bg-white/90 hover:bg-white backdrop-blur-md text-[#161b28] text-xs font-bold flex items-center justify-center gap-1.5 shadow-md active:scale-95 transition-all"
            >
              <span className="material-symbols-outlined text-[17px]">view_in_ar</span>
              <span>Đặt phòng AR</span>
            </button>
          </div>
        </div>

        {/* Scrollable Detail Body */}
        <div className="p-5 overflow-y-auto flex-1 space-y-4 text-xs text-[#161b28]">
          {/* Title & Price */}
          <div>
            <div className="flex items-center gap-2 text-[#805528] mb-1">
              <div className="flex items-center">
                <span className="material-symbols-outlined text-[15px] text-amber-500" style={{ fontVariationSettings: "'FILL' 1" }}>
                  star
                </span>
                <span className="text-xs font-bold ml-1 text-[#161b28]">{product.rating}</span>
              </div>
              <span className="text-[11px] text-[#717973]">({product.reviewCount} đánh giá khách hàng)</span>
              <span className="text-[#dee2f4]">•</span>
              <span className="text-[11px] text-[#2d5a46] font-semibold flex items-center gap-1">
                <span className="material-symbols-outlined text-[14px]">timer</span>
                {product.assemblyTimeMinutes} phút tự lắp ráp
              </span>
            </div>

            <h2 className="text-xl font-bold text-[#161b28] leading-tight">{product.name}</h2>
            <p className="text-xs text-[#414944] mt-0.5">{product.subtitle}</p>

            <div className="mt-3 flex items-baseline gap-2.5">
              <span className="text-2xl font-black text-[#2d5a46]">
                {product.price.toLocaleString('vi-VN')}₫
              </span>
              {product.originalPrice && (
                <>
                  <span className="text-xs text-[#717973] line-through font-medium">
                    {product.originalPrice.toLocaleString('vi-VN')}₫
                  </span>
                  <span className="px-2 py-0.5 rounded-md bg-red-100 text-red-600 text-[10px] font-bold">
                    -{Math.round(((product.originalPrice - product.price) / product.originalPrice) * 100)}%
                  </span>
                </>
              )}
            </div>
          </div>

          {/* Color & Material Variant Selector */}
          <div>
            <label className="text-[11px] font-bold text-[#414944] uppercase tracking-wider block mb-2">
              Phiên bản chất liệu hoàn thiện:
            </label>
            <div className="grid grid-cols-1 gap-2">
              {variants.map((v) => (
                <button
                  key={v.label}
                  type="button"
                  onClick={() => setSelectedVariant(v.label)}
                  className={`p-2.5 rounded-xl border flex items-center justify-between transition-all ${
                    selectedVariant === v.label
                      ? 'border-[#2d5a46] bg-[#bceed3]/20 shadow-xs'
                      : 'border-black/10 hover:border-black/20 bg-white'
                  }`}
                >
                  <div className="flex items-center gap-2.5">
                    <span
                      className="w-4 h-4 rounded-full border border-black/15 shadow-xs"
                      style={{ backgroundColor: v.color }}
                    />
                    <span className="text-xs font-semibold text-[#161b28]">{v.label}</span>
                  </div>
                  {selectedVariant === v.label && (
                    <span className="material-symbols-outlined text-[16px] text-[#2d5a46]">
                      check_circle
                    </span>
                  )}
                </button>
              ))}
            </div>
          </div>

          {/* Description & Features */}
          <div className="space-y-2">
            <h4 className="text-[11px] font-bold text-[#414944] uppercase tracking-wider">
              Mô tả & Đặc điểm thiết kế
            </h4>
            <p className="text-xs text-[#414944] leading-relaxed">
              {product.description}
            </p>
            <div className="grid grid-cols-2 gap-2 pt-1 text-[11px]">
              <div className="p-2.5 rounded-xl bg-[#f2f3ff] flex items-center gap-2">
                <span className="material-symbols-outlined text-[18px] text-[#2d5a46]">layers</span>
                <div>
                  <span className="text-[10px] text-[#717973] block">Chất liệu:</span>
                  <strong className="text-[#161b28]">{product.material.split('&')[0]}</strong>
                </div>
              </div>
              <div className="p-2.5 rounded-xl bg-[#f2f3ff] flex items-center gap-2">
                <span className="material-symbols-outlined text-[18px] text-[#2d5a46]">qr_code_2</span>
                <div>
                  <span className="text-[10px] text-[#717973] block">Mã QR hộp:</span>
                  <strong className="text-[#161b28]">{product.modelCode}</strong>
                </div>
              </div>
            </div>
          </div>

          {/* Quantity Selector */}
          <div className="flex items-center justify-between pt-2 border-t border-black/5">
            <span className="text-xs font-bold text-[#161b28]">Số lượng đặt mua:</span>
            <div className="flex items-center bg-[#f2f3ff] rounded-xl p-1 border border-black/5">
              <button
                type="button"
                onClick={() => setQuantity((q) => Math.max(1, q - 1))}
                className="w-8 h-8 rounded-lg bg-white flex items-center justify-center text-[#161b28] shadow-xs active:scale-95"
              >
                <span className="material-symbols-outlined text-[16px]">remove</span>
              </button>
              <span className="w-10 text-center text-sm font-bold text-[#161b28]">{quantity}</span>
              <button
                type="button"
                onClick={() => setQuantity((q) => q + 1)}
                className="w-8 h-8 rounded-lg bg-white flex items-center justify-center text-[#161b28] shadow-xs active:scale-95"
              >
                <span className="material-symbols-outlined text-[16px]">add</span>
              </button>
            </div>
          </div>
        </div>

        {/* Action Buttons in Bottom Footer */}
        <div className="p-4 bg-white border-t border-black/5 flex items-center gap-2.5">
          <button
            type="button"
            onClick={handleAddToCart}
            className="flex-1 h-12 rounded-2xl bg-[#e9edff] hover:bg-[#dee2f4] text-[#2d5a46] text-xs font-bold flex items-center justify-center gap-2 shadow-xs transition-all active:scale-[0.99]"
          >
            <span className="material-symbols-outlined text-[18px]">add_shopping_cart</span>
            <span>Thêm giỏ hàng</span>
          </button>
          <button
            type="button"
            onClick={handleBuyNow}
            className="flex-1 h-12 rounded-2xl bg-[#2d5a46] hover:bg-[#134230] text-white text-xs font-bold flex items-center justify-center gap-2 shadow-md transition-all active:scale-[0.99]"
          >
            <span className="material-symbols-outlined text-[18px]">shopping_bag</span>
            <span>Mua ngay ({((product.price * quantity)).toLocaleString('vi-VN')}₫)</span>
          </button>
        </div>
      </div>
    </div>
  );
};
