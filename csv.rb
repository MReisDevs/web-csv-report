require "csv"

def run_csv_processor

accounts = {}


CSV.foreach("accounts.csv", {headers: true, return_headers: false}) do |row|

  # Add a key for each account to the accounts Hash.
  account = row["Account"].chomp

  if !accounts[account]
    accounts[account] = {
      tally: 0.00,
      categories: {
      }
    }
  end

  # Set the account which is being affected by this iteration.
  current_account = accounts[account]

  # Clean up outflow and inflow.
  outflow = row["Outflow"].gsub(/[,\$]/, "").to_f.round(2)
  inflow = row["Inflow"].gsub(/[,\$]/, "").to_f.round(2)
  transaction_amount = inflow - outflow

  # Keep a tally for current balance of the account.
  current_account[:tally] += transaction_amount

  category = row["Category"].chomp

  # Initialize category.
  if !current_account[:categories][category]
    current_account[:categories][category] = {
      tally: 0.00,
      num_transactions: 0,
      average_transaction_cost: 0.00
    }
  end

  # Tally category.
  current_account[:categories][category][:tally] += transaction_amount

  # Increment transaction counter.
  current_account[:categories][category][:num_transactions] += 1

  # Update average transaction cost.
  current_account[:categories][category][:average_transaction_cost] = current_account[:categories][category][:tally] / current_account[:categories][category][:num_transactions] 
end

return accounts

end

# Display
#   accounts.each do |name, info|
#     puts “\n”
#     puts “======================================================================”
#     puts “Account: #{name}... Balance: $#{info[:tally].round(2)}”
#     puts “======================================================================”
#     puts “Category                     | Total Spent | Average Transaction”
#     puts “---------------------------- | ----------- | -------------------------”
#     info[:categories].each do |category, c_info|
#       print “#{category.ljust(28)} | $#{c_info[:tally].round(2).to_s.ljust(10)} | $#{c_info[:average_transaction_cost].round(2).to_s.ljust(20)}\n”
#     end
#     puts “\n”
#   end