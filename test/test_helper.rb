# encoding: UTF-8
require 'minitest/autorun'
require 'minitest/pride'
require 'rack/test'
require 'rack/mock'
require 'digest/sha2'
require 'securerandom'
require 'pathname'
require 'json'
require_relative '../lib/rack/signature/test_helpers'

module TestHelper
  def read_json(filename)
    datapath.join("#{filename}.json").read
  end

  def datapath
    Pathname.new('.').dirname.expand_path.join('test')
  end

  def sorted_nested_string
    "company=Datsun&maintenance=false&record[address][street]=123 Here&record[person][age]=22&record[person][area]=everywhere&record[person][name]=John&record[person][occupation][length_of_employment]=12 years&record[person][occupation][name]=Janitor&record[relatives][][parent_siblings]=aunts, uncles&record[relatives][][parent_siblings_children]=cousins&record[relatives][][siblings]=brothers, sisters"
  end

  def sorted_nested_hash
      {
        "company" => "Datsun",
        "maintenance" => false,
        "record"  => {
          "address"   => { "street" => "123 Here" },
          "person"    => {
                          "age"         => 22,
                          "area"        => "everywhere",
                          "name"        => "John",
                          "occupation"  => {
                                            "length_of_employment"  => "12 years",
                                            "name"                  => "Janitor",
                          }
          },

          "relatives" => [
                          { "parent_siblings"           => "aunts, uncles" },
                          { "parent_siblings_children"  => "cousins" },
                          { "siblings"                  => "brothers, sisters" }
          ]
        },
      }
  end

  def nested_hash
      { "record" => {
          "person"    => {"name"        => "John",
                          "age"         => 22,
                          "occupation"  => {"name"                  => "Janitor",
                                            "length_of_employment"  => "12 years"},
                          "area"        => "everywhere" },
          "relatives" => [{ "siblings"                  => "brothers, sisters" },
                          { "parent_siblings"           => "aunts, uncles" },
                          { "parent_siblings_children"  => "cousins" }],
          "address"   => { "street" => "123 Here" }
        },
        "company" => "Datsun",
        "maintenance" => false
      }
  end
end
