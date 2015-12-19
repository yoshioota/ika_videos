require 'rails_helper'

describe Splatoon::AnalyzeRuleAndStage do
  describe '#rule' do
    context 'yaugra' do
      it 'returns yaugra' do
        image = OpenCV::IplImage.load(Rails.root.join('spec/data/kinme-yagura.jpeg').to_s, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
        af = Splatoon::AnalyzeRuleAndStage.new(image)
        expect(af.rule[:rule_name]).to eq(:yagura)
      end
    end
  end

  describe '#stage' do
    context 'kinmedai' do
      it 'returns :kinmedai' do
        image = OpenCV::IplImage.load(Rails.root.join('spec/data/kinme-yagura.jpeg').to_s, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
        af = Splatoon::AnalyzeRuleAndStage.new(image)
        expect(af.stage[:stage_name]).to eq(:kinmedai)
      end
    end
  end
end
