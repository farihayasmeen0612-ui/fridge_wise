import os
import subprocess
import sys
import time

FLUTTER = "/Users/hello/develop/flutter/bin/flutter"
CAPTURE_DIR = "/Users/hello/food_management/test/capture"
DOCS_SCREENSHOTS = "/Users/hello/food_management/docs/screenshots"

tests = [
    ("01_welcome.dart", "01_welcome_screen.png"),
    ("02_login.dart", "02_login_screen.png"),
    ("03_register.dart", "03_register_screen.png"),
    ("04_dashboard.dart", "04_dashboard_screen.png"),
    ("05_inventory.dart", "05_inventory_screen.png"),
    ("06_food_details.dart", "06_food_details_screen.png"),
    ("07_calendar.dart", "07_calendar_screen.png"),
    ("08_food_intake.dart", "08_food_intake_screen.png"),
    ("09_take_out.dart", "09_take_out_screen.png"),
    ("10_notifications.dart", "10_notifications_screen.png"),
    ("11_profile.dart", "11_profile_screen.png"),
    ("12_settings.dart", "12_settings_screen.png"),
]

print("=== STARTING AUTOMATED SCREENSHOT CAPTURE ===")
start_total = time.time()

for idx, (test_file, out_png) in enumerate(tests, 1):
    test_path = os.path.join(CAPTURE_DIR, test_file)
    png_path = os.path.join(DOCS_SCREENSHOTS, out_png)
    
    print(f"[{idx}/{len(tests)}] Capturing {out_png} using {test_file}...")
    t0 = time.time()
    
    cmd = [FLUTTER, "test", test_path]
    try:
        proc = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=25
        )
    except subprocess.TimeoutExpired:
        print(f"  FAILED: Timeout on {test_file}")
        continue
    
    elapsed = time.time() - t0
    if os.path.exists(png_path):
        size_kb = os.path.getsize(png_path) / 1024.0
        print(f"  SUCCESS: {out_png} saved ({size_kb:.1f} KB in {elapsed:.1f}s)")
    else:
        print(f"  FAILED to save {out_png}. Output:\n{proc.stdout[-500:]}")

total_elapsed = time.time() - start_total
print(f"=== FINISHED ALL CAPTURES IN {total_elapsed:.1f}s ===")

