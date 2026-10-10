import os
import math
from PIL import Image, ImageDraw, ImageFont

def get_course_style(course):
    # Map course names to slightly richer pastel background colors and ultra-dark text colors for high print contrast
    styles = {
        "语文": ("#FFEBEB", "#7A1C1C"),          # Dark red
        "语文/书法": ("#FFEBEB", "#7A1C1C"),
        "数学": ("#E6F4EA", "#134E29"),          # Dark green
        "英语": ("#E0F2FE", "#0F4C81"),          # Dark blue
        "美术": ("#F3E8FF", "#4C1D95"),          # Dark purple
        "音乐": ("#F3E8FF", "#4C1D95"),
        "体育": ("#D1FAE5", "#064E3B"),          # Dark mint green
        "体能": ("#D1FAE5", "#064E3B"),
        "体操": ("#D1FAE5", "#064E3B"),
        "足球": ("#D1FAE5", "#064E3B"),
        "花样跳绳": ("#D1FAE5", "#064E3B"),
        "科学": ("#FEF3C7", "#78350F"),          # Dark amber/brown
        "劳动": ("#FEF3C7", "#78350F"),
        "综合实践活动": ("#F3F4F6", "#1F2937"),    # Dark slate grey
        "地方课程/校本课程": ("#F3F4F6", "#1F2937"),
        "道德与法治": ("#FEF3C7", "#78350F"),
        "阅读": ("#FFEBEB", "#7A1C1C"),
        "少先队": ("#FFEBEB", "#7A1C1C")
    }
    for key, val in styles.items():
        if key in course or course in key:
            return val
    return ("#FFFFFF", "#000000")

def draw_text_centered(draw, text, x_center, y_center, font, fill):
    # Get text bounding box to calculate exact centering
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    draw.text((x_center - text_width / 2, y_center - text_height / 2 - bbox[1]), text, font=font, fill=fill)

