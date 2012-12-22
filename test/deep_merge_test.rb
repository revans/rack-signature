require_relative '../lib/rack/signature/deep_merge'
require_relative 'test_helper'

module Rack::Signature
  describe DeepMerge do
    include TestHelper

    it 'will merge a sorted hash into a string' do
      DeepMerge.new(sorted_nested_hash).merge!.must_equal sorted_nested_string
    end

    it 'will merge a sorted hash into a string when the hash is a simple hash' do
      expected = "age=22&name=john"
      DeepMerge.new({'age' => 22, 'name' => 'john'}).merge!.must_equal expected
    end

    it 'will merge a simple nested hash into a string' do
      expected = "age=22&person[name]=john"
      DeepMerge.new({'age' => 22, 'person' => {'name' => 'john'}}).merge!.must_equal expected
    end

    it 'will merge a hash that has a single nested hash, but with multiple values' do
      expected = "age=22&person[first_name]=john&person[last_name]=smith"
      DeepMerge.new({'age' => 22, 'person' => {'first_name' => 'john', 'last_name' => 'smith'}}).merge!.must_equal expected
    end

    it 'will merge a hash that has two levels of nesting' do
      expected = "age=22&person[given_name][first_name]=john&person[given_name][last_name]=smith"
      DeepMerge.new({'age' => 22, 'person' => {'given_name' => {'first_name' => 'john', 'last_name' => 'smith'}}}).merge!.must_equal expected
    end

    it 'will merge a deeply nested hash' do
      actual    = {'id' => 22,
        'person' => {
          'age' => 22, 'given_name' => {'first_name' => 'john', 'last_name' => 'smith'}
        },
        'license' => false,
        'birth'   => { 'country' => 'USA', 'state' => 'California', 'address' => {
          "street" => '123', 'street2' => '456', 'city' => 'san diego', 'further-nesting' => { 'name' => 'smith' }
          }
        }
      }
      expected  = "id=22&person[age]=22&person[given_name][first_name]=john&person[given_name][last_name]=smith&license=false&birth[country]=USA&birth[state]=California&birth[address][street]=123&birth[address][street2]=456&birth[address][city]=san diego&birth[address][further-nesting][name]=smith"

      DeepMerge.new(actual).merge!.must_equal expected
    end

    it 'will merge a hash with an array inside the hash' do
      actual = { 'id' => 22, 'person' => { 'family' => [ { 'father' => 'John Smith Sr.', 'alive' => true }, { 'mother' => 'Marie Smith', 'alive' => false }, { 'siblings' => 2, 'alive' => true }], 'given_name' => 'John Smith', 'last_name' => 'Smith', 'first_name' => 'John' } }
      expected = 'id=22&person[family][][father]=John Smith Sr.&person[family][][alive]=true&person[family][][mother]=Marie Smith&person[family][][alive]=false&person[family][][siblings]=2&person[family][][alive]=true&person[given_name]=John Smith&person[last_name]=Smith&person[first_name]=John'

      DeepMerge.new(actual).merge!.must_equal expected
    end

    it 'will merge a hash that has an array at the top level' do
      actual = { 'company' => 'x', 'people' => [ {'name' => 'John Smith', 'age' => 22}, {'name' => 'Marie Smith', 'age' => 24}, {'name' => 'Bob Smith', 'age' => 27} ], 'family' => true }
      expected = 'company=x&people[][name]=John Smith&people[][age]=22&people[][name]=Marie Smith&people[][age]=24&people[][name]=Bob Smith&people[][age]=27&family=true'
      DeepMerge.new(actual).merge!.must_equal expected
    end

    it 'will merge a hash that includes multiple arrays nested' do
      actual = { 'tree' => [ { 'family' => {'sir_name' => 'smith', 'root' => 'Joseph Smith', 'children' => [ { 'last_name' => 'Wayne', 'number_of_children' => 7} ] } } ] }
      expected = "tree[][family][sir_name]=smith&tree[][family][root]=Joseph Smith&tree[][family][children][][last_name]=Wayne&tree[][family][children][][number_of_children]=7"

      DeepMerge.new(actual).merge!.must_equal expected
    end

    it 'will merge a hash that includes nested array of arrays' do
      actual = {'tree' => [[ { 'leaves' => 'brown', 'type' => 'pine', 'attributes' => { 'height' => '26 feet', 'age' => '32 years' }}], {'count' => 229} ]}
      expected = "tree[][][leaves]=brown&tree[][][type]=pine&tree[][][attributes][height]=26 feet&tree[][][attributes][age]=32 years&tree[][count]=229"

      DeepMerge.new(actual).merge!.must_equal expected
    end

  end
end
