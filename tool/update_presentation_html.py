import os
import base64

DOCS_DIR = "/Users/hello/food_management/docs"
SCREENSHOTS_DIR = os.path.join(DOCS_DIR, "screenshots")
OUTPUT_HTML = os.path.join(DOCS_DIR, "APP_PRESENTATION.html")

def get_b64(filename):
    path = os.path.join(SCREENSHOTS_DIR, filename)
    if not os.path.exists(path):
        print(f"Warning: {filename} not found")
        return ""
    mime = "image/png" if filename.endswith(".png") else "image/jpeg"
    with open(path, "rb") as f:
        data = base64.b64encode(f.read()).decode("utf-8")
    return f"data:{mime};base64,{data}"

print("Encoding screenshots...")
b64_icon = get_b64("01_app_icon.png")
b64_welcome = get_b64("01_welcome_screen.png")
b64_login = get_b64("02_login_screen.png")
b64_register = get_b64("03_register_screen.png")
b64_dashboard = get_b64("04_dashboard_screen.png")
b64_inventory = get_b64("05_inventory_screen.png")
b64_details = get_b64("06_food_details_screen.png")
b64_calendar = get_b64("07_calendar_screen.png")
b64_intake = get_b64("08_food_intake_screen.png")
b64_takeout = get_b64("09_take_out_screen.png")
b64_notifs = get_b64("10_notifications_screen.png")
b64_profile = get_b64("11_profile_screen.png")
b64_settings = get_b64("12_settings_screen.png")
b64_hardware = get_b64("12_hardware_camera_capture.jpg")

