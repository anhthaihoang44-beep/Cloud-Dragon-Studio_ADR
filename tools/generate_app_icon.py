from PIL import Image, ImageDraw, ImageFilter
import math
import os

def create_app_icon(size=1024):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    cx, cy = size / 2, size / 2

    # 1. Background Rounded Squircle with Shadow
    pad = int(size * 0.04)
    radius = int(size * 0.24)
    
    # Shadow
    shadow_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(shadow_img)
    s_draw.rounded_rectangle([pad + 6, pad + 16, size - pad + 6, size - pad + 24], radius=radius, fill=(60, 80, 110, 80))
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(radius=int(size * 0.035)))
    img = Image.alpha_composite(shadow_img, img)
    draw = ImageDraw.Draw(img)

    # Gradient Background on Mask
    mask = Image.new("L", (size, size), 0)
    m_draw = ImageDraw.Draw(mask)
    m_draw.rounded_rectangle([pad, pad, size - pad, size - pad], radius=radius, fill=255)

    grad = Image.new("RGBA", (size, size))
    g_draw = ImageDraw.Draw(grad)
    for y in range(size):
        ratio = y / size
        # Pastel Candy sky gradient: Mint cyan (#96E6D2) to lavender/rose (#E8D4F2)
        r = int(150 * (1 - ratio) + 232 * ratio)
        g = int(230 * (1 - ratio) + 212 * ratio)
        b = int(210 * (1 - ratio) + 242 * ratio)
        g_draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

    img.paste(grad, (0, 0), mask)
    draw = ImageDraw.Draw(img)

    # Golden / White glowing inner border
    draw.rounded_rectangle([pad, pad, size - pad, size - pad], radius=radius, outline=(255, 255, 255, 240), width=int(size * 0.02))
    draw.rounded_rectangle([pad + 8, pad + 8, size - pad - 8, size - pad - 8], radius=radius - 6, outline=(255, 235, 170, 180), width=int(size * 0.01))

    # Floating background clouds at bottom
    def draw_cloud(bx, by, scale):
        w = int(260 * scale)
        h = int(120 * scale)
        c_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        cd = ImageDraw.Draw(c_img)
        cd.ellipse([bx - w//2, by - h//2, bx + w//2, by + h//2], fill=(255, 255, 255, 190))
        cd.ellipse([bx - w//3, by - h//1.6, bx + w//4, by + h//3], fill=(255, 255, 255, 210))
        return c_img

    img = Image.alpha_composite(img, draw_cloud(int(size * 0.25), int(size * 0.88), 1.1))
    img = Image.alpha_composite(img, draw_cloud(int(size * 0.75), int(size * 0.90), 1.2))
    img = Image.alpha_composite(img, draw_cloud(int(size * 0.50), int(size * 0.94), 1.4))
    draw = ImageDraw.Draw(img)

    # 2. DRAGON CHARACTER
    d_center_x = cx
    d_center_y = cy + int(size * 0.05)

    # Wings (behind body)
    wing_color = (195, 170, 235, 255) # Lavender purple
    wing_border = (150, 120, 200, 255)
    w_border_w = int(size * 0.012)
    # Left wing
    draw.ellipse([d_center_x - int(size * 0.44), d_center_y - int(size * 0.24),
                  d_center_x - int(size * 0.16), d_center_y + int(size * 0.04)],
                 fill=wing_color, outline=wing_border, width=w_border_w)
    # Right wing
    draw.ellipse([d_center_x + int(size * 0.16), d_center_y - int(size * 0.24),
                  d_center_x + int(size * 0.44), d_center_y + int(size * 0.04)],
                 fill=wing_color, outline=wing_border, width=w_border_w)

    # Horns (Peach / Golden)
    horn_color = (255, 195, 150, 255)
    horn_border = (230, 150, 100, 255)
    # Left horn
    draw.polygon([(d_center_x - int(size * 0.14), d_center_y - int(size * 0.20)),
                  (d_center_x - int(size * 0.24), d_center_y - int(size * 0.38)),
                  (d_center_x - int(size * 0.06), d_center_y - int(size * 0.24))],
                 fill=horn_color, outline=horn_border)
    # Right horn
    draw.polygon([(d_center_x + int(size * 0.14), d_center_y - int(size * 0.20)),
                  (d_center_x + int(size * 0.24), d_center_y - int(size * 0.38)),
                  (d_center_x + int(size * 0.06), d_center_y - int(size * 0.24))],
                 fill=horn_color, outline=horn_border)

    # Dragon Head & Body (Mint Green)
    body_color = (115, 218, 185, 255) # Pastel mint
    body_border = (65, 158, 130, 255)
    body_w = int(size * 0.014)

    bw = int(size * 0.31)
    bh = int(size * 0.34)
    draw.rounded_rectangle([d_center_x - bw, d_center_y - bh, d_center_x + bw, d_center_y + bh],
                           radius=int(size * 0.22), fill=body_color, outline=body_border, width=body_w)

    # Dragon Belly (Butter Yellow)
    belly_color = (255, 243, 160, 255)
    belly_border = (230, 205, 100, 255)
    belly_w = int(size * 0.20)
    belly_h = int(size * 0.18)
    belly_y = d_center_y + int(size * 0.12)
    draw.ellipse([d_center_x - belly_w, belly_y - belly_h, d_center_x + belly_w, belly_y + belly_h],
                 fill=belly_color, outline=belly_border, width=int(size * 0.008))
    # Belly stripe grooves
    draw.arc([d_center_x - int(belly_w * 0.7), belly_y - int(belly_h * 0.4),
              d_center_x + int(belly_w * 0.7), belly_y + int(belly_h * 0.2)],
             start=20, end=160, fill=belly_border, width=int(size * 0.007))

    # Rosy Cheeks
    cheek_color = (255, 150, 165, 230)
    ch_w = int(size * 0.06)
    ch_h = int(size * 0.035)
    ch_y = d_center_y - int(size * 0.02)
    draw.ellipse([d_center_x - int(size * 0.22) - ch_w, ch_y - ch_h,
                  d_center_x - int(size * 0.22) + ch_w, ch_y + ch_h], fill=cheek_color)
    draw.ellipse([d_center_x + int(size * 0.22) - ch_w, ch_y - ch_h,
                  d_center_x + int(size * 0.22) + ch_w, ch_y + ch_h], fill=cheek_color)

    # Big Anime Sparkle Eyes
    eye_r = int(size * 0.055)
    eye_y = d_center_y - int(size * 0.08)
    eye_lx = d_center_x - int(size * 0.12)
    eye_rx = d_center_x + int(size * 0.12)

    # Eye base (Dark charcoal)
    for ex in [eye_lx, eye_rx]:
        draw.ellipse([ex - eye_r, eye_y - eye_r, ex + eye_r, eye_y + eye_r], fill=(45, 52, 68, 255))
        # Large white top-left gleam
        draw.ellipse([ex - eye_r + int(size * 0.015), eye_y - eye_r + int(size * 0.012),
                      ex + int(size * 0.012), eye_y + int(size * 0.012)], fill=(255, 255, 255, 255))
        # Small white bottom-right gleam
        draw.ellipse([ex + int(size * 0.01), eye_y + int(size * 0.015),
                      ex + int(size * 0.03), eye_y + int(size * 0.035)], fill=(255, 255, 255, 220))

    # Cute Smiling Mouth (w / cat curve)
    m_y = d_center_y - int(size * 0.01)
    m_color = (50, 60, 75, 255)
    m_w = int(size * 0.009)
    draw.arc([d_center_x - int(size * 0.06), m_y - int(size * 0.02),
              d_center_x, m_y + int(size * 0.03)], start=10, end=170, fill=m_color, width=m_w)
    draw.arc([d_center_x, m_y - int(size * 0.02),
              d_center_x + int(size * 0.06), m_y + int(size * 0.03)], start=10, end=170, fill=m_color, width=m_w)

    # Cute Little Star Crown on Head
    def draw_star(sx, sy, rad, color):
        points = []
        for i in range(10):
            r = rad if i % 2 == 0 else rad * 0.42
            angle = i * math.pi / 5 - math.pi / 2
            points.append((sx + r * math.cos(angle), sy + r * math.sin(angle)))
        draw.polygon(points, fill=color, outline=(255, 255, 255, 220))

    # Golden Sparkles
    draw_star(int(size * 0.18), int(size * 0.20), int(size * 0.055), (255, 225, 80, 255))
    draw_star(int(size * 0.82), int(size * 0.22), int(size * 0.045), (255, 215, 70, 255))
    draw_star(int(size * 0.85), int(size * 0.50), int(size * 0.035), (255, 235, 120, 255))
    draw_star(int(size * 0.14), int(size * 0.52), int(size * 0.032), (255, 235, 120, 255))

    return img

def export_all():
    print("Generating 1024x1024 master icon...")
    master = create_app_icon(1024)

    # Save master icon in brain artifacts
    master_512 = master.resize((512, 512), Image.Resampling.LANCZOS)
    brain_path = r"C:\Users\HP\.gemini\antigravity\brain\90700c88-e65c-4d11-bc39-bc037a56a29f\app_icon_512.png"
    master_512.save(brain_path)
    print(f"Saved {brain_path}")

    # Android mipmap targets:
    res_base = r"c:\Users\HP\Desktop\Rainbow Unicorn Candy Salon\android\app\src\main\res"
    sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }

    for folder, px in sizes.items():
        target_dir = os.path.join(res_base, folder)
        os.makedirs(target_dir, exist_ok=True)
        resized = master.resize((px, px), Image.Resampling.LANCZOS)
        out_file = os.path.join(target_dir, "ic_launcher.png")
        resized.save(out_file)
        # Also round launcher icon if supported
        out_round = os.path.join(target_dir, "ic_launcher_round.png")
        resized.save(out_round)
        print(f"Exported {out_file} ({px}x{px})")

if __name__ == '__main__':
    export_all()
