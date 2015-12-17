require 'rails_helper'

include OpenCV

describe Splatoon::AnalyzeKillDeath do
  describe '#kill_death_scene?' do
    context 'when kill death scene' do
      it 'returns true' do
        (1..5).each do |idx|
          af = Splatoon::AnalyzeKillDeath.new(Rails.root.join("spec/data/kd-#{idx}.jpeg").to_s)
          expect(af.kill_death_scene?).to eq(true)
        end
      end
    end
    context 'when not kill death scene' do
      it 'returns false' do
        af = Splatoon::AnalyzeKillDeath.new(Rails.root.join('spec/data/gaming.jpeg').to_s)
        expect(af.kill_death_scene?).to eq(false)
      end
    end
  end

  describe '#kill_death' do
    context 'when kill death scene' do
      it 'returns kill-death' do
        [
          [[7,  8], [ 9, 6], [10,  9], [8, 8], [ 9,  9], [17,  9], [3,  8], [2, 8]],
          [[12, 6], [14, 7], [ 6, 12], [4, 4], [10,  9], [ 5, 10], [9, 10], [5, 7]],
          [[2,  0], [ 5, 1], [ 4,  0], [3, 0], [ 1,  4], [ 0,  4], [0,  3], [0, 3]],
          [[9,  4], [ 8, 8], [ 7,  4], [7, 2], [ 4,  6], [ 1, 11], [6,  5], [6, 9]],
          [[6,  8], [10, 8], [ 8,  5], [8, 7], [10, 11], [ 7, 10], [5,  6], [4, 6]]
        ].each.with_index(1) do |arr, idx|
          af = Splatoon::AnalyzeKillDeath.new(Rails.root.join("spec/data/kd-#{idx}.jpeg").to_s)
          expect(af.kill_death).to eq(arr)
        end
      end
    end
  end

  describe '#number' do
    context 'when kill death scene' do
      it 'returns number' do
        [0, 5, 1, 0, 5].each.with_index(1) do |num, idx|
          af = Splatoon::AnalyzeKillDeath.new(Rails.root.join("spec/data/kd-#{idx}.jpeg").to_s)
          expect(af.number).to eq(num)
          pp [:you, af.kill_death[num]]
        end
      end
    end
  end
end