def main():
    # 1. Create a high-resolution image corresponding to ID card size (85.6mm x 53.98mm) at 300 DPI
    # Width: 85.6 mm / 25.4 * 300 = 1011 pixels
    # Height: 53.98 mm / 25.4 * 300 = 638 pixels
    width, height = 1011, 638
    
    # Create background image with a soft, cute lavender-blue background (slightly darker for better contrast)
    image = Image.new("RGB", (width, height), "#EBF1FF")
    draw = ImageDraw.Draw(image)
    
    # Draw a grid pattern on the background (darker grey for visibility)
    grid_size = 24
    for x in range(0, width, grid_size):
        draw.line([(x, 0), (x, height)], fill="#D2DDF4", width=1)
    for y in range(0, height, grid_size):
        draw.line([(0, y), (width, y)], fill="#D2DDF4", width=1)
        
    # Draw the main card container with rounded corners and a white background
    margin = 12
    draw.rounded_rectangle(
        [(margin, margin), (width - margin, height - margin)],
        radius=16,
        fill="#FFFFFF",
        outline="#4A5568", # Much darker outline for the card container
        width=4            # Thicker outline
    )
    
    # Load fonts
    font_path_bold = r"C:\Windows\Fonts\msyhbd.ttc"
    font_path_regular = r"C:\Windows\Fonts\msyh.ttc"
    
    # Increased font sizes for better print legibility
    font_title = ImageFont.truetype(font_path_bold, 32)
    font_subtitle = ImageFont.truetype(font_path_bold, 15) # Bold subtitle
    font_badge = ImageFont.truetype(font_path_bold, 17)
    font_ampm = ImageFont.truetype(font_path_bold, 18)
    font_period = ImageFont.truetype(font_path_bold, 18)
    font_bar = ImageFont.truetype(font_path_bold, 16)
    
    # Course and teacher fonts (all bold and larger)
    font_course_default = ImageFont.truetype(font_path_bold, 17)
    font_course_medium = ImageFont.truetype(font_path_bold, 14)
    font_course_small = ImageFont.truetype(font_path_bold, 11)
    font_teacher = ImageFont.truetype(font_path_bold, 13) # Bold teacher name, size 13
    
    # Draw Header Elements
    # Title (Darker blue)
    draw_text_centered(draw, "课  程  表", width / 2, 28, font_title, "#1A365D")
    # Subtitle (Darker slate grey)
    draw_text_centered(draw, "杭州市钱塘实验小学 · 108班", width / 2, 70, font_subtitle, "#2D3748")
    
    # Draw a cute minimalist SpongeBob on the left of the header (thicker lines)
    sb_x, sb_y = 120, 48
    # Body (Yellow)
    draw.rounded_rectangle(
        [(sb_x - 18, sb_y - 25), (sb_x + 18, sb_y + 13)],
        radius=4,
        fill="#FDD835",
        outline="#5C3E00", # Darker brown outline
        width=2
    )
    # Shirt (White)
    draw.rectangle(
        [(sb_x - 18, sb_y + 13), (sb_x + 18, sb_y + 18)],
        fill="#FFFFFF",
        outline="#1A202C",
        width=2
    )
    # Pants (Brown)
    draw.rectangle(
        [(sb_x - 18, sb_y + 18), (sb_x + 18, sb_y + 25)],
        fill="#8D6E63",
        outline="#3E2723",
        width=2
    )
    # Tie (Red)
    draw.polygon(
        [(sb_x - 3, sb_y + 13), (sb_x + 3, sb_y + 13), (sb_x, sb_y + 19)],
        fill="#E53935"
    )
    # Sponge holes (greenish-yellow circles)
    draw.ellipse([(sb_x - 14, sb_y - 20), (sb_x - 10, sb_y - 16)], fill="#C0CA33")
    draw.ellipse([(sb_x + 10, sb_y - 18), (sb_x + 14, sb_y - 14)], fill="#C0CA33")
    draw.ellipse([(sb_x - 12, sb_y + 4), (sb_x - 8, sb_y + 8)], fill="#C0CA33")
    draw.ellipse([(sb_x + 8, sb_y + 2), (sb_x + 12, sb_y + 6)], fill="#C0CA33")
    # Eyes (White with blue iris and black pupil)
    draw.ellipse([(sb_x - 9, sb_y - 12), (sb_x + 1, sb_y - 2)], fill="#FFFFFF", outline="#1A202C", width=2)
    draw.ellipse([(sb_x - 1, sb_y - 12), (sb_x + 9, sb_y - 2)], fill="#FFFFFF", outline="#1A202C", width=2)
    # Iris
    draw.ellipse([(sb_x - 5, sb_y - 8), (sb_x - 1, sb_y - 4)], fill="#03A9F4")
    draw.ellipse([(sb_x + 1, sb_y - 8), (sb_x + 5, sb_y - 4)], fill="#03A9F4")
    # Pupil
    draw.ellipse([(sb_x - 4, sb_y - 7), (sb_x - 2, sb_y - 5)], fill="#000000")
    draw.ellipse([(sb_x + 2, sb_y - 7), (sb_x + 4, sb_y - 5)], fill="#000000")
    # Cheeks (Rosy pink)
    draw.ellipse([(sb_x - 14, sb_y - 3), (sb_x - 10, sb_y + 1)], fill="#FF8A80")
    draw.ellipse([(sb_x + 10, sb_y - 3), (sb_x + 14, sb_y + 1)], fill="#FF8A80")
    # Smile
    draw.arc([(sb_x - 8, sb_y - 6), (sb_x + 8, sb_y + 6)], start=0, end=180, fill="#1A202C", width=2)
    # Teeth
    draw.rectangle([(sb_x - 3, sb_y + 6), (sb_x - 1, sb_y + 10)], fill="#FFFFFF", outline="#1A202C", width=1)
    draw.rectangle([(sb_x + 1, sb_y + 6), (sb_x + 3, sb_y + 10)], fill="#FFFFFF", outline="#1A202C", width=1)

    # Draw a cute minimalist Patrick Star on the right of the header (thicker lines)
    pat_x, pat_y = 880, 48
    # Patrick's body polygon (pink)
    pat_points = [
        (pat_x, pat_y - 25),       # Head top
        (pat_x + 5, pat_y - 10),    # Neck right
        (pat_x + 20, pat_y - 5),    # Right arm
        (pat_x + 8, pat_y + 3),     # Underarm right
        (pat_x + 13, pat_y + 25),   # Right leg
        (pat_x, pat_y + 15),       # Crotch
        (pat_x - 13, pat_y + 25),   # Left leg
        (pat_x - 8, pat_y + 3),     # Underarm left
        (pat_x - 20, pat_y - 5),    # Left arm
        (pat_x - 5, pat_y - 10)     # Neck left
    ]
    draw.polygon(pat_points, fill="#FF8DA1", outline="#880E4F")
    
    # Patrick's Pants (Green with purple flowers)
    pants_points = [
        (pat_x - 9, pat_y + 7),
        (pat_x + 9, pat_y + 7),
        (pat_x + 13, pat_y + 25),
        (pat_x, pat_y + 15),
        (pat_x - 13, pat_y + 25)
    ]
    draw.polygon(pants_points, fill="#9CCC65", outline="#33691E")
    # Purple flowers (dots) on pants
    draw.ellipse([(pat_x - 6, pat_y + 12), (pat_x - 3, pat_y + 15)], fill="#AB47BC")
    draw.ellipse([(pat_x + 3, pat_y + 11), (pat_x + 6, pat_y + 14)], fill="#AB47BC")
    draw.ellipse([(pat_x - 2, pat_y + 18), (pat_x + 1, pat_y + 21)], fill="#AB47BC")
    
    # Eyes
    draw.ellipse([(pat_x - 5, pat_y - 14), (pat_x, pat_y - 4)], fill="#FFFFFF", outline="#1A202C", width=2)
    draw.ellipse([(pat_x, pat_y - 14), (pat_x + 5, pat_y - 4)], fill="#FFFFFF", outline="#1A202C", width=2)
    # Pupils
    draw.ellipse([(pat_x - 3, pat_y - 10), (pat_x - 1, pat_y - 8)], fill="#000000")
    draw.ellipse([(pat_x + 1, pat_y - 10), (pat_x + 3, pat_y - 8)], fill="#000000")
    # Eyebrows
    draw.line([(pat_x - 6, pat_y - 17), (pat_x - 2, pat_y - 15)], fill="#1A202C", width=1)
    draw.line([(pat_x + 6, pat_y - 17), (pat_x + 2, pat_y - 15)], fill="#1A202C", width=1)
    # Smile
    draw.arc([(pat_x - 5, pat_y - 4), (pat_x + 5, pat_y + 4)], start=0, end=180, fill="#1A202C", width=1)
    
    # Grid Layout Coordinates
    grid_y_start = 105
    day_header_height = 46
    period_height = 66
    noon_break_height = 34
    sports_height = 36
    
    col_ampm_width = 45
    col_period_width = 40
    col_day_width = 178
    
    x_start = 18
    
    # 1. Draw Day Header Badges (Mon - Fri) - Darker text colors for print
    day_labels = ["周一", "周二", "周三", "周四", "周五"]
    day_colors = [
        ("#FFD1DC", "#4A0E17"), # Mon: dark red-brown text
        ("#FFE5B4", "#4A2800"), # Tue: dark brown text
        ("#D4F0F0", "#003333"), # Wed: dark teal text
        ("#E2F0CB", "#1E3300"), # Thu: dark forest text
        ("#D0E1FD", "#0A1D37")  # Fri: dark navy text
    ]
    
    for i in range(5):
        col_x = x_start + col_ampm_width + col_period_width + i * col_day_width
        x_center = col_x + col_day_width / 2
        bg_color, text_color = day_colors[i]
        
        # Draw rounded badge
        badge_w, badge_h = 100, 30
        draw.rounded_rectangle(
            [(x_center - badge_w/2, grid_y_start + (day_header_height - badge_h)/2), 
             (x_center + badge_w/2, grid_y_start + (day_header_height + badge_h)/2)],
            radius=15,
            fill=bg_color,
            outline="#4A5568", # Added border to header badges
            width=1
        )
        draw_text_centered(draw, day_labels[i], x_center, grid_y_start + day_header_height/2, font_badge, text_color)
        
    # 2. Draw AM/PM vertical blocks (Darker borders and text)
    # Morning block (Periods 1, 2, 3)
    am_y_start = grid_y_start + day_header_height
    am_y_end = am_y_start + 3 * period_height
    draw.rounded_rectangle(
        [(x_start, am_y_start + 2), (x_start + col_ampm_width - 4, am_y_end - 2)],
        radius=8,
        fill="#FFF0F5",
        outline="#4A5568", # Darker outline
        width=2
    )
    # Vertical text "上午" (Darker color)
    draw_text_centered(draw, "上\n午", x_start + (col_ampm_width - 4)/2, am_y_start + (3 * period_height)/2, font_ampm, "#4A0E17")
    
    # Afternoon block (Periods 4, 5, 6)
    pm_y_start = am_y_end + noon_break_height
    pm_y_end = pm_y_start + 3 * period_height
    draw.rounded_rectangle(
        [(x_start, pm_y_start + 2), (x_start + col_ampm_width - 4, pm_y_end - 2)],
        radius=8,
        fill="#F0F8FF",
        outline="#4A5568", # Darker outline
        width=2
    )
    # Vertical text "下午" (Darker color)
    draw_text_centered(draw, "下\n午", x_start + (col_ampm_width - 4)/2, pm_y_start + (3 * period_height)/2, font_ampm, "#0A1D37")
    
    # 3. Draw Period Numbers (1 to 6) (Darker borders and text)
    for p in range(1, 7):
        if p <= 3:
            p_y = am_y_start + (p - 1) * period_height
        else:
            p_y = pm_y_start + (p - 4) * period_height
            
        draw.rounded_rectangle(
            [(x_start + col_ampm_width, p_y + 2), (x_start + col_ampm_width + col_period_width - 4, p_y + period_height - 2)],
            radius=6,
            fill="#F7FAFC",
            outline="#4A5568", # Darker outline
            width=2
        )
        draw_text_centered(draw, str(p), x_start + col_ampm_width + (col_period_width - 4)/2, p_y + period_height/2, font_period, "#1A202C")
        
    # 4. Draw Noon Break Row ("午休") (Darker border and text)
    noon_y = am_y_end
    draw.rounded_rectangle(
        [(x_start, noon_y + 2), (width - x_start, noon_y + noon_break_height - 2)],
        radius=8,
        fill="#FFF9E6",
        outline="#4A5568", # Darker outline
        width=2
    )
    draw_text_centered(draw, "午  休  🎵", width / 2, noon_y + noon_break_height/2, font_bar, "#78350F")
    
    # 5. Draw Sports Activity Row ("体育活动") (Darker border and text)
    sports_y = pm_y_end
    draw.rounded_rectangle(
        [(x_start, sports_y + 2), (width - x_start, sports_y + sports_height - 2)],
        radius=8,
        fill="#F0FDF4",
        outline="#4A5568", # Darker outline
        width=2
    )
    draw_text_centered(draw, "体  育  活  动  🏃", width / 2, sports_y + sports_height/2, font_bar, "#064E3B")
    
    # 6. Draw Course Cells
    timetable = [
        # Period 1
        [
            {"course": "语文", "teacher": "邢钿钿"},
            {"course": "语文", "teacher": "邢钿钿"},
            {"course": "数学", "teacher": "章旦旦"},
            {"course": "数学", "teacher": "章旦旦"},
            {"course": "语文", "teacher": "邢钿钿"}
        ],
        # Period 2
        [
            {"course": "数学", "teacher": "章旦旦"},
            {"course": "数学", "teacher": "章旦旦"},
            {"course": "语文", "teacher": "邢钿钿"},
            {"course": "语文", "teacher": "邢钿钿"},
            {"course": "数学", "teacher": "章旦旦"}
        ],
        # Period 3
        [
            {"course": "美术", "teacher": "马雨曦"},
            {"course": "语文", "teacher": "邢钿钿"},
            {"course": "语文", "teacher": "邢钿钿"},
            {"course": "音乐", "teacher": "游霞"},
            {"course": "科学", "teacher": "曹立刚"}
        ],
        # Period 4
        [
            {"course": "语文/书法", "teacher": "邢钿钿"},
            {"course": "英语", "teacher": "kimberly"},
            {"course": "足球", "teacher": "包欢良"},
            {"course": "花样跳绳", "teacher": "张吉芳"},
            {"course": "阅读", "teacher": "张钰平"}
        ],
        # Period 5
        [
            {"course": "综合实践活动", "teacher": ""},
            {"course": "体能", "teacher": "张吉芳"},
            {"course": "音乐", "teacher": "游霞"},
            {"course": "道德与法治", "teacher": "邢钿钿"},
            {"course": "体操", "teacher": "韩诗琪"}
        ],
        # Period 6
        [
            {"course": "地方课程/校本课程", "teacher": ""},
            {"course": "道德与法治", "teacher": "邢钿钿"},
            {"course": "劳动", "teacher": "金国丽"},
            {"course": "美术", "teacher": "马雨曦"},
            {"course": "少先队", "teacher": "邢钿钿"}
        ]
    ]
    
    for p in range(1, 7):
        for d in range(5):
            cell = timetable[p-1][d]
            course = cell["course"]
            teacher = cell["teacher"]
            
            # Determine cell coordinates
            col_x = x_start + col_ampm_width + col_period_width + d * col_day_width
            if p <= 3:
                row_y = am_y_start + (p - 1) * period_height
            else:
                row_y = pm_y_start + (p - 4) * period_height
                
            cell_box = [
                (col_x + 2, row_y + 2),
                (col_x + col_day_width - 2, row_y + period_height - 2)
            ]
            
            # Get style for course
            bg_color, text_color = get_course_style(course)
            
            # Draw cell background with a darker outline and thicker width for print definition
            draw.rounded_rectangle(cell_box, radius=6, fill=bg_color, outline="#718096", width=2)
            
            # Center of the cell
            cx = col_x + col_day_width / 2
            cy = row_y + period_height / 2
            
            # Choose appropriate font size based on course name length
            if len(course) <= 4:
                font_course = font_course_default
            elif len(course) <= 6:
                font_course = font_course_medium
            else:
                font_course = font_course_small
                
            # Draw course name and teacher name
            if teacher:
                # Draw course slightly higher (adjusted for larger font size)
                draw_text_centered(draw, course, cx, row_y + 20, font_course, text_color)
                # Draw teacher name slightly lower - using pure black (#000000) for maximum print legibility
                draw_text_centered(draw, f"({teacher})", cx, row_y + 46, font_teacher, "#000000")
            else:
                # Draw course name perfectly centered vertically
                draw_text_centered(draw, course, cx, cy, font_course, text_color)
                
    # Save the image as high-resolution PNG with 300 DPI metadata
    output_png = r"C:\TA\docs\班级课程表_卡片版_海绵宝宝.png"
    image.save(output_png, "PNG", dpi=(300, 300))
    print(f"Saved PNG to: {output_png}")
    
    # Save the image as a PDF with 300 DPI resolution (which sets the physical page size to exactly 85.6mm x 53.98mm)
    output_pdf = r"C:\TA\docs\班级课程表_卡片版_海绵宝宝.pdf"
    image.save(output_pdf, "PDF", resolution=300.0)
    print(f"Saved PDF to: {output_pdf}")

if __name__ == "__main__":
    main()
