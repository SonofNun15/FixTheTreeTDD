require 'rspec'
require 'trees/tree'
require 'trees/apple_tree'
require 'trees/fruit'
require 'trees/apple'
require 'trees/tree_report'
require 'trees/history/tree_data'
require 'trees/history/apple_tree_data'
require 'trees/history/tree_history'

describe Tree do
  context "Tree with history" do
    let(:tree_details) { [1, 2, 4, 6, 7].map { |height| TreeData.new(height) } }
    let(:history) { TreeHistory.new(tree_details) }
    let(:tree) { Tree.new(history) }

    it "should live 5 years" do
      expect(tree.dead?).to eq false
      expect(tree.age).to eq 0

      (tree_details.length + 1).times { tree.age! }
      expect(tree.dead?).to eq true
    end

    it "should change height each year" do
      # Tree starts at height 0, age 0
      expect(tree.height).to eq 0

      tree_details.each do |year|
        tree.age!
        expect(tree.height).to eq year.height
      end
    end
  end
end

describe AppleTree do
  let(:first_harvest) { [2, 1, 2, 3, 3] }
  let(:tree_details) do
    TreeHistory.new([
      AppleTreeData.new(1),
      AppleTreeData.new(3),
      AppleTreeData.new(4),
      AppleTreeData.new(5, first_harvest),
      AppleTreeData.new(6, ([2] * 12) + ([3] * 10) + ([4] * 6)),
      AppleTreeData.new(7, ([2] * 19) + ([3] * 38) + ([4] * 43) + ([5] * 34) + ([6] * 23) + ([7] * 3)),
    ])
  end
  let(:apple_tree) { AppleTree.new("red", tree_details) }

  it 'should be a Tree' do
    expect(apple_tree.is_a? Tree).to eq true
  end

  it 'should bear fruit after aging' do
    4.times { apple_tree.age! }
    expect(apple_tree.apples.length).to eq 5

    first_harvest.each do |apple_spec|
      expect(apple_tree.any_apples?).to eq true
      picked_apple = apple_tree.pick_an_apple!
      expect(picked_apple.color).to eq "red"
      expect(picked_apple.diameter).to eq apple_spec
    end

    expect(apple_tree.any_apples?).to eq false

    apple_tree.age!

    expect(apple_tree.any_apples?).to eq true
    expect(apple_tree.apples.length).to eq 28

    apple_tree.age!

    expect(apple_tree.any_apples?).to eq true
    expect(apple_tree.apples.length).to eq 188
  end
end

describe Fruit do
  let(:fruit) { Fruit.new }

  it 'should have seeds' do
    expect(fruit.has_seeds).to eq true
  end
end

describe Apple do
  let(:apple) { Apple.new('red', 3) }

  it 'should be a Fruit' do
    expect(apple.is_a? Fruit).to eq true
  end

  it 'should have a color' do
    expect(apple.color).to eq 'red'
  end

  it 'should have a diameter' do
    expect(apple.diameter).to eq 3
  end
end

describe "tree_data" do
  let(:utils) { Utils.new }
  let(:tree_details) do
    TreeHistory.new([
      AppleTreeData.new(1, []),
      AppleTreeData.new(3, []),
      AppleTreeData.new(4, []),
      AppleTreeData.new(5, [2, 1, 2, 3, 3]),
      AppleTreeData.new(6, ([2] * 12) + ([3] * 10) + ([4] * 6)),
      AppleTreeData.new(7, ([2] * 19) + ([3] * 38) + ([4] * 43) + ([5] * 34) + ([6] * 23) + ([7] * 3)),
    ])
  end

  it "should describe the life of a tree" do
    lines = utils.tree_data(tree_details)

    expected_report = <<-end
Tree is 4 years old and 5 feet tall
Year 4 Report
Tree height: 5 feet
Harvest:     5 apples with an average diameter of 2.2 inches

Year 5 Report
Tree height: 6 feet
Harvest:     28 apples with an average diameter of 2.79 inches

Year 6 Report
Tree height: 7 feet
Harvest:     160 apples with an average diameter of 4.08 inches

Alas, the tree, she is dead!
end

    expected_lines = expected_report.split("\n")

    # Compare expected report to actual lines
    lines.each_with_index do |line, index|
      expect(line).to eq expected_lines[index]
    end
  end
end

