require 'pathname'

module FoodCritic

  # The DSL methods exposed for defining rules.
  class RuleDsl
    attr_reader :rules
    include Helpers
    include Chef::Mixin::ConvertToClassName

    # Define a new rule
    #
    # @param [String] code The short unique identifier for this rule, e.g. 'FC001'
    # @param [String] name The short descriptive name of this rule presented to the end user.
    # @param [Block] block The rule definition
    def rule(code, name, &block)
      @rules = [] if @rules.nil?
      @rules << Rule.new(code, name)
      yield self
    end

    # Add tags to the rule which can be used to filter the rules to be applied.
    #
    # @param [Array] tags The tags associated with this rule.
    def tags(tags)
      rules.last.tags += tags
    end

    # Set the rule description
    #
    # @param [String] description Set the rule description.
    def description(description)
      rules.last.description = description
    end

    # Define a matcher that will be passed the AST with this method.
    #
    # @param [block] block Your implemented matcher that returns a match Hash.
    def recipe(&block)
      rules.last.recipe = block
    end

    # Load the ruleset
    #
    # @param [String] filename The path to the ruleset to load
    # @return [Array] The loaded rules, ready to be matched against provided cookbooks.
    def self.load(filename)
      dsl = RuleDsl.new
      dsl.instance_eval(File.read(filename), filename)
      dsl.rules
    end
  end

end