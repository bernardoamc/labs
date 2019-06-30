# This Ragel file is the source for query_parser.rb
# To recompile it, install Ragel (available via most package managers),
# and run `ragel -R query_parser.rl`

module Pagination
  class QueryParser

    class ParseError < ::StandardError; end

    def self.unescape_text(token)
      token.gsub(/\\(.)/, '\1')
    end

    SPECIAL_CHARS = " \t\r\n+-():\"'\\<>="
    ESCAPE_PATTERN = /([#{Regexp.escape(SPECIAL_CHARS)}])/o

    def self.escape_text(text)
      text.to_s.gsub(ESCAPE_PATTERN, '\\\\\1')
    end

    def self.merge_match_queries(args)
      match_queries, others = args.partition { |clause| clause[0] == :match_all && clause[1] == :default }
      return args if match_queries.size <= 1
      others << [:match_all, :default, match_queries.map { |q| q[2] }.join(' ')]
    end

    def self.merge_bool_queries(args, connective)
      bool_queries, others = args.partition { |clause| clause[0] == connective }
      return args if bool_queries.empty?
      bool_queries.reduce(others) { |others, current| others += current[1] }
    end

    def self.merge_ranges(args)
      args = args.dup
      args.select { |q| q[0] == :range }.group_by { |q| q[1] }.each do |field, queries|
        next if queries.size <= 1

        merged_query = [:range, field, true, nil, true, nil]
        if lower_bound = queries.select { |q| q[3] }.max_by{ |q| [q[3], q[2] ? 0 : 1] }
          merged_query[2..3] = lower_bound[2..3]
        end
        if upper_bound = queries.select { |q| q[5] }.min_by{ |q| [q[5], q[4] ? 0 : 1] }
          merged_query[4..5] = upper_bound[4..5]
        end

        args.delete_if { |q| q[0..1] == [:range, field] }
        args << merged_query
      end
      args
    end

    def self.simplify(tree)
      operation = tree[0]

      case operation
      when :and, :or
        tree = tree[1].map { |subtree| simplify(subtree) }
        tree = merge_bool_queries(tree, operation)
        if operation == :and
          tree = merge_ranges(tree)
          tree = merge_match_queries(tree)
        end
        return tree.size == 1 ? tree[0] : [operation, tree]
      when :not
        subtree = tree[1]
        case subtree[0]
        when :exists
          return [:exists, subtree[1], !subtree[2]]
        when :range
          _, field, include_lower, lower, include_upper, upper = subtree
          unless upper && lower
            return [:range, field, true, nil, !include_lower, lower] if lower
            return [:range, field, !include_upper, upper, true, nil] if upper
          end
        end
      end
      tree.dup
    end

    %%{

      machine parser;

      action start {
        tokstart = p
      }

      action connective {
        current_query.connective = data[ts...te].downcase.to_sym
      }

      action not_modifier {
        current_query.modifier = :not
      }

      action field {
        field = unescape_text(data[tokstart...p])
      }

      action field_query {
        current_query.comparison = op
        current_query.add_value(field, data[tokstart...te])
      }

      action bare_value {
        current_query.add_value(:default, data[tokstart...te])
      }

      action start_subquery {
        current_query = QueryState.new(current_query)
      }

      action end_subquery {
        if parent = current_query.parent
          parent.add_clause(current_query.bool_query)
          current_query = parent
        end
      }

      whitespace = [ \t\r\n];
      escape_char = "\\" any;

      term_start_char = ( ^( whitespace | ":" | "\"" | "'" | "\\" | "-" | "(" | ")" ) | escape_char);
      term_char = (term_start_char | "-" | "\"" | "'");
      term_value = ([^(): \t\r\n]+);
      dquoted_char = (^("\"" | "\\") | escape_char);
      squoted_char = (^("'" | "\\") | escape_char);
      connective = ("AND" | "OR");
      comparison = ('<'  %{ op = '<' } |
                    '>'  %{ op = '>' } |
                    '<=' %{ op = '<='} |
                    '>=' %{ op = '>='} );

      modifier = ("-" | "NOT" whitespace+) % not_modifier;
      quote = ("\"" dquoted_char* "\"" | "'" squoted_char* "'");
      term = term_start_char term_char*;

      # This is tricky, it is basically hooking the "start" action to occur when we first match a "term"
      # and a "field" action to occur at the end of the matching phase of the "term".
      field = term > start % field;
      field_value = ("-"? term | quote | term_value) > start;
      bare_value = (term | quote) > start;

      main := |*
        whitespace;

        connective => connective;

        modifier? "(" => start_subquery;
        ")" => end_subquery;

        modifier? field ":" comparison? >{ op = nil } field_value => field_query;
        modifier? bare_value => bare_value;

        # ignore special characters with no match for their intended use
        # e.g. unterminated quotes, backslash at end of query, etc.
        ['":\-\\];
      *|;

    }%%

    class QueryState
      attr_accessor :parent, :bool_query, :connective, :modifier, :comparison

      def initialize(parent=nil)
        @parent = parent
        @bool_query = [:and, []]
        @modifier = nil
        @comparison = nil
      end

      def add_clause(query)
        query = [:not, query] if @modifier == :not

        last_clause = @bool_query[1].last

        if !last_clause || @connective != :or
          bool_query[1] << query
        elsif last_clause[0] == :or
          last_clause[1] << query
        else
          bool_query[1] << [:or, [@bool_query[1].pop, query]]
        end

        @modifier = nil
        @connective = nil
      end

      def parse_value_token(token)
        if /\A-?(0|[1-9][0-9]*)\z/ =~ token
          token.to_i
        elsif /\A-?(0|[1-9][0-9]*)\.[0-9]+\z/ =~ token
          token.to_f
        elsif date = parse_date(token)
          date
        else
          token = token[1...-1] if ['"', "'"].include?(token[0])
          ::Pagination::QueryParser.unescape_text(token)
        end
      end

      def parse_date(str)
        return unless /\A([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})\z/ =~ str && (1..12).cover?($2.to_i) && (1..31).cover?($3.to_i)
        Date.parse(str)
      rescue ArgumentError
      end

      def add_value(field, token)
        value = parse_value_token(token)
        query ||= if comparison
          lower = comparison[0] == '>' ? value : nil
          upper = comparison[0] == '<' ? value : nil
          include_lower = !lower || comparison[1] == '='
          include_upper = !upper || comparison[1] == '='
          [:range, field, include_lower, lower, include_upper, upper]
        elsif token == '*'
          [:exists, field, true]
        elsif token[-1] == "*"
          [:match_prefix, field, value[0...-1]]
        elsif ['"', "'"].include?(token[0])
          [:match_phrase, field, value]
        else
          [:match_all, field, value.to_s]
        end
        add_clause(query)
      end
    end

    %% write data;

    def self.parse(query_string)
      data = query_string
      eof = pe = data.length
      p = 0

      tokstart = 0
      current_query = QueryState.new

      %% write init;
      %% write exec;

      raise(ParseError, "Invalid input") if cs == parser_error

      while parent = current_query.parent
        parent.add_clause(current_query.bool_query)
        current_query = parent
      end
      simplify(current_query.bool_query)
    end
  end
end