html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>FridgeWise — Smart Fridge IoT Application Presentation</title>
<style>
  :root {{
    --primary: #176343;
    --primary-light: #23563E;
    --accent: #E1EBDF;
    --bg: #F7F8F0;
    --card-bg: #FFFFFF;
    --text-primary: #19251D;
    --text-secondary: #526154;
    --border: #E0E7DE;
    --badge-fresh: #1E7E4B;
    --badge-expiring: #C86D00;
    --badge-danger: #D32F2F;
  }}
  * {{ box-sizing: border-box; margin: 0; padding: 0; }}
  body {{
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
    background-color: var(--bg);
    color: var(--text-primary);
    line-height: 1.6;
    padding: 24px;
  }}
  .container {{
    max-width: 1080px;
    margin: 0 auto;
  }}
  header.hero {{
    background: linear-gradient(135deg, #176343 0%, #0D3E29 100%);
    color: white;
    padding: 44px 36px;
    border-radius: 24px;
    margin-bottom: 36px;
    box-shadow: 0 10px 30px rgba(23, 99, 67, 0.15);
    display: flex;
    align-items: center;
    gap: 28px;
  }}
  header.hero .logo {{
    width: 96px;
    height: 96px;
    background: white;
    border-radius: 20px;
    padding: 8px;
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
    flex-shrink: 0;
  }}
  header.hero .logo img {{
    width: 100%;
    height: 100%;
    object-fit: contain;
  }}
  header.hero h1 {{
    font-size: 32px;
    font-weight: 800;
    letter-spacing: -0.5px;
    margin-bottom: 8px;
  }}
  header.hero p {{
    font-size: 16px;
    opacity: 0.92;
    max-width: 720px;
  }}
  .meta-pills {{
    display: flex;
    gap: 12px;
    margin-top: 14px;
    flex-wrap: wrap;
  }}
  .pill {{
    background: rgba(255, 255, 255, 0.18);
    backdrop-filter: blur(4px);
    padding: 6px 14px;
    border-radius: 999px;
    font-size: 13px;
    font-weight: 600;
  }}
  .card {{
    background: var(--card-bg);
    border-radius: 20px;
    padding: 32px;
    margin-bottom: 32px;
    border: 1px solid var(--border);
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.03);
  }}
  .card h2 {{
    font-size: 24px;
    font-weight: 700;
    color: var(--primary);
    margin-bottom: 16px;
    display: flex;
    align-items: center;
    gap: 10px;
  }}
  .card h3 {{
    font-size: 18px;
    font-weight: 700;
    margin: 20px 0 10px 0;
    color: var(--text-primary);
  }}
  .screen-grid {{
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 24px;
    margin: 20px 0;
  }}
  .screen-item {{
    background: #FDFEFC;
    border: 1px solid var(--border);
    border-radius: 16px;
    padding: 16px;
    text-align: center;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
  }}
  .screen-item:hover {{
    transform: translateY(-3px);
    box-shadow: 0 10px 24px rgba(0, 0, 0, 0.06);
  }}
  .screen-item img {{
    max-width: 100%;
    height: auto;
    max-height: 520px;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    display: block;
    margin: 0 auto 12px auto;
  }}
  .screen-item .caption {{
    font-size: 14px;
    font-weight: 700;
    color: var(--primary);
    margin-bottom: 4px;
  }}
  .screen-item .sub {{
    font-size: 12px;
    color: var(--text-secondary);
  }}
  ul.features {{
    list-style: none;
    margin: 16px 0;
  }}
  ul.features li {{
    position: relative;
    padding-left: 24px;
    margin-bottom: 10px;
    font-size: 15px;
  }}
  ul.features li::before {{
    content: "✓";
    position: absolute;
    left: 0;
    color: var(--primary);
    font-weight: 800;
  }}
  .arch-box {{
    background: #F4F7F2;
    border-left: 4px solid var(--primary);
    padding: 18px 22px;
    border-radius: 0 12px 12px 0;
    margin: 16px 0;
    font-size: 14px;
  }}
  table.tech-table {{
    width: 100%;
    border-collapse: collapse;
    margin: 16px 0;
    font-size: 14px;
  }}
  table.tech-table th, table.tech-table td {{
    padding: 12px 16px;
    text-align: left;
    border-bottom: 1px solid var(--border);
  }}
  table.tech-table th {{
    background: #F0F4EE;
    color: var(--primary);
    font-weight: 700;
  }}
  @media print {{
    body {{ background: white; padding: 0; }}
    .card {{ page-break-inside: avoid; box-shadow: none; border: 1px solid #ccc; }}
    header.hero {{ page-break-inside: avoid; }}
  }}
</style>
</head>
<body>
<div class="container">

  <header class="hero">
    <div class="logo">
      <img src="{b64_icon}" alt="FridgeWise Icon">
    </div>
    <div>
      <h1>FridgeWise — Mobile Application Subsystem</h1>
      <p>IoT Smart Fridge Food & Expiry Management System. Integrated Edge Hardware, Google Gemini AI Vision, and Supabase Cloud Event Ledger.</p>
      <div class="meta-pills">
        <span class="pill">Flutter 3.47.2 / Dart 3.13.2</span>
        <span class="pill">Supabase Cloud</span>
        <span class="pill">Gemini 1.5 Flash Vision</span>
        <span class="pill">Event-Sourced Ledger</span>
      </div>
    </div>
  </header>

  <!-- SLIDE 1: SYSTEM OVERVIEW -->
  <div class="card">
    <h2>1. System Architecture & Edge Integration</h2>
    <p>FridgeWise connects physical refrigerator hardware with cloud intelligence and a cross-platform mobile application.</p>
    
    <div class="arch-box">
      <strong>Three-Tier Real-Time Pipeline:</strong><br>
      1. <strong>Edge Hardware (Subsystem 1)</strong>: ESP32-S3 CAM, Magnetic Reed Door Sensor (IN trigger), and Tactile Button (OUT trigger).<br>
      2. <strong>Cloud AI & Backend (Supabase)</strong>: Image CDN Storage, Google Gemini 1.5 Flash Vision API, PostgreSQL Event Ledger, and Realtime WebSockets.<br>
      3. <strong>Mobile Application (Subsystem 2 — This Subsystem)</strong>: Asynchronous Human-in-the-Loop Verification, Multi-Compartment Inventory, Freshness Tracking, and User Isolation.
    </div>
  </div>

  <!-- SLIDE 2: APP IDENTITY & ONBOARDING -->
  <div class="card">
    <h2>2. App Identity & Onboarding</h2>
    <p>Consistent branding and aesthetic across launcher icons, splash screen, and onboarding.</p>
    <div class="screen-grid">
      <div class="screen-item">
        <img src="{b64_icon}" alt="App Launcher Icon" style="max-height: 220px; width: 220px; object-fit: contain;">
        <div class="caption">Launcher Icon</div>
        <div class="sub">High-res multi-density icon with sparkle badge</div>
      </div>
      <div class="screen-item">
        <img src="{b64_welcome}" alt="Welcome Screen">
        <div class="caption">Welcome / Onboarding Screen</div>
        <div class="sub">Botanical kitchen illustration & theme toggle</div>
      </div>
    </div>
  </div>

  <!-- SLIDE 3: AUTHENTICATION -->
  <div class="card">
    <h2>3. Authentication & User Data Isolation</h2>
    <p>Secure Supabase GoTrue authentication providing scoped data isolation per user.</p>
    <div class="screen-grid">
      <div class="screen-item">
        <img src="{b64_login}" alt="Login Screen">
        <div class="caption">Sign In Screen</div>
        <div class="sub">Forest green aesthetic & form validation</div>
      </div>
      <div class="screen-item">
        <img src="{b64_register}" alt="Register Screen">
        <div class="caption">Create Account Screen</div>
        <div class="sub">Isolated inventory provisioning per UID</div>
      </div>
    </div>
    <ul class="features">
      <li><strong>Data Privacy & Multi-Tenancy</strong>: Each registered user starts with a clean, private fridge inventory scoped to their credentials.</li>
      <li><strong>Session Persistence</strong>: Cryptographic JWT session storage with automatic refresh.</li>
    </ul>
  </div>

  <!-- SLIDE 4: DASHBOARD -->
  <div class="card">
    <h2>4. Executive Dashboard & Real-Time KPIs</h2>
    <p>Centralized control center offering high-level visibility over inventory health and urgent action items.</p>
    <div class="screen-grid">
      <div class="screen-item" style="grid-column: 1 / -1; max-width: 440px; margin: 0 auto;">
        <img src="{b64_dashboard}" alt="Dashboard Screen">
        <div class="caption">Live Executive Dashboard</div>
        <div class="sub">Dynamic time-based greeting, KPI metric bar, urgent attention carousel</div>
      </div>
    </div>
    <ul class="features">
      <li><strong>Live Metrics</strong>: Instant breakdown of Total Items, Fresh Items (> 3 days), Expiring Soon, and Expired items.</li>
      <li><strong>Pending Capture Alerts</strong>: Persistent alert card notifying the user when raw hardware captures await verification.</li>
      <li><strong>Zero-Waste Recipe Integration</strong>: Suggests dynamic chef-crafted recipes based on ingredients currently in the fridge.</li>
    </ul>
  </div>

  <!-- SLIDE 5: FOOD INTAKE -->
  <div class="card">
    <h2>5. Food Intake (IN) — Human-in-the-Loop AI Review</h2>
    <p>Automated intake triggered when the smart fridge door closes, verified with one tap by the user.</p>
    <div class="screen-grid">
      <div class="screen-item">
        <img src="{b64_intake}" alt="Food Intake Screen">
        <div class="caption">Mobile Intake Review Screen</div>
        <div class="sub">Streamlined layout, AI name pre-fill, compartment selector</div>
      </div>
      <div class="screen-item">
        <img src="{b64_hardware}" alt="ESP32 Hardware Photo">
        <div class="caption">Raw ESP32-S3 Camera Capture</div>
        <div class="sub">Captured on door close and uploaded to cloud CDN</div>
      </div>
    </div>
    <ul class="features">
      <li><strong>Asynchronous AI Verification</strong>: Gemini 1.5 Flash Vision classifies the food item, but the user has final confirmation authority.</li>
      <li><strong>Interactive Pinch-to-Zoom</strong>: Tap any photo thumbnail to inspect details in a full-screen viewer.</li>
      <li><strong>Streamlined Actions</strong>: Redundant trash icons removed; single "Confirm Intake" and "Dismiss Request" buttons.</li>
    </ul>
  </div>

  <!-- SLIDE 6: FOOD REMOVAL -->
  <div class="card">
    <h2>6. Food Removal (OUT) — Visual Checklist & Deduction</h2>
    <p>Triggered when a user presses the physical OUT button on the fridge exterior.</p>
    <div class="screen-grid">
      <div class="screen-item" style="grid-column: 1 / -1; max-width: 440px; margin: 0 auto;">
        <img src="{b64_takeout}" alt="Take Out Screen">
        <div class="caption">Food Removal (OUT) Screen</div>
        <div class="sub">Physical extraction photo, item search, quantity selection</div>
      </div>
    </div>
    <ul class="features">
      <li><strong>Zero AI Hallucinations for Extraction</strong>: Removal relies on visual confirmation by the user against their active inventory list.</li>
      <li><strong>Ledger Balance Deduction</strong>: Deductions decrement active stock in the append-only event ledger.</li>
    </ul>
  </div>

  <!-- SLIDE 7: INVENTORY & CALENDAR -->
  <div class="card">
    <h2>7. "My Fridge" Inventory & Expiry Calendar</h2>
    <p>Multi-compartment organization and dynamic freshness monitoring.</p>
    <div class="screen-grid">
      <div class="screen-item">
        <img src="{b64_inventory}" alt="Inventory Screen">
        <div class="caption">Inventory Screen</div>
        <div class="sub">Refrigerator, Freezer, and Deep Fridge tabs</div>
      </div>
      <div class="screen-item">
        <img src="{b64_calendar}" alt="Expiry Calendar">
        <div class="caption">Expiry Calendar Screen</div>
        <div class="sub">Monthly timeline grid with color-coded alerts</div>
      </div>
    </div>
    <ul class="features">
      <li><strong>Multi-Compartment Organization</strong>: Partition groceries across Refrigerator, Freezer, and Deep Fridge zones.</li>
      <li><strong>Color-Coded Freshness</strong>: Clear badges indicate items expiring today, within a week, or already expired.</li>
    </ul>
  </div>

  <!-- SLIDE 8: FOOD DETAILS & NOTIFICATIONS -->
  <div class="card">
    <h2>8. Item Details, Notifications & Settings</h2>
    <p>Granular portion consumption, hardware event notifications, and user configuration.</p>
    <div class="screen-grid">
      <div class="screen-item">
        <img src="{b64_details}" alt="Food Details Screen">
        <div class="caption">Food Item Details</div>
        <div class="sub">Consume portion or discard spoiled</div>
      </div>
      <div class="screen-item">
        <img src="{b64_notifs}" alt="Notifications Screen">
        <div class="caption">Notification Center</div>
        <div class="sub">Hardware capture & expiry alerts</div>
      </div>
      <div class="screen-item">
        <img src="{b64_profile}" alt="Profile Screen">
        <div class="caption">User Profile Screen</div>
        <div class="sub">Clean UI with database UID hidden</div>
      </div>
      <div class="screen-item">
        <img src="{b64_settings}" alt="Settings Screen">
        <div class="caption">Application Settings</div>
        <div class="sub">Custom alert thresholds & sync options</div>
      </div>
    </div>
  </div>

  <!-- SLIDE 9: TECH STACK -->
  <div class="card">
    <h2>9. Technology Stack Summary</h2>
    <table class="tech-table">
      <thead>
        <tr>
          <th>Subsystem</th>
          <th>Technology</th>
          <th>Role & Responsibility</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><strong>Mobile Frontend</strong></td>
          <td>Flutter 3.47.2 / Dart 3.13.2</td>
          <td>Cross-platform iOS & Android mobile application with Material 3 Nature theme.</td>
        </tr>
        <tr>
          <td><strong>State Management</strong></td>
          <td>Flutter Riverpod 3.4.3</td>
          <td>Reactive state stores, dependency injection, and cached repositories.</td>
        </tr>
        <tr>
          <td><strong>Cloud Database</strong></td>
          <td>Supabase PostgreSQL</td>
          <td>Append-only event ledger (<code>food_inventory_logs</code>) and GoTrue Auth.</td>
        </tr>
        <tr>
          <td><strong>Real-Time Sync</strong></td>
          <td>Supabase Realtime WebSockets</td>
          <td>Instant push notification and inventory refresh when hardware writes to DB.</td>
        </tr>
        <tr>
          <td><strong>AI Vision Engine</strong></td>
          <td>Google Gemini 1.5 Flash</td>
          <td>Multimodal food identification, quantity estimation, and classification.</td>
        </tr>
        <tr>
          <td><strong>Edge Hardware</strong></td>
          <td>ESP32-S3 CAM Board</td>
          <td>Door switch (IN trigger) & tactile button (OUT trigger) image captures.</td>
        </tr>
      </tbody>
    </table>
  </div>

</div>
</body>
</html>
"""

with open(OUTPUT_HTML, "w", encoding="utf-8") as f:
    f.write(html_content)

print(f"SUCCESS: Generated {OUTPUT_HTML} ({os.path.getsize(OUTPUT_HTML) / 1024.0:.1f} KB)")

