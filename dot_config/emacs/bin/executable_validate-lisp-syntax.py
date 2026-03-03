import sys

def check_elisp_parens(filename):
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"❌ Error: File '{filename}' not found.")
        return False

    stack = []  # Stores (line, column) of open parentheses
    in_string = False
    escape_next = False

    print(f"🔍 Analyzing: {filename} ...")

    for i, line in enumerate(lines):
        line_num = i + 1

        for j, char in enumerate(line):
            col_num = j + 1

            # 1. If previous char was backslash, skip this one
            if escape_next:
                escape_next = False
                continue

            # 2. Logic inside Strings
            if in_string:
                if char == '\\':
                    escape_next = True
                elif char == '"':
                    in_string = False
                continue

            # 3. Logic outside Strings (Normal Mode)
            if char == '\\':
                escape_next = True
                continue

            if char == ';':
                # Comment: ignore the rest of the line
                break

            if char == '"':
                in_string = True
                continue

            # Parentheses check
            if char == '(':
                stack.append((line_num, col_num))
            elif char == ')':
                if not stack:
                    print(f"❌ Critical Error: Extra closing parenthesis ')' found.")
                    print(f"   Location: Line {line_num}, Column {col_num}")
                    return False
                stack.pop()

    # 4. Final Check
    if in_string:
        print("❌ Error: A string was opened but not closed (missing closing quotes).")
        return False
    elif stack:
        count = len(stack)
        last_open_line, last_open_col = stack[-1]
        print(f"❌ Balance Error: Missing {count} closing parenthesis/parentheses ')'.")
        print(f"👉 The last unclosed open parenthesis is at: Line {last_open_line}, Column {last_open_col}")
        return False
    else:
        print(f"✅ Success: All parentheses in {filename} are balanced correctly!")
        return True

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python validate-lisp-syntax.py <file1.el> <file2.el> ...")
        sys.exit(1)
    
    overall_success = True
    for file_path in sys.argv[1:]:
        if not check_elisp_parens(file_path):
            overall_success = False
            print("-" * 40)
    
    if not overall_success:
        sys.exit(1)
