require 'rails_helper'

describe Splatoon::AnalyzeGameResult do
  describe '#game_result' do
    context 'win' do
      it 'returns win' do
        af = Splatoon::AnalyzeGameResult.new(Rails.root.join('spec/data/win-sample.jpeg').to_s)
        expect(af.game_result[:game_result]).to eq(:win)
      end
    end

    context 'lose' do
      it 'returns lose' do
        af = Splatoon::AnalyzeGameResult.new(Rails.root.join('spec/data/lose-sample.jpeg').to_s)
        expect(af.game_result[:game_result]).to eq(:lose)
      end
    end
  end
end
