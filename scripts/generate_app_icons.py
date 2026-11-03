"""
Script tạo bộ icon cho ứng dụng Sofa So Good - Furni3D Mobile.
Vẽ vector-quality icon với Pillow (supersampling 1024x1024 sau đó resize với LANCZOS).
"""

import os
from PIL import Image, ImageDraw, ImageFont

def create_brand_icon(size=1024):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Background Rounded Rectangle
    # Luxury Espresso / Warm Wood gradient effect
    bg_radius = int(size * 0.22)
    
    # Base dark chocolate / warm wood rounded rect
    draw.rounded_rectangle(
        [(0, 0), (size, size)],
        radius=bg_radius,
        fill=(38, 22, 14, 255),
    )

    # Inner soft gradient overlay (simulated with concentric rounded rects)
    for i in range(1, 30):
        inset = i * 4
        alpha = int(120 * (1 - i / 30))
        draw.rounded_rectangle(
            [(inset, inset), (size - inset, size - inset)],
            radius=max(4, bg_radius - inset // 2),
            outline=(74, 42, 28, alpha),
            width=2
        )

    # Subtle elegant gold/warm border
    draw.rounded_rectangle(
        [(8, 8), (size - 8, size - 8)],
        radius=bg_radius - 4,
        outline=(200, 162, 122, 90),
        width=int(size * 0.015)
    )

    # 2. Modern Minimalist Sofa Silhouette in Warm Cream & Gold
    # Sofa coordinates relative to 1024
    scale = size / 1024.0

    # Colors
    c_cream = (248, 244, 238, 255)
    c_warm = (228, 212, 194, 255)
    c_wood = (195, 145, 100, 255)
    c_accent = (212, 138, 64, 255)
    c_shadow = (25, 14, 9, 120)

    # Sofa Legs (4 tapered wooden legs)
    leg_w = int(24 * scale)
    leg_h = int(90 * scale)
    y_leg_top = int(680 * scale)
    y_leg_bot = y_leg_top + leg_h

    # Front-left leg (angled outward left)
    draw.polygon([
        (int(260 * scale), y_leg_top),
        (int(284 * scale), y_leg_top),
        (int(250 * scale), y_leg_bot),
        (int(228 * scale), y_leg_bot),
    ], fill=c_wood)

    # Front-right leg (angled outward right)
    draw.polygon([
        (int(740 * scale), y_leg_top),
        (int(764 * scale), y_leg_top),
        (int(796 * scale), y_leg_bot),
        (int(774 * scale), y_leg_bot),
    ], fill=c_wood)

    # Back-left leg
    draw.polygon([
        (int(360 * scale), y_leg_top),
        (int(380 * scale), y_leg_top),
        (int(354 * scale), y_leg_bot - int(15 * scale)),
        (int(338 * scale), y_leg_bot - int(15 * scale)),
    ], fill=(150, 110, 75, 255))

    # Back-right leg
    draw.polygon([
        (int(644 * scale), y_leg_top),
        (int(664 * scale), y_leg_top),
        (int(686 * scale), y_leg_bot - int(15 * scale)),
        (int(670 * scale), y_leg_bot - int(15 * scale)),
    ], fill=(150, 110, 75, 255))

    # Sofa Main Base Shadow
    draw.rounded_rectangle(
        [(int(210 * scale), int(585 * scale)), (int(814 * scale), int(695 * scale))],
        radius=int(28 * scale),
        fill=c_shadow
    )

    # Sofa Main Seat Base (Chassis)
    draw.rounded_rectangle(
        [(int(215 * scale), int(580 * scale)), (int(809 * scale), int(690 * scale))],
        radius=int(26 * scale),
        fill=c_warm
    )

    # Sofa Backrest (Wide smooth pillow cushion)
    draw.rounded_rectangle(
        [(int(235 * scale), int(310 * scale)), (int(789 * scale), int(595 * scale))],
        radius=int(48 * scale),
        fill=c_cream
    )

    # Two Backrest Tufting / Division lines
    draw.line(
        [(int(420 * scale), int(350 * scale)), (int(420 * scale), int(550 * scale))],
        fill=(210, 190, 170, 200),
        width=int(6 * scale)
    )
    draw.line(
        [(int(604 * scale), int(350 * scale)), (int(604 * scale), int(550 * scale))],
        fill=(210, 190, 170, 200),
        width=int(6 * scale)
    )

    # Left Armrest (rounded pill)
    draw.rounded_rectangle(
        [(int(170 * scale), int(420 * scale)), (int(275 * scale), int(680 * scale))],
        radius=int(36 * scale),
        fill=c_cream
    )
    # Left Armrest Inner Highlight
    draw.rounded_rectangle(
        [(int(185 * scale), int(435 * scale)), (int(260 * scale), int(665 * scale))],
        radius=int(26 * scale),
        fill=c_warm
    )

    # Right Armrest (rounded pill)
    draw.rounded_rectangle(
        [(int(749 * scale), int(420 * scale)), (int(854 * scale), int(680 * scale))],
        radius=int(36 * scale),
        fill=c_cream
    )
    # Right Armrest Inner Highlight
    draw.rounded_rectangle(
        [(int(764 * scale), int(435 * scale)), (int(839 * scale), int(665 * scale))],
        radius=int(26 * scale),
        fill=c_warm
    )

    # 3. 3D Isometric Cube / Badge in upper right corner
    cube_x = int(740 * scale)
    cube_y = int(220 * scale)
    cube_size = int(80 * scale)

    # Top face
    draw.polygon([
        (cube_x, cube_y),
        (cube_x + int(cube_size * 0.86), cube_y - int(cube_size * 0.5)),
        (cube_x, cube_y - cube_size),
        (cube_x - int(cube_size * 0.86), cube_y - int(cube_size * 0.5)),
    ], fill=(255, 185, 100, 255))

    # Left face
    draw.polygon([
        (cube_x - int(cube_size * 0.86), cube_y - int(cube_size * 0.5)),
        (cube_x, cube_y),
        (cube_x, cube_y + cube_size),
        (cube_x - int(cube_size * 0.86), cube_y + int(cube_size * 0.5)),
    ], fill=(215, 130, 45, 255))

    # Right face
    draw.polygon([
        (cube_x, cube_y),
        (cube_x + int(cube_size * 0.86), cube_y - int(cube_size * 0.5)),
        (cube_x + int(cube_size * 0.86), cube_y + int(cube_size * 0.5)),
        (cube_x, cube_y + cube_size),
    ], fill=(175, 95, 25, 255))

    # 4. Subtle "3D" text badge on bottom center or under sofa
    # Pill for "FURNI 3D"
    badge_w = int(280 * scale)
    badge_h = int(60 * scale)
    bx1 = int((size - badge_w) / 2)
    by1 = int(830 * scale)
    bx2 = bx1 + badge_w
    by2 = by1 + badge_h

    draw.rounded_rectangle(
        [(bx1, by1), (bx2, by2)],
        radius=int(18 * scale),
        fill=(58, 34, 22, 255),
        outline=(200, 162, 122, 160),
        width=int(3 * scale)
    )

    return img


def export_all_icons():
    master = create_brand_icon(size=1024)

    # Android Mipmap Targets
    targets = {
        "android/app/src/main/res/mipmap-mdpi/ic_launcher.png": 48,
        "android/app/src/main/res/mipmap-hdpi/ic_launcher.png": 72,
        "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png": 96,
        "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png": 144,
        "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png": 192,
        "web/icons/Icon-192.png": 192,
        "web/icons/Icon-512.png": 512,
        "web/favicon.png": 64,
    }

    for path, sz in targets.items():
        os.makedirs(os.path.dirname(path), exist_ok=True)
        resized = master.resize((sz, sz), Image.Resampling.LANCZOS)
        resized.save(path, format="PNG", optimize=True)
        print(f"Generated {path} ({sz}x{sz})")

    # Also save a 512x512 master in assets or scripts for reference
    master_512 = master.resize((512, 512), Image.Resampling.LANCZOS)
    master_512.save("scripts/app_icon_512.png", format="PNG", optimize=True)
    print("Generated scripts/app_icon_512.png")


if __name__ == "__main__":
    export_all_icons()
