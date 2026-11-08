import os
import time
from datetime import datetime
from pathlib import Path

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

# ------------------------------------------------------------------
# Paths
# ------------------------------------------------------------------
BASE_DIR = Path(__file__).resolve().parent
RESUME_PATH = BASE_DIR / "Daivik_Awasthi_Resume.pdf"
# Copy of the Chrome profile that is already logged in to Naukri.
# Created by copy_chrome_profile.sh. No credentials are used.
CHROME_USER_DATA = BASE_DIR / "chrome_profile"
CHROME_PROFILE_DIR = os.getenv("CHROME_PROFILE_DIR", "Default")
NAUKRI_PROFILE_URL = "https://www.naukri.com/mnjuser/profile"


def update_naukri():
    if not (CHROME_USER_DATA / "Local State").exists():
        raise RuntimeError(
            "chrome_profile/ not found. Close Chrome and run copy_chrome_profile.sh first."
        )
    if not RESUME_PATH.exists():
        raise RuntimeError(f"Resume not found: {RESUME_PATH}")

    options = Options()
    if os.getenv("HEADLESS") == "1":
        options.add_argument("--headless=new")
    options.add_argument(f"--user-data-dir={CHROME_USER_DATA}")
    options.add_argument(f"--profile-directory={CHROME_PROFILE_DIR}")
    options.add_argument("--window-size=1400,1000")
    # chromedriver defaults to a mock keychain, which cannot decrypt the
    # copied cookies. Let Chrome use the real macOS Keychain.
    options.add_experimental_option("excludeSwitches", ["use-mock-keychain", "password-store"])

    driver = webdriver.Chrome(options=options)

    try:
        print("Navigating to Naukri Profile...")
        driver.get(NAUKRI_PROFILE_URL)

        wait = WebDriverWait(driver, 25)

        # ---------------- SESSION CHECK ----------------
        if "login" in driver.current_url:
            raise RuntimeError(
                "Naukri session expired. Re-run copy_chrome_profile.sh from a "
                "Chrome that is still logged in to Naukri."
            )

        # ---------------- UPLOAD ----------------
        # Naukri Campus profile: a plain file input, and the upload is saved
        # as soon as the file is chosen (no confirm dialogs).
        print("Locating Resume Upload element...")
        upload_input = wait.until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "input.upload-input"))
        )

        print(f"Uploading resume: {RESUME_PATH}")
        upload_input.send_keys(str(RESUME_PATH))

        # Verify: reload and check the profile shows today's upload date
        today = datetime.now()
        expected = f"Uploaded on {today.strftime('%b')} {today.day}, {today.year}"
        time.sleep(5)
        driver.get(NAUKRI_PROFILE_URL)
        wait.until(EC.presence_of_element_located(
            (By.XPATH, f"//*[contains(text(), '{expected}')]")
        ))

        print("✅ Resume updated successfully")

    except Exception as e:
        print(f"❌ Error: {e}")
        driver.save_screenshot(str(BASE_DIR / "error_screenshot.png"))
        print(f"📸 Screenshot saved to {BASE_DIR / 'error_screenshot.png'}")
        raise
    finally:
        driver.quit()


if __name__ == "__main__":
    update_naukri()
