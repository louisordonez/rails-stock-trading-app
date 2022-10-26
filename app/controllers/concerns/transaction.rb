module Transaction
  module Wallet
    def self.deposit(wallet, total_amount)
      transaction =
        wallet.wallet_transactions.create(
          action_type: 'deposit',
          total_amount: total_amount
        )
      wallet.update(balance: wallet.balance + total_amount)
      {
        wallet: wallet,
        transaction: transaction,
        message: "Deposited $#{total_amount} to your account."
      }
    end

    def self.withdraw(wallet, total_amount)
      transaction =
        wallet.wallet_transactions.create(
          action_type: 'withdrawal',
          total_amount: total_amount
        )
      wallet.update(balance: wallet.balance - total_amount)
      {
        wallet: wallet,
        transaction: transaction,
        message: "Withdrawn $#{total_amount} to your account."
      }
    end
  end

  module Stock
    def self.buy(wallet, portfolios, hash)
      portfolio = portfolios.find_by(stock_symbol: hash[:symbol])
      portfolio =
        Portfolio.create(
          stock_name: hash[:quote].company_name,
          stock_symbol: hash[:symbol]
        ) if !portfolio
      transaction =
        StockTransaction.create(
          action_type: 'buy',
          stock_symbol: hash[:symbol],
          stock_name: hash[:quote].company_name,
          stock_quantity: hash[:quantity],
          stock_price: hash[:price],
          total_amount: hash[:total],
          user: wallet.user,
          portfolio: portfolio
        )
      portfolio.update(
        stocks_owned_quantity: portfolio.stocks_owned_quantity + hash[:quantity]
      )
      wallet.update(balance: wallet.balance - hash[:total])
      return(
        {
          wallet: wallet,
          portfolio: portfolio,
          transaction: transaction,
          message:
            "You have purchased #{hash[:quantity]} #{hash[:symbol]} stocks worth $#{hash[:total]} at $#{hash[:price]}/stock."
        }
      )
    end

    def self.sell(wallet, portfolio, hash)
      transaction =
        StockTransaction.create(
          action_type: 'sell',
          stock_symbol: hash[:symbol],
          stock_name: portfolio.stock_name,
          stock_quantity: hash[:quantity],
          stock_price: hash[:price],
          total_amount: hash[:total],
          user: wallet.user,
          portfolio: portfolio
        )
      portfolio.update(
        stocks_owned_quantity: portfolio.stocks_owned_quantity - hash[:quantity]
      )
      wallet.update(balance: wallet.balance + hash[:total])
      return(
        {
          wallet: wallet,
          portfolio: portfolio,
          transaction: transaction,
          message:
            "You have sold #{hash[:quantity]} #{hash[:symbol]} stocks worth $#{hash[:total]} at $#{hash[:price]}/stock."
        }
      )
    end
  end
end
