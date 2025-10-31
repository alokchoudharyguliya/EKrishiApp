#!/usr/bin/env python3
import sys

# Read file content from stdin and write to a file
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 write_files.py <output_file>", file=sys.stderr)
        sys.exit(1)
    
    output_file = sys.argv[1]
    content = sys.stdin.read()
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"File written: {output_file}")

