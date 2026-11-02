import os
import re

files = []
for root, _, fs in os.walk('lib'):
    for f in fs:
        if f.endswith('.dart'):
            files.append(os.path.join(root, f))

patterns = {
    'customer@furni3d.vn': r'customer@furni3d\.vn',
    '0983 838 311': r'0983\s*838\s*311',
    'Dang Thao Vy': r'Đặng Thảo Vy',
    'Landmark 81': r'Landmark 81',
    'getInitialUser': r'getInitialUser',
    'getMockOrders': r'getMockOrders',
    'hardcoded default avatar': r'https://images\.unsplash\.com/photo-1534528741775',
}

print('=== SCANNING LIB FOR HARDCODED VALUES ===')
for label, p in patterns.items():
    print(f'\nScanning for: {label}')
    count = 0
    for fp in sorted(files):
        with open(fp, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        for idx, line in enumerate(lines):
            if re.search(p, line):
                count += 1
                clean_line = line.strip()[:100]
                # print without unicode failure
                safe_line = clean_line.encode('ascii', 'replace').decode('ascii')
                print(f'  {fp}:{idx+1} -> {safe_line}')
    if count == 0:
        print('  None found.')
