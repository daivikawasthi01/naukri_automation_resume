# naukri_automation_resume

Re-uploads your resume to your Naukri profile so it shows as recently updated.
It reuses a copy of your logged-in Chrome profile, so no email or password is stored anywhere.

Works on macOS with Google Chrome.

## Requirements
- macOS
- Google Chrome, logged in to Naukri
- Python 3.8 or newer

## Setup
1. Clone and enter the repo:

       git clone https://github.com/daivikawasthi01/naukri_automation_resume.git
       cd naukri_automation_resume

2. Install dependencies:

       python3 -m venv venv
       ./venv/bin/pip install -r requirements.txt

3. Put your resume PDF in the project folder as `Daivik_Awasthi_Resume.pdf`.
   To use another file name, change `RESUME_PATH` in `naukri.py`.

4. Log in to https://www.naukri.com in Chrome, then copy that session:

       ./copy_chrome_profile.sh

   - Chrome is open: `FORCE=1 ./copy_chrome_profile.sh`
   - Chrome profile other than the default: `export CHROME_PROFILE_DIR="Profile 1"` first
     (the folder name under `~/Library/Application Support/Google/Chrome`), then run the line above.

   This creates `chrome_profile/` in the project folder.

5. Run it:

       ./venv/bin/python naukri.py

   Success prints `Resume updated successfully`. Set `HEADLESS=1` to run without a visible window.
   On failure it saves `error_screenshot.png` to help debugging.

## Run it every day
`run_naukri.sh` refreshes the session copy from Chrome, runs the script and appends to `naukri_log.txt`.

    crontab -e

Add (change the path and time):

    30 9 * * * /full/path/to/naukri_automation_resume/run_naukri.sh

Cron needs permission to run on macOS: System Settings > Privacy & Security > Full Disk Access, add `/usr/sbin/cron`.
The Mac must be awake at the scheduled time.

## Troubleshooting
- **"Naukri session expired"**: log in to Naukri in Chrome again, then re-run step 4.
- **"chrome_profile/ not found"**: run step 4.
- **"Resume not found"**: check the file name in step 3.
- **Keychain prompt on first run**: allow it. Chrome needs the Keychain to read the copied cookies.

## Privacy
`chrome_profile/` holds your login cookies. It, your resume and the logs are git-ignored. Never commit them.
