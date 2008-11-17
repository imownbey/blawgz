require 'rubygems'
require 'fileutils'
require 'yaml'
require 'erb'
require 'redcloth'

class Blawgz
  include FileUtils
  
  attr_accessor :posts

  def initialize(path)
    @posts = get_posts
    clear_output
  end
  
  def clear_output
    rm_r('output')
    mkdir('output')
    mkdir('output/posts')
  end
  
  def build_index
    File.new('output/index.html', 'w').puts(in_template do
      @content = ''
      @posts.each do |post|
        @post = post
        @content << ERB.new(IO.read('post.erb.html')).result(binding)
      end
    end)
  end
  
  def build_posts
    @posts.each do |post|
      @post = post
      File.new("output/#{post[:url]}", 'w').puts(in_template do
        @content = ERB.new(IO.read('post.erb.html')).result(binding)
      end)
    end
  end
  
  def get_posts
    index = YAML.load_file('index.yaml')
    index.inject([]) do |memo, post|
      key = post.keys.first
      memo << {
        :url => "posts/#{key}.html", 
        :title => post[key]["title"], 
        :date => Date.parse(post[key]["date"]),
        :body => RedCloth.new(post[key]["body"]).to_html
      }
    end
  end
  
  def in_template
    erb = ERB.new(IO.read('template.erb.html'))
    yield
    erb.result(binding)
  end
end

b = Blawgz.new('.')
b.build_index
b.build_posts