"""Regression for Python/JavaScript reader-label blankness only."""
import importlib.util
import json
from pathlib import Path
import subprocess
from fractions import Fraction

ROOT = Path(__file__).resolve().parent
SOURCE = ROOT.parent / "sources"


def load(name):
    spec = importlib.util.spec_from_file_location(name, SOURCE / (name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def run():
    # Pin the class to the executing Python's actual str.strip() semantics.
    whitespace = [chr(i) for i in range(0x110000) if not chr(i).strip()]
    declared = [chr(i) for i in (
        list(range(0x0009, 0x000E)) + list(range(0x001C, 0x0021))
        + [0x0085, 0x00A0, 0x1680] + list(range(0x2000, 0x200B))
        + [0x2028, 0x2029, 0x202F, 0x205F, 0x3000]
    )]
    assert whitespace == declared
    labels = whitespace + [
        '', ''.join(whitespace), ' \t\r\n', '\ufeff', '\u180e', '\u200b',
        '\x00', '\x08', '\x0e', '\x1b', 'A', 'reader-01',
        ' \treader-01\u0085', '\u0085reader\u001c', 'reader\ufeff',
    ]
    harmonizer = load('harmonizer')
    relax = load('relax_receipt')
    cases = []
    for name, module, cli, factory in (
        ('harmonizer', harmonizer, 'harm_cli.js',
         lambda: harmonizer.make_receipt(0, '1', '0', '0', 'reader')),
        ('relax', relax, 'relax_cli.js',
         lambda: relax.make_receipt(0, 0, Fraction(1, 4), 3, 'reader')),
    ):
        receipts = []
        expected = []
        for label in labels:
            receipt = factory()
            receipt['reader']['label'] = label
            py_result = module.check(receipt)
            assert py_result == ('INVALID' if not label.strip() else 'OK')
            receipts.append(receipt)
            expected.append(py_result)
        commands = '\n'.join(json.dumps({'op': 'check', 'text': json.dumps(r)}) for r in receipts)
        completed = subprocess.run(['node', str(ROOT / cli)], input=commands,
                                   text=True, capture_output=True, check=True)
        actual = json.loads(completed.stdout)
        assert len(actual) == len(expected)
        for label, py_result, js_result in zip(labels, expected, actual):
            case = {'module': name, 'label_codepoints': ['U+%04X' % ord(c) for c in label],
                    'python': py_result, 'javascript': js_result, 'matched': py_result == js_result}
            cases.append(case)
            assert case['matched'], case
    return {'status': 'PASS', 'python_whitespace_codepoints': ['U+%04X' % ord(c) for c in whitespace],
            'case_count': len(cases), 'cases': cases}


if __name__ == '__main__':
    print(json.dumps(run(), indent=2))
