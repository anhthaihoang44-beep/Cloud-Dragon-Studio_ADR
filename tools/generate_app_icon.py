from PIL import Image, ImageDraw, ImageFilter
import math
import os


def create_app_icon(size=1024, full_bleed=False):
    # Create pastel sky background gradient
    grad = Image.new("RGBA", (size, size))
    g_draw = ImageDraw.Draw(grad)
    for y in range(size):
        ratio = y / size
        # Pastel Candy sky gradient: Mint cyan (#96E6D2) to lavender/rose (#E8D4F2)
        r = int(150 * (1 - ratio) + 232 * ratio)
        g = int(230 * (1 - ratio) + 212 * ratio)
        b = int(210 * (1 - ratio) + 242 * ratio)
        g_draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

    if full_bleed:
        img = grad.copy()
    else:
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        pad = int(size * 0.04)
        radius = int(size * 0.24)

        # Shadow
        shadow_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        s_draw = ImageDraw.Draw(shadow_img)
        s_draw.rounded_rectangle(
            [pad + 6, pad + 16, size - pad + 6, size - pad + 24],
            radius=radius,
            fill=(60, 80, 110, 80),
        )
        shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(radius=int(size * 0.035)))
        img = Image.alpha_composite(shadow_img, img)

        # Rounded squircle mask
        mask = Image.new("L", (size, size), 0)
        m_draw = ImageDraw.Draw(mask)
        m_draw.rounded_rectangle([pad, pad, size - pad, size - pad], radius=radius, fill=255)
        img.paste(grad, (0, 0), mask)

        draw = ImageDraw.Draw(img)
        draw.rounded_rectangle(
            [pad, pad, size - pad, size - pad],
            radius=radius,
            outline=(255, 255, 255, 240),
            width=int(size * 0.02),
        )
        draw.rounded_rectangle(
            [pad + 8, pad + 8, size - pad - 8, size - pad - 8],
            radius=radius - 6,
            outline=(255, 235, 170, 180),
            width=int(size * 0.01),
        )

    cx, cy = size / 2, size / 2
    draw = ImageDraw.Draw(img)

    # Floating background clouds at bottom
    def draw_cloud(bx, by, scale):
        w = int(260 * scale)
        h = int(120 * scale)
        c_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        cd = ImageDraw.Draw(c_img)
        cd.ellipse([bx - w // 2, by - h // 2, bx + w // 2, by + h // 2], fill=(255, 255, 255, 210))
        cd.ellipse([bx - w // 3, by - h // 1.6, bx + w // 4, by + h // 3], fill=(255, 255, 255, 230))
        return c_img

    img = Image.alpha_composite(img, draw_cloud(int(size * 0.24), int(size * 0.88), 1.1))
    img = Image.alpha_composite(img, draw_cloud(int(size * 0.76), int(size * 0.90), 1.2))
    img = Image.alpha_composite(img, draw_cloud(int(size * 0.50), int(size * 0.93), 1.4))
    draw = ImageDraw.Draw(img)

    # 2. DRAGON CHARACTER
    d_center_x = cx
    d_center_y = cy + int(size * 0.07)

    # Wings (behind body)
    wing_color = (195, 170, 235, 255)  # Lavender purple
    wing_border = (150, 120, 200, 255)
    w_border_w = int(size * 0.012)
    draw.ellipse(
        [
            d_center_x - int(size * 0.43),
            d_center_y - int(size * 0.22),
            d_center_x - int(size * 0.16),
            d_center_y + int(size * 0.05),
        ],
        fill=wing_color,
        outline=wing_border,
        width=w_border_w,
    )
    draw.ellipse(
        [
            d_center_x + int(size * 0.16),
            d_center_y - int(size * 0.22),
            d_center_x + int(size * 0.43),
            d_center_y + int(size * 0.05),
        ],
        fill=wing_color,
        outline=wing_border,
        width=w_border_w,
    )

    # Horns (Peach / Golden)
    horn_color = (255, 195, 150, 255)
    horn_border = (230, 150, 100, 255)
    draw.polygon(
        [
            (d_center_x - int(size * 0.14), d_center_y - int(size * 0.20)),
            (d_center_x - int(size * 0.24), d_center_y - int(size * 0.37)),
            (d_center_x - int(size * 0.06), d_center_y - int(size * 0.24)),
        ],
        fill=horn_color,
        outline=horn_border,
    )
    draw.polygon(
        [
            (d_center_x + int(size * 0.14), d_center_y - int(size * 0.20)),
            (d_center_x + int(size * 0.24), d_center_y - int(size * 0.37)),
            (d_center_x + int(size * 0.06), d_center_y - int(size * 0.24)),
        ],
        fill=horn_color,
        outline=horn_border,
    )

    # Golden Crown on top of head
    crown_y_base = d_center_y - int(size * 0.29)
    crown_pts = [
        (d_center_x - int(size * 0.11), crown_y_base),
        (d_center_x - int(size * 0.13), crown_y_base - int(size * 0.10)),
        (d_center_x - int(size * 0.05), crown_y_base - int(size * 0.05)),
        (d_center_x, crown_y_base - int(size * 0.13)),
        (d_center_x + int(size * 0.05), crown_y_base - int(size * 0.05)),
        (d_center_x + int(size * 0.13), crown_y_base - int(size * 0.10)),
        (d_center_x + int(size * 0.11), crown_y_base),
    ]
    draw.polygon(crown_pts, fill=(255, 222, 89, 255), outline=(230, 170, 40, 255), width=int(size * 0.008))
    # Tiny pink jewel on center of crown
    gem_r = int(size * 0.020)
    gem_y = crown_y_base - int(size * 0.045)
    draw.ellipse([d_center_x - gem_r, gem_y - gem_r, d_center_x + gem_r, gem_y + gem_r], fill=(255, 110, 150, 255))

    # Dragon Head & Body (Mint Green)
    body_color = (115, 218, 185, 255)
    body_border = (65, 158, 130, 255)
    body_w = int(size * 0.014)

    bw = int(size * 0.29)
    bh = int(size * 0.32)
    draw.rounded_rectangle(
        [d_center_x - bw, d_center_y - bh, d_center_x + bw, d_center_y + bh],
        radius=int(size * 0.21),
        fill=body_color,
        outline=body_border,
        width=body_w,
    )

    # Dragon Belly (Butter Yellow)
    belly_color = (255, 243, 160, 255)
    belly_border = (230, 205, 100, 255)
    belly_w = int(size * 0.19)
    belly_h = int(size * 0.17)
    belly_y = d_center_y + int(size * 0.11)
    draw.ellipse(
        [d_center_x - belly_w, belly_y - belly_h, d_center_x + belly_w, belly_y + belly_h],
        fill=belly_color,
        outline=belly_border,
        width=int(size * 0.008),
    )
    draw.arc(
        [
            d_center_x - int(belly_w * 0.7),
            belly_y - int(belly_h * 0.4),
            d_center_x + int(belly_w * 0.7),
            belly_y + int(belly_h * 0.2),
        ],
        start=20,
        end=160,
        fill=belly_border,
        width=int(size * 0.007),
    )

    # Rosy Cheeks
    cheek_color = (255, 150, 165, 230)
    ch_w = int(size * 0.055)
    ch_h = int(size * 0.032)
    ch_y = d_center_y - int(size * 0.02)
    draw.ellipse(
        [d_center_x - int(size * 0.20) - ch_w, ch_y - ch_h, d_center_x - int(size * 0.20) + ch_w, ch_y + ch_h],
        fill=cheek_color,
    )
    draw.ellipse(
        [d_center_x + int(size * 0.20) - ch_w, ch_y - ch_h, d_center_x + int(size * 0.20) + ch_w, ch_y + ch_h],
        fill=cheek_color,
    )

    # Big Anime Sparkle Eyes
    eye_r = int(size * 0.052)
    eye_y = d_center_y - int(size * 0.08)
    eye_lx = d_center_x - int(size * 0.11)
    eye_rx = d_center_x + int(size * 0.11)

    for ex in [eye_lx, eye_rx]:
        draw.ellipse([ex - eye_r, eye_y - eye_r, ex + eye_r, eye_y + eye_r], fill=(45, 52, 68, 255))
        draw.ellipse(
            [
                ex - eye_r + int(size * 0.015),
                eye_y - eye_r + int(size * 0.012),
                ex + int(size * 0.012),
                eye_y + int(size * 0.012),
            ],
            fill=(255, 255, 255, 255),
        )
        draw.ellipse(
            [ex + int(size * 0.01), eye_y + int(size * 0.015), ex + int(size * 0.028), eye_y + int(size * 0.033)],
            fill=(255, 255, 255, 220),
        )

    # Cute Smiling Mouth
    m_y = d_center_y - int(size * 0.01)
    m_color = (50, 60, 75, 255)
    m_w = int(size * 0.009)
    draw.arc([d_center_x - int(size * 0.055), m_y - int(size * 0.02), d_center_x, m_y + int(size * 0.03)], start=10, end=170, fill=m_color, width=m_w)
    draw.arc([d_center_x, m_y - int(size * 0.02), d_center_x + int(size * 0.055), m_y + int(size * 0.03)], start=10, end=170, fill=m_color, width=m_w)

    # Stars
    def draw_star(sx, sy, rad, color):
        points = []
        for i in range(10):
            r = rad if i % 2 == 0 else rad * 0.42
            angle = i * math.pi / 5 - math.pi / 2
            points.append((sx + r * math.cos(angle), sy + r * math.sin(angle)))
        draw.polygon(points, fill=color, outline=(255, 255, 255, 220))

    draw_star(int(size * 0.16), int(size * 0.19), int(size * 0.052), (255, 225, 80, 255))
    draw_star(int(size * 0.84), int(size * 0.21), int(size * 0.044), (255, 215, 70, 255))
    draw_star(int(size * 0.86), int(size * 0.52), int(size * 0.034), (255, 235, 120, 255))
    draw_star(int(size * 0.14), int(size * 0.53), int(size * 0.032), (255, 235, 120, 255))

    return img


def export_all():
    print("Generating Android & Showcase squircle icon...")
    android_master = create_app_icon(1024, full_bleed=False)

    # Save master icon in brain artifacts and screenshots
    master_512 = android_master.resize((512, 512), Image.Resampling.LANCZOS)
    brain_path = r"C:\Users\HP\.gemini\antigravity\brain\90700c88-e65c-4d11-bc39-bc037a56a29f\app_icon_512.png"
    master_512.save(brain_path)
    screenshots_icon = r"c:\Users\HP\Desktop\Rainbow Unicorn Candy Salon\screenshots\app_icon.png"
    master_512.save(screenshots_icon)

    # Android mipmap targets:
    res_base = r"c:\Users\HP\Desktop\Rainbow Unicorn Candy Salon\android\app\src\main\res"
    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for folder, px in android_sizes.items():
        target_dir = os.path.join(res_base, folder)
        os.makedirs(target_dir, exist_ok=True)
        resized = android_master.resize((px, px), Image.Resampling.LANCZOS)
        resized.save(os.path.join(target_dir, "ic_launcher.png"))
        resized.save(os.path.join(target_dir, "ic_launcher_round.png"))

    print("Generating iOS full-bleed opaque AppIcon set...")
    # iOS requires NO transparency (RGB mode)
    ios_master = create_app_icon(1024, full_bleed=True).convert("RGB")

    # Save standalone 1024x1024 iOS icon directly to Desktop for Sideloadly!
    desktop_icon = r"C:\Users\HP\Desktop\CloudDragon_Icon.png"
    ios_master.save(desktop_icon, "PNG")
    print(f"Saved Desktop icon: {desktop_icon}")

    ios_appicon_dir = r"c:\Users\HP\Desktop\Rainbow Unicorn Candy Salon\ios\Runner\Assets.xcassets\AppIcon.appiconset"
    ios_icons = {
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-1024x1024@1x.png": 1024,
    }
    for filename, px in ios_icons.items():
        out_path = os.path.join(ios_appicon_dir, filename)
        resized = ios_master.resize((px, px), Image.Resampling.LANCZOS)
        resized.save(out_path, "PNG")
        print(f"Exported iOS icon {filename} ({px}x{px})")

    # Also update macOS AppIcon for consistency
    macos_appicon_dir = r"c:\Users\HP\Desktop\Rainbow Unicorn Candy Salon\macos\Runner\Assets.xcassets\AppIcon.appiconset"
    macos_icons = {
        "app_icon_16.png": 16,
        "app_icon_32.png": 32,
        "app_icon_64.png": 64,
        "app_icon_128.png": 128,
        "app_icon_256.png": 256,
        "app_icon_512.png": 512,
        "app_icon_1024.png": 1024,
    }
    if os.path.isdir(macos_appicon_dir):
        for filename, px in macos_icons.items():
            out_path = os.path.join(macos_appicon_dir, filename)
            resized = android_master.resize((px, px), Image.Resampling.LANCZOS)
            resized.save(out_path, "PNG")


if __name__ == "__main__":
    export_all()
