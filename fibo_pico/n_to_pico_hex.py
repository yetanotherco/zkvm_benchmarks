def decimal_to_hex_input(n):
    hex_str = f"{n:08x}"          # Pad to 8 hex characters
    le_bytes = bytes.fromhex(hex_str)[::-1]  # Reverse for little-endian
    return "0x" + le_bytes.hex().upper()

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) != 2:
        print("Usage: python n_to_pico_hex.py <number>")
        sys.exit(1)
    
    try:
        n = int(sys.argv[1])
        print(decimal_to_hex_input(n))
    except ValueError:
        print("Error: Please provide a valid integer")
        sys.exit(1)
