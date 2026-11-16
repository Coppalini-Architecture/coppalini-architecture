#!/usr/bin/env python3
"""Expected-failure controls for the shared 010s CI guard."""
import hashlib
import tempfile
from pathlib import Path
import unittest
import verify_lean_010s as guard

class GuardTests(unittest.TestCase):
    def test_nested_comments(self):
        self.assertNotIn('sorry', guard.uncomment('x /- sorry /- admit -/ axiom -/ y -- sorry\nz'))
    def test_forbidden_code(self):
        for token in ('sorry', 'admit', 'axiom', 'native_decide', 'Lean.ofReduceBool', 'unsafe'):
            with self.subTest(token=token), tempfile.TemporaryDirectory() as d:
                p=Path(d)/'x.lean'; p.write_text(token)
                with self.assertRaises(ValueError):guard.verify_sources([str(p)])
    def test_comments_only(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'x.lean';p.write_text('-- sorry\n/- admit -/\ntheorem x : True := trivial\n')
            self.assertEqual(1,guard.verify_sources([str(p)]))
    def test_missing_log(self):
        with tempfile.TemporaryDirectory() as d:
            with self.assertRaises(ValueError):guard.verify_logs([str(Path(d)/'missing.log')])
    def test_foreign_axiom(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'x.log';p.write_text("'x' depends on axioms: [propext, foreign_axiom]\n")
            with self.assertRaises(ValueError):guard.verify_logs([str(p)])
    def test_allowed_axioms(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'x.log';p.write_text("'x' depends on axioms: [propext, Classical.choice, Quot.sound]\n")
            self.assertEqual(1,guard.verify_logs([str(p)]))
    def test_missing_checksum(self):
        with tempfile.TemporaryDirectory() as d:
            registry=Path(d)/'SHA256SUMS';registry.write_text('')
            with self.assertRaises(ValueError):guard.verify_hashes(str(registry),['missing'])
    def test_wrong_checksum(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'x';p.write_text('ABC')
            registry=Path(d)/'SHA256SUMS'
            registry.write_text('0'*64+'  '+str(p)+'\n')
            with self.assertRaises(ValueError):guard.verify_hashes(str(registry),[str(p)])
    def test_hash_success(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'x';p.write_text('ABC')
            registry=Path(d)/'SHA256SUMS'
            registry.write_text(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+str(p)+'\n')
            self.assertEqual(1,guard.verify_hashes(str(registry),[str(p)]))
    def test_duplicate_checksum(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'x';p.write_text('ABC')
            line=hashlib.sha256(p.read_bytes()).hexdigest()+'  '+str(p)+'\n'
            registry=Path(d)/'SHA256SUMS';registry.write_text(line+line)
            with self.assertRaises(ValueError):guard.verify_hashes(str(registry),[str(p)])

if __name__=='__main__':unittest.main()
