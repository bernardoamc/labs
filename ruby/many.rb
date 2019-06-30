class Many
  class << self
    def from_value(values)
      new(Array(values))
    end
  end

  attr_reader :values

  def initialize(values)
    @values = values
  end

  def and_then(&block)
    self.class.from_value(
      values.map(&block).flat_map(&:values)
    )
  end

  def method_missing(method,*args, &block)
    and_then do |value|
      self.class.from_value(
        value.public_send(method, *args, &block)
      )
    end
  end
end

Blog     = Struct.new(:categories)
Category = Struct.new(:posts)
Post     = Struct.new(:comments)

def words_in(blogs)
  blogs.flat_map { |blog|
    blog.categories.flat_map { |category|
      category.posts.flat_map { |post|
        post.comments.flat_map { |comment|
          comment.split(/\s+/)
        }
      }
    }
  }
end

def words_in_v1(blogs)
  Many.from_value(blogs)
    .and_then { |blog| Many.from_value(blog.categories) }
    .and_then { |category| Many.from_value(category.posts) }
    .and_then { |post| Many.from_value(post.comments) }
    .and_then { |comment| Many.from_value(comment.split(/\s+/)) }
    .values
end

def words_in_v2(blogs)
  Many.from_value(blogs)
    .categories
    .posts
    .comments
    .split(/\s+/)
    .values
end

blogs = [
  Blog.new([
    Category.new([
      Post.new(['I love cats', 'I love dogs']),
      Post.new(['I love mice', 'I love pigs'])
    ]),
    Category.new([
      Post.new(['I hate cats', 'I hate dogs']),
      Post.new(['I hate mice', 'I hate pigs'])
    ])
  ]),
  Blog.new([
    Category.new([
      Post.new(['Red is better than blue'])
    ]),
    Category.new([
      Post.new(['Blue is better than red'])
    ])
  ])
]

p words_in(blogs)
p words_in_v1(blogs)
p words_in_v2(blogs)
