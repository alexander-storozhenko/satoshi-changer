require 'httparty'
require 'bitcoin'

Bitcoin::NETWORKS[:signet] = {
  project: :bitcoin,
  magic_head: "\x66\x66\x66\x66",
  address_version: "6f",
  p2sh_version: "c4",
  bech32_hrp: "tb",
  privkey_version: "ef",
}

Bitcoin.network = :signet

def to_satoshis(value)
  (value * 100_000_000).round.to_i
end

def get_utxo_details(address)
  utxos = HTTParty.get("https://mempool.space/signet/api/address/#{address}/utxo").parsed_response
  utxos.map do |utxo|
    tx = HTTParty.get("https://mempool.space/signet/api/tx/#{utxo['txid']}").parsed_response
    {
      txid: utxo['txid'],
      vout: utxo['vout'],
      value: (utxo['value']).to_i,
      script_pubkey: tx['vout'][utxo['vout']]['scriptpubkey']
    }
  end
end



def create_signet_tx(recipient_address, send_amount)
  send_amount = to_satoshis send_amount

  sender_address = ENV['SENDER_ADDRESS'] || 'mvpip5o5aM8kfjF9zga4MC4GVqx4nMbJUY'
  private_key = ENV['PRIVATE_KEY'] || 'cPZzpePWADM1DBj81zb6bBkbHzA1YxFCJfq499Pnrh2XvXZbbDZE'

  utxos = get_utxo_details(sender_address).sort_by { |u| -u[:value] }
  raise "No UTXOs available" if utxos.empty?

  key = Bitcoin::Key.from_base58(private_key)

  estimated_fee = send_amount * 0.1 # 1_000
  dust_threshold = 546

  selected_utxos = []
  total_input = 0

  utxos.each do |utxo|
    selected_utxos << utxo
    total_input += utxo[:value]
  end

  raise "Insufficient funds" if total_input < send_amount + estimated_fee

  new_tx = Bitcoin::Protocol::Tx.new

  selected_utxos.each do |utxo|
    new_tx.add_in(
      Bitcoin::Protocol::TxIn.new(
        [utxo[:txid]].pack("H*").reverse,
        utxo[:vout]
      )
    )
  end

  case address_type(recipient_address)
  when :P2SH
    script = Bitcoin::Script.to_p2sh_script(Bitcoin.decode_base58(recipient_address)[1..-5])
    new_tx.add_out(Bitcoin::Protocol::TxOut.new(send_amount, script))
  else # P2PKH
    new_tx.add_out(Bitcoin::Protocol::TxOut.value_to_address(send_amount, recipient_address))
  end

  change_amount = total_input - send_amount - estimated_fee

  if change_amount >= dust_threshold
    new_tx.add_out(Bitcoin::Protocol::TxOut.value_to_address(change_amount.to_i, key.addr))
  end

  selected_utxos.each_with_index do |utxo, index|
    script_pubkey = Bitcoin::Script.to_address_script(sender_address)
    sighash = new_tx.signature_hash_for_input(index, script_pubkey)

    sig_der = key.sign(sighash)
    sig_with_sighash = sig_der

    pubkey = [key.pub].pack("H*")

    new_tx.in[index].script_sig = Bitcoin::Script.to_signature_pubkey_script(sig_with_sighash, pubkey)
  end

  puts "Transaction Details:"
  puts "Inputs: #{selected_utxos.size} (Total: #{total_input} satoshis)"
  puts "Send: #{send_amount} satoshis to #{recipient_address}"
  puts "Change: #{change_amount} satoshis" if change_amount >= dust_threshold
  puts "Fee: #{estimated_fee} satoshis"

  hex_tx = new_tx.to_payload.unpack1('H*')

  response = HTTParty.post(
    "https://mempool.space/signet/api/tx",
    body: hex_tx,
    headers: { 'Content-Type' => 'text/plain' }
  )
  puts "Broadcast Response: #{response.body}"

  {txid: response.body}
rescue => e
  puts "Error: #{e.message}"
  {err: e.message}
end