require 'spec_helper'

describe GraphQL::StaticValidation::ArgumentLiteralsAreCompatible do
  let(:document) { GraphQL.parse(%|
    query getCheese {
      cheese(id: "aasdlkfj") { source }
      cheese(id: 1) { source @skip(if: {id: 1})}
      yakSource: searchDairy(product: [{source: YAK, fatContent: 1.1}]) { source }
      badSource: searchDairy(product: [{source: 1.1}]) { source }
    }

    fragment cheeseFields on Cheese {
      similarCheese(source: 4.5)
    }
  |)}

  let(:validator) { GraphQL::StaticValidation::Validator.new(schema: DummySchema, rules: [GraphQL::StaticValidation::ArgumentLiteralsAreCompatible]) }
  let(:errors) { validator.validate(document) }

  it 'finds undefined arguments to fields and directives' do
    assert_equal(4, errors.length)

    query_root_error = {
      "message"=>"Argument id on Field 'cheese' has an invalid value",
      "locations"=>[{"line"=>3, "column"=>7}]
    }
    assert_includes(errors, query_root_error)

    directive_error = {
      "message"=>"Argument if on Directive 'skip' has an invalid value",
      "locations"=>[{"line"=>4, "column"=>31}]
    }
    assert_includes(errors, directive_error)

    input_object_error = {
      "message"=>"Argument product on Field 'searchDairy' has an invalid value",
      "locations"=>[{"line"=>6, "column"=>7}]
    }
    assert_includes(errors, input_object_error)

    fragment_error = {
      "message"=>"Argument source on Field 'similarCheese' has an invalid value",
      "locations"=>[{"line"=>10, "column"=>7}]
    }
    assert_includes(errors, fragment_error)
  end
end
