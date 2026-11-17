import os
import re

vietnamese_re = re.compile(r'[\u00C0-\u024F\u1EA0-\u1EF9]')
# Matches single or double quoted strings
string_re = re.compile(r"""(?:'([^'\\]*(?:\\.[^'\\]*)*)'|"([^"\\]*(?:\\.[^"\\]*)*)")""")

findings = []

for root, dirs, files in os.walk('lib'):
    for f in files:
        if f.endswith('.dart') and f != 'app_strings.dart':
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8', errors='ignore') as fp:
                for line_no, line in enumerate(fp, start=1):
                    # Skip full comments
                    trimmed = line.strip()
                    if trimmed.startswith('//') or trimmed.startswith('/*') or trimmed.startswith('*'):
                        continue
                    for match in string_re.finditer(line):
                        content = match.group(1) or match.group(2) or ''
                        if vietnamese_re.search(content):
                            findings.append((path, line_no, content, line.strip()))

print(f"Total hardcoded Vietnamese strings outside app_strings.dart: {len(findings)}")
for path, line_no, content, raw in findings:
    print(f"{path}:{line_no} -> {content}")
