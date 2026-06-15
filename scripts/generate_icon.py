"""Generates the 1024x1024 App Icon for Cam & Screen."""

from PIL import Image, ImageDraw

SIZE = 1024
img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Background gradient (deep blue -> purple), diagonal.
top_color = (37, 99, 235)     # blue-600
bottom_color = (124, 58, 237)  # violet-600
for y in range(SIZE):
    t = y / SIZE
    r = int(top_color[0] + (bottom_color[0] - top_color[0]) * t)
    g = int(top_color[1] + (bottom_color[1] - top_color[1]) * t)
    b = int(top_color[2] + (bottom_color[2] - top_color[2]) * t)
    draw.line([(0, y), (SIZE, y)], fill=(r, g, b, 255))

margin = 110
content = SIZE - margin * 2
half = content / 2

# --- Top half: camera lens ---
cam_top = margin
cam_bottom = margin + half
cam_center = (SIZE / 2, (cam_top + cam_bottom) / 2)
lens_radius = half * 0.34

# Outer lens ring
draw.ellipse(
    [cam_center[0] - lens_radius, cam_center[1] - lens_radius,
     cam_center[0] + lens_radius, cam_center[1] + lens_radius],
    outline=(255, 255, 255, 255),
    width=26,
)
# Inner lens dot
inner_r = lens_radius * 0.42
draw.ellipse(
    [cam_center[0] - inner_r, cam_center[1] - inner_r,
     cam_center[0] + inner_r, cam_center[1] + inner_r],
    fill=(255, 255, 255, 255),
)

# Small "flip" arc accents around the lens to suggest front/back flip
flip_r = lens_radius + 46
draw.arc(
    [cam_center[0] - flip_r, cam_center[1] - flip_r,
     cam_center[0] + flip_r, cam_center[1] + flip_r],
    start=200, end=340, fill=(255, 255, 255, 200), width=14,
)
draw.arc(
    [cam_center[0] - flip_r, cam_center[1] - flip_r,
     cam_center[0] + flip_r, cam_center[1] + flip_r],
    start=20, end=160, fill=(255, 255, 255, 200), width=14,
)

# --- Divider line ---
divider_y = SIZE / 2
draw.rounded_rectangle(
    [margin + 30, divider_y - 6, SIZE - margin - 30, divider_y + 6],
    radius=6, fill=(255, 255, 255, 90),
)

# --- Bottom half: screen / record rectangle ---
rect_top = SIZE / 2 + 40
rect_bottom = SIZE - margin
rect_left = margin + 40
rect_right = SIZE - margin - 40

draw.rounded_rectangle(
    [rect_left, rect_top, rect_right, rect_bottom],
    radius=28, outline=(255, 255, 255, 255), width=22,
)

# Record dot inside the screen rectangle
rect_center = ((rect_left + rect_right) / 2, (rect_top + rect_bottom) / 2)
dot_r = (rect_bottom - rect_top) * 0.22
draw.ellipse(
    [rect_center[0] - dot_r, rect_center[1] - dot_r,
     rect_center[0] + dot_r, rect_center[1] + dot_r],
    fill=(239, 68, 68, 255),  # red-500
)

img = img.convert("RGB")  # App icons must not contain an alpha channel
img.save("Sources/CamAndScreen/Assets.xcassets/AppIcon.appiconset/icon-1024.png")
print("Saved icon")
