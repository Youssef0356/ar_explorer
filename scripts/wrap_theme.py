import os
import glob

files_to_check = glob.glob('lib/screens/*game*.dart') + glob.glob('lib/screens/*challenge*.dart')

for filepath in files_to_check:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'ThemeData.dark()' in content:
        continue # Already wrapped

    out = []
    i = 0
    modified = False
    
    while i < len(content):
        # Look for "return Scaffold("
        idx = content.find('return Scaffold(', i)
        if idx == -1:
            out.append(content[i:])
            break
            
        # Append everything up to the 'S' in Scaffold
        scaffold_idx = idx + 7 # 'return '
        out.append(content[i:scaffold_idx])
        out.append('Theme(data: ThemeData.dark(), child: ')
        
        # Now we parse from 'S' manually to find matching ')' for Scaffold(...)
        paren_count = 0
        in_string = False
        in_char = False
        escape = False
        
        j = scaffold_idx
        started = False
        
        while j < len(content):
            c = content[j]
            out.append(c)
            
            if in_string:
                if c == '\\':
                    escape = not escape
                elif c == '"' and not escape:
                    in_string = False
                elif escape:
                    escape = False
            elif in_char:
                if c == '\\':
                    escape = not escape
                elif c == "'" and not escape:
                    in_char = False
                elif escape:
                    escape = False
            else:
                if c == '"':
                    in_string = True
                elif c == "'":
                    in_char = True
                elif c == '(':
                    paren_count += 1
                    started = True
                elif c == ')':
                    paren_count -= 1
                    if started and paren_count == 0:
                        out.append(')') # Close the Theme widget
                        modified = True
                        j += 1
                        break
            j += 1
            
        i = j

    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write("".join(out))
        print(f"Updated {filepath}")
