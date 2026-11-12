"""Run every v0.3 verifier in a fresh interpreter; fail on the first nonzero exit or missing PASS line."""
import subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
SCRIPTS = (
    "verify_z7_lorentz_extension_v0_1.py",
    "verify_suture_basis_change_v0_2.py",
    "verify_suture_field_v0_2.py",
    "verify_magnetic_cap_v0_1.py",
    "verify_suture_image_v0_1.py",
    "verify_mirror_bundle_v0_1.py",
    "verify_chsh_root_v0_1.py",
    "verify_suture_field_dynamics_v0_3.py",
)
for name in SCRIPTS:
    r = subprocess.run([sys.executable, name], cwd=HERE, capture_output=True, text=True)
    ok = r.returncode == 0 and "PASS" in r.stdout
    print(("PASS  " if ok else "FAIL  ") + name)
    if not ok:
        print(r.stdout[-1500:], r.stderr[-1500:])
        sys.exit(1)
print(f"ALL {len(SCRIPTS)} VERIFIERS PASS")
