# frozen_string_literal: true

# Custom FactoryBot strategy to build json representation of factory model
class JsonStrategy
  # initialize FactoryBot::FactoryRunner to send 'run' message to
  def initialize
    @strategy = FactoryBot.strategy_by_name(:build).new
  end

  # Send 'run' message to runner
  def association
    @strategy.run
  end

  # receives FactoryBot::Evaluation instance and let's runner evaluate the result
  def result(evaluation)
    @strategy.result(evaluation).to_json
  end

  def to_sym
    :json
  end
end
