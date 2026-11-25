"""O-Q4 callable adapter for the published RELAX-RECEIPT-001 checker.

check_relax_receipt(receipt) returns OK, OK_WITH_DELTA, or INVALID.
This module performs no ledger append and no clock or mirror operation.
The owning ledger can register SCHEMA with this callable.
"""
import importlib.util
from pathlib import Path

_path = Path(__file__).resolve().with_name("relax_receipt.py")
_spec = importlib.util.spec_from_file_location("_moonlight_relax_receipt", _path)
_module = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_module)
SCHEMA = _module.SCHEMA
check_relax_receipt = _module.check
