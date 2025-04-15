require 'bitcoin'
require 'digest'
require 'base58'

def address_type(address)
  case address[0]
  when '1', 'm', 'n' then :P2PKH
  when '3', '2'      then :P2SH
  when 'b'           then address.start_with?('bc1') ? [:P2WPKH,:P2WSH] : 'Unknown'
  when 't'           then address.start_with?('tb1') ? [:Bech32] : 'Unknown'
  else                    'Unknown'
  end
end

# puts address_type("mi1HqBemjjE4DqM5fd94F5Nw2FhChmxs5C") # P2PKH
# puts address_type("3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy") # P2SH
# puts address_type("bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4") # P2WPKH