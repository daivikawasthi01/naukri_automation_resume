# naukri_automation_resume

Re-uploads your resume to your Naukri profile so it shows as recently updated.
Uses a copy of your logged-in Chrome profile, so no password is stored.

## Setup (macOS)
1. `python3 -m venv venv && ./venv/bin/pip install -r requirements.txt`
2. Put your resume in the project folder as `Daivik_Awasthi_Resume.pdf` (edit `RESUME_PATH` in `naukri.py` to change it).
3. Log in to Naukri in Chrome, then copy that profile:
   - Chrome closed: `./copy_chrome_profile.sh`
   - Chrome open: `FORCE=1 ./copy_chrome_profile.sh`
   - Another profile: pass its folder name, for example `./copy_chrome_profile.sh "Profile 1"`, and set `CHROME_PROFILE_DIR` to match.
4. Run it: `./venv/bin/python naukri.py`

If the session expires, the script says so. Re-run step 3.

## Schedule
`crontab -e`, then add (path and time of your choice):

    30 9 * * * /path/to/naukri_automation_resume/run_naukri.sh

`chrome_profile/`, the resume and `.env` are git-ignored. Never commit them.
