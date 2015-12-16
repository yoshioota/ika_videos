require 'rails_helper'

describe Splatoon::AnalyzeRuleAndStage do
  describe '#rule' do
    context 'yaugra' do
      it 'returns yaugra' do
        af = Splatoon::AnalyzeRuleAndStage.new(Rails.root.join('spec/data/kinme-yagura.jpeg').to_s)
        expect(af.rule[:rule_name]).to eq(:yagura)
      end
    end
  end

  describe '#stage' do
    context 'kinmedai' do
      it 'returns :kinmedai' do
        af = Splatoon::AnalyzeRuleAndStage.new(Rails.root.join('spec/data/kinme-yagura.jpeg').to_s)
        expect(af.stage[:stage_name]).to eq(:kinmedai)
      end
    end
  end
end
