proc parse_hex {hex_num} {
    puts "Input value: $hex_num"
    # Remove the 0x prefix
    set hex_num [string range $hex_num 2 end]
    # Extract the second byte
    set second_byte [string range $hex_num 2 3]
    # Convert the hex number to binary
    binary scan [binary format H* $hex_num] B* bin_num
    # Extract the seventh bit and invert it
    set inverted_seventh_bit [expr {[string index $bin_num 6] ^ 1}]
    # Extract bits 17-20 and reverse their order 
    set reversed_bits [string reverse [string range $bin_num 16 19]]
    # Print the parameters
    puts "Second byte: $second_byte"
    puts "Inverted seventh bit: $inverted_seventh_bit"
    puts "Reversed 17-20 bits: $reversed_bits"

    return [list $second_byte $inverted_seventh_bit $reversed_bits]
}

puts [parse_hex 0x5FABFF01]
