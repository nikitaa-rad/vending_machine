require 'spec_helper'

require_relative '../machine_maintainer'

describe MachineMaintainer do
  let(:maintainer) { MachineMaintainer.new }

  describe '#products' do
    let(:result) { maintainer.available_products }

    context 'when products exist' do
      it 'returns available initially products' do
        expect(result).to eq({
          'cola' => 4,
          'sprite' => 3,
          'fanta' => 1,
          'snickers' => 7 })
      end
    end

    context 'when products are absent' do
      before { allow_any_instance_of(MachineMaintainer).to receive(:products).and_return({}) }

      it 'raises RuntimeError' do
        expect { result }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#set_selected_product' do
    let(:result) { maintainer.set_selected_product product }

    context 'when product is in a list of available products' do
      let(:product) { 'fanta' }

      it 'sets selected_product variable' do
        result

        expect(maintainer.selected_product).to eq(product)
      end
    end

    context 'when product is not in a list of available products' do
      let(:product) { 'empire_state_building' }

      it 'raises RuntimeError' do
        expect { result }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#price' do
    let(:result) { maintainer.price }

    before { allow_any_instance_of(MachineMaintainer).to receive(:selected_product).and_return('cola') }

    it 'returns price of selected_product' do
      expect(result).to eq(2)
    end
  end

  describe '#sell' do
    let(:result) { maintainer.sell }

    before do
      allow_any_instance_of(MachineMaintainer).to receive(:selected_product).and_return('fanta')
      allow_any_instance_of(MachineMaintainer).to receive(:cash_buffer).and_return({ '2' => 1})
    end

    context 'with change' do
      context 'when change can be returned' do
        it 'returns change' do
          expect(result).to eq(['0.25'])
        end
      end

      context 'when change cannot be returned' do
        before { allow_any_instance_of(MachineMaintainer).to receive(:all_available_coins).and_return({ '2' => 1 }) }

        it 'raises RuntimeError' do
          expect { result }.to raise_error(RuntimeError)
        end
      end
    end

    context 'with product' do
      context 'with last product' do
        it 'deletes product if it was the last one' do
          expect { result }.to change { maintainer.products['fanta'] }.from(1).to(nil)
        end
      end

      context 'with not last product' do
        before { allow_any_instance_of(MachineMaintainer).to receive(:selected_product).and_return('snickers') }

        it 'reduces product count' do
          expect { result }.to change { maintainer.products['snickers'] }.by(-1)
        end
      end
    end

    context 'with cashbox' do
      it 'stores purchased money' do
        expect { result }.to change { maintainer.cashbox['2'] }.by(1)
      end
    end
  end
end
