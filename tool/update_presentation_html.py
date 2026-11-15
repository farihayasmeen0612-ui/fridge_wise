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
b64_welcome = get_b64("02_welcome_illustration.png")
b64_register = get_b64("03_login_auth_screen.jpg")
b64_intake_out = get_b64("05_food_intake_in_screen.jpg")
b64_inventory_empty = get_b64("07_fridge_inventory_screen.jpg")
b64_inventory_items = get_b64("09_food_details_screen.png")
b64_details = get_b64("10_food_item_actions.jpg")
b64_profile = get_b64("11_user_profile_screen.jpg")
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
        <img src="{b64_welcome}" alt="Welcome Illustration" style="max-height: 280px; object-fit: contain;">
        <div class="caption">Welcome Illustration</div>
        <div class="sub">Smart fridge cartoon asset for onboarding</div>
      </div>
    </div>
  </div>

  <!-- SLIDE 3: AUTHENTICATION -->
  <div class="card">
    <h2>3. Authentication & User Data Isolation</h2>
    <p>Secure Supabase GoTrue authentication providing scoped data isolation per user.</p>
    <div class="screen-grid">
      <div class="screen-item" style="grid-column: 1 / -1; max-width: 440px; margin: 0 auto;">
        <img src="{b64_register}" alt="Register Screen">
        <div class="caption">Create Account Screen</div>
        <div class="sub">FridgeWise botanical branding, forest green aesthetic & form validation</div>
      </div>
    </div>
    <ul class="features">
      <li><strong>Data Privacy & Multi-Tenancy</strong>: Each registered user starts with a clean, private fridge inventory scoped to their credentials.</li>
      <li><strong>Session Persistence</strong>: Cryptographic JWT session storage with automatic refresh.</li>
    </ul>
  </div>

  <!-- SLIDE 4: FOOD INTAKE & REMOVAL -->
  <div class="card">
    <h2>4. Food Intake / Removal — Human-in-the-Loop Verification</h2>
    <p>Automated capture triggered by ESP32 hardware sensors, verified with one tap by the user.</p>
    <div class="screen-grid">
      <div class="screen-item">
        <img src="{b64_intake_out}" alt="Food Verification Screen">
        <div class="caption">Mobile Verification Screen</div>
        <div class="sub">Visual photo from ESP32, inventory checklist, confirm/dismiss</div>
      </div>
      <div class="screen-item">
        <img src="{b64_hardware}" alt="ESP32 Hardware Photo">
        <div class="caption">Raw ESP32-S3 Camera Capture</div>
        <div class="sub">Captured on door close (IN) or button press (OUT) and uploaded to cloud CDN</div>
      </div>
    </div>
    <ul class="features">
      <li><strong>Asynchronous AI Verification (IN)</strong>: Gemini 1.5 Flash Vision classifies the food item, but the user has final confirmation authority.</li>
      <li><strong>Visual Checklist (OUT)</strong>: User selects which items were physically removed against their tracked inventory.</li>
      <li><strong>Interactive Pinch-to-Zoom</strong>: Tap any photo thumbnail to inspect details in a full-screen viewer.</li>
    </ul>
  </div>

  <!-- SLIDE 5: INVENTORY -->
  <div class="card">
    <h2>5. "My Fridge" Inventory & Multi-Compartment Tracking</h2>
    <p>Multi-compartment organization and dynamic freshness monitoring.</p>
    <div class="screen-grid">
      <div class="screen-item">
        <img src="{b64_inventory_empty}" alt="Empty Inventory">
        <div class="caption">Inventory Screen (Empty State)</div>
        <div class="sub">All Zones, Fridge, Freezer tabs with status filters</div>
      </div>
      <div class="screen-item">
        <img src="{b64_inventory_items}" alt="Inventory with Items">
        <div class="caption">Inventory with Items</div>
        <div class="sub">Color-coded freshness badges and ESP32 thumbnails</div>
      </div>
    </div>
    <ul class="features">
      <li><strong>Multi-Compartment Organization</strong>: Partition groceries across Refrigerator, Freezer, and Deep Fridge zones.</li>
      <li><strong>Color-Coded Freshness</strong>: Clear badges indicate items expiring today, within a week, or already expired.</li>
    </ul>
  </div>

  <!-- SLIDE 6: FOOD DETAILS -->
  <div class="card">
    <h2>6. Food Item Details & Consumption Logging</h2>
    <p>Granular portion consumption and spoilage audit tracking.</p>
    <div class="screen-grid">
      <div class="screen-item" style="grid-column: 1 / -1; max-width: 440px; margin: 0 auto;">
        <img src="{b64_details}" alt="Food Details Screen">
        <div class="caption">Food Item Details</div>
        <div class="sub">Photo zoom, storage info, expiry date, and consumption logging</div>
      </div>
    </div>
    <ul class="features">
      <li><strong>Partial Consumption</strong>: Log specific portions used (e.g. 1 of 4 bananas) with the stepper UI.</li>
      <li><strong>Discard Spoiled</strong>: Track food waste for zero-waste audit analytics.</li>
    </ul>
  </div>

  <!-- SLIDE 7: PROFILE -->
  <div class="card">
    <h2>7. User Profile & Cloud Photo Sync</h2>
    <p>Personalized account management with device camera and cloud storage integration.</p>
    <div class="screen-grid">
      <div class="screen-item" style="grid-column: 1 / -1; max-width: 440px; margin: 0 auto;">
        <img src="{b64_profile}" alt="Profile Screen">
        <div class="caption">User Profile Screen</div>
        <div class="sub">Name, email, phone, profile photo picker, and security options</div>
      </div>
    </div>
    <ul class="features">
      <li><strong>Gallery & Camera Photo Picker</strong>: Upload profile photos directly via device camera or gallery.</li>
      <li><strong>Cloud Sync</strong>: Profile images compressed and stored in Supabase Storage CDN.</li>
      <li><strong>Clean Consumer UI</strong>: Database UUIDs hidden in the latest version for professional aesthetics.</li>
    </ul>
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

