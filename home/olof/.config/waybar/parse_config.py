import jsonc_parser
import sys

def read_jsonc(jsonc_file):
    with open(jsonc_file, 'r') as file:
        return jsonc_parser.loads(file.read())

data = read_jsonc(sys.argv[1])

value = data.get(sys.argv[2], '')

print(value)
