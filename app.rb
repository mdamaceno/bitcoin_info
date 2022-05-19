require 'httparty'
require 'thor'
require 'date'

MEMPOOL_BASE_URL = 'https://mempool.space/api'
BTC_BASE = 100000000

class MyCLI < Thor
  desc "info ADDRESS", "Get info for an address"
  option :t
  def info(address)
    address_info_response = HTTParty.get("#{MEMPOOL_BASE_URL}/address/#{address}")
    address_info_body = JSON.parse(address_info_response.body)
    received = address_info_body["chain_stats"]["funded_txo_sum"].to_f
    spent = address_info_body["chain_stats"]["spent_txo_sum"].to_f
    total = received - spent

    puts "Address:        #{address_info_body["address"]}"
    puts "Transactions:   #{address_info_body["chain_stats"]["tx_count"]}"
    puts "Total Received: #{received / BTC_BASE}"
    puts "Total Spent:    #{spent / BTC_BASE}"
    puts "Final Balance:  #{total / BTC_BASE}"

    if options[:t]
      puts
      puts "========== Transactions =========="
      transactions_response = HTTParty.get("#{MEMPOOL_BASE_URL}/address/#{address}/txs")
      transactions_body = JSON.parse(transactions_response.body)
      transactions_body.each do |tx|
        puts "TxID: #{tx["txid"]}"
        puts "Block Height: #{tx["status"]["block_height"]}"
        puts "Datetime: #{Time.at(tx["status"]["block_time"]).to_datetime}"
        puts '---'
      end
    end
  end
end

MyCLI.start(ARGV)
