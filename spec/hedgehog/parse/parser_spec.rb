RSpec.describe Hedgehog::Parse::Parser do
  let(:described_instance) { described_class.new(tokens) }

  def t(*token_types)
    token_types.map do |type|
      type_map = {
        word_starting_with_letter: "abc",
        space: " ",
        number: "123",
        word_starting_with_number: "1bc",
        equals: "=",
        single_quote: "'",
        double_quote: "\"",
        backtick: "`",
        pipe: "|",
        end: ""
      }
      Hedgehog::Parse::Token.new(type, type_map[type])
    end
  end

  describe "#parse" do
    let(:tokens) { [] }
    subject { described_instance.parse }

    describe "no end" do
      let(:tokens) { t(:word_starting_with_letter) }

      it "raises an exception" do
        expect { subject }
          .to raise_error("Expected :end at the end of the token list")
      end
    end

    describe "simplest command (e.g. ls)" do
      let(:tokens) { t(:word_starting_with_letter, :end) }

      it "returns the parsed output" do
        subject

        expect(subject.type).to eq(:root)
        expect(subject.children.count).to eq(1)
        expect(subject.children[0].type).to eq(:command)

        expect(subject.structure).to eq({
          root: [ { command: [:argument] } ]
        })
      end
    end

    fdescribe "command with an argument (e.g. git log)" do
      let(:tokens) do
        t(:word_starting_with_letter,
          :word_starting_with_letter,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: [
            { command: [ :argument ] }
          ]
        })
      end
    end

    describe "simple environment variable (e.g. a=hello)" do
      let(:tokens) do
        t(:word_starting_with_letter,
          :equals,
          :word_starting_with_letter,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: [
            { env_var: [ :lhs, :rhs ] }
          ]
        })
      end
    end

    describe "complex environment variable (e.g. a=$(echo hello))" do
      xit "returns the parsed output" do
      end
    end
  end
end
